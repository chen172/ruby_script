#!/usr/bin/ruby
#encoding: utf-8

require 'json'
require 'net/http'
require 'uri'

aFile = File.new("all_ball_number.txt", "a+")

year = 3
i = year*1000 + 1
i=3001
for node in 1..2943
	date = i.to_s
	if i < 10000
	date = "0" + date
	end
	$page = "https://kaijiang.500.com/shtml/ssq/" + date + ".shtml"

puts $page
# api request
url = URI.parse($page)
req = Net::HTTP::Get.new url 
begin
	res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http| http.request req}
rescue 
	puts "retry connection"
	retry
end

content = res.body
if content.include? "<head><title>404 Not Found</title></head>"
	year = year + 1
	i = year*1000 + 1
	puts "next year"
	next
end

if content.include? "Result2"
	year = year + 1
	i = year*1000 + 1
	puts "next year"
	next
end
	i = i + 1

	if aFile
		aFile.syswrite(date)
		aFile.syswrite(":")
	else
		puts "unable open file!"
	end
content.each_line {|line| 
	if line.include? "<li class=\"ball_red\">"
		number_start = line.index("<li class=\"ball_red\">") + 21
		number = line[number_start..number_start+1]
		#puts number
		if aFile
			aFile.syswrite(number)
			aFile.syswrite(",")
		else
			puts "unable open file!"
		end
	end
	if line.include? "<li class=\"ball_blue\">"
		number_start = line.index("<li class=\"ball_blue\">") + 22
		number = line[number_start..number_start+1]
		#puts number
		if aFile
			aFile.syswrite(number)
			aFile.syswrite(",")
		else
			puts "unable open file!"
		end
	end
}
if aFile
	aFile.syswrite("\n")
else
	puts "unable open file!"
end
end
aFile.close()					
