# frozen_string_literal: true

require 'find'
require 'fileutils'
require 'getoptlong'
require 'date'
require_relative 'pdumpfs/version'
require_relative 'pdumpfs/i18n'

class File
  def self.real_file?(path)
    File.file?(path) && !File.symlink?(path)
  end

  def self.anything_exist?(path)
    File.exist?(path) || File.symlink?(path)
  end

  def self.real_directory?(path)
    File.directory?(path) && !File.symlink?(path)
  end

  def self.force_symlink(src, dest)
    begin
      File.unlink(dest) if File.anything_exist?(dest)
      File.symlink(src, dest)
    rescue NotImplementedError # for Windows
    end
  end

  def self.force_link(src, dest)
    File.unlink(dest) if File.anything_exist?(dest)
    File.link(src, dest)
  end

  def self.readable_file?(path)
    File.file?(path) && File.readable?(path)
  end

  def self.split_all(path)
    parts = []
    loop do
      dirname, basename = File.split(path)
      break if path == dirname
      parts.unshift(basename) unless basename == "."
      path = dirname
    end
    parts
  end
end

module Pdumpfs
  def windows?
    /mswin32|cygwin|mingw|bccwin/.match?(RUBY_PLATFORM)
  end

  def wprintf(format, *args)
    STDERR.printf("pdumpfs: #{format}\n", *args)
  end

  module_function :windows?, :wprintf

  class NullMatcher
    def initialize(options = {})
    end

    def exclude?(path)
      false
    end
  end

  class FileMatcher
    def initialize(options = {})
      @patterns = options[:patterns]
      @globs    = options[:globs]
      @size     = calc_size(options[:size])
    end

    def calc_size(size)
      table   = { "K" => 1, "M" => 2, "G" => 3, "T" => 4, "P" => 5 }
      pattern = table.keys.join('')
      case size
      when nil
        -1
      when /^(\d+)([#{pattern}]?)$/i
        num  = Regexp.last_match[1].to_i
        unit = Regexp.last_match[2]
        num * 1024** (table[unit] || 0)
      else
        raise "Invalid size: #{size}"
      end
    end

    def exclude?(path)
      stat = File.lstat(path)

      if @size >= 0 && stat.file? && stat.size >= @size
        return true
      elsif @patterns.find { |pattern| pattern.match?(path) }
        return true
      elsif stat.file? &&
            @globs.find { |glob| File.fnmatch(glob, File.basename(path)) }
        return true
      end
      false
    end
  end

  class Engine
    def initialize(config = {})
      @matcher  = (config[:matcher]  || NullMatcher.new)
      @reporter = (config[:reporter] || ->(x) { puts x })
      @log_file = (config[:log_file] || nil)
      @dry_run  = (config[:dry_run] || false)
      @interval_proc = (config[:interval_proc] || -> {})
      @written_bytes = 0
    end

    def create_latest_symlink(dest, today)
      latest_day = File.dirname(make_relative_path(today, dest))
      latest_symlink = File.join(dest, "latest")
      File.force_symlink(latest_day, latest_symlink)
    end

    def same_directory?(src, dest)
      src  = File.expand_path(src)
      dest = File.expand_path(dest)
      src == dest
    end

    def sub_directory?(src, dest)
      src  = File.expand_path(src)
      dest = File.expand_path(dest)
      src  += File::SEPARATOR unless /#{File::SEPARATOR}$/.match?(src)
      /^#{Regexp.quote(src)}/.match?(dest)
    end

    def start(src, dest, base = nil)
      start_time = Time.now

      if ::Pdumpfs.windows?
        # Windows specifics
      end

      if same_directory?(src, dest) || sub_directory?(src, dest)
        raise ::Pdumpfs::I18n.t(:error_same_directory, src, dest)
      end
      # strip the trailing / to avoid basename(src) == '' for Ruby 1.6.x.
      src  = src.sub(%r{/+$}, "") unless src == '/'
      base = File.basename(src) unless base

      latest = latest_snapshot(start_time, src, dest, base)
      today  = File.join(dest, datedir(start_time), base)

      File.umask(0077)
      FileUtils.mkdir_p(today) unless @dry_run
      if latest
        update_snapshot(src, latest, today)
      else
        recursive_copy(src, today)
      end
      return if @dry_run

      create_latest_symlink(dest, today)
      elapsed = Time.now - start_time
      add_log_entry(src, today, elapsed)
    end

    def convert_bytes(bytes)
      if bytes < 1024
        format("%dB", bytes)
      elsif bytes < 1024 * 1000 # 1000kb
        format("%.1fKB", bytes.to_f / 1024)
      elsif bytes < 1024 * 1024 * 1000 # 1000mb
        format("%.1fMB", bytes.to_f / 1024 / 1024)
      else
        format("%.1fGB", bytes.to_f / 1024 / 1024 / 1024)
      end
    end

    def add_log_entry(src, today, elapsed)
      return unless @log_file
      File.open(@log_file, "a") do |f|
        time  = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
        bytes = convert_bytes(@written_bytes)
        f.printf("%s: %s -> %s (in %.2f sec, %s written)\n",
                 time, src, today, elapsed, bytes)
      end
    end

    def same_file?(f1, f2)
      File.real_file?(f1) && File.real_file?(f2) &&
        File.size(f1) == File.size(f2) && File.mtime(f1) == File.mtime(f2)
    end

    def datedir(date)
      s = File::SEPARATOR
      format("%d%s%02d%s%02d", date.year, s, date.month, s, date.day)
    end

    def past_date?(year, month, day, t)
      ([year, month, day] <=> [t.year, t.month, t.day]).negative?
    end

    def latest_snapshot(start_time, src, dest, base)
      dd   = "[0-9][0-9]"
      dddd = dd + dd
      glob_path = File.join(dest, dddd, dd, dd)
      Dir.glob(glob_path).sort.reverse_each do |dir|
        day, month, year = File.split_all(dir).reverse.map(&:to_i)
        path = File.join(dir, base)
        if File.directory?(path) && Date.valid_date?(year, month, day) &&
           past_date?(year, month, day, start_time)
          return path
        end
      end
      nil
    end

    def copy_file(src, dest)
      File.open(src, 'rb') do |r|
        File.open(dest, 'wb') do |w|
          block_size = (r.stat.blksize || 8192)
          begin
            i = 0
            loop do
              block = r.sysread(block_size)
              w.syswrite(block)
              i += 1
              @written_bytes += block.size
              @interval_proc.call if (i % 10).zero?
            end
          rescue EOFError
          end
        end
      end
    end

    def copy(src, dest)
      stat = File.stat(src)
      copy_file(src, dest)
      File.chmod(0200, dest) if ::Pdumpfs.windows?
      File.utime(stat.atime, stat.mtime, dest)
      File.chmod(stat.mode, dest)
    end

    def detect_type(src, latest = nil)
      type = "unsupported"
      if File.real_directory?(src)
        type = "directory"
      elsif latest && File.real_file?(latest)
        case File.ftype(src)
        when "file"
          type = if same_file?(src, latest)
                   "unchanged"
                 else
                   "updated"
                 end
        when "link"
          type = "symlink"
        end
      else
        case File.ftype(src)
        when "file"
          type = "new_file"
        when "link"
          type = "symlink"
        end
      end
      type
    end

    def chown_if_root(type, src, today)
      return unless Process.uid.zero? && type != "unsupported"
      if type == "symlink"
        if File.respond_to?(:lchown)
          stat = File.lstat(src)
          File.lchown(stat.uid, stat.gid, today)
        end
      else
        stat = File.stat(src)
        File.chown(stat.uid, stat.gid, today)
      end
    end

    def report(type, file_name)
      message = format("% -12s %s\n", type, file_name)
      @reporter.call(message)
      @interval_proc.call
    end

    def update_file(src, latest, today)
      type = detect_type(src, latest)
      report(type, src)
      return if @dry_run

      case type
      when "directory"
        FileUtils.mkdir_p(today)
      when "unchanged"
        File.force_link(latest, today)
      when "updated", "new_file"
        copy(src, today)
      when "symlink"
        File.force_symlink(File.readlink(src), today)
      end
      chown_if_root(type, src, today)
    end

    def restore_dir_attributes(dirs)
      dirs.each do |dir, stat|
        File.utime(stat.atime, stat.mtime, dir)
        File.chmod(stat.mode, dir)
      end
    end

    def make_relative_path(path, base)
      pattern = format("^%s%s?", Regexp.quote(base), File::SEPARATOR)
      path.sub(Regexp.new(pattern), "")
    end

    def update_snapshot(src, latest, today)
      dirs = {}

      Find.find(src) do |s|
        if @matcher.exclude?(s)
          if File.lstat(s).directory? then Find.prune else next end
        end
        r = make_relative_path(s, src)
        l = File.join(latest, r)
        t = File.join(today, r)

        begin
          update_file(s, l, t)
          dirs[t] = File.stat(s) if File.ftype(s) == "directory"
        rescue Errno::ENOENT, Errno::EACCES => e
          ::Pdumpfs.wprintf("%s: %s", src, e.message)
          next
        end
      end

      return if @dry_run
      restore_dir_attributes(dirs)
    end

    def recursive_copy(src, dest)
      dirs = {}

      Find.find(src) do |s|
        if @matcher.exclude?(s)
          if File.lstat(s).directory? then Find.prune else next end
        end
        r = make_relative_path(s, src)
        t = File.join(dest, r)

        begin
          type = detect_type(s)
          report(type, s)
          next if @dry_run

          case type
          when "directory"
            FileUtils.mkdir_p(t)
          when "new_file"
            copy(s, t)
          when "symlink"
            File.force_symlink(File.readlink(s), t)
          end
          chown_if_root(type, s, t)
          dirs[t] = File.stat(s) if File.ftype(s) == "directory"
        rescue Errno::ENOENT, Errno::EACCES => e
          ::Pdumpfs.wprintf("%s: %s", s, e.message)
          next
        end
      end

      return if @dry_run
      restore_dir_attributes(dirs)
    end

    def validate_directories(src, dest)
      raise ::Pdumpfs::I18n.t(:error_no_such_directory, src)  unless File.directory?(src)
      raise ::Pdumpfs::I18n.t(:error_no_such_directory, dest) unless File.directory?(dest)

      if ::Pdumpfs.windows?
        # Windows specifics check
      end
    end
  end

  # For backward compatibility
  Pdumpfs = Engine
end