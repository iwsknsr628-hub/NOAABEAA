-- =============================================================================
-- Storage ポリシー（photos / avatars）冪等・再実行可
-- 保存場所: supabase/storage_policies.sql
--
-- 方針:
--   - 公開 READ 維持（既存の public URL 表示）
--   - INSERT は authenticated のみ、オブジェクト名が `{uid}/...` または `{uid}-...`
--   - UPDATE/DELETE は本人パスのみ
-- 緊急適用は supabase/photos_anon_lockdown.sql（同内容＋明示）も可
-- =============================================================================

-- 監査テスト画像は Storage UI から削除すること
-- （SQL の DELETE FROM storage.objects は protect_delete で拒否される）

-- バケットが無ければ作成（public）
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do update set public = true;

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

-- storage.objects の全ポリシーを落として作り直し
-- （「全バケット許可」など名前に photos が無い緩いポリシーが残ると OR で穴が開く）
-- ※ このプロジェクトのバケットは photos / avatars のみ想定
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

-- ---------- photos ----------
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

-- ---------- avatars ----------
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
