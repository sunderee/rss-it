package main

import (
	"context"
	"errors"
	neturl "net/url"
	"testing"

	pb "github.com/sunderee/rss-it/proto"
)

func TestNewErrorDetailTrimsWhitespace(t *testing.T) {
	detail := newErrorDetail(pb.ErrorKind_ERROR_KIND_PARSING, "  boom  ", "  example  ")

	if detail.Message != "boom" {
		t.Fatalf("expected message to be trimmed, got %q", detail.Message)
	}
	if detail.Url != "example" {
		t.Fatalf("expected url to be trimmed, got %q", detail.Url)
	}
}

func TestClassifyParseError(t *testing.T) {
	tests := []struct {
		name     string
		err      error
		expected pb.ErrorKind
	}{
		{
			name:     "deadline exceeded",
			err:      context.DeadlineExceeded,
			expected: pb.ErrorKind_ERROR_KIND_NETWORK,
		},
		{
			name: "url error timeout",
			err: &neturl.Error{
				Op:  "get",
				URL: "https://example.com",
				Err: context.DeadlineExceeded,
			},
			expected: pb.ErrorKind_ERROR_KIND_NETWORK,
		},
		{
			name: "net error temporary",
			err:  netErrorStub{temporary: true},
			expected: pb.ErrorKind_ERROR_KIND_NETWORK,
		},
		{
			name:     "default parsing",
			err:      errors.New("parse failure"),
			expected: pb.ErrorKind_ERROR_KIND_PARSING,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			if got := classifyParseError(tc.err); got != tc.expected {
				t.Fatalf("expected %v, got %v", tc.expected, got)
			}
		})
	}
}

type netErrorStub struct {
	temporary bool
}

func (n netErrorStub) Error() string   { return "stub" }
func (n netErrorStub) Timeout() bool   { return false }
func (n netErrorStub) Temporary() bool { return n.temporary }
