module Pdumpfs
  module Locales
    EN = {
      usage_header: "Usage: pdumpfs SRC DEST [BASE]",
      usage_exclude: "exclude files/directories matching PATTERN",
      usage_exclude_by_size: "exclude files larger than SIZE",
      usage_exclude_by_glob: "exclude files matching GLOB",
      usage_log_file: "write a log to FILE",
      usage_version: "print version information and exit",
      usage_quiet: "suppress all normal output",
      usage_dry_run: "don't actually run any commands",
      usage_help: "show this help message",
      error_same_directory: "cannot copy a directory, `%s', into itself, `%s'",
      error_no_such_directory: "No such directory: %s",
      error_ntfs_only: "only NTFS is supported but %s is %s."
    }
  end
end
