require 'nokogiri'
require 'open-uri'
require 'json'

url = 'https://nekdo.ru/'
html = open(url)

doc = Nokogiri::HTML(html)
k=1
link = doc.search('//*[@class="text"]')
for el in 0...link.length()
	puts k
	puts link[el].content
	k=k+1
	end



#anekdots = []
#id = []
#description=''
#    tags = doc.xpath('//div')
#      tags.each do |tag|
#      description = tags.map { |t| t[:class] }
 #   end

#doc.css('.text').each do |showing|
 # 	anekdot_id = showing['id'].split('"').last.to_i
#  	description = showing.search('//*[@class="text"]').text
#    id.push(anekdot_id:anekdot_id,description:description)
 #  end

#puts description
# k=0





