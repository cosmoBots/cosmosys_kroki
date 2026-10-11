# frozen_string_literal: true

module CosmosysKroki
  module MermaidExportNormalizer
    DEFAULT_INIT_DIRECTIVE = '%%{init: {"htmlLabels": false}}%%'.freeze
    INIT_DIRECTIVE_PATTERN = /%%\s*\{\s*init\s*:[\s\S]*?%%/i
    FRONTMATTER_PATTERN = /\A([ \t]*---[ \t]*\r?\n[\s\S]*?\r?\n---[ \t]*)(?:\r?\n|\z)/
    HTML_LABELS_PATTERN = /["']?htmlLabels["']?\s*:/i

    module_function

    def call(diagram_type, source)
      return source unless diagram_type.to_s.strip.casecmp('mermaid').zero?
      return source unless source.is_a?(String)

      has_explicit_html_labels = source.scan(INIT_DIRECTIVE_PATTERN).any? do |directive|
        directive.match?(HTML_LABELS_PATTERN)
      end
      return source if has_explicit_html_labels

      if (frontmatter = source.match(FRONTMATTER_PATTERN))
        return source if frontmatter[0].match?(HTML_LABELS_PATTERN)

        line_ending = frontmatter[0].include?("\r\n") ? "\r\n" : "\n"
        prefix = frontmatter[1]
        remainder = source[frontmatter[0].length..]
        return "#{prefix}#{line_ending}#{DEFAULT_INIT_DIRECTIVE}#{line_ending}#{remainder}"
      end

      "#{DEFAULT_INIT_DIRECTIVE}\n#{source}"
    end
  end
end
