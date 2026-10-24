-- Dark Oak: progreso compartido para ascensos de nivel
create table if not exists public.level_progress (
 id uuid primary key default gen_random_uuid(),
 level_key text not null check (level_key in ('1-2','2-3','3-4')),
 requirement_key text not null,
 title text not null,
 target_value numeric not null default 1 check (target_value >= 0),
 current_value numeric not null default 0 check (current_value >= 0),
 completed boolean not null default false,
 updated_by uuid references auth.users(id) on delete set null,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(level_key, requirement_key)
);
create table if not exists public.level_progress_log (
 id uuid primary key default gen_random_uuid(),
 level_key text not null,
 requirement_key text not null,
 title text not null,
 previous_value numeric not null default 0,
 new_value numeric not null default 0,
 change_amount numeric not null default 0,
 completed boolean not null default false,
 actor_name text not null,
 actor_id uuid references auth.users(id) on delete set null,
 created_at timestamptz not null default now()
);
alter table public.level_progress enable row level security;
alter table public.level_progress_log enable row level security;
drop policy if exists "Authenticated users can read level progress" on public.level_progress;
create policy "Authenticated users can read level progress" on public.level_progress for select to authenticated using (true);
drop policy if exists "Authenticated users can insert level progress" on public.level_progress;
create policy "Authenticated users can insert level progress" on public.level_progress for insert to authenticated with check (true);
drop policy if exists "Authenticated users can update level progress" on public.level_progress;
create policy "Authenticated users can update level progress" on public.level_progress for update to authenticated using (true) with check (true);
drop policy if exists "Authenticated users can read level progress log" on public.level_progress_log;
create policy "Authenticated users can read level progress log" on public.level_progress_log for select to authenticated using (true);
drop policy if exists "Authenticated users can insert level progress log" on public.level_progress_log;
create policy "Authenticated users can insert level progress log" on public.level_progress_log for insert to authenticated with check (true);
