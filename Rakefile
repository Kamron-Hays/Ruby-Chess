require 'rspec/core/rake_task'

task :default => :spec

desc "Play chess"
task :play do
  ruby "chess.rb"
end

desc "Run tests"
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = "-fdoc"
end
