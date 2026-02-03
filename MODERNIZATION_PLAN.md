# pdumpfs 現代化改修計画 (TDDベース) - 完了報告

## **E**xisting Context (現状)
- **コードベース**: 2004年頃 (Ruby 1.6-1.8 時代) のコード。
- **依存ライブラリ**:
  - `ftools`: Ruby 1.9 で標準添付から削除済み (`fileutils` 推奨)。
  - `Win32API` / `VRuby`: 現代の Ruby 環境では動作困難、または非推奨。
  - `$KCODE`: Ruby 1.9 で廃止。
- **テスト**: シェルスクリプト (`tests/pdumpfs-test`)。GNU `date` コマンドの拡張機能に依存しており、macOS (BSD系) では動作しない。

## **A**nalysis (分析)
- **TDDの障害**: 現在は「テストが失敗する」以前に「テストスクリプト自体が実行できない（日付計算エラー）」かつ「アプリケーションが起動しない（LoadError）」状態にあった。
- **改修アプローチ**:
  1.  まずテストスクリプト自体を修正し、正しく「失敗（Red）」させられる状態にする。 (完了)
  2.  次にアプリケーションの起動エラーを修正し、テストロジックによる検証が可能にする。 (完了)
  3.  既存のE2Eテスト（シェルスクリプト）を回帰テストとして担保しつつ、内部構造を現代化する。 (完了)

## **R**equirements (要件)
- **動作環境**: Ruby 3.2+ (および Ruby 4.0) で動作すること。 (達成)
- **テスト環境**: macOS および Linux 上で、追加のツールインストールなしにテストが実行可能であること（Ruby依存のみにする）。 (達成)
- **開発手法**: テスト駆動開発 (TDD) のサイクルを守る。既存の振る舞いを変えないこと。 (達成)

## **S**trategy (戦略)

### Phase 1: テスト環境の整備 (The "Walking Skeleton") - [DONE]
1.  **日付計算の OS 非依存化**:
    - `tests/pdumpfs-test` 内の `date` コマンド（GNU拡張依存）を、Ruby ワンライナーに置換。
    - **Outcome**: テストが macOS/Linux 両対応となった。

### Phase 2: ミニマム・モダナイゼーション (Red → Green) - [DONE]
1.  **標準ライブラリの置換**:
    - `require 'ftools'` を `require 'fileutils'` に変更。
    - `FileUtils.mkdir_p` 等への置換。
2.  **エンコーディング対応**:
    - `$KCODE` の削除。 `# frozen_string_literal: true` の追加。
3.  **重大なバグ修正**:
    - `and`/`or` 優先順位バグを `&&`/`||` へ修正。
    - **Outcome**: `tests/pdumpfs-test` がパス (Green)。

### Phase 3: リファクタリング & Gem化 (Refactor) - [Refactoring DONE / Gemification TODO]
1.  **ディレクトリ構造の標準化**:
    - `lib/pdumpfs.rb`, `bin/pdumpfs`, `lib/pdumpfs/version.rb` への分離。
    - `pdumpfs.in` (テンプレート) 方式の廃止。
2.  **Windows 固有 GUI (VRuby) の削除**:
    - 現代化に伴い、メンテナンス困難な VRuby 依存コードを完全に除去。
3.  **Gem化**:
    - (将来の課題) `pdumpfs.gemspec` の作成。
4.  **ユニットテストの導入**:
    - (将来の課題) `RSpec` などの導入。
