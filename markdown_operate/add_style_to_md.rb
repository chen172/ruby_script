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
		
			# add the third string
			newline = line[0, 2] + $add_str3 + line[2, line.length]
			
			# add the third string
			index = newline.index("|", 1)
			newline = newline.insert(index-1, $add_str3)
			
			# add the first string
			index = newline.index("|", 1)
			newline = newline[0, index+1] + $add_str1 + newline[index+1, newline.length]
			
			# add the second string
			index = newline.index("|", index+1)
			newline = newline.insert(index, $add_str2)
			a.syswrite(newline)
		end
	else
			a.syswrite(line)
	end
	}
end

system "mv tmp.md #$filename"
