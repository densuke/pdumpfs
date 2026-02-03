# pdumpfs: 現代化版 (Modernized Version)

pdumpfs は、Plan9 の dumpfs に似た、ハードリンクを活用した日次バックアップシステムです。
このリポジトリは、2004年頃に公開されたオリジナル版（v1.3）を、現代の Ruby 環境で動作するように改修したものです。

## 現代化による変更点 (Modernization Changes)

オリジナル版からの主な変更内容は以下の通りです：

- **Ruby 3.x / 4.x 対応**:
  - 廃止された `ftools` ライブラリを `fileutils` へ置換。
  - `$KCODE` 等のレガシーなエンコーディング設定を削除。
  - `and` / `or` 演算子の優先順位に起因する潜在的なバグを `&&` / `||` へ修正。
- **プロジェクト構造の刷新**:
  - 現代的な Ruby プロジェクトの慣習に従い、コードを `lib/` と `bin/` に分離。
  - `pdumpfs.in` テンプレート方式を廃止し、直接実行・開発が可能な構造へ変更。
- **Gem 化**:
  - `gem install` でのインストールに対応（`pdumpfs.gemspec` の整備）。
  - `getoptlong` への依存関係を明記（Ruby 3.4以降の標準添付からの分離に対応）。
- **多言語化 (I18n)**:
  - 英語および日本語のメッセージ切り替えに対応。
  - 実行環境のロケール設定に応じて自動的に言語が切り替わります。
- **Windows 専用 GUI の削除**:
  - 現代の環境でのメンテナンス性を考慮し、レガシーな `VRuby` 依存の GUI コードを完全に削除しました。純粋な CLI ツールとして動作します。
- **ドキュメントの Markdown 化**:
  - 元の XHTML ドキュメントを Markdown 形式に変換し、可読性を向上させました。

## インストール (Installation)

```bash
git clone <this-repository>
cd pdumpfs-1.3
bundle install
rake build
gem install pkg/pdumpfs-1.3.gem
```

## 使い方 (Usage)

詳細な使い方や設定例については、以下のドキュメントを参照してください：

- [日本語ドキュメント (doc/pdumpfs-ja.md)](doc/pdumpfs-ja.md)
- [English Documentation (doc/pdumpfs.md)](doc/pdumpfs.md)

## オリジナル情報 (Original Information)

- **オリジナル作者**: 高林 哲 (Satoru Takabayashi)
- **公式サイト**: [http://0xcc.net/pdumpfs/](http://0xcc.net/pdumpfs/)
- **解説記事**: [pdumpfsによる定期バックアップのススメ (2003年)](http://0xcc.net/pub/sd-2003-08/)

## ライセンス (License)

このソフトウェアは GNU General Public License version 2 (GPL-2.0) の下で配布されています。詳細は `COPYING` ファイルを参照してください。
