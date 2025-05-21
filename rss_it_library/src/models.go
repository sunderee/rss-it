package main

import "github.com/mmcdole/gofeed"

type ParseFeedsRequest struct {
	URLs []string `json:"urls"`
}

type Status string

const (
	StatusSuccess Status = "success"
	StatusPartial Status = "partial"
	StatusError   Status = "error"
)

type Feed struct {
	URL  string       `json:"url"`
	Feed *gofeed.Feed `json:"feed"`
}

type ParseFeedsResponse struct {
	Status Status   `json:"status"`
	Errors []string `json:"errors"`
	Data   []Feed   `json:"data"`
}
