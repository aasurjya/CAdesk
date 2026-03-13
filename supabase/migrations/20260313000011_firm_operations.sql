-- Firm Operations Module Migration
-- Creates tables for firm information, team management, and client assignments

CREATE TABLE firm_info (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT,
  state TEXT,
  pincode TEXT,
  pan_number TEXT UNIQUE,
  tan_number TEXT UNIQUE,
  dsc_certificate BYTEA,
  bank_account TEXT,
  registration_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE team_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID REFERENCES firm_info(id),
  name TEXT NOT NULL,
  pan TEXT UNIQUE,
  role TEXT,
  email TEXT,
  phone TEXT,
  permissions JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE client_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  assigned_to_id UUID REFERENCES team_members(id),
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  role TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE firm_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_assignments ENABLE ROW LEVEL SECURITY;
