require 'nokogiri'
require 'open-uri'

class NewsParser

attr_accessor :link,

def initialize

end

def find_news(url,xpath)
  html = open(url)
  doc = Nokogiri::HTML(html)
  link = doc.search(xpath)
  return link
end
end
