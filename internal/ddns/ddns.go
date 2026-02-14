package ddns

import (
	"duck-ddns/internal/utils"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

func Update_DDNS(c *utils.Config) error {
	if len(c.Domains) == 0 {
		return errors.New("no domains configured")
	}

	ip, err := utils.Get_IP(c)
	if err != nil {
		return err
	}

	client := &http.Client{Timeout: 10 * time.Second}
	for _, domain := range c.Domains {
		domain = strings.TrimSpace(domain)
		if domain == "" {
			continue
		}

		resp, err := client.Get("https://duckdns.org/update/" + domain + "/" + c.Token + "/" + ip)
		if err != nil {
			return err
		}
		body, readErr := io.ReadAll(resp.Body)
		resp.Body.Close()
		if readErr != nil {
			return readErr
		}
		if resp.StatusCode < 200 || resp.StatusCode >= 300 {
			return fmt.Errorf("duckdns update failed for %s: %s", domain, resp.Status)
		}
		respText := strings.TrimSpace(string(body))
		if respText != "OK" {
			return fmt.Errorf("duckdns update failed for %s: %s", domain, respText)
		}
	}

	return nil
}
