-- Billing: invoices, line_items, payments

CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  invoice_number TEXT NOT NULL,
  invoice_date DATE NOT NULL,
  due_date DATE,
  status TEXT NOT NULL DEFAULT 'draft', -- draft, sent, paid, partial, overdue, cancelled
  subtotal DECIMAL(15,2) DEFAULT 0,
  discount_amount DECIMAL(15,2) DEFAULT 0,
  total_gst DECIMAL(15,2) DEFAULT 0,
  grand_total DECIMAL(15,2) DEFAULT 0,
  paid_amount DECIMAL(15,2) DEFAULT 0,
  notes TEXT,
  terms TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  UNIQUE(firm_id, invoice_number)
);

CREATE TABLE invoice_line_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id),
  invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  quantity DECIMAL(10,2) DEFAULT 1,
  unit_price DECIMAL(15,2) NOT NULL,
  gst_rate DECIMAL(5,2) DEFAULT 18,
  amount DECIMAL(15,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  invoice_id UUID NOT NULL REFERENCES invoices(id),
  amount DECIMAL(15,2) NOT NULL,
  payment_date DATE NOT NULL,
  payment_mode TEXT, -- cash, bank_transfer, upi, cheque
  reference_number TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

CREATE INDEX idx_invoices_firm_id ON invoices(firm_id);
CREATE INDEX idx_invoices_client_id ON invoices(client_id);
CREATE INDEX idx_invoices_status ON invoices(status);

CREATE TRIGGER invoices_updated_at BEFORE UPDATE ON invoices
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
CREATE POLICY "invoices_firm_access" ON invoices
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));

ALTER TABLE invoice_line_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "line_items_firm_access" ON invoice_line_items
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));

ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "payments_firm_access" ON payments
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));
