require 'libxml'


class OOXML
  XML = LibXML::XML

  def initialize reader_source
    @reader = XML::Reader.file(reader_source)
  end

  def go
    @reader.read
    raise unless @reader.name == "office:document"

    while @reader.read
      case @reader.node_type
        when XML::Reader::TYPE_ELEMENT
          if @reader.name == "office:body"
            do_body
          else
            @reader.next
          end
          next
      end
    end

  end

  def do_body
    raise unless @reader.name == "office:body"
    @body_start_depth = @reader.depth

    Dir.mkdir("OUT") unless File.directory?("OUT")
    @f_text = File.open("OUT/out_text.html",  "w+")
    @f_note = File.open("OUT/out_notes.html",  "w+")

    @f_text.puts "<!-- TEXT -->"

    process_body_elements @f_text

    @f_text.close
  end

  def process_body_elements f
    html_tags_by_entity_name = {
      "p" => "p",
      "span" => "span",
      "h" => "h1",
    }

    while @reader.read
      what = case @reader.node_type
        when XML::Reader::TYPE_ELEMENT
          if html_tags_by_entity_name.include? @reader.local_name
            write_html_line f, "<#{html_tags_by_entity_name[@reader.local_name]}#{' /' if @reader.empty_element?}>"
          end
          "#{@reader.name}   #{@reader.empty_element? ? '.' : ' :'}"
        when XML::Reader::TYPE_TEXT
          write_html_line f, @reader.value
          "#{@reader.value}"
        when XML::Reader::TYPE_END_ELEMENT
          if html_tags_by_entity_name.include? @reader.local_name
            write_html_line f, "</#{html_tags_by_entity_name[@reader.local_name]}>"
          end
          nil
        else
          next
      end
      puts (". " * @reader.depth) + what if what
    end
  end

  def write_html_line f, s
    f.puts (" " * (@reader.depth - @body_start_depth)) + s
  end

end

OOXML.new(ARGV[0]).go

# while @reader.read
#   what = case @reader.node_type
#   when XML::Reader::TYPE_ELEMENT
#     "#{@reader.name}   #{@reader.empty_element? ? '.' : ' :'}"
#     # "#{@reader.name}  #{@reader.node.attributes.to_h}  #{@reader.empty_element? ? '.' : ' :'}"
#   when XML::Reader::TYPE_TEXT
#     "#{@reader.value}"
#   # when XML::Reader::TYPE_END_ELEMENT
#     # "</#{@reader.name}>"
#   else
#     # p [@reader.depth, @reader.node_type, @reader.name, @reader.empty_element?, @reader.value]
#     next
#   end
#   puts ("  " * @reader.depth) + what
# end
