# frozen_string_literal: true

module CosmosysKroki
  module MacroDefinitionsPatch
    def exec_macro(name, object, arguments, text, options = {})
      return super unless name.to_s == 'kroki'

      if CosmosysKroki::ExportContext.report_export?
        diagram_type = first_macro_argument(arguments)
        Rails.logger.info(
          "[cosmosys_kroki] Kroki macro reached during report export " \
          "(type=#{diagram_type.to_s.strip.downcase}, source_bytes=#{text.to_s.bytesize})"
        )
        if diagram_type.to_s.strip.casecmp('mermaid').zero?
          # Upstream 0.5.1 prefixes macro blocks before Redmine strips them.
          # Restore that marker before adding a directive, otherwise it becomes
          # buried in the source and Mermaid cannot recognize the diagram.
          source = defined?(KrokiBlockIndentation) ? KrokiBlockIndentation.restore(text) : text
          text = CosmosysKroki::MermaidExportNormalizer.call(diagram_type, source)
        end
      end

      result = super(name, object, arguments, text, options)
      return result unless result.is_a?(String) && result.encoding == Encoding::ASCII_8BIT

      # Net::HTTP error bodies can be binary strings containing UTF-8 bytes.
      # Redmine's macro error HTML must compose with subsequent Unicode SVGs.
      utf8 = result.dup.force_encoding(Encoding::UTF_8).scrub
      result.respond_to?(:html_safe?) && result.html_safe? ? utf8.html_safe : utf8
    end

    private

    def first_macro_argument(arguments)
      return arguments.first if arguments.is_a?(Array)

      arguments.to_s.split(/\s*,\s*/, 2).first.to_s.sub(/\A"(.*)"\z/, '\1')
    end
  end
end
