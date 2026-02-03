# pdumpfs Gem化 & 多言語化計画 (Phase 4 & 5)

## **E**xisting Context (現状)
- **構造**: `bin/`, `lib/` に分離済み。Ruby 3.x/4.x で動作確認済み。
- **配布形態**: 現状はソースコードコピーが必要。`gem install` 不可。
- **言語**: エラーメッセージやヘルプ出力は英語ハードコード。過去の `catalog.jpn.txt` (VRuby用) の仕組みはリファクタリングで削除済み。

## **R**equirements (要件)
1.  **Gem化**:
    - `gem install pdumpfs` でインストール可能にする。
    - 依存関係（`fileutils`, `optparse` 等は標準添付だが明記推奨）の整理。
    - `man` や `doc` をGemパッケージに適切に含める。
2.  **多言語化 (I18n)**:
    - 実行環境のロケール (`LANG` 等) に応じて、出力メッセージ（ヘルプ、エラーログ）を日本語/英語で切り替える。
    - 外部Gem (`i18n` 等) への依存は最小限に留めるか、標準添付の範囲で実装するか検討が必要（CLIツールとしての軽快さを維持）。

## **S**trategy (戦略)

### Phase 4: Gem化 (Gemification)
1.  **`pdumpfs.gemspec` の作成**:
    - バージョン: `lib/pdumpfs/version.rb` から参照。
    - 実行ファイル: `bin/pdumpfs` を指定。
    - ファイルリスト: `git ls-files` を利用する形式が一般的。
2.  **`Gemfile` の整備**:
    - 開発用依存 (`rake`, `rspec` 等) を定義。
3.  **Rakeタスク**:
    - `rake test` (現在は `make check`) や `rake build` が動くように `Rakefile` を作成。

### Phase 5: 多言語化 (Localization)
1.  **メッセージ抽出**:
    - `bin/pdumpfs` (Usage, ヘルプ) と `lib/pdumpfs.rb` (ログ、エラー) 内の英語文字列を抽出。
2.  **辞書ファイルの作成**:
    - YAML形式 (`locales/ja.yml`, `locales/en.yml`) または Ruby Hash で定義。
3.  **I18n ロジックの実装**:
    - 簡易的な `Translator` クラスを `lib/pdumpfs/translator.rb` に実装。
    - `ENV['LANG']` を見て辞書を切り替える。
    - 外部Gem `i18n` は依存が増えるため、今回は自前で軽量な実装を行う（メッセージ数が少ないため）。

## **T**ask List (タスクリスト)

### Step 1: Gem化
- [ ] `pdumpfs.gemspec` 作成
- [ ] `Gemfile` 作成
- [ ] `Rakefile` 作成 (`Makefile` の機能を移植)
- [ ] インストールテスト (`gem build` -> `gem install` -> 動作確認)

### Step 2: 多言語化
- [ ] メッセージIDの設計 (例: `usage_banner`, `error_directory_not_found`)
- [ ] `lib/pdumpfs/locales/` ディレクトリ作成と辞書ファイル配置
- [ ] `bin/pdumpfs` および `lib/pdumpfs.rb` のメッセージ出力部分を翻訳メソッド呼び出しに置換
- [ ] 日本語環境 (`LANG=ja_JP.UTF-8`) での動作確認
