#!/usr/bin/ruby
#encoding: utf-8

require 'json'
require 'net/http'
require 'uri'

if ARGV.empty?
	puts "You must add a url"
	exit
end

page_url = ARGV[0]

def get_directory_name(page)
# delete last character in url
if (page[page.length-1] == "/")
	page = page.chop
end

# get the directory name
directory_start = page.rindex("/") + 1
if page.index("?", directory_start) == nil
	directory_end = page.length
else
	directory_end = page.index("?", directory_start) - 1
end

directory_name = page[directory_start..directory_end]
directory_name = URI.decode_www_form_component(directory_name)
if (directory_name == "") 
	abort("not get directory name")
end	

if !Dir.exists?(directory_name)
	Dir.mkdir(directory_name)
end
puts "Downloading file to #{directory_name} directory"
return directory_name
end



def get_hrefs(content, filter1 = "<a href=\"/area/", filter2 = ">", filter1_len = 9, return_filename = false)
hrefs = Array.new
filenames = Array.new
content.each_line {|line| 
	if line.include? filter1
		# get href
		href_start = line.index(filter1) + filter1_len
		href_end = line.index(filter2, href_start) - filter2.length - 1
		href = line[href_start..href_end]
		# filter below href
		if (href == "/prefix/" || href == "/area/")
			next
		end
		
		# put all href together	
		hrefs << (href + "\n")
		
		# get href correspond filename			
		filename_start = href_end + 3			
		filename_end = line.index("<", href_end)-1			
		filename = line[filename_start..filename_end]
		
		# put all filename together	
		filenames << (filename + "\n")
	end
}

# return all hrefs and filenames
if return_filename
	return hrefs, filenames
else
	return hrefs
end

end

def url_request(url_str)
	# api request
	url = URI.parse(url_str)
	req = Net::HTTP::Get.new url 
	begin
		res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http| http.request req}
	rescue 
		puts "retry connection"
		retry
	end
	
	return res
end

=begin
content.each_line {|line| 
	if line.include? "<a href=\"/area/"
		# get href
		href_start = line.index("<a href=\"/area/") + 9
		href_end = line.index(">", href_start)-2
		href = line[href_start..href_end]
		# filter below href
		if (href == "/prefix/" || href == "/area/")
			next
		end
		puts href
	end
}
=end

# create directory
#directory_name = get_directory_name(page_url)
host = URI.parse(page_url).host
res = url_request(page_url)

# get all city hrefs
hrefs= get_hrefs(res.body, "<a href=\"/area/", ">", 9, false)

for i in 0..hrefs.length-1 
	line = hrefs[i]
		# delete the last '\n'
		line = line.chomp
		
		href = URI.encode_www_form_component(line)
		href = href.gsub(/\%2F/, '/')
		file_url = "https://" + host + href
		puts file_url
		# create subdirectory
	subdirectory_name = get_directory_name(file_url)
	
	# request a city
	res_city = url_request(file_url)
	hrefs_city, filenames_city = get_hrefs(res_city.body, "<a href=\"/prefix/", ">", 9, true)
	for j in 0..hrefs_city.length-1
		line_phone = hrefs_city[j]
			# delete the last '\n'
		line_phone = line_phone.chomp
		
		href_phone = URI.encode_www_form_component(line_phone)
		href_phone = href_phone.gsub(/\%2F/, '/')
		file_url_phone = "https://" + host + href_phone
		puts file_url_phone
	
	# request a city phone
	res_city_phone = url_request(file_url_phone)
	
			# save file
			filename = filenames_city[j]		
		aFile = File.new(subdirectory_name.force_encoding(Encoding::UTF_8) + "/" + filename.force_encoding(Encoding::UTF_8), "w")
		if aFile
			res_city_phone.body.each_line {|line_prefix| 
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
end
=begin
hrefs.each_line {|line| 
		# delete the last '\n'
		line = line.chomp
		
		href = URI.encode_www_form_component(line)
		href = href.gsub(/\%2F/, '/')
		file_url = "https://" + host + href
		
		# create subdirectory
	subdirectory_name = get_directory_name(file_url)
		#puts file_url
				# save file		
		#aFile = File.new(subdirectory_name.force_encoding(Encoding::UTF_8) + "/" + filename.force_encoding(Encoding::UTF_8), "w")
	# request city
	res_city = url_request(file_url)
	hrefs_city, filenames_city = get_hrefs(res_city.body, "<a href=\"/prefix/", ">", 9, true)
		filenames_city.each_line {|line_city|
		puts line_city
	}

=end
