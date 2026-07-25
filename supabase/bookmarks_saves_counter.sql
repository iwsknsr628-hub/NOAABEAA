-- =============================================================================
-- posts.saves（保存数の集計列）+ bookmarks 連動トリガー（冪等・再実行可）
-- 保存場所: supabase/bookmarks_saves_counter.sql
-- 前提: supabase/bookmarks.sql 適用済み（bookmarks テーブルが存在すること）
--
-- 目的: プロフィール画面の「保存数」実績を、他人の bookmarks 行を直接
-- SELECT させずに（bookmarks は本人のみ read/write）安全に集計表示するため、
-- posts.likes と同じ発想で posts.saves を持たせ、bookmarks の増減に
-- 合わせてトリガーで同期する。
-- =============================================================================

alter table public.posts add column if not exists saves integer not null default 0;

-- 既存の「クライアントによる likes/reports 直接改ざん防止」トリガー関数に
-- saves も同様に保護対象として追加する（core_rls.sql の定義を上書き）。
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
    new.saves := old.saves;
  end if;
  return new;
end;
$$;

-- bookmarks の増減に合わせて posts.saves を更新するトリガー関数。
-- security definer で posts_protect_sensitive の保護を正規の経路として通過する。
create or replace function public.bump_post_saves()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform set_config('nanshiyo.allow_counters', '1', true);
  if tg_op = 'INSERT' then
    update public.posts set saves = coalesce(saves, 0) + 1 where id = new.post_id;
    return new;
  elsif tg_op = 'DELETE' then
    update public.posts set saves = greatest(coalesce(saves, 0) - 1, 0) where id = old.post_id;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists bookmarks_after_insert_trg on public.bookmarks;
create trigger bookmarks_after_insert_trg
  after insert on public.bookmarks
  for each row execute function public.bump_post_saves();

drop trigger if exists bookmarks_after_delete_trg on public.bookmarks;
create trigger bookmarks_after_delete_trg
  after delete on public.bookmarks
  for each row execute function public.bump_post_saves();
