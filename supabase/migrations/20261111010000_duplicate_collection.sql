-- Duplicate a collection together with its requests in one atomic call.
-- Runs as the caller (security invoker), so Row Level Security still decides
-- what can be read and inserted.

create function public.duplicate_collection(source_id uuid, new_name text)
returns public.collections
language plpgsql
set search_path = ''
as $$
declare
    source public.collections;
    copy public.collections;
begin
    select * into source from public.collections where id = source_id;
    if not found then
        raise exception 'Collection not found' using errcode = 'P0002';
    end if;

    insert into public.collections (workspace_id, name, position)
    values (
        source.workspace_id,
        new_name,
        (select coalesce(max(c.position), -1) + 1
         from public.collections c
         where c.workspace_id = source.workspace_id)
    )
    returning * into copy;

    insert into public.requests (
        collection_id, name, method, url, params, headers, auth, body_type, body, position
    )
    select copy.id, r.name, r.method, r.url, r.params, r.headers, r.auth, r.body_type, r.body, r.position
    from public.requests r
    where r.collection_id = source_id;

    return copy;
end;
$$;

revoke all on function public.duplicate_collection(uuid, text) from public, anon;
grant execute on function public.duplicate_collection(uuid, text) to authenticated;
