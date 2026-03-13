-- GST: clients and returns

CREATE TABLE gst_clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  gstin TEXT NOT NULL,
  pan TEXT NOT NULL,
  registration_type TEXT NOT NULL, -- regular, composition, unregistered, sez, oidar
  state_code TEXT NOT NULL,
  registration_date DATE,
  cancellation_date DATE,
  compliance_score INTEGER DEFAULT 100,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

CREATE TABLE gst_returns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  gstin TEXT NOT NULL,
  return_type TEXT NOT NULL, -- GSTR-1, GSTR-3B, GSTR-9, GSTR-9C
  period_month INTEGER NOT NULL,
  period_year INTEGER NOT NULL,
  due_date DATE,
  filed_date DATE,
  status TEXT NOT NULL DEFAULT 'pending', -- pending, filed, late_filed, not_applicable
  taxable_value DECIMAL(15,2) DEFAULT 0,
  igst DECIMAL(15,2) DEFAULT 0,
  cgst DECIMAL(15,2) DEFAULT 0,
  sgst DECIMAL(15,2) DEFAULT 0,
  cess DECIMAL(15,2) DEFAULT 0,
  late_fee DECIMAL(15,2) DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

CREATE INDEX idx_gst_clients_firm_id ON gst_clients(firm_id);
CREATE INDEX idx_gst_clients_gstin ON gst_clients(gstin);
CREATE INDEX idx_gst_returns_client_id ON gst_returns(client_id);
CREATE INDEX idx_gst_returns_firm_id ON gst_returns(firm_id);

CREATE TRIGGER gst_clients_updated_at BEFORE UPDATE ON gst_clients
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER gst_returns_updated_at BEFORE UPDATE ON gst_returns
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE gst_clients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "gst_clients_firm_access" ON gst_clients
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));

ALTER TABLE gst_returns ENABLE ROW LEVEL SECURITY;
CREATE POLICY "gst_returns_firm_access" ON gst_returns
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));
