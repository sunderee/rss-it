package main

import (
	"sync"

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

			var description *string = nil
			if feed.Description != "" {
				description = &feed.Description
			}

			var image *string = nil
			if feed.Image != nil {
				image = &feed.Image.URL
			}

			var items []*proto.FeedItem = make([]*proto.FeedItem, 0, len(feed.Items))
			for _, item := range feed.Items {
				var description *string = nil
				if item.Description != "" {
					description = &item.Description
				}

				var link *string = nil
				if item.Link != "" {
					link = &item.Link
				}

				var image *string = nil
				if item.Image != nil {
					image = &item.Image.URL
				}

				items = append(items, &proto.FeedItem{
					Title:       item.Title,
					Description: description,
					Link:        link,
					Image:       image,
				})
			}

			resultFeeds = append(resultFeeds, &proto.Feed{
				Url:         feedURL,
				Title:       feed.Title,
				Description: description,
				Image:       image,
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
