# frozen_string_literal: true

require_relative 'locales/en'
require_relative 'locales/ja'

module Pdumpfs
  module I18n
    def self.t(key, *args)
      msg = dictionary[key] || "Translation missing: #{key}"
      args.empty? ? msg : format(msg, *args)
    end

    def self.dictionary
      @dictionary ||= detect_locale
    end

    def self.detect_locale
      lang = ENV['LANG'] || ENV['LC_ALL'] || 'en'
      if lang.start_with?('ja')
        ::Pdumpfs::Locales::JA
      else
        ::Pdumpfs::Locales::EN
      end
    end
  end
end
