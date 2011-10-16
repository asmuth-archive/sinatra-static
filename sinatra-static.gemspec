Gem::Specification.new do |s|
  s.name = "sinatra-static"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Asmuth"]
  s.date = "2011-10-16"
  s.description = "export your sinatra app to a directory of static files"
  s.email = "paul@paulasmuth.com"
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "sinatra-static.gemspec",
    "lib/sinatra_static.rb",
    "readme.rdoc"
  ]
  s.homepage = "http://github.com/paulasmuth/sinatra-static"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "export your sinatra app to a directory of static files"
  s.test_files = [ ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<term-ansicolor>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra-advanced-routes>, [">= 0"])    
      s.add_runtime_dependency(%q<rack>, [">= 0"])
      s.add_runtime_dependency(%q<rack-test>, [">= 0"])
    else
      s.add_dependency(%q<term-ansicolor>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<sinatra-advanced-routes>, [">= 0"])    
      s.add_dependency(%q<rack>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
    end
  else
    s.add_dependency(%q<term-ansicolor>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<sinatra-advanced-routes>, [">= 0"])    
    s.add_dependency(%q<rack>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
  end
end

