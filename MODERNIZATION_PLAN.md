# pdumpfs 現代化改修計画 (TDDベース)

## **E**xisting Context (現状)
- **コードベース**: 2004年頃 (Ruby 1.6-1.8 時代) のコード。
- **依存ライブラリ**:
  - `ftools`: Ruby 1.9 で標準添付から削除済み (`fileutils` 推奨)。
  - `Win32API` / `VRuby`: 現代の Ruby 環境では動作困難、または非推奨。
  - `$KCODE`: Ruby 1.9 で廃止。
- **テスト**: シェルスクリプト (`tests/pdumpfs-test`)。GNU `date` コマンドの拡張機能に依存しており、macOS (BSD系) では動作しない。

## **A**nalysis (分析)
- **TDDの障害**: 現在は「テストが失敗する」以前に「テストスクリプト自体が実行できない（日付計算エラー）」かつ「アプリケーションが起動しない（LoadError）」状態にある。
- **改修アプローチ**:
  1.  まずテストスクリプト自体を修正し、正しく「失敗（Red）」させられる状態にする。
  2.  次にアプリケーションの起動エラーを修正し、テストロジックによる検証が可能にする。
  3.  既存のE2Eテスト（シェルスクリプト）を回帰テストとして担保しつつ、内部構造を現代化する。

## **R**equirements (要件)
- **動作環境**: Ruby 3.2+ (および Ruby 4.0) で動作すること。
- **テスト環境**: macOS および Linux 上で、追加のツールインストールなしにテストが実行可能であること（Ruby依存のみにする）。
- **開発手法**: テスト駆動開発 (TDD) のサイクルを守る。既存の振る舞いを変えないこと。

## **S**trategy (戦略)

### Phase 1: テスト環境の整備 (The "Walking Skeleton")
**目標**: テストスクリプトを「実行可能」にし、アプリケーションのクラッシュを確認できる状態にする。

1.  **日付計算の OS 非依存化**:
    - `tests/pdumpfs-test` 内の `date` コマンド（GNU拡張依存）を、Ruby ワンライナーに置換する。
    - 例: `date --date '1 day ago'` → `ruby -e 'require "date"; puts (Date.today - 1).strftime("%Y/%m/%d")'`
    - **TDD check**: この修正により、テストスクリプトが完走しようとして、`pdumpfs` の実行時に `LoadError: cannot load such file -- ftools` で落ちることを確認する (Red)。

### Phase 2: ミニマム・モダナイゼーション (Red → Green)
**目標**: 既存の E2E テスト (`tests/pdumpfs-test`) をパスさせる（挙動の完全互換）。

1.  **標準ライブラリの置換**:
    - `require 'ftools'` を `require 'fileutils'` に変更。
    - `File.mkpath` 等のメソッド呼び出しを `FileUtils.mkdir_p` 等、互換性のあるメソッドへ置換。
    - **TDD check**: テストを実行し、ファイル操作関連のエラーが解消されるか確認。
2.  **エンコーディング対応**:
    - `$KCODE` の削除。必要に応じて `Encoding` クラスの利用や `# frozen_string_literal: true` の追加。
3.  **レガシー Windows コードの隔離**:
    - macOS/Linux 環境でテストをパスさせるため、Windows 固有の `Win32API` や `VRuby` 読み込み部分を `if Gem.win_platform?` 等でガードし、非Windows環境でロードされないようにする。
    - **TDD check**: `tests/pdumpfs-test` が "ok." を出力して終了することを確認する (Green)。

### Phase 3: リファクタリング & Gem化 (Refactor)
**目標**: 持続可能な開発体制への移行。

1.  **ディレクトリ構造の標準化**:
    - `lib/pdumpfs.rb`, `bin/pdumpfs` への分離。
    - `pdumpfs.in` (テンプレート) 方式からの脱却。
2.  **Gem化**:
    - `pdumpfs.gemspec` の作成。依存関係の明記。
3.  **ユニットテストの導入**:
    - シェルスクリプトだけでなく、`RSpec` などを導入し、クラス単位 (`FileMatcher` 等) の微細な挙動をテスト可能にする。