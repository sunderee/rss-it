package main

/*
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stdint.h>
*/
import "C"
import (
	"encoding/binary"
	"unsafe"

	"github.com/mmcdole/gofeed"
	libproto "github.com/sunderee/rss-it/proto"
	proto "google.golang.org/protobuf/proto"
)

var parser *gofeed.Parser = gofeed.NewParser()

//export validate
func validate(data *C.char, length C.int) *C.char {
	bytes := C.GoBytes(unsafe.Pointer(data), length)

	validateRequest := &libproto.ValidateFeedRequest{}
	err := proto.Unmarshal(bytes, validateRequest)
	if err != nil {
		errorMsg := err.Error()
		errorBytes := []byte(errorMsg)

		// Prepend length (4 bytes) + error message
		result := make([]byte, 4+len(errorBytes))
		binary.LittleEndian.PutUint32(result[0:4], uint32(len(errorBytes)))
		copy(result[4:], errorBytes)

		resultPtr := C.malloc(C.size_t(len(result)))
		C.memcpy(resultPtr, unsafe.Pointer(&result[0]), C.size_t(len(result)))
		return (*C.char)(resultPtr)
	}

	validator := RSSValidator{parser: parser}
	validationResult := validator.ValidateFeedURL(validateRequest)

	deserialized, err := proto.Marshal(&validationResult)
	if err != nil {
		errorMsg := err.Error()
		errorBytes := []byte(errorMsg)

		// Prepend length (4 bytes) + error message
		result := make([]byte, 4+len(errorBytes))
		binary.LittleEndian.PutUint32(result[0:4], uint32(len(errorBytes)))
		copy(result[4:], errorBytes)

		resultPtr := C.malloc(C.size_t(len(result)))
		C.memcpy(resultPtr, unsafe.Pointer(&result[0]), C.size_t(len(result)))
		return (*C.char)(resultPtr)
	}

	// Prepend length (4 bytes) + protobuf data
	result := make([]byte, 4+len(deserialized))
	binary.LittleEndian.PutUint32(result[0:4], uint32(len(deserialized)))
	copy(result[4:], deserialized)

	resultPtr := C.malloc(C.size_t(len(result)))
	C.memcpy(resultPtr, unsafe.Pointer(&result[0]), C.size_t(len(result)))
	return (*C.char)(resultPtr)
}

//export parse
func parse(data *C.char, length C.int) *C.char {
	bytes := C.GoBytes(unsafe.Pointer(data), length)

	parseRequest := &libproto.ParseFeedsRequest{}
	err := proto.Unmarshal(bytes, parseRequest)
	if err != nil {
		errorMsg := err.Error()
		errorBytes := []byte(errorMsg)

		// Prepend length (4 bytes) + error message
		result := make([]byte, 4+len(errorBytes))
		binary.LittleEndian.PutUint32(result[0:4], uint32(len(errorBytes)))
		copy(result[4:], errorBytes)

		resultPtr := C.malloc(C.size_t(len(result)))
		C.memcpy(resultPtr, unsafe.Pointer(&result[0]), C.size_t(len(result)))
		return (*C.char)(resultPtr)
	}

	parser := RSSParser{parser: parser}
	response := parser.ParseFeeds(parseRequest)

	deserialized, err := proto.Marshal(&response)
	if err != nil {
		errorMsg := err.Error()
		errorBytes := []byte(errorMsg)

		// Prepend length (4 bytes) + error message
		result := make([]byte, 4+len(errorBytes))
		binary.LittleEndian.PutUint32(result[0:4], uint32(len(errorBytes)))
		copy(result[4:], errorBytes)

		resultPtr := C.malloc(C.size_t(len(result)))
		C.memcpy(resultPtr, unsafe.Pointer(&result[0]), C.size_t(len(result)))
		return (*C.char)(resultPtr)
	}

	// Prepend length (4 bytes) + protobuf data
	result := make([]byte, 4+len(deserialized))
	binary.LittleEndian.PutUint32(result[0:4], uint32(len(deserialized)))
	copy(result[4:], deserialized)

	resultPtr := C.malloc(C.size_t(len(result)))
	C.memcpy(resultPtr, unsafe.Pointer(&result[0]), C.size_t(len(result)))
	return (*C.char)(resultPtr)
}

func main() {}
