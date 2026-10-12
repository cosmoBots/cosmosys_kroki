# frozen_string_literal: true

module CosmosysKroki
  module DitaaIndentationPatch
    # Mirrors the Redmine macro shape so the original block can be inspected
    # before ApplicationHelper#inject_macros applies String#strip to it.
    KROKI_DITAA_MACRO_PATTERN = /\A\{\{kroki\((?<arguments>[^\r\n]*)\)(?<block>(?:\r\n|\r|\n).*?(?:\r\n|\r|\n))\}\}(?:\r\n|\r|\n)*\z/im

    def inject_macros(text, object, macros, execute = true, options = {})
      unless execute && macros.is_a?(Hash)
        return super
      end

      prepared_macros = macros.transform_values do |macro_source|
        CosmosysKroki::DitaaIndentationPatch.prepare_macro_source(macro_source)
      end

      super(text, object, prepared_macros, execute, options)
    end

    def self.prepare_macro_source(macro_source)
      return macro_source unless macro_source.is_a?(String)

      match = KROKI_DITAA_MACRO_PATTERN.match(macro_source)
      return macro_source unless match

      diagram_type = match[:arguments].split(/\s*,\s*/, 2).first.to_s.strip
      diagram_type = diagram_type[1...-1] if diagram_type.start_with?('"') && diagram_type.end_with?('"')
      return macro_source unless diagram_type.casecmp('ditaa').zero?

      block = match[:block]
      first_separator = block.match(/\A(?:\r\n|\r|\n)/)&.[](0)
      return macro_source unless first_separator

      body = block[first_separator.length..]
      parts = body.split(/(\r\n|\r|\n)/, -1)
      first_content_line_index = parts.each_index.find do |index|
        index.even? && !parts[index].strip.empty?
      end
      return macro_source unless first_content_line_index

      first_content_line = parts[first_content_line_index]
      return macro_source unless first_content_line.start_with?(' ')

      insertion_offset = first_separator.length
      macro_source.dup.insert(match.begin(:block) + insertion_offset, "*#{first_separator}")
    end
  end
end
