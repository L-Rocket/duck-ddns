package utils

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestValidateConfig(t *testing.T) {
	tests := []struct {
		name    string
		config  *Config
		wantErr bool
	}{
		{
			name:    "Valid Config",
			config:  &Config{Domains: []string{"d1"}, Token: "t", UpdateInterval: 60, IPSource: "s"},
			wantErr: false,
		},
		{
			name:    "Missing Token",
			config:  &Config{Domains: []string{"d1"}, Token: "", UpdateInterval: 60, IPSource: "s"},
			wantErr: true,
		},
		{
			name:    "Missing IPSource",
			config:  &Config{Domains: []string{"d1"}, Token: "t", UpdateInterval: 60, IPSource: ""},
			wantErr: true,
		},
		{
			name:    "Invalid Interval",
			config:  &Config{Domains: []string{"d1"}, Token: "t", UpdateInterval: 0, IPSource: "s"},
			wantErr: true,
		},
		{
			name:    "No Domains",
			config:  &Config{Domains: []string{}, Token: "t", UpdateInterval: 60, IPSource: "s"},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if err := ValidateConfig(tt.config); (err != nil) != tt.wantErr {
				t.Errorf("ValidateConfig() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestGet_IP(t *testing.T) {
	// Start a local test server
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Current IP Address: 123.45.67.89"))
	}))
	defer server.Close()

	config := &Config{
		IPSource: server.URL,
	}

	ip, err := Get_IP(config)
	if err != nil {
		t.Fatalf("Get_IP() failed: %v", err)
	}

	expectedIP := "123.45.67.89"
	if ip != expectedIP {
		t.Errorf("Get_IP() = %v, want %v", ip, expectedIP)
	}
}

func TestGet_IP_Invalid(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("No IP here"))
	}))
	defer server.Close()

	config := &Config{
		IPSource: server.URL,
	}

	_, err := Get_IP(config)
	if err == nil {
		t.Error("Get_IP() expected error, got nil")
	}
}
