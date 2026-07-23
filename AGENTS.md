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
- 実体: `index.html`（一般ユーザー向け・CSS/JSインライン）＋ **`admin.html`（運営専用管理画面）**
- バックエンド: **Supabase**（認証・DB・ストレージ）
  - `SUPABASE_URL` / `SUPABASE_ANON_KEY`（公開キー）は各HTML内。公開前提のキーで問題なし。
  - **service_role 等の秘密キーは絶対にコード/リポジトリに入れない。**
  - 運営の削除・BAN・お知らせ配信は **security definer の RPC**（`admin_*` / `track_login`）経由。メール allowlist で権限判定。

## リポジトリ / URL

- リポジトリ: `iwsknsr628-hub/NOAABEAA`（Public）
- ホスティング: GitHub Pages（`main` / ルート `/`）
- 本番URL: **https://nanshiyo.com**（Cloudflare で DNS 管理。ルートの `CNAME` ファイルは削除しない）
- 運営管理: **https://nanshiyo.com/admin.html**（`noindex`・運営メールのみログイン可）
- 予備URL: https://iwsknsr628-hub.github.io/NOAABEAA/
- ローカル作業フォルダ: `C:\Users\iwskn\Projects\nanshiyo`
- **SEO（最低限）**: `robots.txt`（`/admin.html` 除外）・`sitemap.xml`（当面トップのみ）・`index.html` に canonical / OGP / twitter:card。og:image は `https://nanshiyo.com/icons/icon-512.png`。
- **Google Search Console**: ドメインプロパティ `nanshiyo.com` の所有権確認済み（DNS TXT `google-site-verification=…`）。サイトマップ `https://nanshiyo.com/sitemap.xml` 送信済み（成功・検出ページ1）。掲載反映は数日〜数週間かかることがある。確認: Googleで `site:nanshiyo.com`。

## 作業ルール

1. 変更は必ず**このプロジェクト（=GitHub）側の `index.html` / `admin.html`** を編集する。Claudeアプリの旧サンドボックス内ファイルは使わない。
2. セットアップ/デプロイ/URL/バックエンドに変更があったら、**この AGENTS.md を更新**する。
3. 会話で確定したプロダクト判断は **`.cursor/memory/LEARNED.md` に追記**する。**過去判断の抜けにも気づいたら遡って追記**し、常に成長させる（ルール `learned-product.mdc`）。
4. 変更を push したら、ユーザーに「本番へ自動反映される」旨を伝える。

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
- `DIRECT_ADS`（配列）… **スポンサー直販の広告枠**。スポンサーから「広告枠を使わせて」依頼が来たら、配列に1件足すだけで投稿一覧に表示（6件ごと、複数はローテーション）。
  - 画像バナー: `{ img, url, title?, label? }`／自由なHTML・広告タグ: `{ html, label? }`。`PR` ラベルと `rel="noopener sponsored"` 付与済み。
  - 優先順位: `DIRECT_ADS` があればそれを表示、無ければ AdSense。両方空なら枠は出ない（`slotHTMLForIndex()`/`directAdHTML()`）。

送客ボタン: `affButtonsHTML()`。投稿詳細ポップアップとガチャ結果に表示。`PR` ラベル＋`rel="sponsored"` 付与済み（規約・景表法対策）。
- **投稿者リンク優先**: `posts.aff_url` があればそれ1つだけ（運営の自動リンクは出さない）。
- **運営の自動PRは必要なカテゴリだけ**（`AFF_AUTO_CATS`）: `travel` / `study` / `fun` / `life` / `beauty` / `finance`。
  - `food` / `drink`（ご飯屋・呑み屋など現地店舗）は自動PRなし（地図リンクで十分）。
  - `travel` → 楽天トラベル「宿・ホテル」のみ。検索語は **スポット名＋県**（`travelHotelKeyword()`）。県だけだと投稿と無関係な宿ばかりになるため使わない。
  - 上記以外の自動PR対象 → 楽天市場＋Amazon。検索語はスポット名・ジャンルなど投稿内容優先（`shopKeyword()`）。
- 楽天トラベル宿検索: `kw.travel.rakuten.co.jp/keyword/Search.do?charset=utf-8&f_query=`（**`charset=utf-8` 必須**。無いと文字化け・0件）。

### 投稿者アフィリンク（`posts.aff_url`）

投稿フォームに「🔗 アフィリエイトリンク（任意）」欄あり。投稿者が自分のアフィリンク（楽天/Amazon/A8等）を貼ると、その投稿の送客ボタンは**投稿者の成果**になる（`affButtonsHTML()` は `p.aff_url` があればそれ1つだけ表示、無ければ運営の自動リンク）。ドメインでラベル自動判定（`affLinkMeta()`）、`http/https` のみ許可（`normalizeAffUrl()`）。

- **要スキーマ**: `posts` に `aff_url text` 列が必要。Supabase → SQL Editor で:
  ```sql
  alter table posts add column if not exists aff_url text;
  ```
- 列が無い間も**通常投稿・編集は壊れない**設計（`toRow`/`toPatchRow` は値があるとき/明示クリア時のみ `aff_url` を送る）。列追加後にアフィリンク付き投稿が保存可能になる。

- 今後の候補: A8.net/もしも/バリューコマース（個別リンク）、金融系（楽天カード/証券=高単価）。

## Google Maps / Places

- `const GOOGLE_MAPS_KEY` に参照元制限付きキーを設定済み。**Places API (New)** およびピン確定時の住所自動入力用に **Geocoding API** が有効である必要あり。
- 検索は Google Places 優先 → OSM(Nominatim+Photon) フォールバック。
- ピン確定の住所: Google Geocoder 優先（番地まで）→ Nominatim フォールバック。
- 課金対策: Places API (New) の1日ハードキャップはGoogle仕様で不可。代わりに **予算アラート（月¥1,000）** を設定済み。現在は無料トライアル（クレジット/90日、超過時は自動停止・自動課金なし）。

## UI/UX 構成（現状）

直近で実装済みの主要UI。編集時はこの前提を壊さないこと。

- **下部タブバー（タスクバー）** `#tabbar`：画面下に固定。
  - 🏠 ホーム（`goHome()` = 投稿一覧先頭へスクロール＋開いている全画面/モーダルを閉じる）
  - 🔍 さがす（`openSearchPage()` 全画面）
  - ＋ 投稿（中央・強調、`openModal()`。未ログインはログイン誘導）
  - ✈ 通知（`#notifPage` 全画面。`openNotifs()`/`closeNotifs()`。プロフィール同様のページ切替。要ログイン）
  - 👤 マイページ / 🔑 ログイン（`#tabAcct`、ログイン状態で自動切替。`updateAcctUI()` が制御）
  - ヘッダー右上の旧「＋投稿する」ボタンは廃止。ヘッダーの「ログイン/登録」(`#acctBtnTop`) は**ログアウト時のみ表示**。
  - `body{padding-bottom:74px}` でバー分の余白を確保済み。
- **未ログインは閲覧・検索OK**：ヒーロー検索／さがす／投稿一覧・詳細・写真・プロフィール・コメント一覧の表示は誰でも可。投稿・コメント投稿・フォロー・通知・**いいね・通報**は要ログイン（`requireLogin(msg)` → `showToast` ＋ `openAuth()`）。
- **投稿詳細ポップアップ** `#postViewBg`（`openPostView()`/`postDetailHTML()`）：カードをタップすると全文をモーダル表示。z-index 230。URL は `?post=<id>`（再読み込み・共有用）。閉じ方: ✕／背景タップ／**左→右スワイプ**。
- **プロフィールは全画面ページ** `#pvPage`（`openProfileView()`/`closeProfileView()`）：投稿カードの著者名/アバターから遷移。ユーザーの投稿一覧付き。z-index 200。URL は `?u=<user_id>`。
- **共有ボタン**: 投稿カード／詳細・プロフィール／マイページ右上に共有アイコン。`navigator.share`（不可時はリンクコピー）。ディープリンク復元は `restoreDeepLinksFromUrl()`（`?post=` 優先、なければ `?u=`）。
- **デザイン**: 現行1系統のみ（コーラル／ネイビー／Zenフォント／ロゴ「なんしよ。」／すっきりヒーロー）。旧 classic テーマ・切替UIは廃止。
- **投稿詳細の「いいねした人」**: 投稿者本人のみ表示（`loadPostLikers()`）。**DB側は `post_likes` RLS**（`supabase/post_likes_rls.sql`）で保護。クライアントの if だけに頼らない。
- **設定UI**: マイページの三本線 → 右ドロワー → 項目選択で全画面（アカウント情報／アカウント設定／プライバシー／表示＝地図アプリ）。戻るでドロワー再表示。
- **カードのアバター**：`AVATARS` キャッシュに著者の `avatar_url`/`name` をまとめて取得（`fetchAvatars()`、`fetchPosts()` の後に実行）。`avatarOf(uid)` で参照。
- **写真ビューア（ライトボックス）** `#lightboxBg`：ピンチ／ホイール／ダブルタップ拡大、横スワイプ＝写真切替、下スワイプ／タップ＝閉じる。プロフィール画像は `openAvatarView`（`round-avatar`）。**住所・地図の修正でこのブロックを消さない。**
- カード/ポップアップ内の操作は共通ハンドラ `handleCardInteractions(e,rerender)` に集約（タグ検索/共有/著者リンク/コメント/編集/いいね/通報/カードタップ）。
- **タグ検索**: 投稿の `#タグ`（`.tag-link`）をタップ → **検索ページ（さがす）** を開き、入力欄に `#タグ` を入れて同タグ投稿を表示（`searchByTag()` → `openSearchPage()`）。ヒーロー検索で `#タグ` を入れた場合も同様。ホーム一覧の ASSIST 絞り込みにはしない。
- **検索ページのおすすめ**: `#searchRecGrid` に**常時**おすすめ投稿を表示（いいね・新しさ・写真ありのスコア）。キーワード／タグ検索時は結果の下に「ほかのおすすめ」として出す（結果と重複しない）。
- **検索は人間の投稿のみ**: `isHumanPost()`（`user_id` あり・seed 以外）。`fetchPosts()` 時点でフィルタし、ホーム／検索／ガチャなどサイト全体でデモ・user_id なし投稿は出さない。DB上の残骸削除は別途 SQL（要承認）。
- **投稿のタグ入力**: `#無料` のように `#` から入力し、Enter / スペースで1つずつ確定（チップ表示・×で削除、最大8個）。カンマ区切りではない。
- **同一店舗の横並び**: ホーム一覧で、場所系カテゴリ（`LOCATION_CATS` = travel/food/drink/beauty）の投稿が同じ店舗と判断されると `.place-rail` で横スクロール表示。判定は住所正規化一致／座標約80m以内／店名一致＋同じ県（または約500m以内）。2件以上のときだけまとめ、単独投稿・他カテゴリは従来どおりグリッド。

## 認証・アカウント（ログイン / ユーザー名 / @ID）

- **ログイン方法**: メール＋パスワード、および **Googleログイン（Supabase OAuth）**。
  - 認証モーダル `#authBg` に「Googleで続ける」ボタン（`oauthLogin('google')`）。OAuthコールバックは `handleAuthRedirect()`。
  - Google Cloud の OAuth 同意画面は **本番公開済み**（全Googleアカウントでログイン可）。SupabaseのGoogleプロバイダに Client ID / Secret 設定済み。**Client Secret はリポジトリに置かない**（Supabase側に保存）。
  - Supabase: Site URL = `https://nanshiyo.com`、Redirect許可 = `https://nanshiyo.com/**`。
- **表示名（ユーザー名）**: 全アカウントで一意（`nameTaken()` が自分以外の重複を拒否）。必須。**DBでも担保**（`profiles_name_lower_idx` = `unique (lower(name))`）。
- **@ID（ハンドル / `profiles.handle`）**: 全アカウントで一意・必須。英小文字/数字/`_` の3〜20文字（`validHandle()`）。
  - 登録フォーム・設定モーダル・プロフィール編集では **最初からランダムID（`randomHandle()` = `user_xxxxxxxx`）が入力済み**。変えたい人だけ書き換える方式（空欄不可）。
  - **Googleログインの新規ユーザー**は、表示名＝`ユーザーxxxxxxxx`／@ID＝`user_xxxxxxxx` を**自動付与**（`handleAuthRedirect()` 内）。後からプロフィール編集で変更可。
  - プロフィールの表示名の下に `@ID` を表示。横のコピーボタン（`handleViewHTML()`/`copyHandle()`）でコピー可。
  - @ID 未設定の既存ユーザーには通知タブでナッジ＋赤バッジ＋起動時プロンプト（`needsHandle()` / `maybePromptUsername()`）。
- **@ユーザーID（ハンドル）の変更は10日に1回まで**（`USERNAME_COOLDOWN_DAYS=10` / `usernameCooldownLeft()`）。**表示名はいつでも変更可**。
  - @ID を変更した時刻だけを `profiles.username_changed_at` に記録し、10日未満なら @ID 変更を拒否。表示名・自己紹介/アイコン/SNSリンクは制限なし。
  - 初回設定・登録時の自動付与はカウントしない（ユーザー自身の最初の @ID 変更から起算）。
- **要スキーマ**（Supabase → SQL Editor、いずれも安全な冪等 SQL）:
  ```sql
  alter table public.profiles add column if not exists handle text;
  alter table public.profiles add column if not exists username_changed_at timestamptz;
  -- 表示名・@ID の一意（大文字小文字無視）。既存で設定済みなら if not exists で何もしない
  create unique index if not exists profiles_name_lower_idx on public.profiles (lower(name));
  create unique index if not exists profiles_handle_lower_idx on public.profiles (lower(handle));
  ```
  ※ クライアントの 409 は `profileConflictMsg()` で name / handle を出し分け。

## お知らせ（announcements）

マイページのハンバーガーメニューから表示。`loadAnnouncements()` が `announcements` を取得し、未読は赤バッジ（`announceDot`）。

- **要スキーマ**（Supabase に実在。無ければ以下で作成）:
  ```sql
  create table if not exists public.announcements (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    body text,
    created_at timestamptz default now()
  );
  -- サイトは anon key で select のみ。公開読み取りを許可（未設定なら）:
  -- alter table public.announcements enable row level security;
  -- create policy "announcements_public_read" on public.announcements for select using (true);
  ```
- **運用**: 運営が Supabase → Table Editor（または SQL）で直接 INSERT してお知らせを配信する。アプリ側の投稿UIは無し。
  ```sql
  insert into public.announcements (title, body)
  values ('お知らせタイトル', '本文（任意）');
  ```
  ※ 推奨: 運営管理画面（`admin.html`）のお知らせタブから配信（`admin_upsert_announcement` RPC）。

## 運営管理画面（admin.html）

URL: `https://nanshiyo.com/admin.html`（検索非公開 `noindex`）。

- **入場条件**: Supabase ログイン＋メールが `ADMIN_EMAILS` に含まれること（現状 `syallman28@gmail.com` / `iwsknsr628@gmail.com`。追加は `admin.html` 内定数と `is_nanshiyo_admin()` SQL の両方を更新）。
- **機能**:
  - 概要KPI（登録者・投稿・コメント・いいね・今日のログイン・BAN数）
  - グラフ（直近30日の新規登録 / ログイン / 新規投稿 / カテゴリ別）
  - 登録者管理（検索・最終ログイン・投稿数・BAN/解除）
  - 投稿一覧からの削除
  - お知らせの配信・削除
- **権限設計（重要）**:
  - `banned` / `last_login_at` / 登録日 `created_at` は **`profiles` 本体に置かない**。別テーブル `profiles_admin` に分離し、RLS 有効・ポリシー無し・`anon`/`authenticated` から REVOKE。一般の `profiles` SELECT（`openProfileView` 等）では見えない。
  - `login_events` も同様に RLS 有効・ポリシー無し・直接 read/write 不可。書き込みは `track_login()`（security definer）のみ。
  - 本人の BAN 判定は `get_my_profile()` RPC（認証済み・本人のみ）。運営一覧・集計は `admin_list_profiles` / `admin_dashboard_bundle`。
  - `is_nanshiyo_admin()` は **JWT の `email`（`auth.jwt()->>'email'`）** をサーバー側で照合。クライアント改ざんではなりすまし不可。各 `admin_*` は冒頭で必ずチェック。
- **ログイン計測**: 本サイト側 `trackLogin()` → RPC `track_login` が `profiles_admin.last_login_at` 更新＋`login_events` へ INSERT。過去分は `login_events` の `max(created_at)` を `profiles_admin.last_login_at` に反映済み（`supabase/admin_rpc.sql` 内の backfill）。
- **BAN**: `profiles_admin.banned`。本サイトの `requireLogin()` / ログイン時に停止中なら拒否。
- **SQL の正**: リポジトリ `supabase/admin_rpc.sql`（再実行可能な冪等マイグレーション）。Supabase SQL Editor で適用済み。
- **関連リンク集**: `links/README.md`
## メール（送信 / 受信 / 問い合わせ）

- **ドメイン**: `nanshiyo.com`（Cloudflare で DNS 管理）。
- **受信**: Cloudflare Email Routing で `support@nanshiyo.com` → `syallman28@gmail.com` へ転送。
- **送信（システムメール）**: **Resend + Supabase Custom SMTP**。登録確認メール等は `support@nanshiyo.com` から送信。
  - Resend で `nanshiyo.com` をドメイン認証済み（DKIM/SPF/DMARC/MX を Cloudflare に設定済み）。
  - SMTP: `smtp.resend.com` / ポート `465` または `587` / user `resend` / パスワード=Resend APIキー。**APIキーはリポジトリに置かない**（Supabase/Gmail設定側に保存）。
  - Auth「Confirm email」ON。登録 API は `email_redirect_to=https://nanshiyo.com/` を付与。未確認ではログインせず確認メール案内＋再送ボタン（`/auth/v1/resend`）。
  - 届かないときは迷惑メール・Resend ダッシュボードの送信ログ・SMTP パスワード有効期限を確認。
- **問い合わせ返信**: Gmail(`syallman28`) の「他のアドレスから送信（Send mail as）」で `support@nanshiyo.com` を追加・確認済み。差出人名「なんしよ運営事務局」。「受信したアドレスから返信」ON なので、`support@` 宛の転送メールに返信すると差出人が自動で `support@nanshiyo.com` になる。
- **サイト内の問い合わせフォーム**: フッター（`#contact`）に設置。`sendContact()` が `mailto:support@nanshiyo.com` を件名・本文付きで起動。

### メール定型文（Gmail署名・必ず入れる文言）

Gmail（`syallman28`）の署名として設定済み。`support@nanshiyo.com` の新規作成・返信の両方のデフォルト署名は **「なんしよ運営」**（問い合わせ用）。

**① 問い合わせ返信（署名名: `なんしよ運営`）※デフォルト**
```
お問い合わせありがとうございます。
なんしよ運営事務局です。

（ここに返信内容を書いてください）

いつもご利用いただき、ありがとうございます。

────────────────
なんしよ運営事務局
なんしよ？ — みんなのおすすめが集まる場所
https://nanshiyo.com
support@nanshiyo.com
```

**② 一般連絡（署名名: `一般連絡`）※必要時に署名切替**
```
いつもありがとうございます。
なんしよ運営事務局です。

（ここに本文を書いてください）

いつもご利用いただき、ありがとうございます。

────────────────
なんしよ運営事務局
なんしよ？ — みんなのおすすめが集まる場所
https://nanshiyo.com
support@nanshiyo.com
```

使い方: 返信を開くと署名が自動挿入される → 「（ここに〜）」を消して本文を書く。問い合わせ以外は作成画面で署名を「一般連絡」に切替。

**システムメール（Supabase Auth）**: 登録確認・パスワード再設定テンプレも日本語化済み。冒頭に「なんしよ運営事務局です。」、末尾に「いつもご利用いただき、ありがとうございます。／なんしよ運営事務局」を入れる方針。

## アプリ化（PWA）

- **現状: PWA 対応済み**（ストア未着手。将来 Capacitor）。
- ファイル:
  - [`manifest.webmanifest`](manifest.webmanifest) — `standalone` / theme `#FF5F4E`
  - [`sw.js`](sw.js) — network-first。Supabase・地図・CDN API はキャッシュしない。キャッシュ名 `nanshiyo-pwa-v1`
  - [`icons/`](icons/) — `icon-192.png` / `icon-512.png` / `apple-touch-icon.png` / `icon.svg`
- [`index.html`](index.html) で manifest・apple-touch-icon・`serviceWorker.register('/sw.js')`
- 使い方: Android Chrome はインストール可。iOS Safari は共有 →「ホーム画面に追加」。インストール誘導バナーは出さない。
- 予備 URL（`iwsknsr628-hub.github.io/NOAABEAA/`）ではルート相対 `/sw.js` がリポジトリルートとずれる場合あり。本番は `https://nanshiyo.com` 基準。

## 今後の予定（参考）

- アプリ化 Step2: Capacitor で App Store / Google Play
- 決済: **Supabase Edge Functions** で実装予定（GitHub Pages は静的のみ）
- 運営系の機密: `profiles_admin` / `login_events` は RLS＋REVOKE 済み（`supabase/admin_rpc.sql`）。
- **コア RLS（適用必須）**: `supabase/core_rls.sql`
  - `posts` / `comments` / `profiles` / `follows`：SELECT は公開、書き込みは `auth.uid()` 本人のみ。`announcements` は SELECT のみ（書き込みは既存 `admin_*` RPC）。
  - `posts` トリガーで `user_id` / `likes` / `reports` のクライアント改ざんを防止。通報は `report_post`（authenticated のみ・`auth.uid()` 必須）。
- **Storage ポリシー（適用必須）**: `supabase/storage_policies.sql`（緊急時は `supabase/photos_anon_lockdown.sql` でも可）
  - `photos` / `avatars`：公開 READ、INSERT/UPDATE/DELETE は認証済みかつパスが `{uid}/...` または `{uid}-...`。
  - **anon のみでの写真アップロードは不可**（クライアントも JWT 必須。`uploadPhoto` / `uploadToBucket`）。
- **`post_likes`**: 既存どおり `supabase/post_likes_rls.sql`（自分のいいね／自分の投稿へのいいねのみ SELECT、INSERT/DELETE は本人のみ）。
- クライアント側も二重防御: 写真は JWT＋uid パス、`updatePost`/`deletePost`/`deleteComment` に `user_id=eq.`、通報は JWT。`is_private` のフィールド隠蔽 RLS は未実施（UX 優先）。
