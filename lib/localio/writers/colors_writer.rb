require 'localio/template_handler'
require 'localio/segments_list_holder'
require 'localio/segment'
require 'localio/formatter'
require 'nokogiri'

class ColorWriter
  def self.write(colors, terms, path, formatter, options)
    puts 'Writing colors...'
    # default_language = options[:default_language]

    if colors.keys.include?('color')
      color = 'color'
      output_path = File.join(path,"#{color}/")

      # We have now to iterate all the terms for the current language, extract them, and store them into a new array

      segments = SegmentsListHolder.new color
      terms.each do |term|
        key = Formatter.format(term.keyword, formatter, method(:android_key_formatter))
        translation = android_parsing term.values[color]
        segment = Segment.new(key, translation, color)
        segment.key = nil if term.is_comment?
        segments.segments << segment
      end

      TemplateHandler.process_template 'colors_template.erb', output_path, 'colors.xml', segments
      puts " > #{color.yellow}"

    end

  end

  private

  def self.android_key_formatter(key)
    key.space_to_underscore.strip_tag.downcase
  end

  def self.android_parsing(term)
    term.gsub('& ','&amp; ').gsub('...', '…').gsub('%@', '%s')
  end
end
