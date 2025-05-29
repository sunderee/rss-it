package main

import (
	"regexp"
	"strings"
	"sync"
	"time"

	"github.com/mmcdole/gofeed"
	"github.com/sunderee/rss-it/proto"
)

type RSSParser struct {
	parser *gofeed.Parser
}

func (p *RSSParser) ParseFeeds(request *proto.ParseFeedsRequest) proto.ParseFeedsResponse {
	var wg sync.WaitGroup
	var mu sync.Mutex

	resultFeeds := make([]*proto.Feed, 0)
	resultErrors := make([]string, 0)

	semaphore := make(chan struct{}, 10)

	for _, url := range request.Urls {
		wg.Add(1)
		semaphore <- struct{}{}

		go func(feedURL string) {
			defer wg.Done()
			defer func() { <-semaphore }()

			feed, err := p.parser.ParseURL(feedURL)

			mu.Lock()
			defer mu.Unlock()

			if err != nil {
				resultErrors = append(resultErrors, feedURL+": "+err.Error())
				return
			}

			var description string = ""
			if feed.Description != "" {
				description = feed.Description
				description = cleanString(description)
			}

			var image string = ""
			if feed.Image != nil {
				image = feed.Image.URL
			}

			var items []*proto.FeedItem = make([]*proto.FeedItem, 0, len(feed.Items))
			for _, item := range feed.Items {
				var description string = ""
				if item.Description != "" {
					description = item.Description
					description = cleanString(description)
				}

				var link *string = nil
				if item.Link != "" {
					link = &item.Link
				}

				var image *string = nil
				if item.Image != nil {
					image = &item.Image.URL
				}

				var published *string = nil
				if item.PublishedParsed != nil {
					publishedDate := item.PublishedParsed.Format(time.RFC3339)
					published = &publishedDate
				}

				items = append(items, &proto.FeedItem{
					Title:       cleanString(item.Title),
					Description: &description,
					Link:        link,
					Image:       image,
					Published:   published,
				})
			}

			resultFeeds = append(resultFeeds, &proto.Feed{
				Url:         feedURL,
				Title:       cleanString(feed.Title),
				Description: &description,
				Image:       &image,
				Items:       items,
			})
		}(url)
	}

	wg.Wait()

	var status proto.ParseFeedsStatus
	switch {
	case len(resultFeeds) == 0:
		status = proto.ParseFeedsStatus_ERROR
	case len(resultFeeds) == len(request.Urls):
		status = proto.ParseFeedsStatus_SUCCESS
	default:
		status = proto.ParseFeedsStatus_PARTIAL
	}

	return proto.ParseFeedsResponse{
		Status: status,
		Errors: resultErrors,
		Feeds:  resultFeeds,
	}
}

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
