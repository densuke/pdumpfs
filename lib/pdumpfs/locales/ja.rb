# frozen_string_literal: true

module Pdumpfs
  module Locales
    JA = {
      usage_header: "使用法: pdumpfs コピー元 コピー先 [ベース名]",
      usage_exclude: "正規表現パターンに一致するファイルを除外",
      usage_exclude_by_size: "指定サイズより大きいファイルを除外",
      usage_exclude_by_glob: "グロブパターンに一致するファイルを除外",
      usage_log_file: "ログをファイルに出力",
      usage_version: "バージョン情報を表示して終了",
      usage_quiet: "通常の出力を抑制",
      usage_dry_run: "実際のファイル操作を行わない (Dry Run)",
      usage_help: "このヘルプを表示",
      error_same_directory: "ディレクトリ `%s' をそれ自身 `%s' の中にコピーすることはできません",
      error_no_such_directory: "ディレクトリが見つかりません: %s",
      error_ntfs_only: "NTFSのみサポートされていますが、%s は %s です。"
    }
  end
end
