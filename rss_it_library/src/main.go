package main

/*
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stdint.h>
*/
import "C"
import (
	"unsafe"

	"github.com/mmcdole/gofeed"
	libproto "github.com/sunderee/rss-it/proto"
	proto "google.golang.org/protobuf/proto"
)

var parser *gofeed.Parser = gofeed.NewParser()

//export validate
func validate(data *C.char, length C.int) *C.char {
	bytes := C.GoBytes(unsafe.Pointer(data), length)

	var validateRequest *libproto.ValidateFeedRequest
	err := proto.Unmarshal(bytes, validateRequest)
	if err != nil {
		return C.CString(err.Error())
	}

	validator := RSSValidator{parser: parser}
	validationResult := validator.ValidateFeedURL(validateRequest)

	deserialized, err := proto.Marshal(&validationResult)
	if err != nil {
		return C.CString(err.Error())
	}

	return C.CString(string(deserialized))
}

//export parse
func parse(data *C.char, length C.int) *C.char {
	bytes := C.GoBytes(unsafe.Pointer(data), length)

	var parseRequest *libproto.ParseFeedsRequest
	err := proto.Unmarshal(bytes, parseRequest)
	if err != nil {
		return C.CString(err.Error())
	}

	parser := RSSParser{parser: parser}
	response := parser.ParseFeeds(parseRequest)

	deserialized, err := proto.Marshal(&response)
	if err != nil {
		return C.CString(err.Error())
	}

	return C.CString(string(deserialized))
}

func main() {}
