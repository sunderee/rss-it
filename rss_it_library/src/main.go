package main

/*
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stdint.h>
*/
import "C"
import (
	"context"
	"encoding/binary"
	"fmt"
	"time"
	"unsafe"

	"github.com/mmcdole/gofeed"
	pb "github.com/sunderee/rss-it/proto"
	goproto "google.golang.org/protobuf/proto"
)

const (
	defaultParseTimeout = 30 * time.Second
)

var (
	parserFactory   = gofeed.NewParser
	sharedValidator = NewRSSValidator(parserFactory, defaultValidationTimeout)
	sharedParser    = NewRSSParser(parserFactory, defaultParserConcurrency)
)

//export validate
func validate(data *C.char, length C.int) *C.char {
	bytes := C.GoBytes(unsafe.Pointer(data), length)

	request := &pb.ValidateFeedRequest{}
	if err := goproto.Unmarshal(bytes, request); err != nil {
		response := &pb.ValidateFeedResponse{
			Valid: false,
			Error: newErrorDetail(pb.ErrorKind_ERROR_KIND_SERIALIZATION, fmt.Sprintf("decode validate request: %v", err), ""),
		}
		return marshalToC(response, func(mErr error) goproto.Message {
			return &pb.ValidateFeedResponse{
				Valid: false,
				Error: newErrorDetail(pb.ErrorKind_ERROR_KIND_INTERNAL, fmt.Sprintf("encode validate response: %v", mErr), ""),
			}
		})
	}

	ctx := context.Background()
	response := sharedValidator.ValidateFeedURL(ctx, request)

	return marshalToC(response, func(mErr error) goproto.Message {
		return &pb.ValidateFeedResponse{
			Valid: false,
			Error: newErrorDetail(pb.ErrorKind_ERROR_KIND_INTERNAL, fmt.Sprintf("encode validate response: %v", mErr), request.GetUrl()),
		}
	})
}

//export parse
func parse(data *C.char, length C.int) *C.char {
	bytes := C.GoBytes(unsafe.Pointer(data), length)

	request := &pb.ParseFeedsRequest{}
	if err := goproto.Unmarshal(bytes, request); err != nil {
		response := &pb.ParseFeedsResponse{
			Status:     pb.ParseFeedsStatus_ERROR,
			FatalError: newErrorDetail(pb.ErrorKind_ERROR_KIND_SERIALIZATION, fmt.Sprintf("decode parse request: %v", err), ""),
		}
		return marshalToC(response, func(mErr error) goproto.Message {
			return &pb.ParseFeedsResponse{
				Status:     pb.ParseFeedsStatus_ERROR,
				FatalError: newErrorDetail(pb.ErrorKind_ERROR_KIND_INTERNAL, fmt.Sprintf("encode parse response: %v", mErr), ""),
			}
		})
	}

	ctx, cancel := context.WithTimeout(context.Background(), defaultParseTimeout)
	defer cancel()

	response := sharedParser.ParseFeeds(ctx, request)

	return marshalToC(response, func(mErr error) goproto.Message {
		return &pb.ParseFeedsResponse{
			Status:     pb.ParseFeedsStatus_ERROR,
			FatalError: newErrorDetail(pb.ErrorKind_ERROR_KIND_INTERNAL, fmt.Sprintf("encode parse response: %v", mErr), ""),
		}
	})
}

//export free_result
func free_result(ptr *C.char) {
	if ptr == nil {
		return
	}
	C.free(unsafe.Pointer(ptr))
}

func main() {}

// marshalToC serialises a protobuf message and returns a length-prefixed buffer allocated for C consumers.
func marshalToC(message goproto.Message, fallback func(error) goproto.Message) *C.char {
	payload, err := goproto.Marshal(message)
	if err != nil {
		if fallback != nil {
			if fb := fallback(err); fb != nil {
				if fallbackPayload, fallbackErr := goproto.Marshal(fb); fallbackErr == nil {
					payload = fallbackPayload
				} else {
					payload = []byte{}
				}
			} else {
				payload = []byte{}
			}
		} else {
			payload = []byte{}
		}
	}

	return copyToC(lengthPrefix(payload))
}

// lengthPrefix prepends a 32-bit little-endian length header to payload.
func lengthPrefix(payload []byte) []byte {
	result := make([]byte, 4+len(payload))
	binary.LittleEndian.PutUint32(result[0:4], uint32(len(payload)))
	copy(result[4:], payload)
	return result
}

// copyToC allocates C memory and copies the provided Go slice.
func copyToC(data []byte) *C.char {
	if len(data) == 0 {
		return nil
	}

	ptr := C.malloc(C.size_t(len(data)))
	if ptr == nil {
		return nil
	}

	C.memcpy(ptr, unsafe.Pointer(&data[0]), C.size_t(len(data)))
	return (*C.char)(ptr)
}
