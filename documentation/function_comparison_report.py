#!/usr/bin/env python3
import os
import sys
import json
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass
from collections import defaultdict

# Hardcoded paths
DEFAULT_GAMEMODE_ROOT = Path(r"E:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode")
DEFAULT_DOCS_ROOT = Path(r"E:\GMOD\Server\garrysmod\gamemodes\Lilia\documentation")
DEFAULT_LANGUAGE_FILE = Path(r"E:\GMOD\Server\garrysmod\gamemodes\Lilia\gamemode\languages\english.lua")
DEFAULT_MODULES_PATHS = [
    Path(r"E:\GMOD\Server\garrysmod\gamemodes\metrorp\gitmodules"),
    Path(r"E:\GMOD\Server\garrysmod\gamemodes\metrorp\modules"),
    Path(r"E:\GMOD\Server\garrysmod\gamemodes\metrorp\devmodules"),
]
DEFAULT_OUTPUT_DIR = Path(r"E:\GMOD\Server\garrysmod\gamemodes\Lilia\documentation\reports")

# Import from existing files
import sys
import os

# Add current directory to path for imports
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

try:
    from compare_functions import FunctionComparator, LuaFunctionExtractor, DocumentationParser
    from missinghooks import scan_hooks, read_documented_hooks
    from localization_analysis_report import (
        analyze_data, write_framework_md, write_framework_txt,
        write_modules_md, write_modules_txt, DEFAULT_FRAMEWORK_GAMEMODE_DIR,
        DEFAULT_LANGUAGE_FILE, DEFAULT_MODULES_PATHS
    )
except ImportError as e:
    print(f"Error importing required modules: {e}")
    print("Make sure compare_functions.py, missinghooks.py, and localization_analysis_report.py exist in the same directory")
    sys.exit(1)

@dataclass
class CombinedReportData:
    """Container for all analysis results"""
    function_comparison: Dict[str, Dict]
    hooks_missing: List[str]
    hooks_documented: List[str]
    localization_data: Dict
    modules_data: List
    generated_at: str

class FunctionComparisonReportGenerator:
    """Main class for generating comprehensive function comparison reports"""

    def __init__(self, base_path: str = None, docs_path: str = None, language_file: str = None,
                 modules_paths: List[str] = None, generate_module_docs: bool = True):
        self.base_path = Path(base_path) if base_path else DEFAULT_GAMEMODE_ROOT
        self.docs_path = Path(docs_path) if docs_path else DEFAULT_DOCS_ROOT
        self.language_file = language_file or str(DEFAULT_LANGUAGE_FILE)
        self.generate_module_docs = generate_module_docs

        # Handle modules_paths - convert to list of strings if provided
        if modules_paths:
            self.modules_paths = [str(p) for p in modules_paths]
        else:
            self.modules_paths = [str(p) for p in DEFAULT_MODULES_PATHS]

        # Initialize analyzers
        self.function_comparator = FunctionComparator(str(self.base_path))
        self.hooks_doc_path = self.docs_path / "docs" / "hooks" / "gamemode_hooks.md"

    def run_all_analyses(self) -> CombinedReportData:
        """Run all three analyses and combine results"""

        print("🔍 Running comprehensive analysis...")
        print("=" * 60)

        # 1. Function Documentation Comparison
        print("📋 Analyzing function documentation...")
        function_results = self._run_function_comparison()

        # 2. Missing Hooks Analysis
        print("🎣 Analyzing hooks documentation...")
        hooks_missing, hooks_documented = self._run_hooks_analysis()

        # 3. Localization Analysis
        print("🌐 Analyzing localization...")
        localization_data, modules_data = self._run_localization_analysis()

        return CombinedReportData(
            function_comparison=function_results,
            hooks_missing=hooks_missing,
            hooks_documented=hooks_documented,
            localization_data=localization_data,
            modules_data=modules_data,
            generated_at=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        )

    def _run_function_comparison(self) -> Dict[str, Dict]:
        """Run function documentation comparison analysis"""
        try:
            return self.function_comparator.compare_functions()
        except Exception as e:
            print(f"⚠️  Error in function comparison: {e}")
            return {}

    def _run_hooks_analysis(self) -> Tuple[List[str], List[str]]:
        """Run hooks documentation analysis"""
        try:
            hooks_found = scan_hooks(self.base_path / "gamemode")
            hooks_documented = read_documented_hooks(self.hooks_doc_path)
            hooks_missing = [h for h in hooks_found if h not in hooks_documented]
            return sorted(hooks_missing), sorted(list(hooks_documented))
        except Exception as e:
            print(f"⚠️  Error in hooks analysis: {e}")
            return [], []

    def _run_localization_analysis(self) -> Tuple[Dict, List]:
        """Run localization analysis"""
        try:
            # Framework analysis
            framework_data = analyze_data(self.language_file, str(self.base_path))

            # Modules analysis
            modules = []
            lang_name = Path(self.language_file).stem

            for base_path in self.modules_paths:
                base_path = Path(base_path)
                if not base_path.exists():
                    continue

                for module_name in sorted(os.listdir(base_path)):
                    module_dir = base_path / module_name
                    if not module_dir.is_dir():
                        continue

                    # Skip _disabled directories and modules inside _disabled
                    if module_name == "_disabled" or "_disabled" in str(module_dir):
                        print(f"ℹ️  Skipping disabled module: {module_dir}")
                        continue

                    lang_file = module_dir / "languages" / f"{lang_name}.lua"
                    # Only check localization for gitmodules; skip other modules for localization
                    if 'gitmodules' not in str(base_path).lower():
                        # Skip localization analysis for non-gitmodules
                        pass
                    else:
                        if not lang_file.exists():
                            continue
                        module_data = analyze_data(str(lang_file), str(module_dir))
                        modules.append(module_data)

            return framework_data, modules
        except Exception as e:
            print(f"⚠️  Error in localization analysis: {e}")
            return {}, []

    def generate_markdown_report(self, data: CombinedReportData) -> str:
        """Generate comprehensive markdown report"""
        report_lines = []

        # Header
        report_lines.extend([
            "# 🔍 Comprehensive Function Comparison Report",
            "",
            f"**Generated:** {data.generated_at}",
            f"**Base Path:** `{self.base_path}`",
            "",
            "---",
            ""
        ])

        # Executive Summary
        report_lines.extend(self._generate_executive_summary(data))

        # Function Documentation Section
        report_lines.extend(self._generate_function_docs_section(data))

        # Hooks Documentation Section
        report_lines.extend(self._generate_hooks_section(data))

        # Localization Section
        report_lines.extend(self._generate_localization_section(data))

        # Per-module docs generation (for non-Lilia modules)
        if self.generate_module_docs:
            try:
                self._generate_module_docs(data)
            except Exception as e:
                print(f"⚠️  Error generating per-module docs: {e}")
        else:
            print("ℹ️  Skipping per-module documentation generation (disabled by user)")

        return "\n".join(report_lines)

    def _generate_module_docs(self, data: CombinedReportData) -> None:
        """Generate docs inside each external module (non-Lilia) when entries are found.

        Rules:
        - Only modules (from modules_paths) are considered; framework base is ignored.
        - Create a `docs` folder in module directory when any entries exist.
        - If functions with dotted names (e.g., lia.something.doThing) exist, write libraries.md.
        - If hooks are found in module code that are NOT already documented in gamemode_hooks.md, write hooks.md.
        - Meta/functions inside module files (if any) are also recorded in libraries.md.
        """
        # Build a quick detector for dotted function names from function_comparison
        function_map = data.function_comparison or {}

        # Pre-compute per-file functions
        per_file_functions = {}
        for file_name, file_data in function_map.items():
            per_file_functions[file_name] = list(file_data.get('functions', {}).keys())

        # Get documented hooks from main gamemode_hooks.md to filter out already documented hooks
        try:
            documented_hooks = set()
            if self.hooks_doc_path.exists():
                documented_hooks = set(read_documented_hooks(str(self.hooks_doc_path)))
        except Exception:
            documented_hooks = set()

        # Iterate modules
        lang_name = Path(self.language_file).stem
        for base_path in self.modules_paths:
            base_path = Path(base_path)
            if not base_path.exists():
                continue

            for module_name in sorted(os.listdir(base_path)):
                module_dir = base_path / module_name
                if not module_dir.is_dir():
                    continue

                # Skip _disabled directories and modules inside _disabled
                if module_name == "_disabled" or "_disabled" in str(module_dir):
                    print(f"ℹ️  Skipping disabled module: {module_dir}")
                    continue

                docs_dir = module_dir / 'docs'

                # Scan module lua files for dotted functions and hooks
                dotted_functions = []
                hooks_found = set()

                for root, _, files in os.walk(module_dir):
                    for fname in files:
                        if not fname.lower().endswith('.lua'):
                            continue
                        fpath = Path(root) / fname
                        try:
                            with open(fpath, 'r', encoding='utf-8', errors='ignore') as f:
                                content = f.read()
                        except Exception:
                            continue

                        # Dotted functions - only lia.xxxxxx.xxxx pattern
                        import re
                        for m in re.finditer(r'\b(function\s+([A-Za-z_][\w\.]*?)\s*\(|([A-Za-z_][\w\.]*?)\s*=\s*function\s*\()', content):
                            name = m.group(2) or m.group(3)
                            # Only include functions that start with "lia." and have at least one more dot
                            if name and name.startswith('lia.') and name.count('.') >= 2:
                                dotted_functions.append(name)

                        # Hooks via hook.Add / hook.Run literals in module
                        # Only add hooks that are NOT already documented in gamemode_hooks.md
                        for m in re.finditer(r'hook\s*\.\s*Add\s*\(\s*([\"\"])\s*([^\"\']+)\1', content):
                            hook_name = m.group(2)
                            if hook_name not in documented_hooks:
                                hooks_found.add(hook_name)
                        for m in re.finditer(r'hook\s*\.\s*Run\s*\(\s*([\"\"])\s*([^\"\']+)\1', content):
                            hook_name = m.group(2)
                            if hook_name not in documented_hooks:
                                hooks_found.add(hook_name)

                # If any entries exist, create docs folder and write files
                if dotted_functions or hooks_found:
                    docs_dir.mkdir(parents=True, exist_ok=True)

                    # Helper function to get unique filename with suffix
                    def get_unique_filename(directory, base_name):
                        """Get a unique filename, adding suffix if file exists."""
                        base_path = directory / base_name
                        if not base_path.exists():
                            return base_path

                        # File exists, add suffix
                        counter = 2
                        while True:
                            name_parts = base_name.rsplit('.', 1)
                            if len(name_parts) == 2:
                                new_name = f"{name_parts[0]}_{counter}.{name_parts[1]}"
                            else:
                                new_name = f"{base_name}_{counter}"

                            new_path = directory / new_name
                            if not new_path.exists():
                                return new_path
                            counter += 1

                    # Write libraries.md if dotted functions found
                    if dotted_functions:
                        lib_md = get_unique_filename(docs_dir, 'libraries.md')
                        with open(lib_md, 'w', encoding='utf-8') as f:
                            f.write('# Module Libraries\n\n')
                            f.write('Detected dotted functions in this module.\n\n')
                            for name in sorted(set(dotted_functions)):
                                f.write(f'- `{name}`\n')

                    # Write hooks.md if undocumented hooks found
                    if hooks_found:
                        hooks_md = get_unique_filename(docs_dir, 'hooks.md')
                        with open(hooks_md, 'w', encoding='utf-8') as f:
                            f.write('# Module Hooks\n\n')
                            f.write('Detected hooks referenced/added in this module that are NOT documented in gamemode_hooks.md.\n\n')
                            for name in sorted(hooks_found, key=str.lower):
                                f.write(f'- `{name}`\n')

    def _generate_executive_summary(self, data: CombinedReportData) -> List[str]:
        """Generate executive summary section"""
        lines = ["## 📊 Executive Summary", ""]

        # Function stats - use unique counts for display
        total_functions = sum(r.get('total_functions', 0) for r in data.function_comparison.values())
        total_documented = sum(r.get('documented_functions', 0) for r in data.function_comparison.values())
        total_missing = sum(len(r.get('missing_functions', [])) for r in data.function_comparison.values())
        total_missing_unique = sum(r.get('missing_functions_count', len(r.get('missing_functions', []))) for r in data.function_comparison.values())

        # Hooks stats
        hooks_missing_count = len(data.hooks_missing)

        # Localization stats
        unused_keys = data.localization_data.get('unused_count', len(data.localization_data.get('unused', [])))
        undefined_calls = data.localization_data.get('undefined_count', len(data.localization_data.get('undefined_rows', [])))
        mismatch_count = data.localization_data.get('mismatch_count', len(data.localization_data.get('mismatch_rows', [])))
        at_patterns = data.localization_data.get('at_pattern_count', len(data.localization_data.get('at_pattern_rows', [])))

        lines.extend([
            "### 📋 Function Documentation",
            f"- **Total Functions:** {total_functions}",
            f"- **Documented:** {total_documented} ({(total_documented/total_functions*100):.1f}%)" if total_functions > 0 else "- **Documented:** N/A",
            f"- **Missing Functions:** {total_missing} unique ({total_missing_unique} total occurrences)",
            "",
            "### 🎣 Hooks Documentation",
            f"- **Missing Hooks:** {hooks_missing_count}",
            f"- **Documented Hooks:** {len(data.hooks_documented)}",
            "",
            "### 🌐 Localization Analysis",
            f"- **Unused Keys:** {unused_keys}",
            f"- **Undefined Calls:** {undefined_calls} unique",
            f"- **Argument Mismatches:** {mismatch_count} unique",
            f"- **@xxxxx Patterns:** {at_patterns} unique",
            "",
            "---",
            ""
        ])

        return lines

    def _generate_function_docs_section(self, data: CombinedReportData) -> List[str]:
        """Generate function documentation section"""
        lines = ["## 📋 Function Documentation Analysis", ""]

        if not data.function_comparison:
            lines.append("_No function comparison data available._")
            lines.append("")
            return lines

        # Summary stats
        total_files = len(data.function_comparison)
        total_functions = sum(r.get('total_functions', 0) for r in data.function_comparison.values())
        total_documented = sum(r.get('documented_functions', 0) for r in data.function_comparison.values())
        total_missing = sum(len(r.get('missing_functions', [])) for r in data.function_comparison.values())
        total_missing_unique = sum(r.get('missing_functions_count', len(r.get('missing_functions', []))) for r in data.function_comparison.values())
        total_extra = sum(len(r.get('extra_documented', [])) for r in data.function_comparison.values())
        total_extra_unique = sum(r.get('extra_documented_count', len(r.get('extra_documented', []))) for r in data.function_comparison.values())

        lines.extend([
            f"### Summary Statistics",
            f"- **Files Analyzed:** {total_files}",
            f"- **Total Functions:** {total_functions}",
            f"- **Documented Functions:** {total_documented}",
            f"- **Missing Documentation:** {total_missing} unique ({total_missing_unique} total occurrences)",
            f"- **Extra Documentation:** {total_extra} unique ({total_extra_unique} total occurrences)",
            f"- **Coverage:** {(total_documented/total_functions*100):.1f}%" if total_functions > 0 else "- **Coverage:** N/A",
            "",
        ])

        # Detailed breakdown
        for file_name, file_data in data.function_comparison.items():
            lines.extend([
                f"### {file_name}",
                f"- **Functions:** {file_data.get('total_functions', 0)}",
                f"- **Documented:** {file_data.get('documented_functions', 0)}",
                f"- **Missing:** {len(file_data.get('missing_functions', []))}",
                f"- **Extra:** {len(file_data.get('extra_documented', []))}",
                "",
            ])

            # Missing functions
            missing = file_data.get('missing_functions', [])
            if missing:
                lines.append("#### Missing Documentation:")
                for func in sorted(missing):
                    func_info = file_data.get('functions', {}).get(func, {})
                    realm = "Server" if func_info.get('is_server_only') else "Client" if func_info.get('is_client_only') else "Shared"
                    line = func_info.get('line_number', 'N/A')
                    lines.append(f"- `{func}` (Line {line}, {realm})")
                lines.append("")

            # Extra documented functions
            extra = file_data.get('extra_documented', [])
            if extra:
                lines.append("#### Extra Documentation (not in code):")
                for func in sorted(extra):
                    lines.append(f"- `{func}`")
                lines.append("")

        return lines

    def _generate_hooks_section(self, data: CombinedReportData) -> List[str]:
        """Generate hooks documentation section"""
        lines = ["## 🎣 Hooks Documentation Analysis", ""]

        if not data.hooks_missing and not data.hooks_documented:
            lines.append("_No hooks analysis data available._")
            lines.append("")
            return lines

        lines.extend([
            f"### Summary",
            f"- **Missing Hooks:** {len(data.hooks_missing)}",
            f"- **Documented Hooks:** {len(data.hooks_documented)}",
            "",
        ])

        if data.hooks_missing:
            lines.append("### Missing Hook Documentation:")
            for hook in data.hooks_missing:
                lines.append(f"- `{hook}`")
            lines.append("")

        return lines

    def _generate_localization_section(self, data: CombinedReportData) -> List[str]:
        """Generate localization analysis section"""
        lines = ["## 🌐 Localization Analysis", ""]

        if not data.localization_data:
            lines.append("_No localization data available._")
            lines.append("")
            return lines

        loc_data = data.localization_data

        # Framework summary
        lines.extend([
            "### Framework Localization",
            f"- **Language Keys:** {len(loc_data.get('keys', []))}",
            f"- **Total Usages:** {loc_data.get('total_hits', 0)}",
            f"- **Unused Keys:** {loc_data.get('unused_count', len(loc_data.get('unused', [])))}",
            f"- **Undefined Calls:** {loc_data.get('undefined_count', len(loc_data.get('undefined_rows', [])))}",
            f"- **Argument Mismatches:** {loc_data.get('mismatch_count', len(loc_data.get('mismatch_rows', [])))}",
            f"- **@xxxxx Patterns:** {loc_data.get('at_pattern_count', len(loc_data.get('at_pattern_rows', [])))}",
            "",
        ])

        # Issues summary
        issues = []
        if loc_data.get('unused'):
            issues.append(f"🔸 {len(loc_data['unused'])} unused keys")
        if loc_data.get('undefined_rows'):
            issues.append(f"🔸 {len(loc_data['undefined_rows'])} undefined calls")
        if loc_data.get('mismatch_rows'):
            issues.append(f"🔸 {len(loc_data['mismatch_rows'])} argument mismatches")
        if loc_data.get('at_pattern_rows'):
            issues.append(f"🔸 {len(loc_data['at_pattern_rows'])} @xxxxx patterns")

        if issues:
            lines.append("### Key Issues:")
            lines.extend(issues)
            lines.append("")

        # All issues (complete list)
        if loc_data.get('undefined_rows'):
            lines.append("### Undefined Localization Calls:")
            for row in loc_data['undefined_rows']:
                lines.append(f"- `{row[4]}` in {row[0]}:{row[1]}:{row[2]} ({row[3]})")
            lines.append("")

        if loc_data.get('unused'):
            lines.append("### Unused Keys:")
            for key in loc_data['unused']:
                lines.append(f"- `{key}`")
            lines.append("")

        return lines

    def save_report(self, data: CombinedReportData, output_file: str = None):
        """Generate and save the comprehensive report"""
        # Ensure output directory exists
        DEFAULT_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

        if output_file is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_file = str(DEFAULT_OUTPUT_DIR / f"function_comparison_report_{timestamp}.md")
        else:
            # If user provided a relative path, make it relative to DEFAULT_OUTPUT_DIR
            if not Path(output_file).is_absolute():
                output_file = str(DEFAULT_OUTPUT_DIR / output_file)

        report = self.generate_markdown_report(data)

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(report)

        return output_file

def confirm_analysis_actions(base_path: Path, docs_path: Path, language_file: str,
                           modules_paths: List[str], output_dir: Path, force: bool = False,
                           no_module_docs: bool = False) -> Tuple[bool, bool, List[str]]:
    """Display analysis actions and get user confirmation

    Returns:
        Tuple[bool, bool, List[str]]: (proceed_with_analysis, generate_module_docs, approved_modules_paths)
    """
    if force:
        return True, not no_module_docs, modules_paths

    print("\n🔍 ANALYSIS CONFIRMATION")
    print("=" * 60)

    print("\n📁 MAIN DIRECTORIES TO SCAN:")
    print(f"   • Gamemode: {base_path}")
    print(f"   • Documentation: {docs_path}")
    print(f"   • Language file: {language_file}")

    print("\n📤 OUTPUT LOCATION:")
    print(f"   • Reports directory: {output_dir}")
    print("   • Report files will be created here")

    print("\n⚠️  POTENTIAL FILESYSTEM CHANGES:")
    print("   • New report files will be created in the reports directory")
    if not no_module_docs:
        print("   • 'docs' folders may be created in module directories")
        print("   • 'libraries.md' and 'hooks.md' files may be created in module docs folders")

    print("\n" + "=" * 60)

    # Ask about main analysis
    while True:
        response = input("Do you want to proceed with the main analysis? (y/n): ").strip().lower()
        if response in ['y', 'yes']:
            break
        elif response in ['n', 'no']:
            print("❌ Analysis cancelled by user.")
            return False, False, []
        else:
            print("Please enter 'y' for yes or 'n' for no.")

    # Ask about module docs generation if not disabled
    generate_module_docs = True
    if not no_module_docs:
        print("\n📝 MODULE DOCUMENTATION GENERATION:")
        print("   This will scan module directories and may create 'docs' folders")
        print("   with 'libraries.md' and 'hooks.md' files in each module.")

        while True:
            response = input("Generate documentation in module directories? (y/n): ").strip().lower()
            if response in ['y', 'yes']:
                generate_module_docs = True
                break
            elif response in ['n', 'no']:
                generate_module_docs = False
                print("ℹ️  Module documentation generation will be skipped.")
                break
            else:
                print("Please enter 'y' for yes or 'n' for no.")

    # Ask about each module path individually
    approved_modules_paths = []
    print("\n📂 MODULE PATH CONFIRMATION:")
    print("-" * 40)

    for i, path in enumerate(modules_paths, 1):
        path_obj = Path(path)
        status = "✅ Exists" if path_obj.exists() else "❌ Missing"
        print(f"\n{i}. {path}")
        print(f"   Status: {status}")

        if not path_obj.exists():
            print("   ⚠️  Directory does not exist - skipping")
            continue

        while True:
            response = input(f"   Scan this module path? (y/n): ").strip().lower()
            if response in ['y', 'yes']:
                approved_modules_paths.append(path)
                print("   ✅ Added to scan list")
                break
            elif response in ['n', 'no']:
                print("   ❌ Skipped")
                break
            else:
                print("   Please enter 'y' for yes or 'n' for no.")

    if not approved_modules_paths:
        print("\n⚠️  No module paths approved for scanning.")
        while True:
            response = input("Continue with main analysis only? (y/n): ").strip().lower()
            if response in ['y', 'yes']:
                break
            elif response in ['n', 'no']:
                print("❌ Analysis cancelled by user.")
                return False, False, []
            else:
                print("Please enter 'y' for yes or 'n' for no.")

    print("\n✅ Proceeding with analysis...\n")
    return True, generate_module_docs, approved_modules_paths

def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description="Generate comprehensive function comparison reports",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python function_comparison_report.py
  python function_comparison_report.py --base-path /path/to/gamemode --docs-path /path/to/docs
  python function_comparison_report.py --output my_report.md --quiet
  python function_comparison_report.py --force  # Skip confirmations
        """
    )
    parser.add_argument("--base-path", default=str(DEFAULT_GAMEMODE_ROOT),
                       help=f"Base path to gamemode directory (default: {DEFAULT_GAMEMODE_ROOT})")
    parser.add_argument("--docs-path", default=str(DEFAULT_DOCS_ROOT),
                       help=f"Path to documentation directory (default: {DEFAULT_DOCS_ROOT})")
    parser.add_argument("--language-file", default=str(DEFAULT_LANGUAGE_FILE),
                       help=f"Path to main language file (default: {DEFAULT_LANGUAGE_FILE})")
    parser.add_argument("--modules-path", action="append",
                       help=f"Paths to modules directories (default: {DEFAULT_MODULES_PATHS})")
    parser.add_argument("--output", "-o", help="Output file path (default: auto-generated)")
    parser.add_argument("--quiet", "-q", action="store_true", help="Suppress progress output")
    parser.add_argument("--force", "-f", action="store_true", help="Skip confirmation prompts")
    parser.add_argument("--no-module-docs", action="store_true", help="Skip generation of docs in module directories")

    args = parser.parse_args()

    # Validate paths
    base_path = Path(args.base_path)
    docs_path = Path(args.docs_path)

    if not base_path.exists():
        print(f"❌ Error: Base path does not exist: {base_path}")
        sys.exit(1)

    if not docs_path.exists():
        print(f"❌ Error: Documentation path does not exist: {docs_path}")
        sys.exit(1)

    # Handle modules paths
    modules_paths = args.modules_path if args.modules_path else [str(p) for p in DEFAULT_MODULES_PATHS]

    # Confirm analysis actions with user
    proceed, generate_module_docs, approved_modules_paths = confirm_analysis_actions(
        base_path, docs_path, args.language_file, modules_paths,
        DEFAULT_OUTPUT_DIR, args.force, args.no_module_docs
    )
    if not proceed:
        sys.exit(0)

    if not args.quiet:
        print("🚀 Starting comprehensive function comparison analysis...")
        print(f"📁 Base Path: {base_path}")
        print(f"📚 Docs Path: {docs_path}")
        print(f"📂 Approved Module Paths: {len(approved_modules_paths)}")
        for i, path in enumerate(approved_modules_paths, 1):
            print(f"   {i}. {path}")

    # Initialize generator
    generator = FunctionComparisonReportGenerator(
        str(base_path),
        str(docs_path),
        args.language_file,
        approved_modules_paths,
        generate_module_docs
    )

    # Run analyses
    try:
        data = generator.run_all_analyses()

        # Generate and save report
        report_file = generator.save_report(data, args.output)

        if not args.quiet:
            print("\n✅ Analysis complete!")
            print(f"📄 Report saved: {report_file}")

            # Print quick summary
            total_functions = sum(r.get('total_functions', 0) for r in data.function_comparison.values())
            total_documented = sum(r.get('documented_functions', 0) for r in data.function_comparison.values())

            print("\n📈 Quick Summary:")
            print(f"   • Functions: {total_documented}/{total_functions} documented ({(total_documented/total_functions*100):.1f}%)" if total_functions > 0 else "   • Functions: No data")
            print(f"   • Missing hooks: {len(data.hooks_missing)}")
            print(f"   • Localization issues: {len(data.localization_data.get('unused', []))} unused, {len(data.localization_data.get('undefined_rows', []))} undefined")

    except Exception as e:
        print(f"❌ Error during analysis: {e}")
        if not args.quiet:
            import traceback
            traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
