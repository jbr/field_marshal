require 'field_marshal'

foo = 10
bar = 100
other_lambda = lambda { "HELLO" }
my_lambda = lambda{|x| foo * x + bar }

puts my_lambda.marshal
