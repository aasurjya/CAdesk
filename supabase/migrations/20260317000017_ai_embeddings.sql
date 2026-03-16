-- Enable pgvector extension
create extension if not exists vector with schema extensions;

-- AI Embeddings table for RAG pipeline
create table if not exists public.ai_embeddings (
  id uuid primary key default gen_random_uuid(),
  chunk_id text unique not null,
  document_id text not null,
  content text not null,
  embedding vector(384) not null,
  section text,
  category text,
  source text,
  metadata jsonb default '{}'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- HNSW index for fast approximate nearest neighbor search
create index if not exists ai_embeddings_embedding_idx
  on public.ai_embeddings
  using hnsw (embedding vector_cosine_ops)
  with (m = 16, ef_construction = 64);

-- Index for filtering by document_id
create index if not exists ai_embeddings_document_id_idx
  on public.ai_embeddings (document_id);

-- Index for filtering by category
create index if not exists ai_embeddings_category_idx
  on public.ai_embeddings (category);

-- RPC function for similarity search
create or replace function public.match_documents(
  query_embedding vector(384),
  match_count int default 5,
  match_threshold float default 0.3
)
returns table (
  id uuid,
  chunk_id text,
  document_id text,
  content text,
  section text,
  category text,
  source text,
  similarity float
)
language plpgsql
as $$
begin
  return query
    select
      e.id,
      e.chunk_id,
      e.document_id,
      e.content,
      e.section,
      e.category,
      e.source,
      1 - (e.embedding <=> query_embedding) as similarity
    from public.ai_embeddings e
    where 1 - (e.embedding <=> query_embedding) > match_threshold
    order by e.embedding <=> query_embedding
    limit match_count;
end;
$$;

-- Trigger to update updated_at on modification
create or replace function public.update_ai_embeddings_timestamp()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger ai_embeddings_updated_at
  before update on public.ai_embeddings
  for each row
  execute function public.update_ai_embeddings_timestamp();

-- RLS policies
alter table public.ai_embeddings enable row level security;

create policy "Service role can manage embeddings"
  on public.ai_embeddings
  for all
  using (auth.role() = 'service_role');

create policy "Authenticated users can read embeddings"
  on public.ai_embeddings
  for select
  using (auth.role() = 'authenticated');
