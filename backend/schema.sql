CREATE TABLE IF NOT EXISTS lifeos_account (
  id uuid PRIMARY KEY,
  encryption_salt bytea NOT NULL,
  kdf_iterations integer NOT NULL CHECK (kdf_iterations >= 100000)
);

CREATE TABLE IF NOT EXISTS lifeos_devices (
  id uuid PRIMARY KEY,
  account_id uuid NOT NULL REFERENCES lifeos_account(id) ON DELETE CASCADE,
  name text NOT NULL,
  token_hash bytea NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz,
  revoked_at timestamptz
);

CREATE TABLE IF NOT EXISTS lifeos_records (
  account_id uuid NOT NULL REFERENCES lifeos_account(id) ON DELETE CASCADE,
  entity_type text NOT NULL,
  entity_id text NOT NULL,
  revision bigint NOT NULL CHECK (revision > 0),
  payload_envelope text,
  deleted boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (account_id, entity_type, entity_id)
);

CREATE TABLE IF NOT EXISTS lifeos_changes (
  cursor bigserial PRIMARY KEY,
  account_id uuid NOT NULL REFERENCES lifeos_account(id) ON DELETE CASCADE,
  device_id uuid NOT NULL REFERENCES lifeos_devices(id),
  change_id text NOT NULL,
  entity_type text NOT NULL,
  entity_id text NOT NULL,
  revision bigint NOT NULL,
  operation text NOT NULL CHECK (operation IN ('upsert', 'delete')),
  payload_envelope text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (account_id, change_id)
);

CREATE INDEX IF NOT EXISTS lifeos_changes_account_cursor
  ON lifeos_changes(account_id, cursor);
