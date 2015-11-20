require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:spec) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec

desc "Run specs with coverage"
task :coverage do
  ENV['COVERAGE'] = '1'
  Rake::Task['spec'].invoke
end


desc "Check syntax of all .rb files"
task :check_syntax do
  Dir['**/*.rb'].each{|file| print `#{ENV['RUBY'] || :ruby} -c #{file} | fgrep -v "Syntax OK"`}
end
