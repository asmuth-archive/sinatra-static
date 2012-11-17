# sinatra-static

> Exports your Sinatra app to static files. 
Requires "sinatra-advanced-routes". 
Get requests and response-status 200 only (no redirects). you also have to copy the public-dir yourself (if you're using it).

## Installation

Add `sinatra-static` to your Gemfile

    gem 'sinatra-static', '>= 0.1.1'

## Usage

    builder = SinatraStatic.new(App)
    builder.build!('public/')

## Getting started

Sample Sinatra application :

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

    end

    builder = SinatraStatic.new(App)
    builder.build!('public/')

Will generate this output when run :

    public/index.html              -> "homepage"
    public/contact/index.html      -> "contact"
