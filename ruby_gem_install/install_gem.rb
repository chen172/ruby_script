require 'json'
require 'net/http'

if ARGV.empty?
	puts "You must add a filename"
	exit
end

$filename = ARGV[0]

# get the written pronunciation in Merriam-Webster format
# and get audio playback information
File.open($filename, "r") do |file|
	file.each_line {|line| $word = line.chomp

	if $word[0] == "#"
		next
	end
	
	if $word.include? "gem '"
		package_start = $word.index("'") + 1;
		package_end = $word.index("'", package_start);
		#puts $word
		# get package name
		package = $word[package_start..package_end-1];
		puts package
		version_start = $word.index("'", package_end+1);
		if !version_start.nil?
			version_start = version_start + 1;
			version_end = $word.index("'", version_start);
			version = $word[version_start..version_end-1];
			if !$word.index("~>", version_start).nil?
				number_start = $word.index("~>", version_start);
			elsif !$word.index(">=", version_start).nil?
				number_start = $word.index(">=", version_start);
			else
				puts "no version"
			end
			if !number_start.nil?
				number_start = number_start + 3;
				number = $word[number_start..version_end-1];
				puts number
				code = "sudo gem install " + package + " -v " + "\"" + number + "\"";
				puts code;
				system(code);
				#sudo gem install rack -v “2.2.4”
			end
			#puts version
		end

	end
	}
end
		
