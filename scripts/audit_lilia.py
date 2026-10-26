"""Standalone entry point for auditing only the Lilia framework."""

from __future__ import annotations

import argparse
import contextlib
import io
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


LILIA_ROOT = Path(__file__).resolve().parent
REPORT_NAME = "comparison_report.md"
IGNORED_DIRS = {"docs", "documentation", "languages", "_disabled"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit only the Lilia gamemode framework.")
    parser.add_argument("--base-path", type=Path, default=LILIA_ROOT, help="Lilia root or its gamemode directory.")
    parser.add_argument("--documentation-path", "--docs-path", type=Path, help="Read-only documentation reference root.")
    parser.add_argument("--output-path", type=Path, help="Markdown output (default: <Lilia>/comparison_report.md).")
    parser.add_argument("--quiet", "-q", action="store_true", help="Suppress progress output.")
    parser.add_argument("--watch", action="store_true", help="Rerun when Lua or documentation inputs change.")
    parser.add_argument("--watch-interval", type=float, default=1.5, help="Watch polling interval in seconds.")
    return parser.parse_args()


def resolve_paths(base_path: Path, docs_path: Path | None):
    base = base_path.expanduser().resolve()
    root, gamemode = (base.parent, base) if base.name.lower() == "gamemode" else (base, base / "gamemode")
    docs = docs_path.expanduser().resolve() if docs_path else root / "documentation"
    if not gamemode.is_dir():
        raise SystemExit(f"Lilia gamemode path does not exist: {gamemode}")
    return root, gamemode, docs


def source_files(roots, include_docs=False):
    suffixes = {".lua", ".md"} if include_docs else {".lua"}
    for root in roots:
        if not root.is_dir():
            continue
        for path in root.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in suffixes or path.name.lower() == REPORT_NAME:
                continue
            if not include_docs and {part.lower() for part in path.parts} & IGNORED_DIRS:
                continue
            yield path


def stable_timestamp(roots):
    mtimes = [path.stat().st_mtime for path in source_files(roots, include_docs=True)]
    return datetime.fromtimestamp(max(mtimes, default=0), timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def load_engine(root: Path):
    scripts = root / "scripts"
    if str(scripts) not in sys.path:
        sys.path.insert(0, str(scripts))
    from function_comparison_dashboard import FunctionComparisonReportGenerator
    return FunctionComparisonReportGenerator


def run_audit(root: Path, gamemode: Path, docs: Path, output: Path, quiet: bool):
    generator_class = load_engine(root)
    generator = generator_class(
        base_path=str(gamemode), docs_path=str(docs),
        language_file=str(gamemode / "languages" / "english.lua"),
        modules_paths=[], generate_module_docs=False, audit_scope="lilia",
    )
    if quiet:
        with contextlib.redirect_stdout(io.StringIO()):
            data = generator.run_all_analyses()
    else:
        data = generator.run_all_analyses()
    data.generated_at = stable_timestamp([gamemode, docs])
    report = "\n".join([
        "# Lilia Framework Audit", "",
        f"- **Scanned source:** `{gamemode}`",
        "- **External module roots scanned:** 0",
        f"- **Documentation reference:** `{docs}`", "",
        generator.generate_markdown_report(data),
    ])
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(report, encoding="utf-8")


def main():
    args = parse_args()
    root, gamemode, docs = resolve_paths(args.base_path, args.documentation_path)
    output = (args.output_path or root / REPORT_NAME).expanduser().resolve()

    def audit():
        if not args.quiet:
            print(f"[lilia-audit] scanning: {gamemode}")
            print("[lilia-audit] external modules: disabled")
            print(f"[lilia-audit] report: {output}")
        run_audit(root, gamemode, docs, output, args.quiet)

    audit()
    if not args.watch:
        return
    previous = tuple(sorted((str(path), path.stat().st_mtime_ns) for path in source_files([gamemode, docs], True)))
    if not args.quiet:
        print(f"[lilia-audit] watching every {args.watch_interval:g}s; press Ctrl+C to stop")
    while True:
        time.sleep(args.watch_interval)
        current = tuple(sorted((str(path), path.stat().st_mtime_ns) for path in source_files([gamemode, docs], True)))
        if current != previous:
            previous = current
            audit()


if __name__ == "__main__":
    main()
