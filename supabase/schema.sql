create table if not exists public.budget_documents (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.budget_documents enable row level security;

drop policy if exists "budget_owner_select" on public.budget_documents;
create policy "budget_owner_select"
on public.budget_documents
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "budget_owner_insert" on public.budget_documents;
create policy "budget_owner_insert"
on public.budget_documents
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "budget_owner_update" on public.budget_documents;
create policy "budget_owner_update"
on public.budget_documents
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
