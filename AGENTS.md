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

### 補足: Claude（Cowork）からの制約

- Claude（Cowork）はこのフォルダのファイルを直接読み書きできるが、実行環境（サンドボックス）から `github.com` へのネットワークアクセスができないため、**`git push` を代行できない**。
- そのためClaudeが編集した後は、ユーザー自身に以下を実行してもらう必要がある:
  ```bash
  git add -A
  git commit -m "変更内容"
  git push origin main
  ```
- Claudeは毎回の変更後、上記コマンドを案内すること。

## 収益化（アフィリエイト＆広告）

`index.html` 冒頭の定数に各IDを入れるだけで有効化。**空でも壊れない**（通常リンク/枠非表示で動作）。公開前提のIDなので直書きOK。

- `RAKUTEN_AFFILIATE_ID` … 楽天アフィリエイト（`affiliate.rakuten.co.jp`・審査なし/即時）。入れると全楽天リンクが成果報酬化。形式 `https://hb.afl.rakuten.co.jp/hgc/{ID}/?pc={enc}&m={enc}`。
- `AMAZON_ASSOCIATE_TAG` … Amazonアソシエイト（要審査）。例 `yourtag-22`。`amazonSearch()` の `&tag=` に付与。
- `ADSENSE_CLIENT` / `ADSENSE_SLOT` … Google AdSense（要審査）。入れると投稿一覧に6件ごとに広告枠を表示（`adSlotHTML()`/`activateAds()`、スクリプトは動的読み込み）。
  - ※AdSense審査時はサイト所有確認用スニペットを `<head>` に貼る必要が出る場合あり。

送客ボタン: `affButtonsHTML()`。travel → 楽天トラベル(宿)＋楽天市場、その他 → 楽天市場＋Amazon。投稿カードとガチャ結果に表示。`PR` ラベル＋`rel="sponsored"` 付与済み（規約・景表法対策）。

- 今後の候補: A8.net/もしも/バリューコマース（個別リンク）、金融系（楽天カード/証券=高単価）。

## Google Maps / Places

- `const GOOGLE_MAPS_KEY` に参照元制限付きキーを設定済み。**Places API (New) が有効**である必要あり。
- 検索は Google Places 優先 → OSM(Nominatim+Photon) フォールバック。
- 課金対策: Places API (New) の1日ハードキャップはGoogle仕様で不可。代わりに **予算アラート（月¥1,000）** を設定済み。現在は無料トライアル（クレジット/90日、超過時は自動停止・自動課金なし）。

## 今後の予定（参考）

- アプリ化: PWA → 将来 Capacitor でストアアプリ
- 決済: **Supabase Edge Functions** で実装予定（GitHub Pages は静的のみ）
- 未実施: Supabase の RLS（行レベルセキュリティ）確認
