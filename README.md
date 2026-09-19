# Godot CSV Check — raw CSV missing after export

Godot 4 imports `.csv` files as translation data by default. If your game reads the raw CSV with `FileAccess`, the file may work in the editor but be missing from an exported game. This free, local checker catches common source-side causes before you ship.

Need export-pack verification as well? The [$7 Godot Data Export Guard full kit](https://karrden.itch.io/godot-data-export-guard) adds fresh exported-ZIP checks, byte-for-byte source comparison, broken and fixed sample projects, integration tests, and a release checklist. The open source checker in this repository remains fully usable on its own.

## Get and run the checker

[Download the free v0.2.1 ZIP](https://github.com/karden335/godot-csv-export-check/releases/download/v0.2.1/godot-csv-check-free-0.2.1.zip) and extract it. From the extracted folder, run:

```sh
python3 godot_csv_check.py /path/to/your/godot/project
```

To try it before pointing it at your own project, run `python3 godot_csv_check.py tests/fixture` from the extracted folder. The included corrected Godot sample should report one raw CSV path and no findings. This sample run is a source scan, not an export test.

To run the same source check in GitHub Actions, add this step after checkout:

```yaml
- uses: actions/checkout@v6
- uses: karden335/godot-csv-export-check@v0.2.1
  with:
    project-path: .
```

The Action uses the Python on the runner and does not export or launch Godot. GitHub-hosted runner charges, if any, belong to the repository that runs the workflow; check [GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions) before adding it to a private repository. This repository's own smoke workflow uses a standard runner in a public repository.

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
