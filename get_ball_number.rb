#!/usr/bin/ruby
#encoding: utf-8

require 'json'
require 'net/http'
require 'uri'

aFile = File.new("all_ball_number.txt", "a+")

=begin
year = 3
i = year*1000 + 1
i=3001
for node in 1..2948
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
			aFile.syswrite(":")
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
=end

$page = "https://kaijiang.500.com/static/info/kaijiang/xml/ssq/list.xml?_A=BLWXUIYA1546584359929"
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
content.each_line {|line| 
	if line.include? "expect"
		date_start = line.index("opentime=\"") + 10
		date = line[date_start..date_start+10]
		time = Time.local(date[0..3], date[5..6], date[8..10])
		puts time
		if aFile
			aFile.syswrite(time.yday)
			aFile.syswrite(":")
		else
			puts "unable open file!"
		end
		
		number_start = line.index("opencode=\"") + 10
		number = line[number_start..number_start+19]
		puts number
		if aFile
			for i in 0..5
				aFile.syswrite(number[i*3..i*3+1])
				aFile.syswrite(":")
			end
			aFile.syswrite(number[18..19])
			aFile.syswrite("\n")			
		else
			puts "unable open file!"
		end
	end
}

aFile.close()					
