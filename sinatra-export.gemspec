Gem::Specification.new do |s|
  s.name = 'sinatra-export'
  s.version = '1.0.1'
  
  s.authors = ['Jean-Philippe Doyle', 'Paul Asmuth']
  s.description = 'Exports all your Sinatra application routes to static files in your public folder'
  s.summary = 'Sinatra static export.'
  s.email = 'jeanphilippe.doyle@hooktstudios.com'
  s.cert_chain  = ['certs/j15e.pem']
  s.signing_key = File.expand_path('~/.gem/private_key.pem') if $0 =~ /gem\z/
  s.files = [
    'Gemfile',
    'Gemfile.lock',
    'sinatra-export.gemspec',
    'lib/sinatra/export.rb',
    'lib/sinatra/export/rake.rb',
    'README.md',
    'LICENSE',
    'UPGRADING'
  ]
  s.homepage = 'http://github.com/hooktstudios/sinatra-export'
  s.license = 'MIT'
  s.required_ruby_version = '>= 1.8.7'

  if File.exists?('UPGRADING')
    s.post_install_message = File.read("UPGRADING")
  end

  s.add_runtime_dependency 'term-ansicolor'
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'sinatra-advanced-routes'
  s.add_runtime_dependency 'rack'
  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'rack-test'
  s.add_development_dependency 'rack-test'
end

