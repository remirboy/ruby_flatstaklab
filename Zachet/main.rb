require './news_printer.rb'

puts "Последние 10  новостей с https://lenta.ru. Подробности там "
puts "Наберите /exit чтобы выйти"
puts "Нажмите enter чтобы продолжить"
while gets.chomp().to_s!='/exit'
  puts "Наберите /get чтобы обновить новости "
  if gets.chomp().to_s=='/get'
   	news_printer = NewsPrinter.new
	news_printer.print_news
   end 
end