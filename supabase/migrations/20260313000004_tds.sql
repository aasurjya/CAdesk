-- TDS: returns, deductees, challans

CREATE TABLE tds_returns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  tan TEXT NOT NULL,
  form_type TEXT NOT NULL, -- 24Q, 26Q, 27Q, 27EQ
  quarter TEXT NOT NULL, -- Q1, Q2, Q3, Q4
  financial_year TEXT NOT NULL,
  due_date DATE,
  filed_date DATE,
  status TEXT NOT NULL DEFAULT 'pending',
  total_deductions INTEGER DEFAULT 0,
  total_tax_deducted DECIMAL(15,2) DEFAULT 0,
  total_tax_deposited DECIMAL(15,2) DEFAULT 0,
  late_fee DECIMAL(15,2) DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

CREATE TABLE tds_challans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  tds_return_id UUID REFERENCES tds_returns(id),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  bsr_code TEXT,
  challan_number TEXT,
  payment_date DATE,
  amount DECIMAL(15,2) NOT NULL,
  tax_type TEXT, -- 200, 400
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

CREATE INDEX idx_tds_returns_client_id ON tds_returns(client_id);
CREATE INDEX idx_tds_returns_firm_id ON tds_returns(firm_id);

CREATE TRIGGER tds_returns_updated_at BEFORE UPDATE ON tds_returns
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE tds_returns ENABLE ROW LEVEL SECURITY;
CREATE POLICY "tds_returns_firm_access" ON tds_returns
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));

ALTER TABLE tds_challans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "tds_challans_firm_access" ON tds_challans
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));
