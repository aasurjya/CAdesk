-- MCA Module Migration
-- Creates table for Ministry of Corporate Affairs filings

CREATE TABLE mca_filings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  form_type TEXT,
  financial_year TEXT,
  due_date TIMESTAMPTZ,
  filed_date TIMESTAMPTZ,
  status TEXT,
  filing_number TEXT,
  remarks TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE mca_filings ENABLE ROW LEVEL SECURITY;
