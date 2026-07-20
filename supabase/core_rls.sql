-- =============================================================================
-- コアテーブル RLS（冪等・再実行可）
-- 保存場所: supabase/core_rls.sql
--
-- 方針:
--   - SELECT は公開（コミュニティ閲覧を維持）
--   - INSERT/UPDATE/DELETE は本人のみ（auth.uid()）
--   - announcements の書き込みは admin_* RPC（security definer）のみ
--   - posts の user_id / likes / reports はクライアントから書き換え不可
-- =============================================================================

-- ---------- ヘルパー: 既存ポリシーを全部落とす ----------
create or replace function public._nanshiyo_drop_policies(p_table text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  pol text;
begin
  for pol in
    select policyname from pg_policies
    where schemaname = 'public' and tablename = p_table
  loop
    execute format('drop policy if exists %I on public.%I', pol, p_table);
  end loop;
end;
$$;

revoke all on function public._nanshiyo_drop_policies(text) from public;

-- =============================================================================
-- posts
-- =============================================================================
alter table public.posts enable row level security;

revoke all on table public.posts from anon;
revoke all on table public.posts from public;
grant select on table public.posts to anon, authenticated;
grant insert, update, delete on table public.posts to authenticated;

select public._nanshiyo_drop_policies('posts');

create policy "posts_select_all"
  on public.posts for select
  to anon, authenticated
  using (true);

create policy "posts_insert_own"
  on public.posts for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "posts_update_own"
  on public.posts for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "posts_delete_own"
  on public.posts for delete
  to authenticated
  using (auth.uid() = user_id);

-- 所有権・カウンタ保護（クライアント PATCH 対策）
-- report_post / 将来の likes 同期は set_config('nanshiyo.allow_counters','1',true) 後に更新
create or replace function public.posts_protect_sensitive()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.user_id := old.user_id;
  if current_setting('nanshiyo.allow_counters', true) is distinct from '1' then
    new.likes := old.likes;
    new.reports := old.reports;
  end if;
  return new;
end;
$$;

drop trigger if exists posts_protect_sensitive_trg on public.posts;
create trigger posts_protect_sensitive_trg
  before update on public.posts
  for each row execute function public.posts_protect_sensitive();

-- =============================================================================
-- comments
-- =============================================================================
alter table public.comments enable row level security;

revoke all on table public.comments from anon;
revoke all on table public.comments from public;
grant select on table public.comments to anon, authenticated;
grant insert, delete on table public.comments to authenticated;

select public._nanshiyo_drop_policies('comments');

create policy "comments_select_all"
  on public.comments for select
  to anon, authenticated
  using (true);

create policy "comments_insert_own"
  on public.comments for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "comments_delete_own"
  on public.comments for delete
  to authenticated
  using (auth.uid() = user_id);

-- =============================================================================
-- profiles
-- =============================================================================
alter table public.profiles enable row level security;

revoke all on table public.profiles from anon;
revoke all on table public.profiles from public;
grant select on table public.profiles to anon, authenticated;
grant insert, update, delete on table public.profiles to authenticated;

select public._nanshiyo_drop_policies('profiles');

create policy "profiles_select_all"
  on public.profiles for select
  to anon, authenticated
  using (true);

create policy "profiles_insert_own"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "profiles_update_own"
  on public.profiles for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "profiles_delete_own"
  on public.profiles for delete
  to authenticated
  using (auth.uid() = user_id);

-- =============================================================================
-- follows
-- =============================================================================
alter table public.follows enable row level security;

revoke all on table public.follows from anon;
revoke all on table public.follows from public;
grant select on table public.follows to anon, authenticated;
grant insert, update, delete on table public.follows to authenticated;

select public._nanshiyo_drop_policies('follows');

create policy "follows_select_all"
  on public.follows for select
  to anon, authenticated
  using (true);

create policy "follows_insert_own"
  on public.follows for insert
  to authenticated
  with check (auth.uid() = follower_id);

create policy "follows_update_own"
  on public.follows for update
  to authenticated
  using (auth.uid() = follower_id)
  with check (auth.uid() = follower_id);

create policy "follows_delete_own"
  on public.follows for delete
  to authenticated
  using (auth.uid() = follower_id);

-- =============================================================================
-- announcements（閲覧のみ。書き込みは admin_* RPC）
-- =============================================================================
alter table public.announcements enable row level security;

revoke all on table public.announcements from anon;
revoke all on table public.announcements from public;
grant select on table public.announcements to anon, authenticated;
-- INSERT/UPDATE/DELETE は一般ロールに付与しない（admin RPC が security definer で実施）

select public._nanshiyo_drop_policies('announcements');

create policy "announcements_select_all"
  on public.announcements for select
  to anon, authenticated
  using (true);

-- =============================================================================
-- report_post RPC（ログイン必須・通報カウンタは保護トリガーを一時解除）
-- =============================================================================
create or replace function public.report_post(pid uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'login required';
  end if;
  if pid is null then
    raise exception 'invalid post';
  end if;
  perform set_config('nanshiyo.allow_counters', '1', true);
  update public.posts
    set reports = coalesce(reports, 0) + 1
  where id = pid;
end;
$$;

revoke all on function public.report_post(uuid) from public;
revoke all on function public.report_post(uuid) from anon;
grant execute on function public.report_post(uuid) to authenticated;
