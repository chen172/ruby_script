$add_str1 = " <serif>"
$add_str2 = "</serif> "
$add_str3 = "**"

$filename = ARGV[0]

a = File.open("tmp.md", "w")
table_line = 0;
# get the written pronunciation in Merriam-Webster format
# and get audio playback information
File.open($filename, "r") do |file|
	
	file.each_line {|line|
	if line[0] == "|"
		if table_line != 2		
			table_line = table_line + 1
			a.syswrite(line)
		else
		
			# find the second column
			index = line.index("|", 1)
			
			# find the third column
			index = line.index("|", index+1)
			
			index = line.index("(", index+1)			
			newline = line[0, index] + " |\n"

			a.syswrite(newline)
		end
	else
			a.syswrite(line)
	end
	}
end

a.close
system "mv tmp.md #$filename"
