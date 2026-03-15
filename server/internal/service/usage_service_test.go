package service

import "testing"

// TestTruncateRune tests the string truncation helper.
func TestTruncateRune(t *testing.T) {
	tests := []struct {
		name  string
		input string
		n     int
		want  string
	}{
		{
			name:  "short string unchanged",
			input: "hello",
			n:     10,
			want:  "hello",
		},
		{
			name:  "exactly at limit unchanged",
			input: "hello",
			n:     5,
			want:  "hello",
		},
		{
			name:  "exceeds limit gets truncated",
			input: "hello world",
			n:     5,
			want:  "hello",
		},
		{
			name:  "empty string unchanged",
			input: "",
			n:     10,
			want:  "",
		},
		{
			name:  "limit zero returns empty",
			input: "hello",
			n:     0,
			want:  "",
		},
		{
			name:  "multibyte CJK characters counted as runes not bytes",
			input: "안녕하세요", // 5 Korean runes, 15 bytes
			n:     3,
			want:  "안녕하",
		},
		{
			name:  "multibyte within limit unchanged",
			input: "안녕하세요",
			n:     10,
			want:  "안녕하세요",
		},
		{
			name:  "mixed ASCII and CJK truncated at rune boundary",
			input: "hello안녕",
			n:     6,
			want:  "hello안",
		},
		{
			name:  "emoji counted as single rune",
			input: "😀😁😂😃😄",
			n:     3,
			want:  "😀😁😂",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := truncateRune(tt.input, tt.n)
			if got != tt.want {
				t.Errorf("truncateRune(%q, %d) = %q, want %q", tt.input, tt.n, got, tt.want)
			}
		})
	}
}

// TestTruncateRune_500CharLimit matches production usage (preview field).
func TestTruncateRune_500CharLimit(t *testing.T) {
	long := ""
	for i := 0; i < 600; i++ {
		long += "a"
	}
	result := truncateRune(long, 500)
	if len([]rune(result)) != 500 {
		t.Errorf("expected 500 runes, got %d", len([]rune(result)))
	}
}
