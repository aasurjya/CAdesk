-- Payroll Module Migration
-- Creates table for payroll entries and salary calculations

CREATE TABLE payroll_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL,
  employee_id TEXT,
  month INT NOT NULL,
  year INT NOT NULL,
  basic_salary DECIMAL(10,2),
  allowances DECIMAL(10,2),
  deductions DECIMAL(10,2),
  tds_deducted DECIMAL(10,2),
  pf_deducted DECIMAL(10,2),
  esi_deducted DECIMAL(10,2),
  net_salary DECIMAL(10,2),
  status TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE payroll_entries ENABLE ROW LEVEL SECURITY;
