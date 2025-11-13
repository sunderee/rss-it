package main

import (
	"context"
	"errors"
	"net"
	neturl "net/url"
	"strings"

	pb "github.com/sunderee/rss-it/proto"
)

// newErrorDetail creates a proto.ErrorDetail with trimmed message/url values.
func newErrorDetail(kind pb.ErrorKind, message, url string) *pb.ErrorDetail {
	return &pb.ErrorDetail{
		Kind:    kind,
		Message: strings.TrimSpace(message),
		Url:     strings.TrimSpace(url),
	}
}

// classifyParseError attempts to categorise an error produced while fetching a feed.
func classifyParseError(err error) pb.ErrorKind {
	if err == nil {
		return pb.ErrorKind_ERROR_KIND_UNKNOWN
	}

	if errors.Is(err, context.DeadlineExceeded) || errors.Is(err, context.Canceled) {
		return pb.ErrorKind_ERROR_KIND_NETWORK
	}

	var urlErr *neturl.Error
	if errors.As(err, &urlErr) {
		if errors.Is(urlErr.Err, context.Canceled) || errors.Is(urlErr.Err, context.DeadlineExceeded) {
			return pb.ErrorKind_ERROR_KIND_NETWORK
		}

		if netErr, ok := urlErr.Err.(net.Error); ok {
			if netErr.Timeout() || netErr.Temporary() {
				return pb.ErrorKind_ERROR_KIND_NETWORK
			}
			return pb.ErrorKind_ERROR_KIND_NETWORK
		}

		return pb.ErrorKind_ERROR_KIND_NETWORK
	}

	var netErr net.Error
	if errors.As(err, &netErr) {
		return pb.ErrorKind_ERROR_KIND_NETWORK
	}

	return pb.ErrorKind_ERROR_KIND_PARSING
}
