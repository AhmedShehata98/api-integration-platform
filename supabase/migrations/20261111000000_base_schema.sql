-- Base schema for Test Point (see docs/data_model.md and docs/IMPLEMENTATION_PLAN.md §4).

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table public.users (
    id uuid primary key references auth.users (id) on delete cascade,
    email varchar(255) unique, -- null for anonymous (guest) users
    name varchar(255),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.organizations (
    id uuid primary key default gen_random_uuid(),
    name varchar(255) not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.organization_members (
    organization_id uuid not null references public.organizations (id) on delete cascade,
    user_id uuid not null references public.users (id) on delete cascade,
    role varchar(50) not null default 'member',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    primary key (organization_id, user_id)
);

create table public.workspaces (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations (id) on delete cascade,
    name varchar(255) not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- variables: [{ "key": "", "value": "", "secret": false, "enabled": true }]
create table public.environments (
    id uuid primary key default gen_random_uuid(),
    workspace_id uuid not null references public.workspaces (id) on delete cascade,
    name varchar(255) not null,
    variables jsonb not null default '[]'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.collections (
    id uuid primary key default gen_random_uuid(),
    workspace_id uuid not null references public.workspaces (id) on delete cascade,
    name varchar(255) not null,
    position int not null default 0,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.requests (
    id uuid primary key default gen_random_uuid(),
    collection_id uuid not null references public.collections (id) on delete cascade,
    name varchar(255) not null,
    method varchar(10) not null default 'GET',
    url text not null default '',
    params jsonb not null default '[]'::jsonb,
    headers jsonb not null default '[]'::jsonb,
    auth jsonb not null default '{"type": "none"}'::jsonb,
    body_type varchar(30) not null default 'none',
    body text,
    position int not null default 0,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index workspaces_organization_id_idx on public.workspaces (organization_id);
create index environments_workspace_id_idx on public.environments (workspace_id);
create index collections_workspace_id_idx on public.collections (workspace_id);
create index requests_collection_id_idx on public.requests (collection_id);
create index organization_members_user_id_idx on public.organization_members (user_id);

-- ---------------------------------------------------------------------------
-- updated_at maintenance
-- ---------------------------------------------------------------------------

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create trigger set_updated_at before update on public.users
    for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.organizations
    for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.organization_members
    for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.workspaces
    for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.environments
    for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.collections
    for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.requests
    for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Membership helpers (security definer so policies do not recurse through RLS)
-- ---------------------------------------------------------------------------

create function public.is_org_member(org_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
        from public.organization_members m
        where m.organization_id = org_id
          and m.user_id = (select auth.uid())
    );
$$;

create function public.is_workspace_member(ws_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
        from public.workspaces w
        join public.organization_members m on m.organization_id = w.organization_id
        where w.id = ws_id
          and m.user_id = (select auth.uid())
    );
$$;

create function public.is_collection_member(col_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
        from public.collections c
        join public.workspaces w on w.id = c.workspace_id
        join public.organization_members m on m.organization_id = w.organization_id
        where c.id = col_id
          and m.user_id = (select auth.uid())
    );
$$;

revoke all on function public.is_org_member(uuid) from public, anon;
revoke all on function public.is_workspace_member(uuid) from public, anon;
revoke all on function public.is_collection_member(uuid) from public, anon;
grant execute on function public.is_org_member(uuid) to authenticated;
grant execute on function public.is_workspace_member(uuid) to authenticated;
grant execute on function public.is_collection_member(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- Anonymous (guest) users also use the `authenticated` role.
-- users / organizations / organization_members are written only by triggers.
-- ---------------------------------------------------------------------------

alter table public.users enable row level security;
alter table public.organizations enable row level security;
alter table public.organization_members enable row level security;
alter table public.workspaces enable row level security;
alter table public.environments enable row level security;
alter table public.collections enable row level security;
alter table public.requests enable row level security;

create policy users_select_own on public.users
    for select to authenticated
    using (id = (select auth.uid()));

create policy users_update_own on public.users
    for update to authenticated
    using (id = (select auth.uid()))
    with check (id = (select auth.uid()));

create policy organizations_select_member on public.organizations
    for select to authenticated
    using (public.is_org_member(id));

create policy organizations_update_member on public.organizations
    for update to authenticated
    using (public.is_org_member(id))
    with check (public.is_org_member(id));

create policy organization_members_select_member on public.organization_members
    for select to authenticated
    using (public.is_org_member(organization_id));

create policy workspaces_all_member on public.workspaces
    for all to authenticated
    using (public.is_org_member(organization_id))
    with check (public.is_org_member(organization_id));

create policy environments_all_member on public.environments
    for all to authenticated
    using (public.is_workspace_member(workspace_id))
    with check (public.is_workspace_member(workspace_id));

create policy collections_all_member on public.collections
    for all to authenticated
    using (public.is_workspace_member(workspace_id))
    with check (public.is_workspace_member(workspace_id));

create policy requests_all_member on public.requests
    for all to authenticated
    using (public.is_collection_member(collection_id))
    with check (public.is_collection_member(collection_id));

-- ---------------------------------------------------------------------------
-- Auth triggers (D4, D7)
-- ---------------------------------------------------------------------------

-- First sign-in (including anonymous): create the profile, a personal
-- organization, the owner membership and a default workspace.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    org_id uuid;
begin
    insert into public.users (id, email)
    values (new.id, nullif(new.email, ''));

    insert into public.organizations (name)
    values ('Personal')
    returning id into org_id;

    insert into public.organization_members (organization_id, user_id, role)
    values (org_id, new.id, 'owner');

    insert into public.workspaces (organization_id, name)
    values (org_id, 'My Workspace');

    return new;
end;
$$;

create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- Guest signs up: copy the new email into the profile.
create function public.handle_user_updated()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    update public.users
    set email = nullif(new.email, '')
    where id = new.id;

    return new;
end;
$$;

create trigger on_auth_user_updated
    after update of email on auth.users
    for each row
    when (old.email is distinct from new.email)
    execute function public.handle_user_updated();
