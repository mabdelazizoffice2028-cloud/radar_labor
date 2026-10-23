-- Radar Labour cloud identity and row-level access baseline.
-- Apply only after reviewing against the target Supabase project's schemas.
-- Public signup must remain disabled; profile roles are never taken from
-- user_metadata. New Auth users receive an inactive viewer profile.

create schema if not exists attendance;

create table if not exists attendance.users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  role text not null default 'viewer'
    check (role in ('admin', 'hr', 'housing_supervisor', 'site_supervisor', 'viewer')),
  active boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists attendance.teams (
  team_id uuid primary key default gen_random_uuid(),
  name text not null,
  active boolean not null default true
);

create table if not exists attendance.housings (
  housing_id uuid primary key default gen_random_uuid(),
  name text not null,
  active boolean not null default true
);

create table if not exists attendance.user_scopes (
  user_id uuid not null references attendance.users(user_id) on delete cascade,
  scope_type text not null check (scope_type in ('team', 'housing')),
  scope_id uuid not null,
  primary key (user_id, scope_type, scope_id)
);

create table if not exists attendance.employees (
  employee_uid uuid primary key default gen_random_uuid(),
  employee_code text not null unique,
  full_name text not null,
  team_id uuid references attendance.teams(team_id),
  housing_id uuid references attendance.housings(housing_id),
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

create table if not exists attendance.events (
  event_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references attendance.users(user_id),
  event_type text not null,
  business_date date not null,
  employee_uid uuid references attendance.employees(employee_uid),
  team_id uuid references attendance.teams(team_id),
  housing_id uuid references attendance.housings(housing_id),
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  check (team_id is not null or housing_id is not null)
);

create index if not exists attendance_events_date_idx
  on attendance.events (business_date, created_at);
create index if not exists attendance_events_team_idx
  on attendance.events (team_id, business_date);
create index if not exists attendance_events_housing_idx
  on attendance.events (housing_id, business_date);
create index if not exists attendance_scopes_scope_idx
  on attendance.user_scopes (scope_type, scope_id);

create or replace function attendance.current_role()
returns text
language sql stable security definer
set search_path = ''
as $$
  select u.role from attendance.users u
  where u.user_id = (select auth.uid()) and u.active
$$;

create or replace function attendance.is_admin()
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select coalesce(attendance.current_role() in ('admin', 'hr'), false)
$$;

create or replace function attendance.has_scope(requested_type text, requested_id uuid)
returns boolean
language sql stable security definer
set search_path = ''
as $$
  select exists (
    select 1 from attendance.user_scopes s
    where s.user_id = (select auth.uid())
      and s.scope_type = requested_type
      and s.scope_id = requested_id
  )
$$;

create or replace function attendance.create_inactive_profile()
returns trigger
language plpgsql security definer
set search_path = ''
as $$
begin
  insert into attendance.users (user_id, display_name, role, active)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', ''),
    'viewer',
    false
  ) on conflict (user_id) do nothing;
  return new;
end
$$;

drop trigger if exists radar_labor_profile_on_auth_user on auth.users;
create trigger radar_labor_profile_on_auth_user
  after insert on auth.users
  for each row execute function attendance.create_inactive_profile();

alter table attendance.users enable row level security;
alter table attendance.teams enable row level security;
alter table attendance.housings enable row level security;
alter table attendance.user_scopes enable row level security;
alter table attendance.employees enable row level security;
alter table attendance.events enable row level security;

create policy users_read_self_or_admin on attendance.users
  for select to authenticated
  using (user_id = (select auth.uid()) or attendance.is_admin());
create policy users_admin_update on attendance.users
  for update to authenticated
  using (attendance.is_admin())
  with check (attendance.is_admin());

create policy scopes_read_self_or_admin on attendance.user_scopes
  for select to authenticated
  using (user_id = (select auth.uid()) or attendance.is_admin());
create policy scopes_admin_manage on attendance.user_scopes
  for all to authenticated
  using (attendance.is_admin())
  with check (attendance.is_admin());

create policy teams_read_scoped_or_admin_or_viewer on attendance.teams
  for select to authenticated
  using (
    attendance.is_admin()
    or attendance.current_role() = 'viewer'
    or attendance.has_scope('team', team_id)
  );
create policy teams_admin_manage on attendance.teams
  for all to authenticated
  using (attendance.is_admin())
  with check (attendance.is_admin());

create policy housings_read_scoped_or_admin_or_viewer on attendance.housings
  for select to authenticated
  using (
    attendance.is_admin()
    or attendance.current_role() = 'viewer'
    or attendance.has_scope('housing', housing_id)
  );
create policy housings_admin_manage on attendance.housings
  for all to authenticated
  using (attendance.is_admin())
  with check (attendance.is_admin());

create policy employees_read_by_role_scope on attendance.employees
  for select to authenticated
  using (
    attendance.is_admin()
    or attendance.current_role() = 'viewer'
    or (attendance.current_role() = 'site_supervisor'
        and team_id is not null and attendance.has_scope('team', team_id))
    or (attendance.current_role() = 'housing_supervisor'
        and housing_id is not null and attendance.has_scope('housing', housing_id))
  );
create policy employees_admin_manage on attendance.employees
  for all to authenticated
  using (attendance.is_admin())
  with check (attendance.is_admin());

create policy events_read_by_role_scope on attendance.events
  for select to authenticated
  using (
    attendance.is_admin()
    or attendance.current_role() = 'viewer'
    or (attendance.current_role() = 'site_supervisor'
        and team_id is not null and attendance.has_scope('team', team_id))
    or (attendance.current_role() = 'housing_supervisor'
        and housing_id is not null and attendance.has_scope('housing', housing_id))
  );
create policy events_insert_by_role_scope on attendance.events
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and (
      attendance.is_admin()
      or (attendance.current_role() = 'site_supervisor'
          and team_id is not null and housing_id is null
          and attendance.has_scope('team', team_id))
      or (attendance.current_role() = 'housing_supervisor'
          and housing_id is not null and team_id is null
          and attendance.has_scope('housing', housing_id))
    )
    and (
      employee_uid is null
      or exists (
        select 1 from attendance.employees e
        where e.employee_uid = events.employee_uid
          and ((events.team_id is not null and e.team_id = events.team_id)
            or (events.housing_id is not null and e.housing_id = events.housing_id))
      )
    )
  );
create policy events_admin_update on attendance.events
  for update to authenticated
  using (attendance.is_admin())
  with check (attendance.is_admin());

grant usage on schema attendance to authenticated;
grant select, update on attendance.users to authenticated;
grant select, insert, update, delete on attendance.user_scopes to authenticated;
grant select, insert, update, delete on attendance.teams to authenticated;
grant select, insert, update, delete on attendance.housings to authenticated;
grant select, insert, update, delete on attendance.employees to authenticated;
grant select, insert, update on attendance.events to authenticated;

-- Provision the first admin out of band in the SQL editor using its auth.users
-- UUID. Never expose a service-role key to the Flutter client.
