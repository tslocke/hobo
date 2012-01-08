require 'rexml/document'
require 'rexml/formatters/default'

# strip whitespace when formatting XML

class StripFormatter < REXML::Formatters::Default

  protected

  def write_text(node, output)
    output << node.to_s.strip
  end

end
