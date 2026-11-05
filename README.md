# cosmoSys Kroki integration

Version **0.1.3** requires cosmoSys **0.2.8** or later. This dependency-only
update aligns the integration with the current release set; the export-marker
and Unicode-error fixes were already included in 0.1.2.

[`cosmoSys`](https://github.com/cosmoBots/cosmoSys) extension for exporting
Mermaid diagrams rendered by
[`redmine_kroki`](https://github.com/JeffDess/redmine-kroki) in ODT/PDF
reports. It is an optional companion plugin: cosmoSys remains usable without
Kroki or this integration.

> **EXPERIMENTAL — opt-in:** This integration is not part of the production core.
> Expect defects, incomplete features, performance limits and breaking changes.
> Do not install it if you require production-level stability and support.
> The warning concerns the integration itself, not just its deployment wiring.

For Mermaid macros in a cosmoSys report export, this plugin adds Mermaid's
`htmlLabels: false` initialization directive when the diagram does not already
define `htmlLabels`. This makes Mermaid use SVG-native text rather than
`foreignObject`-embedded HTML, which is not reliably carried through the ODT
conversion pipeline. Explicit `htmlLabels` choices are preserved. Stored source
text and the regular HTML report preview are not changed.

Install this plugin alongside cosmoSys and `redmine_kroki` 0.5.1 or later, then
restart Redmine. The dependency is mandatory: if Kroki is absent or too old,
Redmine reports a plugin requirement error instead of starting with this
integration silently disabled. Indentation preservation for Ditaa, Svgbob and
GoAT is handled by upstream `redmine_kroki` 0.5.1 or later.

This is a deliberately narrow integration. A more general approach to SVG/HTML
report export is being evaluated in cosmoSys; if that approach supersedes this
plugin, it may be retired rather than expanded with diagram-specific fixes.

Before injecting the Mermaid directive, this integration restores upstream's
indentation marker. Adding the directive ahead of the marker would leave an
invisible character in the diagram source and cause Mermaid syntax errors.
Binary-encoded Kroki macro error HTML is normalized to UTF-8 while preserving
its existing HTML-safety status, so one invalid diagram can be shown as an
error without aborting a report containing Unicode SVGs.

## License

Licensed under the GNU General Public License, version 3. See [`LICENSE`](LICENSE).
