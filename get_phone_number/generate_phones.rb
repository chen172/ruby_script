require 'json'
require 'net/http'

if ARGV.empty?
	puts "You must add a filename"
	exit
end

$filename = ARGV[0]

output_file = File.basename($filename) + "_phones" + ".txt"
aFile = File.new(output_file, "a+")

File.open($filename, "r") do |file|
	file.each_line {|line| $word = line.chomp

	if $word[0] == "#"
		next
	end
	
	for i in 0..9999
		suffix = "%04d" % i
		phone = $word + suffix
		
		if aFile
			aFile.syswrite(phone+"\n")
		else
			puts "Unable to open file!"
		end
	end
	}
end
aFile.close

