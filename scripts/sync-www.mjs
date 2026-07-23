/**
 * GitHub Pages 用の静的ファイルを Capacitor の www/ にコピーする。
 * アプリはローカル資産を開き、API は本番 Supabase へ接続する。
 */
import { cpSync, mkdirSync, rmSync, existsSync, writeFileSync, readFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const www = join(root, "www");

const files = [
  "index.html",
  "privacy.html",
  "manifest.webmanifest",
  "sw.js",
  "robots.txt",
  "sitemap.xml",
  "CNAME"
];

rmSync(www, { recursive: true, force: true });
mkdirSync(www, { recursive: true });

for (const f of files) {
  const src = join(root, f);
  if (existsSync(src)) cpSync(src, join(www, f));
}
if (existsSync(join(root, "icons"))) {
  cpSync(join(root, "icons"), join(www, "icons"), { recursive: true });
}

/* アプリ内では SW が邪魔になることがあるため、起動時に登録を弱める注記を残す（削除はしない） */
writeFileSync(
  join(www, ".nanshiyo-build.json"),
  JSON.stringify({ builtAt: new Date().toISOString(), source: "sync-www" }, null, 2)
);

console.log("synced -> www/ (", files.filter((f) => existsSync(join(root, f))).join(", "), "+ icons )");
