package main

import (
	"context"
	"strings"
	"time"

	"github.com/mmcdole/gofeed"

	pb "github.com/sunderee/rss-it/proto"
)

const (
	defaultValidationTimeout = 10 * time.Second
)

// RSSValidator performs feed validation with bounded execution time.
type RSSValidator struct {
	newParser func() *gofeed.Parser
	timeout   time.Duration
}

// NewRSSValidator constructs an RSSValidator using the supplied parser factory and timeout.
func NewRSSValidator(newParser func() *gofeed.Parser, timeout time.Duration) *RSSValidator {
	if newParser == nil {
		newParser = gofeed.NewParser
	}
	if timeout <= 0 {
		timeout = defaultValidationTimeout
	}
	return &RSSValidator{
		newParser: newParser,
		timeout:   timeout,
	}
}

// ValidateFeedURL checks that a feed can be fetched and parsed within the configured timeout.
func (v *RSSValidator) ValidateFeedURL(ctx context.Context, request *pb.ValidateFeedRequest) *pb.ValidateFeedResponse {
	if ctx == nil {
		ctx = context.Background()
	}

	response := &pb.ValidateFeedResponse{Valid: false}

	if request == nil {
		response.Error = newErrorDetail(pb.ErrorKind_ERROR_KIND_VALIDATION, "validate request is empty", "")
		return response
	}

	feedURL := strings.TrimSpace(request.GetUrl())
	if feedURL == "" {
		response.Error = newErrorDetail(pb.ErrorKind_ERROR_KIND_VALIDATION, "feed URL is empty", "")
		return response
	}

	parser := v.newParser()

	parseCtx, cancel := context.WithTimeout(ctx, v.timeout)
	defer cancel()

	feed, err := parser.ParseURLWithContext(feedURL, parseCtx)
	if err != nil {
		response.Error = newErrorDetail(classifyParseError(err), err.Error(), feedURL)
		return response
	}

	if feed == nil {
		response.Error = newErrorDetail(pb.ErrorKind_ERROR_KIND_VALIDATION, "no feed data returned", feedURL)
		return response
	}

	response.Valid = true
	return response
}
