#!/usr/bin/ruby
#encoding: utf-8

require 'json'
require 'net/http'
require 'uri'

if ARGV.empty?
	puts "You must add a url"
	exit
end

$page = ARGV[0]

# get the directory name
directory_start = $page.rindex("/") + 1
if $page.index("?", directory_start) == nil
	directory_end = $page.length
else
	directory_end = $page.index("?", directory_start) - 1
end

directory_name = $page[directory_start..directory_end]
directory_name = URI.decode_www_form_component(directory_name)
if (directory_name == "") 
	abort("not get directory name")
end	

if !Dir.exists?(directory_name)
	Dir.mkdir(directory_name)
end
puts "Downloading file to #{directory_name} directory"
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
	if line.include? "<a href=\"/prefix/"
		# get href
		href_start = line.index("<a href=\"/prefix/") + 9
		href_end = line.index(">", href_start)-2
		href = line[href_start..href_end]
		if (href == "/prefix/")
			next
		end
		
		# get href correspond filename			
		filename_start = href_end + 3			
		filename_end = line.index("<", href_end)-1			
		filename = line[filename_start..filename_end]
		puts filename
			
		# get file content from href
		href = URI.encode_www_form_component(href)
		href = href.gsub(/\%2F/, '/')
		file_url = "https://" + url.host + "/" + href + "/"

		url = URI.parse(file_url)
		req = Net::HTTP::Get.new url 
		begin
			res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http| http.request req}
		rescue 
			puts "retry connection"
			retry
		end

		# save file		
		aFile = File.new(directory_name.force_encoding(Encoding::UTF_8) + "/" + filename.force_encoding(Encoding::UTF_8), "w")
		if aFile
			res.body.each_line {|line_prefix| 
			if line_prefix.include? "<a href=\"/prefix/"
				# get phone prefix
				prefix_start = line_prefix.index("<a href=\"/prefix/") + 9 + 8
				prefix_end = line_prefix.index(">", prefix_start)-2-1
				prefix = line_prefix[prefix_start..prefix_end]
				if (prefix.length == 7)
					aFile.syswrite(prefix)
					aFile.syswrite("\n")
				end
			end
			}
		else
			puts "Unable to open file!"
		end					
	end			
}
