package main

import (
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/contrib/static"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

const (
	uiDirectory = "ui"
)

func buildRouter() *gin.Engine {
	r := gin.New()
	r.Use(gin.Logger(), gin.Recovery())

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, nil)
	})

	r.Use(static.Serve("/", static.LocalFile(uiDirectory, false)))
	r.NoRoute(func(c *gin.Context) {
		c.File(filepath.Join(uiDirectory, "index.html"))
	})
	return r
}

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("warning: .env not loaded:", err)
	}

	r := buildRouter()

	port := os.Getenv("PORT")
	if port == "" {
		port = "8443"
	}
	addr := port
	if !strings.HasPrefix(port, ":") {
		addr = ":" + port
	}
	log.Printf("listening on %s", addr)

	if err := r.Run(addr); err != nil {
		log.Fatal(err)
	}
}
