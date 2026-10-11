# frozen_string_literal: true

module CosmosysKroki
  module ExportContext
    THREAD_KEY = :cosmosys_kroki_report_export

    module_function

    def report_export?
      Thread.current[THREAD_KEY] == true
    end

    def within_report_export
      previous_value = Thread.current[THREAD_KEY]
      Thread.current[THREAD_KEY] = true
      yield
    ensure
      Thread.current[THREAD_KEY] = previous_value
    end
  end
end
