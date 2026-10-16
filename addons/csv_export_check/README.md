# CSV Export Check

This Godot 4.4+ editor plugin scans the current project for literal `.csv` paths read through `FileAccess.open`, `file_exists`, or `get_file_as_string`.

It reports:

- a missing source CSV;
- a CSV that is not configured as **Keep File (No Import)**;
- invalid UTF-8;
- a UTF-8 byte-order mark that may affect exact header matching.

Install `addons/csv_export_check`, enable **CSV Export Check** under **Project > Project Settings > Plugins**, then use the new dock and click **Scan current project**.

The plugin reads source files but does not edit them, upload them, or use telemetry. It checks literal paths only and does not inspect an export pack or prove runtime behavior. Always export and launch the actual target build.

The full [Godot Data Export Guard](https://karrden.itch.io/godot-data-export-guard) kit ($3) adds fresh exported-ZIP inspection, byte-for-byte source comparison, broken and fixed sample projects, integration tests, and a release checklist.

MIT licensed. Independent community tool; not affiliated with or endorsed by the Godot Foundation.

AI disclosure: code and text were created with AI assistance and validated with automated Python and headless Godot tests plus editor startup QA.
