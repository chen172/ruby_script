require 'json'
require 'net/http'

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
	if line.include? "ls-mode"
		# get href
		href_start = line.rindex("href") + 6
		href_end = line.index(">", href_start)-2
		href = line[href_start..href_end]
		
		# get href correspond filename
		href_start = line.index("href") + 6
		href_end = line.index(">", href_start)-2	
		filename_start = href_end + 3			
		filename_end = line.index("<", href_end)-1			
		filename = line[filename_start..filename_end]
		puts filename
			
		# get file content from href
		file_url = "https://" + url.host + href
		url = URI.parse(file_url)
		req = Net::HTTP::Get.new url 
		begin
			res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http| http.request req}
		rescue 
			puts "retry connection"
			retry
		end
		
		
		# save file
		
		aFile = File.new(directory_name + "/" + filename, "a+")
		if aFile
			aFile.syswrite(res.body)
		else
			puts "Unable to open file!"
		end	
	end			
}
