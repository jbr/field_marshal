require 'parse_tree'
require 'ruby2ruby'
require 'parse_tree_extensions'

module BandMarshal
  def self.marshal(thing = nil, name = nil, &blk)
    thing ||= blk
    hash    = marshal_ thing
    assigns = []
    keys    = hash.keys.compact
    while keys.length > 0
      key   = keys.shift
      value = hash[ key ]
      if keys.include? value
        keys.push key
      else
        assigns << "#{key} = #{value}"
      end
    end

    [assigns.join("\n"), name ? name : hash[nil]].join("\n")
  end

  private
  def self.marshal_(thing, name = nil, already_marshalled = {})
    assigns_hash = {}

    already_existing_var_name = already_marshalled.invert[ thing ]

    if already_existing_var_name && name != already_existing_var_name
      assigns_hash[name] = already_existing_var_name
    end

    unless already_marshalled[name] == thing
      already_marshalled[name] = thing

      assigns_hash[name] =
        case thing
        when Array
          "[" + thing.map do |t|
          assigns_hash.merge! marshal_(t, nil, already_marshalled)
          assigns_hash.delete nil
        end.join(", ") + "]"

        when Hash
          "{" + thing.map do |key, value|
          [key, value].map do |t|
            assigns_hash.merge! marshal_(t, nil, already_marshalled)
            assigns_hash.delete nil
          end.join(" => ")
        end.join(", ") + "}"

        when nil, Symbol, String, Numeric, Hash then thing.inspect

        when Proc
          var_names = eval('local_variables', thing.binding).reject do |n|
          already_marshalled.has_key? n
        end

          var_names.each do |var_name|
          var = eval var_name, thing.binding
          if var != thing
            assigns_hash.merge! marshal_(var, var_name, already_marshalled)
          end
        end

          thing.to_ruby
        end
    end
    assigns_hash
  end
end


class Proc
  def marshal
    BandMarshal.marshal self
  end
end