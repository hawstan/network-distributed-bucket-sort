# -----
# Network-distributed Bucket Sort
# Class representing a key--value pair to be sorted
# Version 0.1
# -----
# Author hawstan (Stanley Hawkeye)
# Created 2013-10-23
# -----
# This is experimental implementation just for demonstration purposes.
# Use at your own risk.
# -----
class Node
	attr_accessor :key, :value
	
	def initialize(key, value)
		@key = key
		@value = value
	end
	
	def to_s
		return @key.to_s + " " + @value.to_s
	end
	

	def self.fromString(str)
		str = str.split(" ",2)
		return Node.new(str[0].to_i, str[1].to_i)
	end
	
	def getPacked()
		return [@key].pack("l>") + [@value].pack("l>")
	end
	
	def self.fromPacked(data)
		data = data.unpack("l>l>")
		return Node.new(data.shift, data.shift)
	end
end