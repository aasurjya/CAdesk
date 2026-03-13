-- Background jobs and dead letter queue (for RPA/async operations)

CREATE TABLE jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  job_type TEXT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'pending', -- pending, processing, completed, failed
  priority INTEGER DEFAULT 5,
  attempts INTEGER DEFAULT 0,
  max_attempts INTEGER DEFAULT 3,
  scheduled_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  error TEXT,
  result JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

CREATE TABLE dlq (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID REFERENCES jobs(id),
  firm_id UUID NOT NULL REFERENCES firms(id),
  job_type TEXT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}',
  error TEXT NOT NULL,
  failed_at TIMESTAMPTZ DEFAULT NOW(),
  resolved_at TIMESTAMPTZ,
  resolved_by UUID REFERENCES auth.users(id)
);

CREATE INDEX idx_jobs_firm_id ON jobs(firm_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_scheduled_at ON jobs(scheduled_at);

CREATE TRIGGER jobs_updated_at BEFORE UPDATE ON jobs
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "jobs_firm_access" ON jobs
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));

ALTER TABLE dlq ENABLE ROW LEVEL SECURITY;
CREATE POLICY "dlq_firm_access" ON dlq
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));
