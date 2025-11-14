package main

import (
	"context"
	"regexp"
	"strings"
	"sync"
	"time"

	"github.com/mmcdole/gofeed"
	"golang.org/x/sync/errgroup"

	pb "github.com/sunderee/rss-it/proto"
	goproto "google.golang.org/protobuf/proto"
)

const (
	defaultParserConcurrency = 8
)

// RSSParser coordinates concurrent feed downloads while converting them to protobuf responses.
type RSSParser struct {
	newParser     func() *gofeed.Parser
	maxConcurrent int
}

// NewRSSParser constructs an RSSParser with the provided parser factory and concurrency limit.
func NewRSSParser(newParser func() *gofeed.Parser, maxConcurrent int) *RSSParser {
	if newParser == nil {
		newParser = gofeed.NewParser
	}
	if maxConcurrent <= 0 {
		maxConcurrent = defaultParserConcurrency
	}
	return &RSSParser{
		newParser:     newParser,
		maxConcurrent: maxConcurrent,
	}
}

// ParseFeeds fetches and normalises all feeds in the request, aggregating successes and error details.
func (p *RSSParser) ParseFeeds(ctx context.Context, request *pb.ParseFeedsRequest) *pb.ParseFeedsResponse {
	if ctx == nil {
		ctx = context.Background()
	}

	response := &pb.ParseFeedsResponse{
		Status: pb.ParseFeedsStatus_ERROR,
		Feeds:  make([]*pb.Feed, 0, len(request.GetUrls())),
		Errors: make([]*pb.ErrorDetail, 0),
	}

	urls := request.GetUrls()
	if len(urls) == 0 {
		response.Errors = append(response.Errors, newErrorDetail(pb.ErrorKind_ERROR_KIND_VALIDATION, "no feed URLs supplied", ""))
		return response
	}

	var (
		mu     sync.Mutex
		feeds  = make([]*pb.Feed, 0, len(urls))
		errors = make([]*pb.ErrorDetail, 0)
	)

	group, groupCtx := errgroup.WithContext(ctx)
	group.SetLimit(p.maxConcurrent)

	for _, candidate := range urls {
		rawURL := strings.TrimSpace(candidate)
		if rawURL == "" {
			mu.Lock()
			errors = append(errors, newErrorDetail(pb.ErrorKind_ERROR_KIND_VALIDATION, "feed URL is empty", candidate))
			mu.Unlock()
			continue
		}

		feedURL := rawURL
		group.Go(func() error {
			parser := p.newParser()

			feed, err := parser.ParseURLWithContext(feedURL, groupCtx)
			mu.Lock()
			defer mu.Unlock()

			if err != nil {
				errors = append(errors, newErrorDetail(classifyParseError(err), err.Error(), feedURL))
				return nil
			}

			feeds = append(feeds, toProtoFeed(feedURL, feed))
			return nil
		})
	}

	if err := group.Wait(); err != nil {
		mu.Lock()
		errors = append(errors, newErrorDetail(pb.ErrorKind_ERROR_KIND_INTERNAL, err.Error(), ""))
		mu.Unlock()
	}

	response.Feeds = feeds
	response.Errors = errors

	switch {
	case len(feeds) == 0:
		response.Status = pb.ParseFeedsStatus_ERROR
	case len(errors) == 0:
		response.Status = pb.ParseFeedsStatus_SUCCESS
	default:
		response.Status = pb.ParseFeedsStatus_PARTIAL
	}

	return response
}

// toProtoFeed converts a gofeed.Feed into the protobuf representation, sanitising content fields.
func toProtoFeed(feedURL string, feed *gofeed.Feed) *pb.Feed {
	if feed == nil {
		return &pb.Feed{
			Url:   feedURL,
			Title: "",
		}
	}

	cleanDescription := cleanString(feed.Description)
	var descriptionPtr *string
	if cleanDescription != "" {
		descriptionPtr = goproto.String(cleanDescription)
	}

	var imagePtr *string
	if feed.Image != nil && feed.Image.URL != "" {
		imagePtr = goproto.String(feed.Image.URL)
	}

	items := make([]*pb.FeedItem, 0, len(feed.Items))
	for _, item := range feed.Items {
		items = append(items, toProtoFeedItem(item))
	}

	return &pb.Feed{
		Url:         feedURL,
		Title:       cleanString(feed.Title),
		Description: descriptionPtr,
		Image:       imagePtr,
		Items:       items,
	}
}

// toProtoFeedItem translates a gofeed.Item into protobuf form, normalising optional fields.
func toProtoFeedItem(item *gofeed.Item) *pb.FeedItem {
	if item == nil {
		return &pb.FeedItem{}
	}

	cleanDesc := cleanString(item.Description)
	var descriptionPtr *string
	if cleanDesc != "" {
		descriptionPtr = goproto.String(cleanDesc)
	}

	var linkPtr *string
	if item.Link != "" {
		linkPtr = goproto.String(item.Link)
	}

	var imagePtr *string
	if item.Image != nil && item.Image.URL != "" {
		imagePtr = goproto.String(item.Image.URL)
	}

	var publishedPtr *string
	if item.PublishedParsed != nil {
		formatted := item.PublishedParsed.Format(time.RFC3339)
		publishedPtr = goproto.String(formatted)
	}

	return &pb.FeedItem{
		Title:       cleanString(item.Title),
		Description: descriptionPtr,
		Link:        linkPtr,
		Image:       imagePtr,
		Published:   publishedPtr,
	}
}

// cleanString removes HTML tags, decodes common entities and fixes whitespace artefacts.
func cleanString(input string) string {
	htmlTagRegex := regexp.MustCompile(`<[^>]*>`)
	result := htmlTagRegex.ReplaceAllString(input, "")

	// Decode common HTML entities
	entityReplacements := map[string]string{
		"&amp;":  "&",
		"&lt;":   "<",
		"&gt;":   ">",
		"&quot;": "\"",
		"&apos;": "'",
		"&nbsp;": " ",
		"&#39;":  "'",
		"&#34;":  "\"",
	}

	for entity, replacement := range entityReplacements {
		result = strings.ReplaceAll(result, entity, replacement)
	}

	// Clean up whitespace issues
	return cleanWhitespace(result)
}

// cleanWhitespace collapses excessive whitespace and normalises punctuation spacing.
func cleanWhitespace(input string) string {
	// Replace multiple whitespace characters with single space
	multiSpaceRegex := regexp.MustCompile(`\s+`)
	input = multiSpaceRegex.ReplaceAllString(input, " ")

	// Remove spaces before punctuation
	spaceBeforePunctRegex := regexp.MustCompile(`\s+([,.!?;:])`)
	input = spaceBeforePunctRegex.ReplaceAllString(input, "$1")

	// Ensure single space after punctuation (but not multiple)
	spaceAfterPunctRegex := regexp.MustCompile(`([,.!?;:])\s*`)
	input = spaceAfterPunctRegex.ReplaceAllString(input, "$1 ")

	// Remove space before closing brackets/parentheses
	spaceBeforeClosingRegex := regexp.MustCompile(`\s+([)\]}])`)
	input = spaceBeforeClosingRegex.ReplaceAllString(input, "$1")

	// Remove space after opening brackets/parentheses
	spaceAfterOpeningRegex := regexp.MustCompile(`([(\[{])\s+`)
	input = spaceAfterOpeningRegex.ReplaceAllString(input, "$1")

	// Trim leading and trailing whitespace
	input = strings.TrimSpace(input)
	return input
}
