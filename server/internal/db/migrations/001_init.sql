-- LingoNexus DB Schema
-- MySQL 8.4 / UTF8MB4

CREATE TABLE IF NOT EXISTS users (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  email       VARCHAR(255)               NOT NULL,
  name        VARCHAR(255)               NOT NULL DEFAULT '',
  avatar_url  TEXT,
  provider    ENUM('google','apple')     NOT NULL,
  provider_id VARCHAR(255)               NOT NULL,
  created_at  TIMESTAMP                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP                  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_email (email),
  UNIQUE KEY uk_provider (provider, provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Credits stored in seconds (1 credit = 60 s)
CREATE TABLE IF NOT EXISTS credit_accounts (
  user_id             BIGINT UNSIGNED  NOT NULL PRIMARY KEY,
  balance             INT              NOT NULL DEFAULT 0,
  daily_free_used     INT              NOT NULL DEFAULT 0,   -- seconds used today
  daily_free_reset_at DATE             NOT NULL DEFAULT (CURRENT_DATE),
  updated_at          TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_ca_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS credit_transactions (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     BIGINT UNSIGNED  NOT NULL,
  amount      INT              NOT NULL,  -- positive = add, negative = deduct (seconds)
  type        ENUM('purchase','subscription_grant','audio_usage','refund','admin_grant') NOT NULL,
  description VARCHAR(500),
  product_id  VARCHAR(255),
  created_at  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_ct_user_created (user_id, created_at),
  CONSTRAINT fk_ct_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- plans: basic=300min, pro=1000min, premium=3000min (stored in seconds)
CREATE TABLE IF NOT EXISTS subscriptions (
  id                       BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id                  BIGINT UNSIGNED  NOT NULL,
  plan                     ENUM('basic','pro','premium') NOT NULL,
  credits_per_month        INT              NOT NULL,  -- seconds
  started_at               TIMESTAMP        NOT NULL,
  expires_at               TIMESTAMP        NOT NULL,
  platform                 ENUM('ios','android') NOT NULL,
  original_transaction_id  VARCHAR(255),
  created_at               TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_sub_user_expires (user_id, expires_at),
  CONSTRAINT fk_sub_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id    BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64)        NOT NULL,   -- SHA-256 hex
  expires_at TIMESTAMP       NOT NULL,
  created_at TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_rt_hash (token_hash),
  INDEX idx_rt_user (user_id),
  CONSTRAINT fk_rt_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
