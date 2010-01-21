#
# simpleweather.rb - a bitty ruby script to get Environment Canada weather 
#                    and just show you the good stuff.
require 'open-uri'
require 'csv'

require 'rubygems'
require 'sinatra'
require 'haml'
require 'amatch'


city_data = File.dirname(__FILE__) + "/data/citymap.csv"
city_code = {}
base_url = "http://text.www.weatheroffice.gc.ca/forecast/city_e.html?"

CSV::Reader.parse(File.open(city_data, "rb")) do |row|
  city_code[row[0]] = row[1]
end

get '/:city' do |city|
  if not city_code.has_key? city then

    # Do a search to see if we can find a similarly spelled weather station
    m = Amatch::LongestSubsequence.new(city)
    matches = []
    best_distance = 0

    city_code.keys.each do |key|

      # First check to see that it's not a case issue (eg. Vancouver/vancouver)
      if key.downcase == city.downcase then
        redirect "/" + key
      end

      distance = m.match(key)

      if distance > best_distance then
        best_distance = distance
        matches = [key]

      elsif distance == best_distance then
        matches << key
      end

    end
    
    @city = matches.first
    @suggest_url = "/" + @city
    haml :didyoumean

  else
    code = city_code[city]
    @city = city
    @weatherurl = base_url + code

    response = ""
    open(base_url + code) {|f| response = f.read }
    if response =~ /.*<dt>Condition:<\/dt><dd>(.*?)<\/dd>/ then
      @conditions = $1
    end
    if response =~/.*<dt>Temperature:<\/dt><dd>(.*?)<\/dd>/ then
      @temperature = $1
    end

    if @conditions and @temperature then
      @conditions = "#{@temperature}, #{@conditions}"
    elsif @temperature then
      @conditions = @temperature
    elsif not @conditions and not @temperature then
      @conditions = "No observations. Forecast at Weatheroffice."
    end

    haml :weather
  end
end

get '/' do
  if params[:city] then
    redirect "/" + params[:city]
  end
  @city = "canada"
  haml :pickcity
end

