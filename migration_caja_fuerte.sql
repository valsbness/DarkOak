-- DARK OAK: caja fuerte con 10 casillas y registro de movimientos
-- Ejecuta este archivo una sola vez en Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.vault_slots (
  slot_no integer primary key check (slot_no between 1 and 10),
  item_name text,
  icon_url text,
  quantity numeric not null default 0 check (quantity >= 0),
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now(),
  constraint vault_slot_item_consistency check (
    (item_name is null and icon_url is null and quantity = 0)
    or (item_name is not null and length(trim(item_name)) > 0)
  )
);

insert into public.vault_slots (slot_no)
select n from generate_series(1,10) as n
on conflict (slot_no) do nothing;

create table if not exists public.vault_movements (
  id uuid primary key default gen_random_uuid(),
  slot_no integer not null check (slot_no between 1 and 10),
  item_name text not null,
  change_amount numeric not null,
  quantity_before numeric not null check (quantity_before >= 0),
  quantity_after numeric not null check (quantity_after >= 0),
  action text not null check (action in ('add_item','increase','decrease','clear_item')),
  actor_name text not null,
  actor_id uuid references auth.users(id),
  created_at timestamptz not null default now()
);

create index if not exists vault_movements_created_idx
  on public.vault_movements (created_at desc);
create index if not exists vault_movements_slot_idx
  on public.vault_movements (slot_no, created_at desc);

alter table public.vault_slots enable row level security;
alter table public.vault_movements enable row level security;

grant select, insert, update, delete on public.vault_slots to authenticated;
grant select, insert on public.vault_movements to authenticated;

drop policy if exists "authenticated vault slots access" on public.vault_slots;
create policy "authenticated vault slots access" on public.vault_slots
for all to authenticated using (true) with check (true);

drop policy if exists "authenticated vault movement read" on public.vault_movements;
create policy "authenticated vault movement read" on public.vault_movements
for select to authenticated using (true);

drop policy if exists "authenticated vault movement insert" on public.vault_movements;
create policy "authenticated vault movement insert" on public.vault_movements
for insert to authenticated with check (true);
