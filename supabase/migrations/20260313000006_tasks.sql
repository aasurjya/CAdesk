-- Tasks

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id),
  title TEXT NOT NULL,
  description TEXT,
  task_type TEXT,
  priority TEXT DEFAULT 'medium', -- low, medium, high, urgent
  status TEXT NOT NULL DEFAULT 'pending', -- pending, in_progress, completed, cancelled
  due_date DATE,
  completed_at TIMESTAMPTZ,
  assigned_to UUID REFERENCES auth.users(id),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE task_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  assigned_by UUID REFERENCES auth.users(id)
);

CREATE INDEX idx_tasks_firm_id ON tasks(firm_id);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);

CREATE TRIGGER tasks_updated_at BEFORE UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "tasks_firm_access" ON tasks
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));
