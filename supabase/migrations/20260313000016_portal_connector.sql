-- Portal Connector Module Migration
-- Creates table for portal credentials and sync management

CREATE TABLE portal_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  portal_type TEXT NOT NULL,
  username TEXT,
  encrypted_password TEXT,
  grant_token TEXT,
  refresh_token TEXT,
  expires_at TIMESTAMPTZ,
  last_sync_date TIMESTAMPTZ,
  status TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE portal_credentials ENABLE ROW LEVEL SECURITY;
