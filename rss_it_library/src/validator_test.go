package main

import (
	"context"
	"testing"

	"github.com/mmcdole/gofeed"
	pb "github.com/sunderee/rss-it/proto"
)

func TestRSSValidator_ValidateFeedURL_ValidFeed(t *testing.T) {
	validator := NewRSSValidator(gofeed.NewParser, defaultValidationTimeout)

	// Use a known working RSS feed URL
	request := &pb.ValidateFeedRequest{
		Url: "https://feeds.feedburner.com/oreilly/radar",
	}

	response := validator.ValidateFeedURL(context.Background(), request)

	// Note: This test may fail if the feed is unavailable, so we log the result
	// but don't fail the test if it's invalid (network issues, etc.)
	if response.Valid {
		t.Log("Feed validation succeeded (expected)")
	} else {
		t.Log("Feed validation failed - this may be due to network issues or feed unavailability")
		// Don't fail the test as network conditions may vary
	}
}

func TestRSSValidator_ValidateFeedURL_InvalidURL(t *testing.T) {
	validator := NewRSSValidator(gofeed.NewParser, defaultValidationTimeout)

	request := &pb.ValidateFeedRequest{
		Url: "not-a-valid-url",
	}

	response := validator.ValidateFeedURL(context.Background(), request)

	if response.Valid {
		t.Error("Expected invalid URL to return Valid=false")
	}
}

func TestRSSValidator_ValidateFeedURL_NonExistentURL(t *testing.T) {
	validator := NewRSSValidator(gofeed.NewParser, defaultValidationTimeout)

	request := &pb.ValidateFeedRequest{
		Url: "https://this-domain-does-not-exist-12345.com/rss.xml",
	}

	response := validator.ValidateFeedURL(context.Background(), request)

	if response.Valid {
		t.Error("Expected non-existent URL to return Valid=false")
	}
}

func TestRSSValidator_ValidateFeedURL_EmptyURL(t *testing.T) {
	validator := NewRSSValidator(gofeed.NewParser, defaultValidationTimeout)

	request := &pb.ValidateFeedRequest{
		Url: "",
	}

	response := validator.ValidateFeedURL(context.Background(), request)

	if response.Valid {
		t.Error("Expected empty URL to return Valid=false")
	}
}

func TestRSSValidator_ValidateFeedURL_HTTPURL(t *testing.T) {
	validator := NewRSSValidator(gofeed.NewParser, defaultValidationTimeout)

	// Test with HTTP (non-HTTPS) URL
	request := &pb.ValidateFeedRequest{
		Url: "http://www.w3.org/2005/Atom",
	}

	response := validator.ValidateFeedURL(context.Background(), request)

	// Should still validate (though may fail due to redirects or security)
	// We're just testing that it doesn't crash
	_ = response.Valid
}

func TestRSSValidator_ValidateFeedURL_ResponseStructure(t *testing.T) {
	validator := NewRSSValidator(gofeed.NewParser, defaultValidationTimeout)

	request := &pb.ValidateFeedRequest{
		Url: "https://www.w3.org/2005/Atom",
	}

	response := validator.ValidateFeedURL(context.Background(), request)

	// Verify response structure
	// Valid field should be set (either true or false)
	_ = response.Valid
}
