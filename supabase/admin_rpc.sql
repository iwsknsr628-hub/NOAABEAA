-- =============================================================================
-- なんしよ？ 運営管理・権限まわり（冪等・再実行可）
-- 保存場所: supabase/admin_rpc.sql
--
-- 設計方針:
-- 1) banned / last_login_at / 登録日(created_at) は profiles 本体に置かず
--    profiles_admin に分離。anon/authenticated は直接 SELECT 不可（RLS・権限）。
-- 2) login_events は RLS 有効・ポリシー無し = 直接 read/write 不可。
--    書き込みは security definer の track_login() のみ。
-- 3) is_nanshiyo_admin() は JWT の email をサーバー側で判定（クライアント改ざん不可）。
-- 4) すべての admin_* / track_login / get_my_profile は SECURITY DEFINER で
--    冒頭（または内部）で権限チェックを行う。
-- =============================================================================

-- ---------- 運営メール判定（サーバー側 JWT） ----------
-- auth.jwt()->>'email' は Supabase Auth が発行したトークンのクレーム。
-- ブラウザからメール文字列を偽って渡すことはできない。
create or replace function public.is_nanshiyo_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) in (
    'syallman28@gmail.com',
    'iwsknsr628@gmail.com'
  );
$$;

revoke all on function public.is_nanshiyo_admin() from public;
grant execute on function public.is_nanshiyo_admin() to authenticated;

-- ---------- 運営専用プロフィール補助テーブル ----------
create table if not exists public.profiles_admin (
  user_id uuid primary key,
  banned boolean not null default false,
  last_login_at timestamptz,
  created_at timestamptz not null default now()
);

-- 既存 profiles から移行（列が残っている場合のみ）
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='profiles' and column_name='banned'
  ) then
    insert into public.profiles_admin (user_id, banned, last_login_at, created_at)
    select
      p.user_id,
      coalesce(p.banned, false),
      p.last_login_at,
      coalesce(p.created_at, now())
    from public.profiles p
    where p.user_id is not null
    on conflict (user_id) do update set
      banned = excluded.banned,
      last_login_at = coalesce(public.profiles_admin.last_login_at, excluded.last_login_at),
      created_at = least(public.profiles_admin.created_at, excluded.created_at);
  else
    insert into public.profiles_admin (user_id, created_at)
    select p.user_id, coalesce(p.updated_at, now())
    from public.profiles p
    where p.user_id is not null
    on conflict (user_id) do nothing;
  end if;
end $$;

-- 機密列を profiles から削除（公開テーブルに残さない）
alter table public.profiles drop column if exists banned;
alter table public.profiles drop column if exists last_login_at;
alter table public.profiles drop column if exists created_at;

-- profiles_admin: 直接アクセス禁止
alter table public.profiles_admin enable row level security;
revoke all on table public.profiles_admin from anon, authenticated;
-- オーナー（postgres）と security definer 関数のみ利用

-- 新規プロフィール作成時に admin 行も用意
create or replace function public.ensure_profiles_admin_row()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles_admin (user_id)
  values (new.user_id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_profiles_ensure_admin on public.profiles;
create trigger trg_profiles_ensure_admin
  after insert on public.profiles
  for each row execute function public.ensure_profiles_admin_row();

-- ---------- login_events: 直接アクセス禁止 ----------
create table if not exists public.login_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  created_at timestamptz not null default now()
);
create index if not exists login_events_created_at_idx on public.login_events (created_at desc);
create index if not exists login_events_user_id_idx on public.login_events (user_id);

alter table public.login_events enable row level security;
-- ポリシーを意図的に作らない = anon/authenticated は行を見られない
revoke all on table public.login_events from anon, authenticated;

-- 既存の緩いポリシーがあれば削除
do $$
declare pol record;
begin
  for pol in
    select policyname from pg_policies
    where schemaname='public' and tablename='login_events'
  loop
    execute format('drop policy if exists %I on public.login_events', pol.policyname);
  end loop;
end $$;

-- ---------- 自分のプロフィール（banned 含む） ----------
-- 公開 select=* では banned が取れないため、本人のみ RPC で取得
create or replace function public.get_my_profile()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  j jsonb;
begin
  if uid is null then
    return null;
  end if;
  select to_jsonb(p) || jsonb_build_object(
    'banned', coalesce(a.banned, false),
    'last_login_at', a.last_login_at,
    'created_at', a.created_at
  )
  into j
  from public.profiles p
  left join public.profiles_admin a on a.user_id = p.user_id
  where p.user_id = uid;
  return j;
end;
$$;

revoke all on function public.get_my_profile() from public;
grant execute on function public.get_my_profile() to authenticated;

-- ---------- ログイン計測（本人のみ・直接 INSERT 不可） ----------
create or replace function public.track_login()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  -- 認証済みユーザーのみ。anon から呼んでも auth.uid() が null で何もしない
  if uid is null then
    return;
  end if;
  insert into public.profiles_admin (user_id, last_login_at)
  values (uid, now())
  on conflict (user_id) do update set last_login_at = now();
  insert into public.login_events (user_id) values (uid);
end;
$$;

revoke all on function public.track_login() from public;
grant execute on function public.track_login() to authenticated;
-- anon には付与しない（以前付与していた場合は剥奪）
revoke execute on function public.track_login() from anon;

-- ---------- 運営: BAN ----------
create or replace function public.admin_set_banned(target uuid, is_banned boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_nanshiyo_admin() then
    raise exception 'admin only';
  end if;
  insert into public.profiles_admin (user_id, banned)
  values (target, coalesce(is_banned, false))
  on conflict (user_id) do update set banned = coalesce(is_banned, false);
end;
$$;

revoke all on function public.admin_set_banned(uuid, boolean) from public;
grant execute on function public.admin_set_banned(uuid, boolean) to authenticated;

-- ---------- 運営: 投稿削除 ----------
-- posts.id の型に合わせて uuid 想定。失敗時は型を確認すること。
create or replace function public.admin_delete_post(pid uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_nanshiyo_admin() then
    raise exception 'admin only';
  end if;
  delete from public.posts where id = pid;
end;
$$;

revoke all on function public.admin_delete_post(uuid) from public;
grant execute on function public.admin_delete_post(uuid) to authenticated;

-- ---------- 運営: お知らせ ----------
create or replace function public.admin_upsert_announcement(p_title text, p_body text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_nanshiyo_admin() then
    raise exception 'admin only';
  end if;
  insert into public.announcements (title, body) values (p_title, p_body);
end;
$$;

create or replace function public.admin_delete_announcement(aid uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_nanshiyo_admin() then
    raise exception 'admin only';
  end if;
  delete from public.announcements where id = aid;
end;
$$;

revoke all on function public.admin_upsert_announcement(text, text) from public;
revoke all on function public.admin_delete_announcement(uuid) from public;
grant execute on function public.admin_upsert_announcement(text, text) to authenticated;
grant execute on function public.admin_delete_announcement(uuid) to authenticated;

-- ---------- 運営: ユーザー一覧（機密列込み） ----------
create or replace function public.admin_list_profiles(q text default null)
returns table (
  user_id uuid,
  name text,
  handle text,
  updated_at timestamptz,
  created_at timestamptz,
  last_login_at timestamptz,
  banned boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  qq text := nullif(trim(both from coalesce(q, '')), '');
begin
  if not public.is_nanshiyo_admin() then
    raise exception 'admin only';
  end if;
  return query
  select
    p.user_id,
    p.name,
    p.handle,
    p.updated_at,
    a.created_at,
    a.last_login_at,
    coalesce(a.banned, false) as banned
  from public.profiles p
  left join public.profiles_admin a on a.user_id = p.user_id
  where qq is null
     or p.name ilike '%' || qq || '%'
     or p.handle ilike '%' || qq || '%'
  order by p.updated_at desc nulls last
  limit 200;
end;
$$;

revoke all on function public.admin_list_profiles(text) from public;
grant execute on function public.admin_list_profiles(text) to authenticated;

-- ---------- 運営: ダッシュボード集計 ----------
create or replace function public.admin_dashboard_bundle(since_iso timestamptz)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  result jsonb;
begin
  if not public.is_nanshiyo_admin() then
    raise exception 'admin only';
  end if;

  select jsonb_build_object(
    'counts', jsonb_build_object(
      'users', (select count(*)::int from public.profiles),
      'posts', (select count(*)::int from public.posts),
      'comments', (select count(*)::int from public.comments),
      'likes', (select count(*)::int from public.post_likes),
      'banned', (select count(*)::int from public.profiles_admin where banned = true),
      'logins_today', (
        select count(*)::int from public.login_events
        where created_at >= date_trunc('day', now() at time zone 'Asia/Tokyo')
          at time zone 'Asia/Tokyo'
      )
    ),
    'registrations', coalesce((
      select jsonb_agg(jsonb_build_object('d', d, 'n', n) order by d)
      from (
        select (a.created_at at time zone 'Asia/Tokyo')::date::text as d, count(*)::int as n
        from public.profiles_admin a
        where a.created_at >= since_iso
        group by 1
      ) t
    ), '[]'::jsonb),
    'logins', coalesce((
      select jsonb_agg(jsonb_build_object('d', d, 'n', n) order by d)
      from (
        select (e.created_at at time zone 'Asia/Tokyo')::date::text as d, count(*)::int as n
        from public.login_events e
        where e.created_at >= since_iso
        group by 1
      ) t
    ), '[]'::jsonb),
    'posts', coalesce((
      select jsonb_agg(jsonb_build_object('d', d, 'n', n) order by d)
      from (
        select (p.created_at at time zone 'Asia/Tokyo')::date::text as d, count(*)::int as n
        from public.posts p
        where p.created_at >= since_iso
        group by 1
      ) t
    ), '[]'::jsonb),
    'cats', coalesce((
      select jsonb_object_agg(cat, n)
      from (
        select coalesce(p.cat, 'unknown') as cat, count(*)::int as n
        from public.posts p
        where p.created_at >= since_iso
        group by 1
      ) t
    ), '{}'::jsonb)
  ) into result;

  return result;
end;
$$;

revoke all on function public.admin_dashboard_bundle(timestamptz) from public;
grant execute on function public.admin_dashboard_bundle(timestamptz) to authenticated;
