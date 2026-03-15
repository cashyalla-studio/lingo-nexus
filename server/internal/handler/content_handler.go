package handler

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/liel/lingo-nexus-server/internal/model"
)

type ContentHandler struct{}

func NewContentHandler() *ContentHandler {
	return &ContentHandler{}
}

// Import godoc
// POST /api/v1/content/import
func (h *ContentHandler) Import(w http.ResponseWriter, r *http.Request) {
	var req model.ContentImportRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body: "+err.Error())
		return
	}
	if req.URL == "" {
		writeError(w, http.StatusBadRequest, "url is required")
		return
	}

	// Check yt-dlp is available on the server
	if _, err := exec.LookPath("yt-dlp"); err != nil {
		writeError(w, http.StatusServiceUnavailable, "yt-dlp not installed on server")
		return
	}

	// Create a unique temp directory for this download
	fileID := fmt.Sprintf("%d", time.Now().UnixNano())
	tmpDir := filepath.Join(os.TempDir(), "lingo_import", fileID)
	if err := os.MkdirAll(tmpDir, 0755); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to create temp dir: "+err.Error())
		return
	}

	outTemplate := filepath.Join(tmpDir, "audio.%(ext)s")

	// Run yt-dlp: extract audio as m4a, print title to stdout
	cmd := exec.CommandContext(r.Context(), "yt-dlp",
		"--extract-audio",
		"--audio-format", "m4a",
		"--audio-quality", "128K",
		"--no-playlist",
		"--output", outTemplate,
		"--print", "title",
		req.URL,
	)

	output, err := cmd.Output()
	if err != nil {
		// Clean up on failure
		os.RemoveAll(tmpDir)
		writeError(w, http.StatusBadRequest, "failed to download audio: "+err.Error())
		return
	}

	title := strings.TrimSpace(string(output))
	if req.Title != "" {
		title = req.Title
	}
	if title == "" {
		title = "Imported Audio"
	}

	// Find the downloaded audio file
	entries, _ := os.ReadDir(tmpDir)
	var audioFile string
	for _, e := range entries {
		if !e.IsDir() {
			audioFile = filepath.Join(tmpDir, e.Name())
			break
		}
	}

	if audioFile == "" {
		os.RemoveAll(tmpDir)
		writeError(w, http.StatusInternalServerError, "audio file not found after download")
		return
	}

	resp := model.ContentImportResponse{
		Title:    title,
		AudioURL: "/api/v1/content/file/" + fileID + "/" + filepath.Base(audioFile),
		FileID:   fileID,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

// ServeFile godoc
// GET /api/v1/content/file/{fileID}/{filename}
func (h *ContentHandler) ServeFile(w http.ResponseWriter, r *http.Request) {
	fileID := chi.URLParam(r, "fileID")
	filename := chi.URLParam(r, "filename")

	if fileID == "" || filename == "" {
		writeError(w, http.StatusBadRequest, "fileID and filename are required")
		return
	}

	// Prevent path traversal: filename must not contain separators
	if strings.ContainsAny(filename, "/\\") {
		writeError(w, http.StatusBadRequest, "invalid filename")
		return
	}

	filePath := filepath.Join(os.TempDir(), "lingo_import", fileID, filename)

	// Verify the resolved path is inside the expected directory
	expectedDir := filepath.Join(os.TempDir(), "lingo_import", fileID)
	if !strings.HasPrefix(filePath, expectedDir) {
		writeError(w, http.StatusBadRequest, "invalid file path")
		return
	}

	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		writeError(w, http.StatusNotFound, "file not found or expired")
		return
	}

	http.ServeFile(w, r, filePath)
}
