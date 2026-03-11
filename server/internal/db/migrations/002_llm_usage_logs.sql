-- LLM 요청 사용 로그 (토큰, 사용자, 결과 기록)
CREATE TABLE IF NOT EXISTS llm_usage_logs (
  id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id        BIGINT UNSIGNED,               -- nullable (인증 비활성 시 NULL)
  endpoint       VARCHAR(100)   NOT NULL,        -- 'transcribe' | 'tone_evaluate' | 'grammar' | 'vocabulary' | 'chat'
  provider       ENUM('gemini','qwen') NOT NULL,
  model          VARCHAR(100)   NOT NULL,
  language       VARCHAR(10),
  input_tokens   INT            NOT NULL DEFAULT 0,
  output_tokens  INT            NOT NULL DEFAULT 0,
  duration_ms    INT            NOT NULL DEFAULT 0,
  result_preview TEXT,                           -- 결과 앞 500자
  error          TEXT,                           -- 실패 시 에러 메시지
  created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_lul_user    (user_id),
  INDEX idx_lul_created (created_at),
  INDEX idx_lul_endpoint (endpoint),
  CONSTRAINT fk_lul_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
