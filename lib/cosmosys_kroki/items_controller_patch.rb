# frozen_string_literal: true

module CosmosysKroki
  module ItemsControllerPatch
    def report_export
      Rails.logger.info('[cosmosys_kroki] Entering cosmoSys report export context')
      CosmosysKroki::ExportContext.within_report_export { super }
    end
  end
end
