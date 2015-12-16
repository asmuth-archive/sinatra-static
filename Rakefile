require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb']   # optional
    t.options = ['--any', '--extra', '--opts'] # optional
    t.stats_options = ['--list-undoc']         # optional
  end
rescue LoadError
end