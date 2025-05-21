package main

import (
	"sync"

	"github.com/mmcdole/gofeed"
)

type RSSParser struct {
	parser *gofeed.Parser
}

func (p *RSSParser) ParseFeeds(request ParseFeedsRequest) ParseFeedsResponse {
	var wg sync.WaitGroup
	var mu sync.Mutex

	resultFeeds := make([]Feed, 0)
	resultErrors := make([]string, 0)

	semaphore := make(chan struct{}, 10)

	for _, url := range request.URLs {
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

			resultFeeds = append(resultFeeds, Feed{
				URL:  feedURL,
				Feed: feed,
			})
		}(url)
	}

	wg.Wait()

	var status Status
	switch {
	case len(resultFeeds) == 0:
		status = StatusError
	case len(resultFeeds) == len(request.URLs):
		status = StatusSuccess
	default:
		status = StatusPartial
	}

	return ParseFeedsResponse{
		Status: status,
		Errors: resultErrors,
		Data:   resultFeeds,
	}
}
