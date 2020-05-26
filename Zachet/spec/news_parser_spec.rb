require_relative '../news_parser.rb'

RSpec.describe NewsParser do
  
  it "http get request to https://lenta.ru/parts/news/ " do
      news_parser = NewsParser.new
      doc = news_parser.find_news('https://lenta.ru/parts/news/','//*[@id="more"]/div')
      puts doc
  end

  it "http get request to https://ria.ru " do
      news_parser = NewsParser.new
      doc = news_parser.find_news('https://ria.ru','//*[@id="content"]/div[5]/div[1]/div[1]/div[1]')
      puts doc
  end

end
 