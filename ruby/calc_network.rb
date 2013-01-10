#!/usr/bin/ruby
# -*- coding: utf-8 -*-

FILL = "032"
def main

  if ARGV.size < 2
    puts ""
    puts "USAGE: 192.168.1.150 (24 | 255.255.255.0)" 
    puts ""
    exit 1
  end

  address = ARGV[0]
  subnet = ARGV[1]
  cidr = "32"
  if(subnet.split(".").size == 4) 
    cidr = get_cidr(subnet)
  else
    cidr = subnet
    subnet = fix_subnet(subnet)
  end
  bound = (32 - cidr.to_i).to_s

  puts "address => " + address
  puts "address => " + _10to2(address)
  puts "cidr    => " + cidr
  puts "subnet  => " + subnet
  puts "subnet  => " + _10to2(subnet)
  puts "bound 2**#{bound} => " + ( 2**bound.to_i ).to_s + "-2 コ"

  address_octets = address.split(".")
  subnet_octets = subnet.split(".")

  network_octets = []
  4.times { |v|
    network_octets << (address_octets[v].to_i & subnet_octets[v].to_i)
  }

  network = network_octets.join(".")
  puts "network => " + network
  puts "network => " + _10to2(network)

  _2 = _10to2(network)
  _10 = _2to10(_2.split(".").join(""))
  bcast_10 = (_10.to_i + 2**bound.to_i - 1).to_s

  puts "bcast   => " + _2toAddress(_10to2(bcast_10,FILL))

  #------
  (_10.to_i .. bcast_10.to_i).each_with_index do |v,index|
    print _2toAddress(_10to2(v.to_s,FILL)) + "\t" 

    if (index+1) % 5 == 0
	print "\n"
    end

    #print _2toAddress(_10to2(v.to_s,FILL)) + "\n" 
  end
  puts
  #------
end

def fix_subnet(subnet)
  _cidr = subnet
  _2 = ""
  _cidr.to_i.times {
    _2 << "1"
  }
  (32 - _cidr.to_i).times{
    _2 << "0"
  }
  return [ ("0b"+_2[0,8]).oct,
           ("0b"+_2[8,8]).oct,
           ("0b"+_2[16,8]).oct,
           ("0b"+_2[24,8]).oct ].join(".")
end

def get_cidr(subnet)
  _10 = subnet
  _2 = _10.split(".").map{|v| v.to_i.to_s(2)}
  ret = (_2.join("").rindex("1") + 1)
  return ret.to_s
end

def _2to10(_2)
  "#{'0b' + _2.to_s}".oct
end

def _10to2(_10,fill = "08")
  ret=[]

  [_10].flatten.each do |v|
    v.split(".").each do |vv|
      ret <<  sprintf("%#{fill}d", vv.to_i.to_s(2))
    end
  end
  ret.join(".")
end


def _2toAddress(_2)
  tmp = []
  tmp << _2to10(_2[0..7])
  tmp << _2to10(_2[8..15])
  tmp << _2to10(_2[16..23])
  tmp << _2to10(_2[24..31])
  tmp.join(".")
end

main()
