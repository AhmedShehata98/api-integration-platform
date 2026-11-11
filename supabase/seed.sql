-- Dev seed data. Runs after migrations on `supabase db reset`.
-- Workspaces are created per user by the on_auth_user_created trigger, so this
-- seeds one email/password dev user whose default workspace gets sample data.
-- Dev login: dev@testpoint.local / password123

insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, email_change, email_change_token_new, recovery_token
) values (
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-1111-1111-111111111111',
    'authenticated', 'authenticated', 'dev@testpoint.local',
    extensions.crypt('password123', extensions.gen_salt('bf')), now(),
    '{"provider":"email","providers":["email"]}', '{}', now(), now(),
    '', '', '', ''
);

insert into auth.identities (
    id, user_id, provider_id, identity_data, provider, created_at, updated_at, last_sign_in_at
) values (
    gen_random_uuid(),
    '11111111-1111-1111-1111-111111111111',
    '11111111-1111-1111-1111-111111111111',
    '{"sub":"11111111-1111-1111-1111-111111111111","email":"dev@testpoint.local"}',
    'email', now(), now(), now()
);

with ws as (
    select w.id
    from public.workspaces w
    join public.organization_members m on m.organization_id = w.organization_id
    where m.user_id = '11111111-1111-1111-1111-111111111111'
    limit 1
), col as (
    insert into public.collections (workspace_id, name, position)
    select id, 'Sample API', 0 from ws
    returning id
), env as (
    insert into public.environments (workspace_id, name, variables)
    select id, 'Local',
        '[{"key":"baseUrl","value":"https://httpbin.org","secret":false,"enabled":true}]'::jsonb
    from ws
    returning id
)
insert into public.requests (collection_id, name, method, url, position)
select id, 'Get anything', 'GET', '{{baseUrl}}/anything', 0 from col;
