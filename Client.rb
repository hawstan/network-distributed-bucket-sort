# -----
# Network-distributed Bucket Sort
# Client part
# Version 0.1
# -----
# Author hawstan (Stanley Hawkeye)
# Created 2013-10-23
# -----
# This is experimental implementation just for demonstration purposes.
# Use at your own risk.
# -----

require 'socket'
load 'Node.rb'

puts "Server hostname?"
hostname = gets.chomp
puts "Server port?"
port = gets.chomp.to_i

if not (0 < port and port < 65535)
	puts "Please use port between 1 and 65535"
	exit
end

sorted = []

puts "Connecting to #{hostname}:#{port}..."
socket = TCPSocket.new(hostname, port)
puts "Ready to sort!"
while line = socket.gets do
	line.chomp!
	next if( line == nil)
	caseChar = String.new(line[0])
	line = line[1,line.length]
	case caseChar
	when ">" # incoming number to be sorted
		data = line.unpack("l>l>")
		newNode = Node.new(data[0],data[1])
		i=0
		while i < sorted.size do
			break if(sorted[i].key > newNode.key)
			i = i + 1
		end
		sorted.insert(i, newNode)
	when "<" # request for sorted list
		sorted.each do |item|
			socket.print([item.key].pack("l>") + [item.value].pack("l>"))
		end
		socket.print("=") # end of list
		break # After sending the sorted list, the client closes connection
	end
end
socket.close
puts "Connection closed."
