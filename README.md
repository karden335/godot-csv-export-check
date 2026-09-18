# Godot CSV Check — raw CSV missing after export

Godot 4 imports `.csv` files as translation data by default. If your game reads the raw CSV with `FileAccess`, the file may work in the editor but be missing from an exported game. This free, local checker catches common source-side causes before you ship.

## Run before exporting

```sh
python3 godot_csv_check.py /path/to/your/godot/project
```

Requires Python 3.9+; no packages, account, network request, or file upload. This source-only checker finds literal `FileAccess.open("res://...csv", ...)`, `file_exists`, and `get_file_as_string` calls in GDScript. Errors exit with code 2. `--json` prints a machine-readable report suitable for CI.

## Fix a finding

- `MISSING_SOURCE`: the literal `res://` CSV path does not exist in the project. Check the path and filename case.
- `CSV_NOT_KEPT`: select the CSV in Godot's Import dock, choose **Keep File (No Import)**, then **Reimport**. Export again.
- `CSV_NOT_UTF8`: save the file as UTF-8, reimport and test.
- `CSV_BOM`: the UTF-8 byte-order mark may affect exact header matching; remove it if your parser expects the first header to start at byte 0.

After fixing a finding, export your actual target build and launch it outside the editor. Exercise the feature that reads the CSV. A successful source scan alone does not verify an export.

The checker reads but never edits your project. It does not discover paths assembled at runtime, inspect an exported pack, validate arbitrary CSV data, or prove that a game runs. Always export and run your game. For the documented Godot CSV importer behavior, see [Godot's localization CSV guide](https://docs.godotengine.org/en/4.7/tutorials/i18n/localization_using_spreadsheets.html).

If this catches a false positive or misses a literal path, [open an issue](https://github.com/karden335/godot-csv-export-check/issues) with a minimal reproducible example. Do not include private project data.

License: MIT. See `LICENSE`.

Independent community tool; not affiliated with or endorsed by the Godot Foundation.
