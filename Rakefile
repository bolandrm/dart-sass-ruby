# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

desc 'download version of sass_embedded'
task :embed_sass do
  unless ENV["VERSION"]
    raise "VERSION env var must be specified.  e.g. '1.0.0-beta.6'"
  end
  unless ENV["PLATFORM"]
    raise "PLATFORM env var must be specified.  e.g. 'macos-x64'"
  end

  url = "https://github.com/sass/dart-sass-embedded/releases/download/#{ENV["VERSION"]}/sass_embedded-#{ENV["VERSION"]}-#{ENV["PLATFORM"]}.tar.gz"
  system "curl -L '#{url}' -o embedded.tar.gz"
  system "tar -xzvf embedded.tar.gz"
  system "rm -r bin/sass_embedded"
  system "mv sass_embedded bin/sass_embedded"
end

task default: :test