package main

/*
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
*/
import "C"
import (
	"encoding/json"

	"github.com/mmcdole/gofeed"
)

var parser *gofeed.Parser = gofeed.NewParser()

//export validate
func validate(url *C.char) C.bool {
	validator := RSSValidator{parser: parser}

	goURL := C.GoString(url)
	validationResult := validator.ValidateFeedURL(goURL)

	return C.bool(validationResult)
}

//export parse
func parse(urls *C.char) *C.char {
	parser := RSSParser{parser: parser}

	rawGoURLs := C.GoString(urls)
	var parseRequest ParseFeedsRequest
	err := json.Unmarshal([]byte(rawGoURLs), &parseRequest)
	if err != nil {
		return C.CString(err.Error())
	}

	response := parser.ParseFeeds(parseRequest)
	responseJSON, err := json.Marshal(response)
	if err != nil {
		return C.CString(err.Error())
	}

	return C.CString(string(responseJSON))
}

func main() {}
