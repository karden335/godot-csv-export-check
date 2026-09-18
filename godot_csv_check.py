#!/usr/bin/env python3
"""Free source-only preflight for raw CSV files read with Godot FileAccess."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sys


REFERENCE = re.compile(r"FileAccess\s*\.\s*(?:open|file_exists|get_file_as_string)\s*\(\s*['\"](res://[^'\"]+\.csv)['\"]", re.IGNORECASE)
IMPORTER = re.compile(r'^\s*importer\s*=\s*"([^"]+)"', re.MULTILINE)
SKIP_DIRS = {".godot", ".git", "node_modules", ".venv"}


def scan(project: Path) -> dict:
    project = project.expanduser().resolve()
    if not (project / "project.godot").is_file():
        raise ValueError(f"not a Godot project: {project}")
    paths: dict[str, list[str]] = {}
    for script in project.rglob("*.gd"):
        if script.is_symlink() or any(part in SKIP_DIRS for part in script.relative_to(project).parts):
            continue
        source = script.read_text(encoding="utf-8", errors="replace")
        lines = source.splitlines()
        for match in REFERENCE.finditer(source):
            line = source.count("\n", 0, match.start()) + 1
            if lines[line - 1].lstrip().startswith("#"):
                continue
            paths.setdefault(match.group(1), []).append(f"{script.relative_to(project).as_posix()}:{line}")
    findings: list[dict] = []
    for res_path, locations in sorted(paths.items()):
        relative = res_path.removeprefix("res://")
        if "\\" in relative or any(part in {"", ".", ".."} for part in relative.split("/")):
            findings.append({"severity": "error", "code": "UNSAFE_PATH", "path": res_path, "detail": "Path escapes or is malformed."})
            continue
        source_file = project / relative
        if not source_file.resolve().is_relative_to(project) or not source_file.is_file():
            findings.append({"severity": "error", "code": "MISSING_SOURCE", "path": res_path, "detail": f"Referenced at {', '.join(locations)} but file is absent."})
            continue
        import_file = Path(str(source_file) + ".import")
        importer = None
        if import_file.is_file():
            match = IMPORTER.search(import_file.read_text(encoding="utf-8", errors="replace"))
            importer = match.group(1) if match else None
        if importer != "keep":
            findings.append({"severity": "error", "code": "CSV_NOT_KEPT", "path": res_path, "detail": f"Importer is {importer or '<unset>'}; select Keep File (No Import) in Godot's Import dock and Reimport."})
        data = source_file.read_bytes()
        try:
            data.decode("utf-8")
        except UnicodeDecodeError:
            findings.append({"severity": "error", "code": "CSV_NOT_UTF8", "path": res_path, "detail": "Save as UTF-8, then reimport and test."})
        else:
            if data.startswith(b"\xef\xbb\xbf"):
                findings.append({"severity": "warning", "code": "CSV_BOM", "path": res_path, "detail": "UTF-8 BOM appears before the first field; save without BOM if exact header matching matters."})
    if not paths:
        findings.append({"severity": "warning", "code": "NO_LITERAL_CSV_PATHS", "path": "", "detail": "No literal raw CSV FileAccess paths found; variable-built paths are not covered."})
    return {"project": str(project), "csv_paths_checked": len(paths), "findings": findings,
            "limits": "Source-only scan. Run an actual Godot export and the exported game before release."}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project", type=Path)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    try:
        report = scan(args.project)
    except (ValueError, OSError) as exc:
        parser.error(str(exc))
    if args.json:
        print(json.dumps(report, indent=2))
    else:
        print(f"Godot CSV Check: {report['csv_paths_checked']} raw CSV path(s)")
        for finding in report["findings"]:
            print(f"{finding['severity'].upper()} {finding['code']} {finding['path']}: {finding['detail']}")
        if not report["findings"]:
            print("No findings in the covered checks.")
        print(report["limits"])
    return 2 if any(item["severity"] == "error" for item in report["findings"]) else 0


if __name__ == "__main__":
    sys.exit(main())
