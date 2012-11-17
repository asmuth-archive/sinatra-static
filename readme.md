# sinatra-static

> Exports your Sinatra app to static files. Depends on [sinatra-advanced-routes](https://github.com/rkh/sinatra-advanced-routes).

## Installation

Add `sinatra-static` to your Gemfile :

    gem 'sinatra-static', '>= 0.1.1'

## Usage

```ruby
builder = SinatraStatic.new(App)
builder.build!('public/')
```

## Getting started

Sample Sinatra application building static pages :

```ruby
require 'sinatra'
require 'sinatra/advanced_routes'
require 'sinatra_static'

class App < Sinatra::Base

    register Sinatra::AdvancedRoutes

    get '/' do    
        "homepage"
    end

    get '/contact' do
        "contact"
    end

    get '/data.json' do
        "{json: 1}"
    end

end

builder = SinatraStatic.new(App)
builder.build!('public/')
```

Running your app ex. `ruby app.rb` will automatically generate theses files :

    public/index.html              -> "homepage"
    public/contact/index.html      -> "contact"
    public/data.json               -> "{json: 1}"

### Advanced assets management

If you wish to generate your assets (CSS, JS, images) with an assets packaging system,
you may use [Sinatra-AssetPack](https://github.com/rstacruz/sinatra-assetpack) and build
your assets in the same target directory with `rake assetpack:build` task.

IMPORTANT : to achieve `Sinatra-AssetPack` and `Sinatra-Static` compatibility, see [pull request #1](https://github.com/paulasmuth/sinatra-static/pull/1).