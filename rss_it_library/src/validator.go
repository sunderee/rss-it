package main

import (
	"github.com/mmcdole/gofeed"
	"github.com/sunderee/rss-it/proto"
)

type RSSValidator struct {
	parser *gofeed.Parser
}

func (v *RSSValidator) ValidateFeedURL(request *proto.ValidateFeedRequest) proto.ValidateFeedResponse {
	feedURL := request.Url
	feed, err := v.parser.ParseURL(feedURL)
	if err != nil {
		return proto.ValidateFeedResponse{
			Valid: false,
		}
	}

	return proto.ValidateFeedResponse{
		Valid: feed != nil,
	}
}
