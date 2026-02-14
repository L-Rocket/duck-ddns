package ddns

import (
	"duck-ddns/internal/utils"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
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

	// DuckDNS supports updating multiple domains in one request by separating them with commas
	domains := strings.Join(c.Domains, ",")

	u, err := url.Parse("https://www.duckdns.org/update")
	if err != nil {
		return fmt.Errorf("failed to parse url: %w", err)
	}

	q := u.Query()
	q.Set("domains", domains)
	q.Set("token", c.Token)
	q.Set("ip", ip)
	u.RawQuery = q.Encode()

	resp, err := client.Get(u.String())
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	body, readErr := io.ReadAll(resp.Body)
	if readErr != nil {
		return readErr
	}

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("duckdns update failed: %s", resp.Status)
	}

	respText := strings.TrimSpace(string(body))
	if respText != "OK" {
		return fmt.Errorf("duckdns update failed: %s", respText)
	}

	log.Printf("Successfully updated domains %s to IP %s", domains, ip)
	return nil
}
