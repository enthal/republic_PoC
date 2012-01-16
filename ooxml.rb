require 'libxml'

XML = LibXML::XML


def do_body(reader)
  raise unless reader.name == "office:body"
  start_depth = reader.depth

  Dir.mkdir("OUT") unless File.directory?("OUT")
  f_text = File.open("OUT/out_text.html",  "w+")
  f_note = File.open("OUT/out_notes.html",  "w+")

  f_text.puts "<!-- TEXT -->"

  write_html = lambda {|s| f_text.puts (" " * (reader.depth - start_depth)) + s}

  html_tags_by_entity_name = {
    "p" => "p",
    "span" => "span",
    "h" => "h1",
  }

  while reader.read
    what = case reader.node_type
      when XML::Reader::TYPE_ELEMENT
        if html_tags_by_entity_name.include? reader.local_name
          write_html[ "<#{html_tags_by_entity_name[reader.local_name]}#{' /' if reader.empty_element?}>" ]
        end
        "#{reader.name}   #{reader.empty_element? ? '.' : ' :'}"
      when XML::Reader::TYPE_TEXT
        write_html[ reader.value ]
        "#{reader.value}"
      when XML::Reader::TYPE_END_ELEMENT
        if html_tags_by_entity_name.include? reader.local_name
          write_html[ "</#{html_tags_by_entity_name[reader.local_name]}>" ]
        end
        nil
      else
        next
    end
    puts (". " * reader.depth) + what if what
  end

  f_text.close
end


reader = XML::Reader.file(ARGV[0])

reader.read

while reader.read
  case reader.node_type
    when XML::Reader::TYPE_ELEMENT
      if reader.name == "office:body"
        do_body reader
      else
        reader.next
      end
      next
  end
end



# while reader.read
#   what = case reader.node_type
#   when XML::Reader::TYPE_ELEMENT
#     "#{reader.name}   #{reader.empty_element? ? '.' : ' :'}"
#     # "#{reader.name}  #{reader.node.attributes.to_h}  #{reader.empty_element? ? '.' : ' :'}"
#   when XML::Reader::TYPE_TEXT
#     "#{reader.value}"
#   # when XML::Reader::TYPE_END_ELEMENT
#     # "</#{reader.name}>"
#   else
#     # p [reader.depth, reader.node_type, reader.name, reader.empty_element?, reader.value]
#     next
#   end
#   puts ("  " * reader.depth) + what
# end
