package main

import "github.com/mmcdole/gofeed"

type RSSValidator struct {
	parser *gofeed.Parser
}

func (v *RSSValidator) ValidateFeedURL(url string) bool {
	feed, err := v.parser.ParseURL(url)
	if err != nil {
		return false
	}

	return feed != nil
}
