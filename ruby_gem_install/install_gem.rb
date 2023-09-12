require 'json'
require 'net/http'

if ARGV.empty?
	puts "You must add a filename"
	exit
end

$filename = ARGV[0]

if $filename == "Gemfile"
File.open($filename, "r") do |file|
	file.each_line {|line| $word = line.chomp
	# TODO: fix # not at start
	if $word[0] == "#"
		next
	end
	
	# TODO: quote bug
	if $word.include? "gem '"
		quote = "'"
	elsif $word.include? "gem \""
		quote = "\""
	else
		quote = nil
	end
	if quote
		package_start = $word.index(quote) + 1;
		package_end = $word.index(quote, package_start);
		#puts $word
		# get package name
		package = $word[package_start..package_end-1];
		puts package
		version_start = $word.index(quote, package_end+1);
		# has version
		if !version_start.nil?
			# get version
			version_start = version_start + 1;
			version_end = $word.index(quote, version_start);
			version = $word[version_start..version_end-1];
			#puts "version is: " + version
			if !$word.index("~>", version_start).nil?
				number_start = $word.index("~>", version_start);
				number_start = number_start + 3;
				number = $word[number_start..version_end-1];
			elsif !$word.index(">=", version_start).nil?
				number_start = $word.index(">=", version_start);
				number_start = number_start + 3;
				number = $word[number_start..version_end-1];
			# TODO: robost check
			else
				number = version
			end
			if 1
				
				puts "version number is: "+number
				code = "gem install " + package + " -v " + "\"" + number + "\"";
				puts "code is: "+code;
				system(code);
				#sudo gem install rack -v “2.2.4”
			end
			#puts version
		
		else
			# no version
		# get version from Gemfile.lock
			File.open("Gemfile.lock", "r") do |file|
				file.each_line {|line| line = line.chomp
				if line.include? package+" ("
					# get version
					version_start = line.index("(") + 1;
					version_end = line.index(")");
					version = line[version_start..version_end-1];
					number = version
					break
				end
			#version_start = version_start + 1;
			#version_end = $word.index("'", version_start);
			#version = $word[version_start..version_end-1];

			}
		end
		
		puts "version number is: "+number
		code = "gem install " + package + " -v " + "\"" + number + "\"";
		puts "code is: "+code;
		system(code);
		end

	end
	}
end
end

if $filename == "Gemfile.checksum"
	File.open($filename, "r") do |file|
	file.each_line {|line| $word = line.chomp

	if $word[0] == "#"
		next
	end
	
	if $word.include? "name"
		package_start = $word.index(":") + 2;
		package_end = $word.index("\"", package_start);
		#puts $word
		# get package name
		package = $word[package_start..package_end-1];
		puts package
		version_start = $word.index(":", package_end+1);
		if !version_start.nil?
			version_start = version_start + 2;
			version_end = $word.index("\"", version_start);
			version = $word[version_start..version_end-1];

			if !version.nil?
				puts version
				code = "sudo gem install " + package + " -v " + "\"" + version + "\"";
				puts code;
				system(code);
				#sudo gem install rack -v “2.2.4”
			end
			#puts version
		end

	end
	}
end
end
		
