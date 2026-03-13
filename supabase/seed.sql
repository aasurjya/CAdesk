-- Dev seed data

-- Insert 3 dev firms (no auth.users dependency — using UUIDs directly)
INSERT INTO firms (id, name, registration_number, gstin, pan, email, phone, city, state) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Dev CA Firm Alpha', 'REG001', '29DEVCA1234A1Z1', 'DEVCA1234A', 'alpha@devca.com', '9000000001', 'Bengaluru', 'Karnataka'),
  ('00000000-0000-0000-0000-000000000002', 'Beta Accountants', 'REG002', '07BETAC5678B1Z2', 'BETAC5678B', 'info@betaaccountants.com', '9000000002', 'New Delhi', 'Delhi'),
  ('00000000-0000-0000-0000-000000000003', 'Gamma Tax Consultants', 'REG003', '27GAMMT9012C1Z3', 'GAMMT9012C', 'contact@gammatax.com', '9000000003', 'Mumbai', 'Maharashtra');

-- Insert feature flags (global — firm_id NULL means applies to all)
INSERT INTO feature_flags (flag_name, is_enabled, description, firm_id) VALUES
  ('clients_real_repo', FALSE, 'Use real Supabase/Drift repository for clients', NULL),
  ('income_tax_real_repo', FALSE, 'Use real repository for income tax filings', NULL),
  ('gst_real_repo', FALSE, 'Use real repository for GST data', NULL),
  ('tds_real_repo', FALSE, 'Use real repository for TDS data', NULL),
  ('billing_real_repo', FALSE, 'Use real repository for billing/invoices', NULL);

-- Sample clients for firm 1
INSERT INTO clients (id, firm_id, name, pan, email, phone, client_type, status, services_availed, city, state) VALUES
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 'Rajesh Kumar Sharma', 'ABCPS1234A', 'rajesh.sharma@gmail.com', '9876543210', 'individual', 'active', ARRAY['itrFiling', 'gstFiling'], 'Mumbai', 'Maharashtra'),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 'ABC Infra Pvt Ltd', 'AABCA1234C', 'accounts@abcinfra.in', '9111222333', 'company', 'active', ARRAY['itrFiling', 'gstFiling', 'tds', 'audit'], 'New Delhi', 'Delhi'),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 'Mehta & Sons', 'AAPFM5678D', 'mehtasons@yahoo.com', '9444555666', 'firm', 'active', ARRAY['itrFiling', 'gstFiling', 'bookkeeping'], 'Ahmedabad', 'Gujarat'),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 'TechVista Solutions LLP', 'AAFT1234F', 'finance@techvista.co.in', '8055667788', 'llp', 'active', ARRAY['itrFiling', 'gstFiling', 'tds', 'payroll'], 'Bengaluru', 'Karnataka'),
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 'Priya Mehta', 'BQKPM5678B', 'priya.mehta@outlook.com', '9988776655', 'individual', 'active', ARRAY['itrFiling'], 'Hyderabad', 'Telangana');

-- Dev user profile (auth.users + identity created by migration 20260313000010)
-- Login credentials: dev@caapp.com / Dev@123456
INSERT INTO profiles (id, firm_id, full_name, email, role)
VALUES (
  '00000000-0000-0000-0001-000000000001'::UUID,
  '00000000-0000-0000-0000-000000000001'::UUID,
  'Dev Admin',
  'dev@caapp.com',
  'admin'
)
ON CONFLICT (id) DO NOTHING;

-- Add tasks_real_repo feature flag
INSERT INTO feature_flags (flag_name, is_enabled, description, firm_id)
VALUES ('tasks_real_repo', FALSE, 'Use real repository for tasks', NULL)
ON CONFLICT (firm_id, flag_name) DO NOTHING;
