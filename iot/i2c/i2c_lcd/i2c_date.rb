#!/bin/env ruby

cmd = "unset LANG; date +\"%m/%d%a%H:%M:%S\""
date = %x{ #{cmd} }


line1 = date[0,8]
line2 = date[8,8]

lines = [line1,line2]

cmd1 = "i2cset -y 1 0x3e 0 0x38 0x39 0x14 0x70 0x56 0x6c i"
cmd2 = "i2cset -y 1 0x3e 0 0x38 0x0d 0x01 i"

puts cmd1
%x{ #{cmd1}}
puts cmd2
%x{ #{cmd2}}

lines.each do |s|
  tmp_cmd1 = "i2cset -y 1 0x3e 0x40 "
  s.unpack("U*").each do |c|
    tmp_cmd1 << "0x#{c.to_i.to_s(16)} "
  end
  tmp_cmd1 << "i"
  tmp_cmd2 = "i2cset -y 1 0x3e 0x00 0xc0 i"
  puts tmp_cmd1
  %x{ #{tmp_cmd1}}
  puts tmp_cmd2
  %x{ #{tmp_cmd2}}
end

cmd3 = "i2cset -y 1 0x3e 0x00 0xc7 i"
%x{#{cmd3}}

