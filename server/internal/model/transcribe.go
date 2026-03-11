package model

// TranscribeRequest는 클라이언트가 서버로 보내는 음성 전사 요청입니다.
type TranscribeRequest struct {
	AudioBase64    string `json:"audio_base64"`    // base64 인코딩된 오디오 (MP3/M4A/WAV)
	Language       string `json:"language"`        // 오디오 언어 코드: zh, ja, en, ko, es, de, fr, pt, ar
	DurationMs     int64  `json:"duration_ms"`     // 오디오 길이 (ms) — 타임스탬프 계산용
	TargetLanguage string `json:"target_language"` // 번역 대상 언어 코드 (기본값: ko)
}

// TranscribeSyncItem은 타임스탬프가 있는 단일 문장 + 발음기호 + 번역입니다.
type TranscribeSyncItem struct {
	StartMs     int64  `json:"start_ms"`
	EndMs       int64  `json:"end_ms"`
	Sentence    string `json:"sentence"`
	Phonetics   string `json:"phonetics,omitempty"`   // 발음기호 (병음/후리가나/IPA 등)
	Translation string `json:"translation,omitempty"` // 대상 언어 번역
}

// TranscribeResponse는 서버가 클라이언트에 반환하는 전사 결과입니다.
type TranscribeResponse struct {
	Script    string               `json:"script"`
	SyncItems []TranscribeSyncItem `json:"sync_items"`
}

// AnnotationItem은 문장 하나의 발음기호+번역입니다.
type AnnotationItem struct {
	Phonetics   string `json:"phonetics"`
	Translation string `json:"translation"`
}

// AnnotateRequest는 기기 내장 STT로 전사된 문장에 발음기호+번역을 추가 요청합니다.
type AnnotateRequest struct {
	Sentences      []string `json:"sentences"`       // 전사된 문장 목록
	Language       string   `json:"language"`        // 원문 언어 코드
	TargetLanguage string   `json:"target_language"` // 번역 대상 언어 코드 (기본값: ko)
}
