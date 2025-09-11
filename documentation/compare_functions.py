#!/usr/bin/env python3
"""
Function comparison module for analyzing Lua function documentation coverage.
"""

import os
import re
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from dataclasses import dataclass


@dataclass
class FunctionInfo:
    """Information about a function"""
    name: str
    line_number: int
    is_server_only: bool = False
    is_client_only: bool = False
    parameters: List[str] = None
    description: str = ""

    def __post_init__(self):
        if self.parameters is None:
            self.parameters = []


class LuaFunctionExtractor:
    """Extracts functions from Lua files"""

    def __init__(self, base_path: str):
        self.base_path = Path(base_path)

    def extract_functions_from_file(self, file_path: str) -> Dict[str, FunctionInfo]:
        """Extract all functions from a single Lua file"""
        functions = {}

        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception as e:
            print(f"Warning: Could not read {file_path}: {e}")
            return functions

        lines = content.split('\n')

        # Pattern for function declarations
        # Matches: function name(...) and name = function(...)
        func_pattern = r'^\s*(?:local\s+)?function\s+([A-Za-z_][\w\.]*)\s*\(([^)]*)\)|^\s*([A-Za-z_][\w\.]*)\s*=\s*function\s*\(([^)]*)\)'

        for line_num, line in enumerate(lines, 1):
            match = re.search(func_pattern, line)
            if match:
                # Handle both patterns
                if match.group(1):  # function name(...)
                    func_name = match.group(1)
                    params = match.group(2)
                else:  # name = function(...)
                    func_name = match.group(3)
                    params = match.group(4)

                # Parse parameters
                param_list = []
                if params and params.strip():
                    param_list = [p.strip() for p in params.split(',') if p.strip()]

                # Determine realm (server/client/shared)
                is_server = self._is_server_realm(content, line_num)
                is_client = self._is_client_realm(content, line_num)

                functions[func_name] = FunctionInfo(
                    name=func_name,
                    line_number=line_num,
                    is_server_only=is_server and not is_client,
                    is_client_only=is_client and not is_server,
                    parameters=param_list
                )

        return functions

    def _is_server_realm(self, content: str, line_num: int) -> bool:
        """Check if function is in server realm"""
        lines = content.split('\n')
        start_line = max(0, line_num - 20)  # Look 20 lines back

        for i in range(start_line, line_num):
            line = lines[i].strip().lower()
            if 'if server' in line or 'if (server)' in line:
                return True
            if 'if client' in line or 'if (client)' in line:
                return False
            if 'server' in line and ('then' in line or '{' in line):
                return True

        return False

    def _is_client_realm(self, content: str, line_num: int) -> bool:
        """Check if function is in client realm"""
        lines = content.split('\n')
        start_line = max(0, line_num - 20)  # Look 20 lines back

        for i in range(start_line, line_num):
            line = lines[i].strip().lower()
            if 'if client' in line or 'if (client)' in line:
                return True
            if 'if server' in line or 'if (server)' in line:
                return False
            if 'client' in line and ('then' in line or '{' in line):
                return True

        return False

    def extract_all_functions(self) -> Dict[str, Dict[str, FunctionInfo]]:
        """Extract functions from all Lua files in the gamemode"""
        all_functions = {}

        # Scan all .lua files
        for root, dirs, files in os.walk(self.base_path):
            # Skip certain directories
            dirs[:] = [d for d in dirs if d not in ['node_modules', '.git']]

            for file in files:
                if file.endswith('.lua'):
                    file_path = os.path.join(root, file)
                    relative_path = os.path.relpath(file_path, self.base_path)

                    functions = self.extract_functions_from_file(file_path)
                    if functions:
                        all_functions[relative_path] = functions

        return all_functions


class DocumentationParser:
    """Parses documentation files to extract documented functions"""

    def __init__(self, docs_path: str):
        self.docs_path = Path(docs_path)

    def extract_documented_functions(self) -> Dict[str, Dict[str, FunctionInfo]]:
        """Extract all documented functions from documentation files"""
        documented_functions = {}

        # Look for library documentation files
        libraries_path = self.docs_path / "docs" / "libraries"
        if libraries_path.exists():
            for md_file in libraries_path.glob("*.md"):
                if md_file.name.startswith("lia."):
                    functions = self._parse_library_file(md_file)
                    if functions:
                        documented_functions[md_file.name] = functions

        # Look for meta documentation files
        meta_path = self.docs_path / "docs" / "meta"
        if meta_path.exists():
            for md_file in meta_path.glob("*.md"):
                functions = self._parse_meta_file(md_file)
                if functions:
                    documented_functions[f"meta/{md_file.name}"] = functions

        return documented_functions

    def _parse_library_file(self, file_path: Path) -> Dict[str, FunctionInfo]:
        """Parse a library documentation file"""
        functions = {}

        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception as e:
            print(f"Warning: Could not read {file_path}: {e}")
            return functions

        lines = content.split('\n')

        # Look for function headers in the format "### function.name"
        for line_num, line in enumerate(lines, 1):
            stripped = line.strip()

            # Look for function headers like "### lia.include"
            func_match = re.search(r'^###+\s+([A-Za-z_][\w\.]*)\s*$', stripped)
            if func_match:
                func_name = func_match.group(1)
                # Extract parameters from the following lines
                params = self._extract_parameters_from_docs(lines, line_num)

                functions[func_name] = FunctionInfo(
                    name=func_name,
                    line_number=line_num,
                    parameters=params
                )

        return functions

    def _extract_parameters_from_docs(self, lines: List[str], start_line: int) -> List[str]:
        """Extract parameters from documentation following a function header"""
        params = []

        # Look for the Parameters section
        in_params_section = False
        for i in range(start_line, min(start_line + 50, len(lines))):  # Look up to 50 lines ahead
            line = lines[i].strip()

            if line.lower() == '**parameters**':
                in_params_section = True
                continue
            elif line.startswith('**') and in_params_section:
                # We've moved to the next section
                break
            elif in_params_section and line.startswith('* `'):
                # Extract parameter name from format: * `param` (*type*): description
                param_match = re.search(r'\* `([^`]+)`', line)
                if param_match:
                    params.append(param_match.group(1))

        return params

    def _parse_meta_file(self, file_path: Path) -> Dict[str, FunctionInfo]:
        """Parse a meta documentation file"""
        functions = {}

        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception as e:
            print(f"Warning: Could not read {file_path}: {e}")
            return functions

        lines = content.split('\n')

        # Look for method definitions
        for line_num, line in enumerate(lines, 1):
            # Look for method signatures like: object:method(param)
            method_match = re.search(r'`([A-Za-z_][\w\.:]*)\(([^)]*)\)`', line)
            if method_match:
                method_name = method_match.group(1)
                params_str = method_match.group(2)
                params = [p.strip() for p in params_str.split(',') if p.strip()]

                functions[method_name] = FunctionInfo(
                    name=method_name,
                    line_number=line_num,
                    parameters=params
                )

        return functions


class FunctionComparator:
    """Compares functions between code and documentation"""

    def __init__(self, base_path: str, docs_path: str = None):
        self.base_path = Path(base_path)
        self.docs_path = Path(docs_path) if docs_path else self.base_path.parent / "documentation"

        self.extractor = LuaFunctionExtractor(str(self.base_path))
        self.parser = DocumentationParser(str(self.docs_path))

    def compare_functions(self) -> Dict[str, Dict]:
        """Compare functions between code and documentation"""
        print("Extracting functions from code...")
        code_functions = self.extractor.extract_all_functions()

        print("Extracting functions from documentation...")
        doc_functions = self.parser.extract_documented_functions()

        print("Comparing functions...")
        comparison_results = {}

        # Compare each code file with documentation
        for file_path, functions in code_functions.items():
            file_comparison = self._compare_file_functions(file_path, functions, doc_functions)
            if file_comparison:
                comparison_results[file_path] = file_comparison

        return comparison_results

    def _compare_file_functions(self, file_path: str, code_functions: Dict[str, FunctionInfo],
                               doc_functions: Dict[str, Dict[str, FunctionInfo]]) -> Dict:
        """Compare functions for a single file"""
        # Flatten all documented functions
        all_documented = {}
        for doc_file, funcs in doc_functions.items():
            for func_name, func_info in funcs.items():
                all_documented[func_name] = func_info

        # Find functions in this file that are documented
        documented_in_file = {}
        missing_functions = []
        extra_documented = []

        for func_name, func_info in code_functions.items():
            if func_name in all_documented:
                documented_in_file[func_name] = func_info
            else:
                missing_functions.append(func_name)

        # Find documented functions that don't exist in code
        code_function_names = set(code_functions.keys())
        for doc_file, funcs in doc_functions.items():
            for func_name in funcs.keys():
                if func_name not in code_function_names:
                    extra_documented.append(func_name)

        # Create unique lists for missing and extra functions
        unique_missing = sorted(set(missing_functions))
        unique_extra = sorted(set(extra_documented))

        return {
            'total_functions': len(code_functions),
            'documented_functions': len(documented_in_file),
            'missing_functions': unique_missing,
            'extra_documented': unique_extra,
            'functions': {name: {
                'line_number': info.line_number,
                'is_server_only': info.is_server_only,
                'is_client_only': info.is_client_only,
                'parameters': info.parameters
            } for name, info in code_functions.items()},
            # Keep original counts for detailed analysis
            'missing_functions_count': len(missing_functions),
            'extra_documented_count': len(extra_documented)
        }
