# Godot Asset Store submission — v0.3.0

## Listing

- **Name:** Godot CSV Export Check
- **Summary:** Find raw CSV files that work in the editor but can disappear or change in an exported Godot build.
- **Asset type:** Addon
- **License:** MIT
- **Source:** https://github.com/karden335/godot-csv-export-check
- **Minimum Godot version:** 4.4
- **Maximum Godot version:** leave empty
- **Version:** 0.3.0
- **Tags:** Editor Tool, Testing, CSV, Export, Compatibility
- **Archive:** `dist/godot-csv-export-check-0.3.0.zip`
- **Thumbnail:** `media/store-thumbnail.jpg` (1280×720, 16:9, below 600 KB)

## Detailed description

Godot CSV Export Check is a local editor plugin that finds literal raw CSV paths that can work inside the editor but disappear or change in an exported build.

Click Scan current project in the dock. The plugin reads GDScript source and reports missing CSV files, CSV files that are not configured as Keep File (No Import), invalid UTF-8, and UTF-8 byte-order marks that can affect exact header matching. Every finding includes a direct fix.

The plugin reads local project files only. It makes no network requests, uploads, telemetry, service accounts, or project edits. The repository also includes a dependency-free Python CLI and GitHub Action for CI.

This is a conservative source-side check for literal FileAccess paths. It does not discover paths assembled at runtime, inspect every resource API, validate arbitrary CSV schemas, inspect an export pack, or prove the exported game works. Make a fresh target export and launch it before release.

An optional paid export-verification kit is available at https://karrden.itch.io/godot-data-export-guard. It adds fresh export-pack inspection, byte-for-byte source comparison, broken and fixed projects, integration tests, and a release checklist. The free plugin has no in-editor advertisement or interruption.

Independent community tool; not affiliated with or endorsed by the Godot Foundation.

## AI usage disclosure

Code and listing text used AI assistance. Verified with a Python smoke test, headless GDScript analyzer and dock tests, deterministic archive validation, and Godot editor startup on supported engine versions.

## Review checklist

- [x] Add-on works without paid dependencies.
- [x] `LICENSE` and `README.md` are inside the add-on folder.
- [x] Archive contains only `addons/csv_export_check/`.
- [x] Source repository has a root MIT license and `.gitignore`.
- [x] Store thumbnail is 1280×720 and below the 600 KB limit.
- [x] English name and description use full sentences.
- [x] AI assistance is disclosed.
- [x] No pop-up or in-editor advertisement for the paid version.
- [x] Python, GDScript analyzer, dock, archive, and editor-startup checks pass.
- [ ] Stable v0.3.0 GitHub release is public.
- [ ] Asset Store Draft is saved.
- [ ] Listing has been submitted for manual review.
