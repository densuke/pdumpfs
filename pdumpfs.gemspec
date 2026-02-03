# frozen_string_literal: true

require_relative 'lib/pdumpfs/version'

Gem::Specification.new do |spec|
  spec.name          = "pdumpfs"
  spec.version       = Pdumpfs::VERSION
  spec.authors       = ["Satoru Takabayashi", "MASH (Maintained by)"]
  spec.email         = ["satoru@namazu.org"] # 元の作者のアドレスを残しつつ、必要ならメンテナのを追加
  spec.summary       = "A daily backup system similar to Plan9's dumpfs."
  spec.description   = <<~DESC
    pdumpfs is a simple daily backup system similar to Plan9's dumpfs which
    preserves every daily snapshot. It copies only updated or newly created files
    and stores unchanged files as hard links to save disk space.
  DESC
  spec.homepage      = "http://0xcc.net/pdumpfs/" # Original homepage (or new one if migrated)
  spec.license       = "GPL-2.0"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0.0"

  spec.add_dependency "getoptlong"
end
