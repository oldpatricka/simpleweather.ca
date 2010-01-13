#!/usr/bin/env ruby
#
# scrape_pages.rb - scrape ids of weather pages to names of cities, spit out 
#                   a list of them

require 'open-uri'

data_file = File.dirname(__FILE__) + "/../data/citymap.csv"
province_base_url = "http://text.www.weatheroffice.gc.ca/forecast/canada/index_e.html?id="
provinces = ["AB", "BC", "MB", "NB", "NL", "NT", "NS", "NU", "ON", "PE", "QC", "SK", "YT"]
response = ""
output = ""

provinces.each { |province|

  open(province_base_url + province) {|f| response = f.read }
  code_cities = response.scan(/city_e.html\?(.*)&amp;unit=m">(.*)<\/a>/)

  code_cities.each { |code_city|
    output += "#{code_city[0]},#{code_city[1]}\n"
  }

}

data_out = File.open(data_file, "w")
data_out.puts(output)
data_out.close
