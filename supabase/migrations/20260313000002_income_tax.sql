-- Income Tax: ITR filings

CREATE TABLE itr_filings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  pan TEXT NOT NULL,
  itr_type TEXT NOT NULL, -- ITR-1, ITR-2, ITR-3, ITR-4, ITR-5, ITR-6, ITR-7
  assessment_year TEXT NOT NULL, -- e.g. "2026-27"
  financial_year TEXT NOT NULL,
  filing_status TEXT NOT NULL DEFAULT 'pending', -- pending, in_progress, filed, verified, defective
  total_income DECIMAL(15,2),
  tax_payable DECIMAL(15,2),
  refund_due DECIMAL(15,2),
  tds_amount DECIMAL(15,2),
  advance_tax DECIMAL(15,2),
  self_assessment_tax DECIMAL(15,2),
  acknowledgement_number TEXT,
  filed_date DATE,
  verified_date DATE,
  due_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id)
);

CREATE INDEX idx_itr_filings_client_id ON itr_filings(client_id);
CREATE INDEX idx_itr_filings_firm_id ON itr_filings(firm_id);
CREATE INDEX idx_itr_filings_assessment_year ON itr_filings(assessment_year);

CREATE TRIGGER itr_filings_updated_at BEFORE UPDATE ON itr_filings
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE itr_filings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "itr_filings_firm_access" ON itr_filings
  FOR ALL USING (
    firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid())
  );
