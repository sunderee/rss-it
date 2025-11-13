package main

import (
	"encoding/binary"
	"testing"

	libproto "github.com/sunderee/rss-it/proto"
	proto "google.golang.org/protobuf/proto"
)

// Test protobuf serialization/deserialization logic
// Note: CGO functions cannot be tested directly in Go tests, so we test the core protobuf logic

func TestProtobufSerialization_ValidateRequest(t *testing.T) {
	request := &libproto.ValidateFeedRequest{
		Url: "https://example.com/rss.xml",
	}

	data, err := proto.Marshal(request)
	if err != nil {
		t.Fatalf("Failed to marshal request: %v", err)
	}

	// Test round-trip serialization/deserialization
	unmarshalled := &libproto.ValidateFeedRequest{}
	err = proto.Unmarshal(data, unmarshalled)
	if err != nil {
		t.Fatalf("Failed to unmarshal request: %v", err)
	}

	if unmarshalled.Url != request.Url {
		t.Errorf("Expected URL %q, got %q", request.Url, unmarshalled.Url)
	}
}

func TestProtobufSerialization_ValidateResponse(t *testing.T) {
	response := &libproto.ValidateFeedResponse{
		Valid: true,
	}

	data, err := proto.Marshal(response)
	if err != nil {
		t.Fatalf("Failed to marshal response: %v", err)
	}

	// Test length prefix logic (simulating CGO buffer format)
	result := make([]byte, 4+len(data))
	binary.LittleEndian.PutUint32(result[0:4], uint32(len(data)))
	copy(result[4:], data)

	// Extract length
	lengthBytes := result[0:4]
	length := binary.LittleEndian.Uint32(lengthBytes)

	if length != uint32(len(data)) {
		t.Errorf("Expected length %d, got %d", len(data), length)
	}

	// Extract data
	extractedData := result[4 : 4+length]

	unmarshalled := &libproto.ValidateFeedResponse{}
	err = proto.Unmarshal(extractedData, unmarshalled)
	if err != nil {
		t.Fatalf("Failed to unmarshal response: %v", err)
	}

	if unmarshalled.Valid != response.Valid {
		t.Errorf("Expected Valid %v, got %v", response.Valid, unmarshalled.Valid)
	}
}

func TestProtobufSerialization_ParseRequest(t *testing.T) {
	request := &libproto.ParseFeedsRequest{
		Urls: []string{
			"https://example.com/rss1.xml",
			"https://example.com/rss2.xml",
		},
	}

	data, err := proto.Marshal(request)
	if err != nil {
		t.Fatalf("Failed to marshal request: %v", err)
	}

	unmarshalled := &libproto.ParseFeedsRequest{}
	err = proto.Unmarshal(data, unmarshalled)
	if err != nil {
		t.Fatalf("Failed to unmarshal request: %v", err)
	}

	if len(unmarshalled.Urls) != len(request.Urls) {
		t.Errorf("Expected %d URLs, got %d", len(request.Urls), len(unmarshalled.Urls))
	}

	for i, url := range request.Urls {
		if unmarshalled.Urls[i] != url {
			t.Errorf("Expected URL[%d] %q, got %q", i, url, unmarshalled.Urls[i])
		}
	}
}

func TestProtobufSerialization_ParseResponse(t *testing.T) {
	response := &libproto.ParseFeedsResponse{
		Status: libproto.ParseFeedsStatus_SUCCESS,
		Feeds: []*libproto.Feed{
			{
				Url:   "https://example.com/rss.xml",
				Title: "Test Feed",
			},
		},
		Errors: []*libproto.ErrorDetail{},
	}

	data, err := proto.Marshal(response)
	if err != nil {
		t.Fatalf("Failed to marshal response: %v", err)
	}

	// Test length prefix logic
	result := make([]byte, 4+len(data))
	binary.LittleEndian.PutUint32(result[0:4], uint32(len(data)))
	copy(result[4:], data)

	// Extract and verify
	length := binary.LittleEndian.Uint32(result[0:4])
	extractedData := result[4 : 4+length]

	unmarshalled := &libproto.ParseFeedsResponse{}
	err = proto.Unmarshal(extractedData, unmarshalled)
	if err != nil {
		t.Fatalf("Failed to unmarshal response: %v", err)
	}

	if unmarshalled.Status != response.Status {
		t.Errorf("Expected Status %v, got %v", response.Status, unmarshalled.Status)
	}

	if len(unmarshalled.Feeds) != len(response.Feeds) {
		t.Errorf("Expected %d feeds, got %d", len(response.Feeds), len(unmarshalled.Feeds))
	}
}

func TestProtobufSerialization_ErrorHandling(t *testing.T) {
	// Test with invalid protobuf data
	invalidData := []byte("not a valid protobuf")

	request := &libproto.ValidateFeedRequest{}
	err := proto.Unmarshal(invalidData, request)

	if err == nil {
		t.Error("Expected error when unmarshalling invalid data")
	}
}

func TestLengthPrefixEncoding(t *testing.T) {
	testData := []byte("test data")
	length := uint32(len(testData))

	// Encode
	encoded := make([]byte, 4+len(testData))
	binary.LittleEndian.PutUint32(encoded[0:4], length)
	copy(encoded[4:], testData)

	// Decode
	decodedLength := binary.LittleEndian.Uint32(encoded[0:4])
	decodedData := encoded[4 : 4+decodedLength]

	if decodedLength != length {
		t.Errorf("Expected length %d, got %d", length, decodedLength)
	}

	if string(decodedData) != string(testData) {
		t.Errorf("Expected data %q, got %q", string(testData), string(decodedData))
	}
}
