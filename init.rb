# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register :cosmosys_kroki do
  name 'cosmoSys Kroki integration'
  author 'cosmoBots.eu'
  description 'Adapts Kroki diagrams for cosmoSys document export and Ditaa macros.'
  version '0.1.1'
  url 'https://cosmobots.eu'
  author_url 'https://cosmobots.eu'

  requires_redmine version_or_higher: '7.0.1'
  requires_redmine_plugin :cosmosys, version_or_higher: '0.1.10'
end

# Redmine loads plugin directories in lexical order. Since this directory sorts
# before redmine_kroki, its initializer cannot check that dependency yet. Run
# Redmine's normal requirement check after every plugin has registered instead.
unless defined?(CosmosysKrokiPluginDependencyListener)
  class CosmosysKrokiPluginDependencyListener < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      Redmine::Plugin.find(:cosmosys_kroki).requires_redmine_plugin(
        :redmine_kroki,
        version_or_higher: '0.5.0'
      )
    end
  end
end

require_dependency File.expand_path('lib/cosmosys_kroki/mermaid_export_normalizer', __dir__)
require_dependency File.expand_path('lib/cosmosys_kroki/export_context', __dir__)
require_dependency File.expand_path('lib/cosmosys_kroki/ditaa_indentation_patch', __dir__)
require_dependency File.expand_path('lib/cosmosys_kroki/macro_definitions_patch', __dir__)
require_dependency File.expand_path('lib/cosmosys_kroki/items_controller_patch', __dir__)

patch_cosmosys_kroki = proc do
  ApplicationHelper.prepend CosmosysKroki::DitaaIndentationPatch unless ApplicationHelper < CosmosysKroki::DitaaIndentationPatch

  definitions = Redmine::WikiFormatting::Macros::Definitions
  definitions.prepend CosmosysKroki::MacroDefinitionsPatch unless definitions < CosmosysKroki::MacroDefinitionsPatch

  controller = Cosmosys::ItemsController
  controller.prepend CosmosysKroki::ItemsControllerPatch unless controller < CosmosysKroki::ItemsControllerPatch

  Rails.logger.info('[cosmosys_kroki] Installed Kroki macro and cosmoSys report-export patches')
end

patch_cosmosys_kroki.call
Rails.application.config.to_prepare(&patch_cosmosys_kroki)
