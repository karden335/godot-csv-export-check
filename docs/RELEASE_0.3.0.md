# Godot CSV Export Check v0.3.0

This release adds a native Godot 4.4+ editor dock to the existing local CSV preflight.

## Install the editor plugin

1. Download `godot-csv-export-check-0.3.0.zip`.
2. Extract `addons/csv_export_check` into the root of the Godot project.
3. Enable **CSV Export Check** under **Project > Project Settings > Plugins**.
4. Open the **CSV Export Check** dock and click **Scan current project**.

The plugin reports literal raw CSV paths that are missing, not configured as **Keep File (No Import)**, invalid UTF-8, or prefixed with a UTF-8 BOM. It reads local source files only and does not modify or upload them.

The Python CLI and GitHub Action remain available for scripts and CI. This source-side check does not inspect an exported pack or prove runtime behavior; export and launch the actual target build before release.

The optional [$7 Godot Data Export Guard](https://karrden.itch.io/godot-data-export-guard) adds real export-pack inspection, source/export byte comparison, broken and fixed fixtures, integration tests, and a release checklist. The [$10 Godot Release Safety Bundle](https://itch.io/s/204610/godot-release-safety-bundle) includes that kit plus Godot Save Compatibility Guard.

AI disclosure: code and text used AI assistance and were validated with Python smoke tests, headless GDScript analyzer and dock tests, archive verification, and Godot editor startup.
