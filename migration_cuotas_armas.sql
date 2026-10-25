-- Dark Oak: permitir elegir cuota semanal de bolsas o armas y registrar abonos parciales.
-- Ejecutar una sola vez en Supabase SQL Editor.

alter table public.weekly_dues
  add column if not exists quota_type text not null default 'bags',
  add column if not exists weapon_type text,
  add column if not exists required_weapons integer not null default 14;

alter table public.weekly_dues_payments
  add column if not exists quota_type text not null default 'bags',
  add column if not exists weapon_type text;

-- Las cuotas antiguas permanecen como cuota de bolsas; sus abonos no se pierden.
update public.weekly_dues
set quota_type = 'bags'
where quota_type is null;

update public.weekly_dues_payments
set quota_type = 'bags'
where quota_type is null;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'weekly_dues_quota_type_check') then
    alter table public.weekly_dues
      add constraint weekly_dues_quota_type_check check (quota_type in ('bags','weapons'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'weekly_dues_weapon_type_check') then
    alter table public.weekly_dues
      add constraint weekly_dues_weapon_type_check check (weapon_type is null or weapon_type in ('sns','vintage','pistol9'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'weekly_dues_required_weapons_check') then
    alter table public.weekly_dues
      add constraint weekly_dues_required_weapons_check check (required_weapons > 0);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'weekly_dues_payments_quota_type_check') then
    alter table public.weekly_dues_payments
      add constraint weekly_dues_payments_quota_type_check check (quota_type in ('bags','weapons'));
  end if;
  if not exists (select 1 from pg_constraint where conname = 'weekly_dues_payments_weapon_type_check') then
    alter table public.weekly_dues_payments
      add constraint weekly_dues_payments_weapon_type_check check (weapon_type is null or weapon_type in ('sns','vintage','pistol9'));
  end if;
end $$;

grant select, insert, update on table public.weekly_dues to authenticated;
grant select, insert, update, delete on table public.weekly_dues_payments to authenticated;
