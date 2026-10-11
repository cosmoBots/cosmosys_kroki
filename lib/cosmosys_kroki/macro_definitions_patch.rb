# frozen_string_literal: true

module CosmosysKroki
  module MacroDefinitionsPatch
    def exec_macro(name, object, arguments, text, options = {})
      unless name.to_s == 'kroki' && CosmosysKroki::ExportContext.report_export?
        return super
      end

      diagram_type = first_macro_argument(arguments)
      Rails.logger.info(
        "[cosmosys_kroki] Kroki macro reached during report export " \
        "(type=#{diagram_type.to_s.strip.downcase}, source_bytes=#{text.to_s.bytesize})"
      )
      return super unless diagram_type.to_s.strip.casecmp('mermaid').zero?

      normalized_text = CosmosysKroki::MermaidExportNormalizer.call(diagram_type, text)
      if normalized_text.equal?(text)
        Rails.logger.info('[cosmosys_kroki] Mermaid source already defines htmlLabels; source left unchanged')
        return super
      end

      Rails.logger.info('[cosmosys_kroki] Injected Mermaid htmlLabels=false before delegating to redmine_kroki')

      super(name, object, arguments, normalized_text, options)
    end

    private

    def first_macro_argument(arguments)
      return arguments.first if arguments.is_a?(Array)

      arguments.to_s.split(/\s*,\s*/, 2).first.to_s.sub(/\A"(.*)"\z/, '\1')
    end
  end
end
