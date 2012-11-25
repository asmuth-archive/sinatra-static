Gem::Specification.new do |s|
  s.name = "sinatra-static"
  s.version = "0.1.1"
  
  s.authors = ["Paul Asmuth"]
  s.date = "2011-10-16"
  s.description = "export your sinatra app to a directory of static files"
  s.email = "paul@paulasmuth.com"
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "sinatra-static.gemspec",
    "lib/sinatra_static.rb",
    "readme.md"
  ]
  s.homepage = "http://github.com/paulasmuth/sinatra-static"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "export your sinatra app to a directory of static files"
  s.add_runtime_dependency 'term-ansicolor'
  s.add_runtime_dependency 'sinatra'
  s.add_runtime_dependency 'sinatra-advanced-routes'
  s.add_runtime_dependency 'rack'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'test-unit'
end

