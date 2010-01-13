#
# simpleweather.rb - a bitty ruby script to get Environment Canada weather 
#                    and just show you the good stuff.



require 'rubygems'
require 'sinatra'

get '/:name' do
  "Hello. It looks like you want weather for #{params[:name]}"
end

get '/' do
  'Hello. It looks like you want weather.'
end

