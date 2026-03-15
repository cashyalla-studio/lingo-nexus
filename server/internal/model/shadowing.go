package model

type ShadowingScoreRequest struct {
	AudioBase64  string `json:"audio_base64"`
	OriginalText string `json:"original_text"`
	Language     string `json:"language"`
}

type ShadowingScoreResponse struct {
	Accuracy       int      `json:"accuracy"`
	Intonation     int      `json:"intonation"`
	Fluency        int      `json:"fluency"`
	Transcription  string   `json:"transcription"`
	IncorrectWords []string `json:"incorrect_words"`
	Feedback       string   `json:"feedback"`
}
