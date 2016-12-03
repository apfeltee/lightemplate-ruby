
require "ostruct"

class LighTemplate
  class Parser
    def initialize(src)
      @src = src
      @conf = OpenStruct.new(
        buffername: "__lightpl_buffer__",
      )
    end

    def process_code(chunk)
      # comment block
      if chunk[0] == '#' then
        return ""
      elsif chunk[0] == '=' then
        return "#{@conf.buffername} += (#{chunk[1 .. -1]})\n"
      else
        return chunk + ";\n"
      end
    end

    def process_stringdata(chunk)
      skip = 0
      chunk.each_byte do |s|
        # skip \n and \r, so html doesn't get mangled
        if (s == 10) || (s == 13) then
          skip += 1
        else
          break
        end
      end
      return sprintf("#{@conf.buffername} += (%p);\n", chunk[skip .. -1])
    end

    def parse
      buf = []
      iter = 0
      buf << "#{@conf.buffername} = '';\n"
      while iter < @src.length do
        chunk = String.new
        if (@src[iter] == '<') && (@src[iter + 1] == '%') then
          iter += 2
          while true do
            if (iter >= @src.length) || ((@src[iter] == '%') && (@src[iter + 1] == '>')) then
              if (iter < @src.length) then
                iter += 2
              end
              break
            end
            chunk << @src[iter]
            iter += 1
          end
          if chunk.length > 0 then
            buf << process_code(chunk)
          end
          chunk = String.new
        else
          while iter < @src.length do
            if (@src[iter] == '<') && (@src[iter + 1] == '%') then
              break
            end
            chunk << @src[iter]
            iter += 1
          end
          if chunk.strip.length > 0 then
            buf << process_stringdata(chunk)
          end
          chunk = String.new
        end
      end
      buf << @conf.buffername << ";\n"
      return buf.join("")
    end    
  end

  def initialize(src)
    @code = Parser.new(src).parse
  end

  def exec(objbinding = nil)
    if objbinding.is_a?(Hash) || objbinding.is_a?(OpenStruct) then
      objbinding = OpenStruct.new(objbinding).instance_eval{binding}
    end
    if objbinding.nil? then
      return eval(@code)
    end
    return eval(@code, objbinding)
  end

  def self.file(filename, objbinding=nil)
    return LighTemplate.new(File.read(filename)).exec(objbinding)
  end

  def self.string(src, objbinding=nil)
    return LighTemplate.new(src).exec(objbinding)
  end

  attr_accessor :code
end

