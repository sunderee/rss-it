package main

/*
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
*/
import "C"
import "github.com/mmcdole/gofeed"

var parser *gofeed.Parser = gofeed.NewParser()

//export validateFeedURL
func validateFeedURL(url *C.char) C.bool {
	validator := RSSValidator{parser: parser}

	goURL := C.GoString(url)
	validationResult := validator.ValidateFeedURL(goURL)

	return C.bool(validationResult)
}

func main() {}
