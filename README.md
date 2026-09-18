# Godot CSV Check — free edition

Before exporting a Godot 4 game, run:

```sh
python3 godot_csv_check.py /path/to/your/godot/project
```

Requires Python 3.9+; no packages, account, network request, or file upload. This source-only checker finds literal `FileAccess.open("res://...csv", ...)`, `file_exists`, and `get_file_as_string` calls in GDScript. It flags missing CSV files, CSVs not set to **Keep File (No Import)**, invalid UTF-8, and a UTF-8 BOM. Errors exit with code 2. `--json` prints a machine-readable report.

The checker reads but never edits your project. It does not discover paths assembled at runtime, inspect an exported pack, validate arbitrary CSV data, or prove that a game runs. Always export and run your game. For the documented Godot CSV importer behavior, see [Godot's localization CSV guide](https://docs.godotengine.org/en/4.7/tutorials/i18n/localization_using_spreadsheets.html).

If this catches a false positive or misses a literal path, provide a minimal reproducible example without private project data.

License: MIT. See `LICENSE`.

Independent community tool; not affiliated with or endorsed by the Godot Foundation.
