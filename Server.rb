# -----
# Network-distributed Bucket Sort
# Server part
# Version 0.1
# -----
# Author hawstan (Stanley Hawkeye)
# Created 2013-10-23
# -----
# This is experimental implementation just for demonstration purposes.
# Use at your own risk.
# -----

require 'socket'
include Socket::Constants

load 'Node.rb'

class Bucket
	attr_accessor :socket, :left, :right
	
	def initialize(socket, left, right)
		@socket = socket
		@left = left
		@right = right
	end
	
	def shallContain(number)
		return (left <= number and number <= right)
	end
end

puts "Input file?"
inputFileName = gets.chomp
if not File.exists?(inputFileName)
	puts "Input file #{inputFileName} doesn't exist."
	exit()
end

puts "Output file?"
outputFileName = gets.chomp
if not File.exists?(outputFileName)
	puts "Output file #{inputFileName} doesn't exist."
	exit
end

puts "Hostname (please a valid one)?"
hostname = gets.chomp

puts "Port?"
port = gets.chomp.to_i
if not (0 < port and port < 65535)
	puts "Please use port between 1 and 65535"
	exit
end

puts "Lower bound?"
lower = gets.chomp.to_i

puts "Upper bound?"
upper = gets.chomp.to_i

count = upper - lower + 1

buckets = []

server = TCPServer.new(hostname, port)
server.listen(5)

loop do
	puts "Waiting for bucket to connect"
	begin
		socket = server.accept
		buckets.push Bucket.new(socket, nil, nil)
	rescue
		puts "An error occured."
	end
	
	puts "There are "+buckets.size.to_s+" clients connected."
	puts "Wait for another?"
	break unless gets =~ /^y/i
end

perBucket = count.fdiv(buckets.size).ceil
current_left = lower

buckets.each do |bucket|
	bucket.left = current_left
	bucket.right = current_left + perBucket
	current_left = current_left + perBucket + 1
end

# send data to buckets
inputFile = File.new(inputFileName, "r")
totalNumbers = 0
while line = inputFile.gets do
	# send to the right bucket
	newNode = Node.fromString(line.chomp)
	buckets.each do |bucket|
		next if not bucket.shallContain(newNode.key)
		totalNumbers = totalNumbers + 1
		bucket.socket.puts ">" + newNode.getPacked()
	end
end
inputFile.close

puts "There are totally #{totalNumbers} items."

# receive data from buckets
outputFile = File.new(outputFileName, "w")
buckets.each do |bucket|
	puts "Reading from bucket #{bucket.left} to #{bucket.right}"
	bucket.socket.puts "<"
	while data = bucket.socket.recv(8) do
		if data == nil
			puts "data is nil Panic! Invalid condition! next"
			next
		end
		break if data == "="
		outputFile.puts(Node.fromPacked(data).to_s)
	end
	bucket.socket.close
end
outputFile.close
puts "Done"
