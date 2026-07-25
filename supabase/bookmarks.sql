-- =============================================================================
-- bookmarks（保存機能）テーブル + RLS（冪等・再実行可）
-- 保存場所: supabase/bookmarks.sql
--
-- 「いいね」(post_likes) とは独立した「保存」機能。
-- 個人のお気に入りリストなので、post_likes と違って投稿者本人にも
-- 「誰が保存したか」は見せない（本人の行のみ read/write）。
-- =============================================================================

create table if not exists public.bookmarks (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  post_id    uuid not null references public.posts(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  unique (post_id, user_id)
);

create index if not exists bookmarks_user_idx on public.bookmarks (user_id, created_at desc);

alter table public.bookmarks enable row level security;

-- 匿名はテーブルへ直接触れない
revoke all on table public.bookmarks from anon;
revoke all on table public.bookmarks from public;

-- ログインユーザーのみ必要最小限
grant select, insert, delete on table public.bookmarks to authenticated;

-- 既存ポリシーを消してから作り直す（再実行可）
do $$
declare
  pol text;
begin
  for pol in
    select policyname from pg_policies
    where schemaname = 'public' and tablename = 'bookmarks'
  loop
    execute format('drop policy if exists %I on public.bookmarks', pol);
  end loop;
end $$;

-- 自分の保存行だけ読める（投稿者にも他人の保存は見せない）
create policy "bookmarks_select_own"
  on public.bookmarks
  for select
  to authenticated
  using (auth.uid() = user_id);

-- 保存追加は本人名義のみ
create policy "bookmarks_insert_own"
  on public.bookmarks
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- 保存解除は本人の行のみ
create policy "bookmarks_delete_own"
  on public.bookmarks
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- UPDATE は不要（ポリシー無し = 不可）
