package main

import (
	"duck-ddns/internal/ddns"
	"duck-ddns/internal/utils"
	"log"
	"os"
	"path/filepath"
	"time"
)

func main() {
	c, err := utils.Get_Config("config/duck-ddns.json")
	if err != nil {
		panic(err)
	}
	logFile, err := setupLog(c.LogFile)
	if err != nil {
		panic(err)
	}
	if logFile != nil {
		defer logFile.Close()
	}
	if err := utils.ValidateConfig(c); err != nil {
		log.Fatalf("invalid config: %v", err)
	}

	for {
		err = ddns.Update_DDNS(c)
		if err != nil {
			log.Printf("ddns update failed: %v", err)
		}
		time.Sleep(time.Duration(c.UpdateInterval) * time.Second)
	}
}

func setupLog(logFile string) (*os.File, error) {
	if logFile == "" {
		return nil, nil
	}

	logDir := filepath.Dir(logFile)
	if logDir != "." {
		if err := os.MkdirAll(logDir, 0o755); err != nil {
			return nil, err
		}
	}
	file, err := os.OpenFile(logFile, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o644)
	if err != nil {
		return nil, err
	}
	log.SetOutput(file)
	return file, nil
}
