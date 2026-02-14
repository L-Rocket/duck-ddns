package utils

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"
)

type Config struct {
	Domains        []string `json:"domains"`
	Token          string   `json:"token"`
	UpdateInterval int      `json:"update_interval"`
	LogFile        string   `json:"log_file"`
	IPSource       string   `json:"ip_source"`
}

func Get_Config(path string) (config *Config, err error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	config = &Config{}
	err = json.NewDecoder(file).Decode(config)
	if err != nil {
		return nil, err
	}
	return config, nil
}

func ValidateConfig(config *Config) error {
	if config == nil {
		return errors.New("config is nil")
	}
	if strings.TrimSpace(config.Token) == "" {
		return errors.New("token is required")
	}
	if strings.TrimSpace(config.IPSource) == "" {
		return errors.New("ip_source is required")
	}
	if config.UpdateInterval <= 0 {
		return errors.New("update_interval must be > 0")
	}

	cleaned := make([]string, 0, len(config.Domains))
	for _, domain := range config.Domains {
		domain = strings.TrimSpace(domain)
		if domain != "" {
			cleaned = append(cleaned, domain)
		}
	}
	config.Domains = cleaned
	if len(config.Domains) == 0 {
		return errors.New("at least one domain is required")
	}

	return nil
}

func Get_IP(config *Config) (ip string, err error) {
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(config.IPSource)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return "", fmt.Errorf("ip source returned %s", resp.Status)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	re := regexp.MustCompile(`\b(?:\d{1,3}\.){3}\d{1,3}\b`)
	match := re.Find(body)
	if match == nil {
		return "", errors.New("no IPv4 address found in response")
	}

	ipStr := strings.TrimSpace(string(match))
	if net.ParseIP(ipStr) == nil {
		return "", errors.New("invalid IP address found in response")
	}

	return ipStr, nil
}
