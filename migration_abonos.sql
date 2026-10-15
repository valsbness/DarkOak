-- DARK OAK: historial de abonos de cuotas semanales
-- Ejecuta este archivo en Supabase SQL Editor una sola vez (es seguro volver a ejecutarlo).

create extension if not exists pgcrypto;

create table if not exists public.weekly_dues_payments (
  id uuid primary key default gen_random_uuid(),
  due_id uuid not null references public.weekly_dues(id) on delete restrict,
  amount_bags integer not null check (amount_bags > 0),
  paid_on date not null default current_date,
  payer_name text,
  note text,
  recorded_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create index if not exists weekly_dues_payments_due_idx
  on public.weekly_dues_payments (due_id, paid_on, created_at);

alter table public.weekly_dues_payments enable row level security;

grant select, insert, update, delete
  on table public.weekly_dues_payments to authenticated;

drop policy if exists "authenticated payments access" on public.weekly_dues_payments;
create policy "authenticated payments access"
  on public.weekly_dues_payments
  for all
  to authenticated
  using (true)
  with check (true);
