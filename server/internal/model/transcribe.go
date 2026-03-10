package model

// TranscribeRequest는 클라이언트가 서버로 보내는 음성 전사 요청입니다.
type TranscribeRequest struct {
	AudioBase64 string `json:"audio_base64"` // base64 인코딩된 오디오 (MP3/M4A/WAV)
	Language    string `json:"language"`     // 언어 코드: zh, ja, en, ko, es, de, fr, pt, ar
	DurationMs  int64  `json:"duration_ms"`  // 오디오 길이 (ms) — 타임스탬프 계산용
}

// TranscribeSyncItem은 타임스탬프가 있는 단일 문장입니다.
type TranscribeSyncItem struct {
	StartMs  int64  `json:"start_ms"`
	EndMs    int64  `json:"end_ms"`
	Sentence string `json:"sentence"`
}

// TranscribeResponse는 서버가 클라이언트에 반환하는 전사 결과입니다.
type TranscribeResponse struct {
	Script    string               `json:"script"`
	SyncItems []TranscribeSyncItem `json:"sync_items"`
}
