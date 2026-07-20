-- =============================================================================
-- 緊急: photos 匿名アップロード封じ
-- 保存場所: supabase/photos_anon_lockdown.sql
--
-- Supabase SQL Editor でこのファイル全文を実行してください。
-- （データ行の DROP なし。storage.objects のポリシー作り直し）
-- 監査テスト画像の削除は Storage UI から（SQL DELETE は protect_delete で拒否される）
-- =============================================================================

insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do update set public = true;

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

do $$
declare
  pol text;
begin
  for pol in
    select policyname from pg_policies
    where schemaname = 'storage' and tablename = 'objects'
  loop
    execute format('drop policy if exists %I on storage.objects', pol);
  end loop;
end $$;

create policy "nanshiyo_photos_select_public"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'photos');

create policy "nanshiyo_photos_insert_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'photos'
    and auth.uid() is not null
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or name like auth.uid()::text || '/%'
      or name like auth.uid()::text || '-%'
    )
  );

create policy "nanshiyo_photos_update_own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'photos'
    and auth.uid() is not null
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or name like auth.uid()::text || '/%'
      or name like auth.uid()::text || '-%'
    )
  )
  with check (
    bucket_id = 'photos'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or name like auth.uid()::text || '/%'
      or name like auth.uid()::text || '-%'
    )
  );

create policy "nanshiyo_photos_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'photos'
    and auth.uid() is not null
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or name like auth.uid()::text || '/%'
      or name like auth.uid()::text || '-%'
    )
  );

create policy "nanshiyo_avatars_select_public"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'avatars');

create policy "nanshiyo_avatars_insert_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and auth.uid() is not null
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or name like auth.uid()::text || '/%'
      or name like auth.uid()::text || '-%'
    )
  );

create policy "nanshiyo_avatars_update_own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and auth.uid() is not null
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or name like auth.uid()::text || '/%'
      or name like auth.uid()::text || '-%'
    )
  )
  with check (
    bucket_id = 'avatars'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or name like auth.uid()::text || '/%'
      or name like auth.uid()::text || '-%'
    )
  );

create policy "nanshiyo_avatars_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'avatars'
    and auth.uid() is not null
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or name like auth.uid()::text || '/%'
      or name like auth.uid()::text || '-%'
    )
  );
