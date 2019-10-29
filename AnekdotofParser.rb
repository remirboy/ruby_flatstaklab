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


def toDb(arr, table)
	begin
	i = 1;
	require 'pg'
	con = PG.connect :dbname => 'remir', :user => 'remir'
	for text in arr do
		rs = con.exec "SELECT * FROM " + table + " WHERE type=" + "'" + text + "';"
		if rs.ntuples == 0 then
		con.exec "INSERT INTO " + table + " VALUES ('" + text + "');"
		puts i.to_s + " " + text
		i += 1
		end
	end
	
	rescue PG::Error => e
	puts e.message
	
	ensure
	con.close if con
	end
end

def jokeSearch(request,link)
	for el in 0...link.length()
	if /#{request}/=~link[el] then
		puts link[el].text
		joke = link[el].text
	end
end
	
end


toDb(link, "jokes")

request=""

joke=""

while request!="exit"
	puts "Enter word for search"
	request = gets.chomp().to_s
	jokeSearch(request,link)
end
