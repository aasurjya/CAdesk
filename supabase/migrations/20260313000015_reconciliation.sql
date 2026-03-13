-- Reconciliation Module Migration
-- Creates table for reconciliation results and discrepancy tracking

CREATE TABLE reconciliation_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  reconciliation_type TEXT,
  period TEXT,
  total_matched INT,
  total_unmatched INT,
  discrepancies JSONB,
  status TEXT,
  reviewed_by TEXT,
  reviewed_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE reconciliation_results ENABLE ROW LEVEL SECURITY;
