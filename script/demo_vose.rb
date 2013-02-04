#!/usr/bin/env ruby

require 'vose'

probs = [0.133, 0.133, 0.067, 0.133, 0.267, 0.267]

vose = Vose::AliasMethod.new probs
10.times do 
  puts vose.next
end

names = ["impr", "prbl"]
probs = [0.1, 0.9]
vose = Vose::AliasMethod.new probs
res = []
30.times do 
 res << vose.next
end
p res.map{|r|names[r]}

