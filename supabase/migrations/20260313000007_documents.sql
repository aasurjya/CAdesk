-- Documents and folders

CREATE TABLE document_folders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id),
  name TEXT NOT NULL,
  parent_folder_id UUID REFERENCES document_folders(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id),
  folder_id UUID REFERENCES document_folders(id),
  name TEXT NOT NULL,
  file_type TEXT,
  file_size INTEGER,
  storage_path TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  description TEXT,
  uploaded_at TIMESTAMPTZ DEFAULT NOW(),
  uploaded_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_documents_firm_id ON documents(firm_id);
CREATE INDEX idx_documents_client_id ON documents(client_id);

CREATE TRIGGER documents_updated_at BEFORE UPDATE ON documents
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "documents_firm_access" ON documents
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));

ALTER TABLE document_folders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "folders_firm_access" ON document_folders
  FOR ALL USING (firm_id = (SELECT firm_id FROM profiles WHERE id = auth.uid()));
