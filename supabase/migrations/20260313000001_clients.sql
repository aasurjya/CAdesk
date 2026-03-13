-- Clients table

CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  pan TEXT NOT NULL,
  aadhaar_hash TEXT, -- SHA-256 hash only, never plaintext (DPDP compliance)
  email TEXT,
  phone TEXT,
  alternate_phone TEXT,
  client_type TEXT NOT NULL, -- individual, huf, firm, llp, company, publicLimited, trust, aop
  date_of_birth DATE,
  date_of_incorporation DATE,
  address TEXT,
  city TEXT,
  state TEXT,
  pincode TEXT,
  gstin TEXT,
  tan TEXT,
  services_availed TEXT[] DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'active', -- active, inactive, prospect
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id)
);

CREATE INDEX idx_clients_firm_id ON clients(firm_id);
CREATE INDEX idx_clients_pan ON clients(pan);
CREATE INDEX idx_clients_status ON clients(status);
CREATE INDEX idx_clients_name ON clients USING gin(to_tsvector('english', name));

CREATE TRIGGER clients_updated_at BEFORE UPDATE ON clients
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- RLS
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "clients_firm_access" ON clients
  FOR ALL USING (
    firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid())
  );
