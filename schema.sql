-- DARK OAK / Supabase SQL Editor
-- Ejecuta este script en un proyecto Supabase nuevo. RLS limita el acceso a usuarios autenticados.
create extension if not exists pgcrypto;
create table if not exists public.members (
 id uuid primary key default gen_random_uuid(),
 ic_name text not null,
 age integer not null check (age between 1 and 120),
 discord_name text,
 discord_id text,
 joined_on date not null default current_date,
 status text not null default 'activo' check (status in ('activo','ausente','retirado')),
 notes_summary text,
 left_on date,
 created_by uuid references auth.users(id),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.weekly_dues (
 id uuid primary key default gen_random_uuid(),
 member_id uuid not null references public.members(id) on delete restrict,
 week_start date not null,
 required_bags integer not null default 300 check (required_bags=300),
 delivered boolean not null default false,
 delivered_at date,
 recorded_by uuid references auth.users(id),
 created_at timestamptz not null default now(),
 unique(member_id, week_start)
);
create table if not exists public.member_notes (
 id uuid primary key default gen_random_uuid(),
 member_id uuid not null references public.members(id) on delete restrict,
 category text not null default 'observacion' check (category in ('observacion','incidencia','cuota','reconocimiento')),
 note_date date not null default current_date,
 body text not null,
 created_by uuid references auth.users(id),
 created_at timestamptz not null default now()
);
create index if not exists members_status_idx on public.members(status);
create index if not exists dues_week_idx on public.weekly_dues(week_start);
create index if not exists notes_member_idx on public.member_notes(member_id, note_date desc);
alter table public.members enable row level security;
alter table public.weekly_dues enable row level security;
alter table public.member_notes enable row level security;
-- Solo usuarios autenticados podrán leer/escribir. Crea las cuentas autorizadas manualmente en Supabase Auth.
drop policy if exists "auth members access" on public.members;
create policy "auth members access" on public.members for all to authenticated using (true) with check (true);
drop policy if exists "auth dues access" on public.weekly_dues;
create policy "auth dues access" on public.weekly_dues for all to authenticated using (true) with check (true);
drop policy if exists "auth notes access" on public.member_notes;
create policy "auth notes access" on public.member_notes for all to authenticated using (true) with check (true);
