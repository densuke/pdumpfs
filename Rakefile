require "bundler/gem_tasks"

task :default => :test

desc "Run E2E tests"
task :test do
  puts "Running E2E tests..."
  # tests/pdumpfs-test はシェルスクリプトなので、systemで呼び出す
  Dir.chdir("tests") do
    system("bash pdumpfs-test") or abort("Test failed")
  end
end
