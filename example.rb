require 'band_master'

foo = 10
bar = 100
my_lambda = lambda{|x| foo * x + bar }

puts my_lambda.marshal
