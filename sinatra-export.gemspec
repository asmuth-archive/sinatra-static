Gem::Specification.new do |s|
  s.name = 'sinatra-export'
  s.version = '0.9.4'
  
  s.authors = ['Jean-Philippe Doyle', 'Paul Asmuth']
  s.date = '2013-01-16'
  s.description = 'Exports all your Sinatra application routes to static files in your public folder'
  s.summary = 'Sinatra static export.'
  s.email = 'jeanphilippe.doyle@hooktstudios.com'
  s.files = [
    'Gemfile',
    'Gemfile.lock',
    'sinatra-export.gemspec',
    'lib/sinatra/export.rb',
    'lib/sinatra/export/rake.rb',
    'README.md',
    'LICENSE'
  ]
  s.homepage = 'http://github.com/hooktstudios/sinatra-export'
  s.license = 'MIT'
  s.required_ruby_version = '>= 1.8.7'

  s.add_runtime_dependency 'term-ansicolor'
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'sinatra-advanced-routes'
  s.add_runtime_dependency 'rack'
end

