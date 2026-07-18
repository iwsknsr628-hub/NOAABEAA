# プロジェクト引き継ぎメモ（なんしよ？）

このファイルは、AI（Claude / Claude Code など）が作業する際に**最初に読むべき重要な前提**をまとめたものです。

## いちばん大事なこと（デプロイ方針の変更）

- **Netlify はもう使っていません。** 旧デプロイ先 `incandescent-pika-e1c426.netlify.app` はクレジット切れで停止しており、**今後は使いません**。
- **現在の公開方法は GitHub Pages です。** `main` ブランチに push すると自動でデプロイされます。
- したがって、**Netlify へのデプロイ操作（drag&drop / Netlify CLI / Netlify連携）は行わないでください。**

## プロジェクト概要

- サイト名: **なんしよ？ — みんなのおすすめが集まる場所**
- 実体: **単一の `index.html`**（CSS/JS すべてインライン、約2,100行）
- バックエンド: **Supabase**（認証・DB・ストレージ）
  - `SUPABASE_URL` と `SUPABASE_ANON_KEY`（publishable/公開キー）は `index.html` 内に記載。これはクライアント公開前提のキーで問題なし。
  - **service_role などの秘密キーは絶対にコード/リポジトリに入れないこと。**

## デプロイ手順（これが唯一の正しい方法）

```bash
# 1. index.html などを編集
# 2. コミット
git add -A
git commit -m "変更内容"
# 3. push（これで GitHub Pages が自動デプロイ。反映まで1〜3分）
git push origin main
```

## リポジトリ / URL

- GitHub リポジトリ: `iwsknsr628-hub/NOAABEAA`（Public）
- ホスティング: **GitHub Pages**（`main` ブランチ / ルート `/`）
- 公開URL（本番）: **https://nanshiyo.com**（独自ドメイン、Cloudflare で DNS 管理）
  - GitHub Pages 標準URL: https://iwsknsr628-hub.github.io/NOAABEAA/
  - ルートに `CNAME` ファイル（`nanshiyo.com`）があるため削除しないこと。
- 旧URL（使用禁止・非推奨）: ~~incandescent-pika-e1c426.netlify.app~~

## 今後の予定（参考）

- アプリ化: まず PWA 化、将来 Capacitor でストアアプリ化を検討
- 決済: サーバー処理が必要なため、**Supabase Edge Functions** で実装予定（GitHub Pages は静的のみでサーバー処理は持てない）
- セキュリティ: Supabase の RLS（行レベルセキュリティ）が有効かの確認が未実施。要チェック。
