# sinatra-export

> Exports all your Sinatra application routes to static files in your public folder.

[![Build Status](https://travis-ci.org/hooktstudios/sinatra-export.png)](https://travis-ci.org/hooktstudios/sinatra-export)
[![Dependency Status](https://gemnasium.com/hooktstudios/sinatra-export.png)](https://gemnasium.com/hooktstudios/sinatra-export)
[![Code Climate](https://codeclimate.com/github/hooktstudios/sinatra-export.png)](https://codeclimate.com/github/hooktstudios/sinatra-export)
[![Gem Version](https://badge.fury.io/rb/sinatra-export.png)](https://rubygems.org/gems/sinatra-export)

## Installation

Add to your `Gemfile` :

```ruby
gem 'sinatra-export'
```

Setup your application with [sinatra-advanced-routes](https://github.com/rkh/sinatra-advanced-routes) :

```ruby
register Sinatra::AdvancedRoutes
```

Setup your `Rakefile` :

```ruby
APP_FILE  = 'app.rb'
APP_CLASS = 'App'

require 'sinatra/export/rake'
```

## Quick Start

Sample Sinatra application building static pages :

```ruby
require 'sinatra'
require 'sinatra/advanced_routes'
require 'sinatra/export'

class App < Sinatra::Base

    register Sinatra::AdvancedRoutes

    get '/' do    
        "<h1>My homepage</h1>"
    end

    get '/contact' do
        "<h1>My contact page<h1>"
    end

    get '/data.json' do
      "{test: 'ok'}"
    end

end
```

Running your app ex. `rake sinatra:export` will automatically generate theses files :

    public/index.html              -> "<h1>My homepage</h1>"
    public/contact/index.html      -> "<h1>My contact page<h1>"
    public/data.json               -> "{test: 'ok'}"

## Usage

    $ rake sinatra:export

Or invoke it manually within ruby code :

````ruby
Sinatra::Export.new(App).build!
```

## Other resources

* [capistrano-s3](http://github.com/hooktstudios/capistrano-s3) : build and deploy a static website to Amazon S3
* [sinatra-assetpack](https://github.com/rstacruz/sinatra-assetpack) : package your assets transparently in Sinatra
* [sinatra-static-bp](https://github.com/hooktstudios/sinatra-static-bp) : boilerplate to setup complete static website

## Contributing

See [CONTRIBUTING.md](https://github.com/hooktstudios/sinatra-export/blob/master/CONTRIBUTING.md) for more details on contributing and running test.

## Credits

![hooktstudios](http://hooktstudios.com/logo.png)

[sinatra-export](https://rubygems.org/gems/sinatra-export) is maintained and funded by [hooktstudios](https://github.com/hooktstudios)
