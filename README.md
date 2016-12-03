
LighTemplate is a tiny library abstraction for ERB-like HTML templates.

Usage for `lightemplate-ruby`:

   require "lightemplate"
   
   tpl = LighTemplate.new("Hello, <%=name%>!")

   # prints the generated code
   puts tpl.code
   
   # prints the result of executing the generated code
   puts tpl.exec({name: "world"})


A helper function to work with files quick and easy exists as well:

    puts LighTemplate.file("something.rhtml", mybinding)

which is the same as:

    puts LighTemplate.new(File.read("something.rhtml")).exec(mybinding)

You can pass classic `Binding` objects, or `OpenStruct` and `Hash`es to `#exec`.

---
LighTemplate *should* work just fine with mruby, because it does not use any regular expressions.
More testing is needed!
