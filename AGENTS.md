# AGENTS.md — なんしよ？ プロジェクト共通指示（唯一の正）

このファイルは **Cursor / Claude Code / その他AIエージェント全員が最初に読む共通の前提**です。
内容が古くなったら、作業したAIが**このファイルを必ず更新**してから終わること。

## 最重要：デプロイ方針

- **Netlify は使用禁止。** 旧URL `incandescent-pika-e1c426.netlify.app` はクレジット切れで停止済み。Netlify への drag&drop / CLI / 連携は**行わない**。
- **公開は GitHub Pages のみ。** `main` に push すると自動デプロイ（反映1〜3分）。

## デプロイ手順（唯一の正しい方法）

```bash
git add -A
git commit -m "変更内容"
git push origin main   # → GitHub Pages が自動デプロイ
```

## プロジェクト概要

- サイト: **なんしよ？ — みんなのおすすめが集まる場所**
- 実体: 単一の `index.html`（CSS/JS インライン）
- バックエンド: **Supabase**（認証・DB・ストレージ）
  - `SUPABASE_URL` / `SUPABASE_ANON_KEY`（公開キー）は `index.html` 内。公開前提のキーで問題なし。
  - **service_role 等の秘密キーは絶対にコード/リポジトリに入れない。**

## リポジトリ / URL

- リポジトリ: `iwsknsr628-hub/NOAABEAA`（Public）
- ホスティング: GitHub Pages（`main` / ルート `/`）
- 本番URL: **https://nanshiyo.com**（Cloudflare で DNS 管理。ルートの `CNAME` ファイルは削除しない）
- 予備URL: https://iwsknsr628-hub.github.io/NOAABEAA/
- ローカル作業フォルダ: `C:\Users\iwskn\Projects\nanshiyo`

## 作業ルール

1. 変更は必ず**このプロジェクト（=GitHub）側の `index.html`** を編集する。Claudeアプリの旧サンドボックス内ファイルは使わない。
2. セットアップ/デプロイ/URL/バックエンドに変更があったら、**この AGENTS.md を更新**する。
3. 変更を push したら、ユーザーに「本番へ自動反映される」旨を伝える。

## 今後の予定（参考）

- アプリ化: PWA → 将来 Capacitor でストアアプリ
- 決済: **Supabase Edge Functions** で実装予定（GitHub Pages は静的のみ）
- 未実施: Supabase の RLS（行レベルセキュリティ）確認
