-- =============================================================================
-- post_likes の個人情報漏洩対策（冪等・再実行可）
-- 保存場所: supabase/post_likes_rls.sql
--
-- 問題: anon キーで post_likes を全件 SELECT でき、誰が何にいいねしたか追跡可能だった。
-- 方針:
--   - anon は一切不可（REVOKE + RLS）
--   - SELECT: 自分のいいね行、または「自分の投稿」へのいいね一覧のみ
--   - INSERT / DELETE: 本人の行のみ（いいねトグルを維持）
-- =============================================================================

alter table public.post_likes enable row level security;

-- 匿名はテーブルへ直接触れない
revoke all on table public.post_likes from anon;
revoke all on table public.post_likes from public;

-- ログインユーザーのみ必要最小限
grant select, insert, delete on table public.post_likes to authenticated;

-- 既存ポリシーを消してから作り直す（再実行可）
do $$
declare
  pol text;
begin
  for pol in
    select policyname from pg_policies
    where schemaname = 'public' and tablename = 'post_likes'
  loop
    execute format('drop policy if exists %I on public.post_likes', pol);
  end loop;
end $$;

-- 自分のいいね、または自分の投稿に付いたいいねだけ読める
create policy "post_likes_select_own_or_post_owner"
  on public.post_likes
  for select
  to authenticated
  using (
    auth.uid() = user_id
    or auth.uid() = (
      select p.user_id from public.posts p where p.id = post_likes.post_id
    )
  );

-- いいね追加は本人名義のみ
create policy "post_likes_insert_own"
  on public.post_likes
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- いいね取消は本人の行のみ
create policy "post_likes_delete_own"
  on public.post_likes
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- UPDATE は不要（ポリシー無し = 不可）
