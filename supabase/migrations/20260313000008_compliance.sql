-- Compliance deadlines

CREATE TABLE compliance_deadlines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id),
  title TEXT NOT NULL,
  description TEXT,
  compliance_type TEXT NOT NULL, -- gst, income_tax, tds, roc, mca, other
  due_date DATE NOT NULL,
  period TEXT,
  status TEXT NOT NULL DEFAULT 'upcoming', -- upcoming, due_soon, overdue, completed
  completed_at DATE,
  assigned_to UUID REFERENCES auth.users(id),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

CREATE INDEX idx_compliance_deadlines_firm_id ON compliance_deadlines(firm_id);
CREATE INDEX idx_compliance_deadlines_due_date ON compliance_deadlines(due_date);
CREATE INDEX idx_compliance_deadlines_status ON compliance_deadlines(status);

CREATE TRIGGER compliance_deadlines_updated_at BEFORE UPDATE ON compliance_deadlines
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE compliance_deadlines ENABLE ROW LEVEL SECURITY;
CREATE POLICY "compliance_deadlines_firm_access" ON compliance_deadlines
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));
