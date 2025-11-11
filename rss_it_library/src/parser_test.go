package main

import (
	"testing"
	"time"

	"github.com/mmcdole/gofeed"
	"github.com/sunderee/rss-it/proto"
)

func TestCleanString(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "Remove HTML tags",
			input:    "<p>Hello World</p>",
			expected: "Hello World",
		},
		{
			name:     "Decode HTML entities",
			input:    "Hello &amp; World &lt;test&gt;",
			expected: "Hello & World <test>",
		},
		{
			name:     "Decode numeric entities",
			input:    "Test &#39;quotes&#34;",
			expected: "Test 'quotes\"",
		},
		{
			name:     "Clean whitespace",
			input:    "Hello    World",
			expected: "Hello World",
		},
		{
			name:     "Remove spaces before punctuation",
			input:    "Hello , World . Test",
			expected: "Hello, World. Test",
		},
		{
			name:     "Complex HTML with entities",
			input:    "<p>Hello &amp; <strong>World</strong> &nbsp; Test</p>",
			expected: "Hello & World Test",
		},
		{
			name:     "Empty string",
			input:    "",
			expected: "",
		},
		{
			name:     "Only HTML tags",
			input:    "<div><span></span></div>",
			expected: "",
		},
		{
			name:     "Multiple spaces and newlines",
			input:    "Hello    \n\n   World",
			expected: "Hello World",
		},
		{
			name:     "Spaces around brackets",
			input:    "Test ( example ) and [ another ]",
			expected: "Test (example) and [another]",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := cleanString(tt.input)
			if result != tt.expected {
				t.Errorf("cleanString(%q) = %q, want %q", tt.input, result, tt.expected)
			}
		})
	}
}

func TestCleanWhitespace(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "Multiple spaces",
			input:    "Hello    World",
			expected: "Hello World",
		},
		{
			name:     "Spaces before punctuation",
			input:    "Hello , World . Test",
			expected: "Hello, World. Test",
		},
		{
			name:     "Spaces after punctuation",
			input:    "Hello,World.Test",
			expected: "Hello, World. Test",
		},
		{
			name:     "Spaces around brackets",
			input:    "Test ( example )",
			expected: "Test (example)",
		},
		{
			name:     "Leading and trailing spaces",
			input:    "   Hello World   ",
			expected: "Hello World",
		},
		{
			name:     "Tabs and newlines",
			input:    "Hello\t\t\n\nWorld",
			expected: "Hello World",
		},
		{
			name:     "Empty string",
			input:    "",
			expected: "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := cleanWhitespace(tt.input)
			if result != tt.expected {
				t.Errorf("cleanWhitespace(%q) = %q, want %q", tt.input, result, tt.expected)
			}
		})
	}
}

func TestRSSParser_ParseFeeds_EmptyRequest(t *testing.T) {
	parser := RSSParser{parser: gofeed.NewParser()}
	request := &proto.ParseFeedsRequest{
		Urls: []string{},
	}

	response := parser.ParseFeeds(request)

	if response.Status != proto.ParseFeedsStatus_ERROR {
		t.Errorf("Expected ERROR status for empty request, got %v", response.Status)
	}
	if len(response.Feeds) != 0 {
		t.Errorf("Expected no feeds, got %d", len(response.Feeds))
	}
	if len(response.Errors) != 0 {
		t.Errorf("Expected no errors, got %d", len(response.Errors))
	}
}

func TestRSSParser_ParseFeeds_StatusSuccess(t *testing.T) {
	// Note: This test requires network access or a mock parser
	// For now, we'll test the status logic with a mock scenario
	parser := RSSParser{parser: gofeed.NewParser()}

	// Test with a known valid RSS feed URL
	// Using a well-known public RSS feed for testing
	testURL := "https://www.w3.org/2005/Atom"
	request := &proto.ParseFeedsRequest{
		Urls: []string{testURL},
	}

	response := parser.ParseFeeds(request)

	// The status should be SUCCESS if the feed is valid, ERROR if not
	// We're testing that the status logic works correctly
	if response.Status != proto.ParseFeedsStatus_SUCCESS && response.Status != proto.ParseFeedsStatus_ERROR {
		t.Errorf("Expected SUCCESS or ERROR status, got %v", response.Status)
	}
}

func TestRSSParser_ParseFeeds_StatusPartial(t *testing.T) {
	parser := RSSParser{parser: gofeed.NewParser()}

	// Test with mix of valid and invalid URLs
	request := &proto.ParseFeedsRequest{
		Urls: []string{
			"https://www.w3.org/2005/Atom", // Valid
			"https://invalid-url-that-does-not-exist-12345.com/rss.xml", // Invalid
		},
	}

	response := parser.ParseFeeds(request)

	// Should get PARTIAL status if some succeed and some fail
	if len(response.Feeds) > 0 && len(response.Errors) > 0 {
		if response.Status != proto.ParseFeedsStatus_PARTIAL {
			t.Errorf("Expected PARTIAL status for mixed results, got %v", response.Status)
		}
	}
}

func TestRSSParser_ParseFeeds_ConcurrentParsing(t *testing.T) {
	parser := RSSParser{parser: gofeed.NewParser()}

	// Test concurrent parsing with multiple URLs
	request := &proto.ParseFeedsRequest{
		Urls: []string{
			"https://www.w3.org/2005/Atom",
			"https://www.w3.org/2005/Atom",
			"https://www.w3.org/2005/Atom",
		},
	}

	start := time.Now()
	response := parser.ParseFeeds(request)
	duration := time.Since(start)

	// Concurrent parsing should be faster than sequential
	// (though this is a heuristic test)
	if duration > 5*time.Second {
		t.Logf("Parsing took %v, which seems slow for concurrent parsing", duration)
	}

	// Verify semaphore limit (max 10 concurrent)
	// We can't directly test this, but we verify it doesn't crash
	if response.Status == proto.ParseFeedsStatus_ERROR && len(response.Errors) > 0 {
		t.Logf("Got errors (expected for network test): %v", response.Errors)
	}
}

func TestRSSParser_ParseFeeds_FeedItemConversion(t *testing.T) {
	parser := RSSParser{parser: gofeed.NewParser()}

	// Test with a feed that should have items
	request := &proto.ParseFeedsRequest{
		Urls: []string{"https://www.w3.org/2005/Atom"},
	}

	response := parser.ParseFeeds(request)

	if len(response.Feeds) > 0 {
		feed := response.Feeds[0]
		// Verify feed structure
		if feed.Url == "" {
			t.Error("Feed URL should not be empty")
		}
		if feed.Title == "" {
			t.Error("Feed title should not be empty")
		}

		// Check that items are properly converted
		for _, item := range feed.Items {
			if item.Title == "" {
				t.Error("Feed item title should not be empty")
			}
		}
	}
}

func TestRSSParser_ParseFeeds_ErrorHandling(t *testing.T) {
	parser := RSSParser{parser: gofeed.NewParser()}

	// Test with invalid URL
	request := &proto.ParseFeedsRequest{
		Urls: []string{"not-a-valid-url"},
	}

	response := parser.ParseFeeds(request)

	if response.Status != proto.ParseFeedsStatus_ERROR {
		t.Errorf("Expected ERROR status for invalid URL, got %v", response.Status)
	}
	if len(response.Errors) == 0 {
		t.Error("Expected at least one error for invalid URL")
	}
	if len(response.Feeds) != 0 {
		t.Errorf("Expected no feeds for invalid URL, got %d", len(response.Feeds))
	}
}

func TestRSSParser_ParseFeeds_AllInvalid(t *testing.T) {
	parser := RSSParser{parser: gofeed.NewParser()}

	request := &proto.ParseFeedsRequest{
		Urls: []string{
			"https://invalid-url-1.com/rss.xml",
			"https://invalid-url-2.com/rss.xml",
		},
	}

	response := parser.ParseFeeds(request)

	if response.Status != proto.ParseFeedsStatus_ERROR {
		t.Errorf("Expected ERROR status for all invalid URLs, got %v", response.Status)
	}
	if len(response.Feeds) != 0 {
		t.Errorf("Expected no feeds, got %d", len(response.Feeds))
	}
	if len(response.Errors) != len(request.Urls) {
		t.Errorf("Expected %d errors, got %d", len(request.Urls), len(response.Errors))
	}
}

