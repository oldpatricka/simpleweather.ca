#
# simpleweather.rb - a bitty ruby script to get Environment Canada weather 
#                    and just show you the good stuff.

require 'rubygems'
require 'sinatra'
require 'csv'
require 'haml'
require 'open-uri'


city_data = File.dirname(__FILE__) + "/data/citymap.csv"
city_code = {}
base_url = "http://text.www.weatheroffice.gc.ca/forecast/city_e.html?"

CSV::Reader.parse(File.open(city_data, "rb")) do |row|
  city_code[row[0]] = row[1]
end

get '/:city' do |city|
  if not city_code.has_key? city then
    "I'm too dumb to understand where #{city} is. Is that a real city?"
  else
    @code = city_code[city]
    @city = city
    response = ""

    open(base_url + @code) {|f| response = f.read }
    if response =~ /.*<dt>Condition:<\/dt><dd>(.*?)<\/dd>/ then
      @conditions = $1
    end
    if response =~/.*<dt>Temperature:<\/dt><dd>(.*?)<\/dd>/ then
      @temperature = $1
    end

    if @conditions then
      @conditions = "#{@temperature}, #{@conditions}"
    else
      @conditions = @temperature
    end

    haml :weather
  end
end

get '/' do
  'Hello. It looks like you want weather.'
end

