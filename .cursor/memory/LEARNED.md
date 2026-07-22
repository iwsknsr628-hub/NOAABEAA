# 学習メモ（なんしよ？）— 常に成長

エージェントが会話・実装から拾った**プロダクト／運用判断**の置き場。
- **消さない。** 訂正するときは古い行を残し、下に「訂正: …」を足す。
- **毎回成長させる。** 作業終了時に「今回決まったこと／思い出した過去判断」を追記する。
- セットアップ／デプロイ／URL／バックエンドの手順の「正」は `AGENTS.md`（ここは判断・方針・やってはいけないことの要約）。

最終更新: 2026-07-21

---

## 成長ルール（エージェント向け）

1. 作業開始: このファイル＋`AGENTS.md` を読む。
2. ユーザーが方針を言ったら／バグ修正で方針が固まったら、**同じターンでここへ追記**。
3. 過去チャットで言及されていたのに未記載の判断を見つけたら、**遡って追記**（「過去判断」と日付メモ可）。
4. `AGENTS.md` と矛盾したら **AGENTS を直し、ここにも訂正を書く**。

---

## デプロイ・リポジトリ（過去〜現在）

- 当初 Netlify。クレジット切れで停止 → **GitHub Pages のみ**に移行。Netlify への再デプロイは禁止。
- 本番: **https://nanshiyo.com**（Cloudflare DNS）。リポジトリ直下 `CNAME` は削除しない。
- 予備: `https://iwsknsr628-hub.github.io/NOAABEAA/`
- 公開手順は `main` への通常 push のみ（force push しない）。
- コードの正は `C:\Users\iwskn\Projects\nanshiyo`。Claude 旧サンドボックスのファイルは使わない・信用しない。
- Claude（Cowork）は `git push` できない → ユーザーに commit/push コマンドを案内する。
- Cursor ↔ Claude 連携: 変更後は **Claudeアプリ用コピペ共有文を必ず出す**（「強制的に連携・共有」）。

## プロダクト方針（全体）

- サイト名「なんしよ？」— みんなのおすすめが集まる場所。
- 実体は主に単一 `index.html`（＋運営用 `admin.html`）。静的ホスト前提。
- 将来: PWA → Capacitor でストア。決済は Supabase Edge Functions（Pages は静的のみ）。
- 未ログインは**閲覧・検索OK**。投稿・いいね・コメント投稿・フォロー・通報・通知は要ログイン。
- 危険操作（DROP/一括DELETE/force push/秘密鍵コミット等）はユーザーの明確な承認なしにやらない（憲法）。

## UI / UX（壊さない前提）

- **下部タブバー**: ホーム／さがす／投稿／通知／マイページ（ログインで切替）。旧ヘッダー「＋投稿」は廃止。
- **投稿詳細**はポップアップ。**プロフィール**は全画面ページ（著者タップ）。
- 投稿詳細の閉じ方: ✕ボタン、背景タップ、**左→右スワイプ**（縦スクロールと干渉しないよう横確定時のみ）。
- **写真ライトボックス**: ピンチ／ホイール／ダブルタップで拡大必須（`lbScale`）。スワイプ切替・下スワイプ閉じも維持。
- **トプ画（プロフィール画像）タップ**: `setAvatarEl` + `openAvatarView` で丸くライトボックス表示。`#mpAvatar` / `#pvAvatar`。消さない。
- **過去の事故**: `3de957c`（ピン住所の番地補完）でライトボックス拡大・トプ画表示が誤って削除された。住所変更時に lightbox／avatar ブロックを触らない。
- **デザインは1系統のみ**（コーラル／ネイビー等）。classic テーマ・テーマ切替UIは**廃止済み・復活させない**。
- 設定: マイページ三本線 → 右ドロワー → 全画面パネル。プロフィール編集はペンアイコン。
- パスワード変更は**現在のパスワード必須**。
- ガチャに都道府県セレクトあり。県の「指定なし」表記（「任意」に戻さない）。
- ヒーロー検索: モバイルはコンパクト（アイコン検索など）。ゲストでも検索・閲覧可と明示。
- 地図アプリ優先は設定の「地図アプリ」で選択（Google / Yahoo / Apple）。カード／詳細の地図ボタン順に反映。

## 共有（Share）

- 投稿カード・詳細・他ユーザープロフィール・マイページに**共有ボタン必須**。消さない・「後で」にしない。
- `navigator.share`、不可時はリンクコピー。
- ディープリンク: `?post=<id>` / `?u=<user_id>`。起動時 `restoreDeepLinksFromUrl()`（post 優先）。
- プロフィール再読み込みでホームに戻さない（`?u=` 維持）。別実装の `?user=` に戻さない（現行は `u`）。

## PR / アフィリエイト

- 運営の自動PRは**全部に出さない**（`AFF_AUTO_CATS` のみ）。
- **food / drink は自動PRなし**（ご飯屋・呑み屋に PR は意味がない、という明示判断）。
- 旅行「宿・ホテル」: **県だけ検索は禁止**。**スポット名＋県**で楽天トラベル（投稿の宿の予約に近づけたい）。
- 通販系: 検索語は投稿のスポット／ジャンル優先。
- 投稿者 `aff_url` があればそれだけ（運営リンクは出さない）。`PR` ラベル＋`rel=sponsored`。
- 楽天トラベル URL に **`charset=utf-8` 必須**（無いと文字化け・0件）。
- 広告枠: `DIRECT_ADS` 優先、なければ AdSense。両方空なら枠なし。

## 地図・位置

- Places: Google 優先 → OSM フォールバック。
- ピン住所: Google Geocoder 優先 → Nominatim。ピンで住所を上書きしてよい。
- Yahoo キーワードは **`/search?q=`**（`p=` は無効だった）。座標ありは `/place?lat=&lon=`。
- Google 課金: 予算アラート月¥1,000。キーは参照元制限。

## 認証・プロフィール

- メール＋パスワード、Google OAuth（同意画面は本番公開済み）。
- 表示名・@ID は全アカウント一意・必須。**@ID の変更のみ10日に1回**（表示名はいつでも可）。
- 登録／Google新規はランダム @ID を最初から入れてよい（空欄不可）。
- @ID コピーボタンあり。

## プライバシー・セキュリティ

- `post_likes` は RLS 済み（anon は読めない）。「いいねした人」は投稿者本人のみ UI 表示＋DB保護。
- 運営機密（BAN・最終ログイン等）は `profiles_admin` 等に分離。一般 profiles SELECT に載せない。
- service_role / Resend API / OAuth Client Secret はリポジトリに入れない。anon key は公開前提でOK。

## 運営・メール

- 運営画面: `admin.html`（allowlist メールのみ）。
- 問い合わせ: `support@nanshiyo.com`（転送・Send mail as・署名定型あり）。
- お知らせは announcements／admin から。アプリ内投稿UIなし。

## コミュニケーション（ユーザー好み）

- 日本語で簡潔に。危険操作は事前説明＋承認。
- 実装したら本番反映（push）まで含めることが多い。空コミットは作らない。
- 判断が変わったら memory と AGENTS の両方を育てる。

---

## 追記ログ（新しい判断は下に足す）

### 2026-07-22
- 投稿タグ入力を `#無料` → Enter/スペース確定のチップ方式に変更（カンマ区切り廃止、最大8、×で削除）。
- タグ検索は常に1タグずつ（検索欄に複数 `#` があっても先頭のみ／トースト案内）。

### 2026-07-21
- memory フォルダ新設。共有ボタン必須・PRは必要カテゴリのみ・Yahoo `q=`・`?u=` 復元を明文化。
- 「過去の判断も入れて常に成長」→ 本ファイルを AGENTS／会話履歴ベースで大幅拡充。以降も毎作業で追記。
- 投稿詳細: 左→右スワイプで閉じられるように（✕以外）。
- タグタップで同タグ投稿を検索（`searchByTag`／検索欄 `#タグ`）。
- トプ画タップ拡大・投稿写真ピンチズームを復元（`3de957c` で誤削除されていた）。

### 2026-07-21（セキュリティ強化）
- anon 公開キー前提なので防御は **Supabase RLS / Storage ポリシーが本命**。クライアントの所有者チェックは補助。
- コア: `supabase/core_rls.sql`（posts/comments/profiles/follows/announcements）。SELECT 公開・書き込み本人のみ。`posts` の `user_id`/`likes`/`reports` はトリガーで保護。`report_post` は authenticated + `auth.uid()` 必須。
- Storage: `supabase/storage_policies.sql`（photos/avatars）。公開 READ、書き込みは `{uid}/` または `{uid}-` パスのみ。緩い旧ポリシーは OR で穴になるので関連ポリシーを落としてから作り直す。
- クライアント: 写真 JWT アップロード、PATCH/DELETE に `user_id=eq.`、通報 JWT、`setAvatarEl` は http(s) のみ、ガチャの pref/genre は `esc()`。
- `is_private` のフィールド隠蔽 RLS は今回やらない（フォロワー判定が複雑で UX 破壊リスク）。
- SQL 適用はデータ削除ではないが、ポリシー誤りで投稿不能になり得る → 本番実行は説明＋明示承認後。
- 2026-07-21 監査: `uploadPhoto` が anon キーのみだった／photos に anon INSERT 可 → 容量悪用リスク。JWT＋uid パス＋Storage ポリシーで封じ。監査テスト画像 `security-audit-test-1627237152.jpg` は Storage UI で削除（SQL DELETE は `storage.protect_delete` で拒否される）。
- プロフィール／マイページの投稿欄は Instagram 風 3列サムネ（`igThumbHTML`）。タップで既存の投稿詳細ポップアップ。ホーム一覧のカード表示は変更なし。

### 2026-07-21（PWA）
- アプリ化は **PWA 先行**（ストア／Capacitor は後）。`manifest.webmanifest` + `sw.js`（network-first、API不キャッシュ）+ `icons/`。
- インストール誘導バナーは出さない。iOS は「ホーム画面に追加」、Android は Chrome インストール。
- SW キャッシュ名を変えると古いキャッシュを落とせる（`nanshiyo-pwa-v1`）。

### 2026-07-21（登録フォーム・確認メール）
- 登録モーダルの必須表示は「必須」ではなく `*`。メールも必須＋形式チェック。
- 確認メール: signup に `email_redirect_to`、未確認はログインせず案内。再送は `/auth/v1/resend`。pending の名前/@ID は確認リンク／初回ログインで profiles へ。
- Confirm email は Supabase 側 ON。SMTP は Resend（support@）。届かないときは Resend ログ／迷惑メールを先に見る。
- メール確認を別端末で開くと localStorage の pending が無い → `user_metadata.handle/name` をフォールバック（Google は handle 無しなのでランダム付与のまま）。

### 2026-07-22（表示名 vs @ID クールダウン）
- 表示名は何回でも変更可。**@ユーザーID だけ** 10日に1回（`username_changed_at` は handle 変更時のみ更新）。

### 2026-07-21（SEO 最低限）
- `robots.txt`（admin.html 除外）+ `sitemap.xml`（トップのみ）+ canonical / OGP / twitter:card。og:image は当面 `icons/icon-512.png`。Search Console は別途 DNS 確認。
