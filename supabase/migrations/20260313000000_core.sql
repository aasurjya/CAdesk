-- Core tables: firms, profiles, roles, audit_log, feature_flags

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Firms (multi-tenant root)
CREATE TABLE firms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  registration_number TEXT,
  gstin TEXT,
  pan TEXT,
  email TEXT,
  phone TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  pincode TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Profiles (extends auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  firm_id UUID NOT NULL REFERENCES firms(id),
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  role TEXT NOT NULL DEFAULT 'staff',
  avatar_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Feature flags
CREATE TABLE feature_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID REFERENCES firms(id),
  flag_name TEXT NOT NULL,
  is_enabled BOOLEAN DEFAULT FALSE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(firm_id, flag_name)
);

-- Audit log
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id),
  table_name TEXT NOT NULL,
  record_id UUID NOT NULL,
  operation TEXT NOT NULL,
  old_data JSONB,
  new_data JSONB,
  performed_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger function: updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to firms
CREATE TRIGGER firms_updated_at BEFORE UPDATE ON firms
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Apply trigger to profiles
CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Apply trigger to feature_flags
CREATE TRIGGER feature_flags_updated_at BEFORE UPDATE ON feature_flags
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- RLS: feature_flags (firm-scoped or global)
ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "feature_flags_firm_access" ON feature_flags
  FOR ALL USING (
    firm_id IS NULL OR
    firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid())
  );

-- RLS: profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profiles_firm_access" ON profiles
  FOR ALL USING (
    firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid())
  );
