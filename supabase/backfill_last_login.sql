-- 過去の login_events から profiles_admin.last_login_at を反映（冪等）
-- profiles 本体には機密列を追加しない

insert into public.profiles_admin (user_id, last_login_at)
select e.user_id, max(e.created_at)
from public.login_events e
where e.user_id is not null
group by e.user_id
on conflict (user_id) do update set
  last_login_at = greatest(
    coalesce(public.profiles_admin.last_login_at, '-infinity'::timestamptz),
    excluded.last_login_at
  );
