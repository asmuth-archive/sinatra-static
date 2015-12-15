# sinatra-export

> Exports all your Sinatra application routes to static files in your public folder.

[![Build Status](https://travis-ci.org/hooktstudios/sinatra-export.png?branch=master)](https://travis-ci.org/hooktstudios/sinatra-export)
[![Dependency Status](https://gemnasium.com/hooktstudios/sinatra-export.png)](https://gemnasium.com/hooktstudios/sinatra-export)
[![Code Climate](https://codeclimate.com/github/hooktstudios/sinatra-export.png)](https://codeclimate.com/github/hooktstudios/sinatra-export)
[![Gem Version](https://badge.fury.io/rb/sinatra-export.png)](https://rubygems.org/gems/sinatra-export)

## Installation

```ruby
# Gemfile
gem 'sinatra-export'
```

```ruby
# Rakefile
APP_FILE  = 'app.rb'
APP_CLASS = 'Sinatra::Application'

require 'sinatra/export/rake'
```

## Quick Start

Sample Sinatra application building static pages :

```ruby
require 'sinatra'
require 'sinatra/export'

get '/' do
  "<h1>My homepage</h1>"
end

get '/contact' do
  "<h1>My contact page<h1>"
end

get '/data.json' do
  "{test: 'ok'}"
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
Sinatra::Application.export!
```

## Advanced usage ##

### Supplied paths ###

If you wish to specify specific paths to be visited (only):

````ruby
Sinatra::Application.export! paths: ["/", "/contact"]
```

Only the homepage and the contact page would be visited (these would be visited anyway, but lets start off simple!) If you wanted the paths you specify *and* any paths that Sinatra::AdvancedRoutes can find then you could use:

````ruby
Sinatra::Application.export! paths: ["/", "/contact"], use_routes: true
```

Now all the routes listed above would be found. But what if you have some routes with wildcards or named captures?

````ruby
get '/articles/:slug' do
  # an article is retrieved via params["slug"]
  # but we'll stub one in for this example:
  markdown("# I have wonderful news! #\n\nYou can use wildcard routes now.\n")
end
```

You could access that route as well via:

````ruby
Sinatra::Application.export! paths: ["/articles/i-have-wonderful-news"], use_routes: true
```

### Supplying statuses ###

Perhaps you would like a static 404 page.

````ruby
not_found do
  halt 404, haml(:not_found)
end
```

By default, Sinatra Export will only use routes that return an HTTP status code of 200. If you want non 200 pages then supply the path with the expected status in an array, for example:

````ruby
Sinatra::Application.export! paths: ["/articles/i-have-wonderful-news",["/404.html",400]], use_routes: true
```

Among the static files output you will find 404.html.

### Skipping pages ###

If you want to ignore certain pages no matter what, supply them via the `skip` keyword in a list:

````ruby
Sinatra::Application.export! skips: ["/contact","/data.json"]
```

Only the "/" route will be output. This will work with supplied paths or routes found via `use_routes`.

### Non standard directory for output ###

By default, Sinatra Export will place the generated static files into the Sinatra app's public folder. If you want to put them somewhere else then you can use the `EXPORT_BUILD_DIR` environment variable. For example:

````ruby
ENV["EXPORT_BUILD_DIR"] = File.join ENV["HOME"], "projects/static"
Sinatra::Application.export!
```

The files would be in "~/projects/static"

## Super advanced usage ##

### Error handling ###

By default, Sinatra Export will skip routes that are non 200 status unless you supply the expected status for a page. When it hits an unexpected status it will output an error in red text to the terminal and continue processing. If you want to change this, you can supply your own error handler. For example, to stop processing when you hit an unexpected status code:

````ruby
Sinatra::Application.export! paths: ["/this-path-doesnt-exist"], error_handler: ->(desc){ fail "Didn't expect that! #{desc}" }
```

All that's needed is something that responds to `call` - so a proc, block or lambda - that takes 1 argument, a description string of the error.

### Supplying a process block ###

`export!` can take a block that will be run for every page that is processed. Inside the block, and instance of the `Builder` class (the one that does all the work, see the API docs via `rake yard` for more) will be accessible. For example, let's add a path during the processing:

````ruby
get '/this-route-has-an-internal-link' do
  "<a href='/articles/i-have-wonderful-news'>Follow this link!</a>"
end
```

Now to find that link:

````ruby
require 'hpricot' # nokogiri is available too
Sinatra::Application.export! do |builder|
  doc = Hpricot(builder.last_response.body)
  (doc/"a").map{|elem| URI( elem.attributes["href"] ) }
           .map(&:path).each do |path|
             builder.paths.push path unless builder.paths.include? path
           end
end
```

You'd probably want to check the links weren't external too.

**Note!** If you know something about arrays and some of the set like methods available then you'll think that the last block given to each could've been made shorter by using `|=` instead of `push` with `unless`. Be warned that under the hood the Builder is using an Enumerator to check each of the `paths`, and by using `|=` the paths will somehow become disassociated with the enumerator and your work will be in vain!

There's other stuff you could do in that block, the builder gives you access to `paths`, `skips` (both read/write); `visited` (a list of the paths visited so far), `errored` (a list of the paths that have called the error handler), the `last_path` (which inside the block will be the current path) and the `last_response`, so you can access things like the `last_response.status` and `last_response.body`.

### Filtering ###

If you want to apply a filter to every path that is written then you can supply those via the `filters` keyword:

````ruby
require 'hpricot' # nokogiri is available too
Sinatra::Application.export! filters: [->(text){ text.upcase }]
```

That would upcase everything. If you wanted you could do things like remove mentions of "localhost" or whatever.

````ruby
require 'hpricot' # nokogiri is available too
Sinatra::Application.export! filters: [->(text){ text.gsub("localhost", "example.org" }, ->(text){ text.gsub("http://", "https://" }]
```

`filter` takes an array, each item should respond to `call` and take 1 argument, the text to be filtered. Each filter will be applied in the order of the array.

## Other resources

* [capistrano-s3](http://github.com/hooktstudios/capistrano-s3) : build and deploy a static website to Amazon S3
* [sinatra-assetpack](https://github.com/rstacruz/sinatra-assetpack) : package your assets transparently in Sinatra
* [sinatra-static-bp](https://github.com/hooktstudios/sinatra-static-bp) : boilerplate to setup complete static website

## Contributing

See [CONTRIBUTING.md](https://github.com/hooktstudios/sinatra-export/blob/master/CONTRIBUTING.md) for more details on contributing and running test.

## Credits

![hooktstudios](http://hooktstudios.com/logo.png)

[sinatra-export](https://rubygems.org/gems/sinatra-export) is maintained and funded by [hooktstudios](https://github.com/hooktstudios)
