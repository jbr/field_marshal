require 'parse_tree'
require 'ruby2ruby'
require 'parse_tree_extensions'

def assign(name, value)
  name ? "#{name} = #{value}" : value
end

def marshal(thing, name = nil, already_marshalled = {})
  return if already_marshalled[name] == thing

  if already_existing_var_name = already_marshalled.invert[thing]
    already_marshalled[name] = thing if name
    return assign(name, already_existing_var_name)
  end

  if name
    already_marshalled[name] = thing
  end

  case thing
  when String, Numeric, Hash
    assign name, thing.inspect

  when nil
    assign name, 'nil'

  when Proc
    var_names = eval('local_variables', thing.binding).reject do |n|
      already_marshalled.has_key? n
    end

    assignments = var_names.map do |var_name|
      var = eval var_name, thing.binding

      unless var == thing
        marshal var, var_name, already_marshalled
      end
    end.compact.join("\n")

    [assignments, assign(name, thing.to_ruby)].join("\n")
  end
end

l = lambda {|x| x * x }
squid = foo = 10
bar = 100 * 50
myproc = lambda{ l.first.call foo * bar}

puts marshal(myproc)
