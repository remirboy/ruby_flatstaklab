require './news_parser.rb'
require 'nokogiri'

class NewsPrinter

attr_accessor :doc,

def initialize

end

def print_news
  news_parser = NewsParser.new
  doc = news_parser.find_news('https://lenta.ru/parts/news/','//*[@id="more"]/div')
    for el in 0...10
      puts el+1
	  topic =  doc[el].content.split('—')[0]
	  time = doc[el].content.slice(topic.to_s.length+2..topic.to_s.length+6)
	  content = doc[el].content.slice(topic.to_s.length+7..doc[el].content.length)
	  puts 'Тема:' "#{topic}"
	  puts 'Время публикации:'  "#{time}"
	  puts 'Контент:' "#{content}"
	end
  end
end