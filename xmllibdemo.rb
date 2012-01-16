require 'libxml'

XML = LibXML::XML

reader = XML::Reader.string("<doc><a/><b>some text</b>\n  <c/></doc>")
while reader.read
  what = case reader.node_type
  when XML::Reader::TYPE_ELEMENT
    "<#{reader.name}#{'/' if reader.empty_element?}>"
  when XML::Reader::TYPE_TEXT
    "#{reader.value}"
  when XML::Reader::TYPE_END_ELEMENT
    "</#{reader.name}>"
  else
    # p [reader.depth, reader.node_type, reader.name, reader.empty_element?, reader.value]
    next
  end
  puts ("  " * reader.depth) + what
end


reader = XML::Reader.string("<doc><a/><b bob='fred'>some text</b>\n  <c/></doc>")
while reader.read
  what = case reader.node_type
  when XML::Reader::TYPE_ELEMENT
    "#{reader.name}  #{reader.node.attributes.to_h}  #{reader.empty_element? ? '.' : ' :'}"
  when XML::Reader::TYPE_TEXT
    "#{reader.value}"
  # when XML::Reader::TYPE_END_ELEMENT
    # "</#{reader.name}>"
  else
    # p [reader.depth, reader.node_type, reader.name, reader.empty_element?, reader.value]
    next
  end
  puts ("  " * reader.depth) + what
end
