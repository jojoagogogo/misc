#!/bin/env ruby

@device = "/dev/ttyUSB2"
@range = [*(1..30)] 
def main
  File.write(@device,"15\n")
  
  @range.each do |v|
    puts v = 190 + v * 5
    File.write(@device,"#{v}\n")
  end
  
  File.write(@device,"195\n")
end

main
