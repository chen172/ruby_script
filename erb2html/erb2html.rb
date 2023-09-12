require 'erb'
#require 'rails/all'
require 'render_anywhere'

if ARGV.empty?
	puts "You must add a filename"
	exit
end

erb_file = ARGV[0]
html_file = File.basename(erb_file, '.erb') #=>"page.html"

erb_str = File.read(erb_file)

@name = "John"
renderer = ERB.new(erb_str)
result = renderer.result(binding)

File.open(html_file, 'w') do |f|
  f.write(result)
end
