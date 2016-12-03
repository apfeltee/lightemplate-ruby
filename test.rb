#!/usr/bin/ruby

require_relative "lib/lightemplate"

mybinding = OpenStruct.new(myenv: ENV)
tpl = LighTemplate.new(File.read("print_env.rhtml"))
puts tpl.exec(mybinding)
