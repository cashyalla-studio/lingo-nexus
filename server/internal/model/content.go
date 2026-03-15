package model

type ContentImportRequest struct {
	URL      string `json:"url"`
	Language string `json:"language"`
	Title    string `json:"title"` // optional override
}

type ContentImportResponse struct {
	Title    string `json:"title"`
	AudioURL string `json:"audio_url"`  // served from server temporarily
	Duration int64  `json:"duration_ms"`
	FileID   string `json:"file_id"` // UUID for retrieval
}
