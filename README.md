# cosmoSys Kroki integration

[`cosmoSys`](https://github.com/cosmoBots/cosmoSys) extension for exporting
Mermaid diagrams rendered by
[`redmine_kroki`](https://github.com/cosmoBots/redmine-kroki) in ODT/PDF
reports. It is an optional companion plugin: cosmoSys remains usable without
Kroki or this integration.

> **EXPERIMENTAL:** The integration works. Its deployment wiring remains
> provisional until Iván incorporates it into a more modular deployment
> strategy; this label does not indicate a known functional limitation.

For Mermaid macros in a cosmoSys report export, this plugin adds Mermaid's
`htmlLabels: false` initialization directive when the diagram does not already
define `htmlLabels`. This makes Mermaid use SVG-native text rather than
`foreignObject`-embedded HTML, which is not reliably carried through the ODT
conversion pipeline. Explicit `htmlLabels` choices are preserved. Stored source
text and the regular HTML report preview are not changed.

For Ditaa macros, Redmine removes leading and trailing whitespace from a macro
block before passing it to `redmine_kroki`. That can shift an indented first
diagram line relative to the remaining lines. When the first non-blank Ditaa
line starts with ASCII spaces, this plugin inserts Ditaa's visually inert `*`
marker on its own line immediately before the original diagram body, so
Redmine's trimming no longer removes its indentation. Unindented Ditaa source
and tab-indented lines are left unchanged.

Install this plugin alongside cosmoSys and `redmine_kroki` 0.5.0 or later, then
restart Redmine. The dependency is mandatory: if Kroki is absent or too old,
Redmine reports a plugin requirement error instead of starting with this
integration silently disabled. The integration is intentionally narrow; it
does not patch `redmine_kroki` or alter other Kroki diagram languages.

This is a deliberately narrow integration. A more general approach to SVG/HTML
report export is being evaluated in cosmoSys; if that approach supersedes this
plugin, it may be retired rather than expanded with diagram-specific fixes.

## License

Licensed under the GNU General Public License, version 3. See [`LICENSE`](LICENSE).
