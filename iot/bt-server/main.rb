#!/bin/env ruby
require 'serialport'
#require 'json'
 
@serial_port = "/dev/ttyAMA0"
@serial_bps = 9600
 
@sp = SerialPort.new(@serial_port,@serial_bps)
 
def main
  loop do
    line = @sp.gets # read

    puts "-------------------"
    puts "#{line}"
    res = exec(line.chop)
    #puts res
    @sp.puts res
  end
end

def exec line
  #puts "-->#{line}<--"
  
  if line == "1"
    cmd = "ip a s | grep 'inet ' |grep -v 127.0.0.1"
    r = %x{ #{cmd} }
  elsif line== "2"
    cmd = "ip a add 192.168.255.1/24 dev eth0 broadcast 255.255.255.255"
    r = %x{ #{cmd} }
  elsif line == "3"
    cmd = "hostname"
    r = %x{ #{cmd} }
  elsif line == "98"
    cmd = "shutdown -h now"
    r = %x{ #{cmd} }

  elsif line == "99"
    cmd = "reboot"
    r = %x{ #{cmd} }
  else
    begin
      r = "1 ip
2 ip a add
3 hostname
98 shutdown 
99 reboot

"
    rescue
    end
  end
  
  r
end

main
