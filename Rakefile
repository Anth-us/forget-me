# Rakefile

require 'rspec/core/rake_task'

desc 'Run all RSpec tests'
RSpec::Core::RakeTask.new(:spec)

desc 'Start Guard'
task :guard do
  exec 'bundle exec guard'
end

task default: :spec
