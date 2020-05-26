require_relative '../news_printer.rb'

RSpec.describe NewsPrinter do
  
  it "news printer" do
    news_printer = NewsPrinter.new
	expect(news_printer.print_news)
  end


end
 