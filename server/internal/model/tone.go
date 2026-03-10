package model

// ToneEvalRequest는 클라이언트가 서버로 보내는 발음 평가 요청입니다.
// 오디오는 VAD 트리밍된 WAV (16kHz mono) base64 인코딩 값입니다.
type ToneEvalRequest struct {
	AudioBase64 string `json:"audio_base64"` // base64(WAV 16kHz mono)
	Word        string `json:"word"`         // 평가 대상 단어 (예: 妈)
	Pinyin      string `json:"pinyin"`       // 병음 (예: mā)
	Tone        int    `json:"tone"`         // 목표 성조 (1~4, 0=경성)
	Language    string `json:"language"`     // 학습 언어 코드 (예: zh, ja, en)
}

// ToneEvalResponse는 서버가 클라이언트에게 반환하는 평가 결과입니다.
type ToneEvalResponse struct {
	Correct         bool    `json:"correct"`
	DetectedPattern string  `json:"detected_pattern"`
	Score           float64 `json:"score"` // 0.0 ~ 1.0
	Feedback        string  `json:"feedback"`
}
