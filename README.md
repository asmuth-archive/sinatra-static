# sinatra-export

> Exports all your Sinatra application routes to static files in your public folder.

[![Build Status](https://travis-ci.org/hooktstudios/sinatra-export.png)](https://travis-ci.org/hooktstudios/sinatra-export)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/hooktstudios/sinatra-export)

## Installation

Add to your `Gemfile` :

```ruby
gem 'sinatra-export'
```

Setup your application with [sinatra-advanced-routes](https://github.com/hooktstudios/sinatra-advanced-routes) :

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

Or invoke it manually :

````ruby
Sinatra::Export.new(App).build!
```

### Assets management and more

If you wish to generate your assets (css, images, etc) with a packaging system,
you may use [Sinatra-AssetPack](https://github.com/hooktstudios/sinatra-assetpack)
and build your assets in the same target directory with `rake assetpack:build` task.

You may also have a look at [sinatra-static-bp](https://github.com/hooktstudios/sinatra-static-bp)
boilerplate to setup a simple exportable Sinatra app, using both gems.