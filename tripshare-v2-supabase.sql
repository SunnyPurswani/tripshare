create table if not exists public.trip_documents (
  id text primary key,
  trip_name text not null default 'TripShare',
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.trip_documents enable row level security;

drop policy if exists "anon can read trip documents" on public.trip_documents;
create policy "anon can read trip documents"
on public.trip_documents
for select
to anon
using (true);

drop policy if exists "anon can create trip documents" on public.trip_documents;
create policy "anon can create trip documents"
on public.trip_documents
for insert
to anon
with check (true);

drop policy if exists "anon can update trip documents" on public.trip_documents;
create policy "anon can update trip documents"
on public.trip_documents
for update
to anon
using (true)
with check (true);

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'trip_documents'
  ) then
    alter publication supabase_realtime add table public.trip_documents;
  end if;
end $$;

create index if not exists trip_documents_updated_at_idx
on public.trip_documents (updated_at desc);
