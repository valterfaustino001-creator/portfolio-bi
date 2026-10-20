-- Executar em um banco dedicado de aplicação, nunca nas tabelas internas do n8n.
CREATE TABLE IF NOT EXISTS wa_sessions (
  phone text PRIMARY KEY,
  data jsonb NOT NULL DEFAULT '{}'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS wa_events (
  event_id text PRIMARY KEY,
  phone text NOT NULL,
  payload jsonb NOT NULL,
  state text NOT NULL DEFAULT 'pending'
    CHECK (state IN ('pending','processing','done','review','failed')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  error text
);
CREATE TABLE IF NOT EXISTS wa_campaigns (
  campaign_id text NOT NULL,
  phone text NOT NULL,
  state text NOT NULL DEFAULT 'reserved',
  wamid text,
  error text,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (campaign_id, phone)
);
CREATE TABLE IF NOT EXISTS wa_phone_locks (
  phone text PRIMARY KEY,
  owner text NOT NULL,
  expires_at timestamptz NOT NULL
);
CREATE TABLE IF NOT EXISTS wa_outbox (
  id bigserial PRIMARY KEY,
  dedup_key text UNIQUE NOT NULL,
  phone text NOT NULL,
  kind text NOT NULL,
  payload jsonb NOT NULL,
  state text NOT NULL DEFAULT 'pending',
  attempts integer NOT NULL DEFAULT 0,
  next_attempt_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  error text
);
CREATE INDEX IF NOT EXISTS wa_outbox_pending ON wa_outbox(state, next_attempt_at);
CREATE INDEX IF NOT EXISTS wa_events_pending ON wa_events(state, created_at);
CREATE TABLE IF NOT EXISTS wa_delivery (
  wamid text NOT NULL,
  status text NOT NULL,
  event_at timestamptz NOT NULL,
  phone text NOT NULL,
  payload jsonb NOT NULL,
  PRIMARY KEY (wamid, status, event_at)
);

-- Lock com TTL: usar um owner único por execução, renovar antes de expirar.
-- Retorna true apenas ao proprietário que pode processar o telefone.
CREATE OR REPLACE FUNCTION wa_try_lock(p_phone text, p_owner text, ttl_seconds integer DEFAULT 120)
RETURNS boolean LANGUAGE plpgsql AS $$
DECLARE claimed text;
BEGIN
  INSERT INTO wa_phone_locks(phone, owner, expires_at)
  VALUES (p_phone, p_owner, now() + make_interval(secs => ttl_seconds))
  ON CONFLICT(phone) DO UPDATE SET owner = EXCLUDED.owner, expires_at = EXCLUDED.expires_at
  WHERE wa_phone_locks.expires_at < now() OR wa_phone_locks.owner = EXCLUDED.owner
  RETURNING owner INTO claimed;
  RETURN claimed IS NOT NULL;
END;
$$;
