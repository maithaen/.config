#!/usr/bin/env python3
"""
DevInit - Development Configuration File Generator

Generate configuration files for various development tools including:
- GolangCI, Python pyproject.toml, Aider, EditorConfig
- Prettier, ESLint, TypeScript, Docker, Git, VSCode
- Makefile, GitHub Actions, Rust/Cargo, Jest

Usage:
    devinit <template>           # Generate single config
    devinit --list               # List all templates
    devinit --all [--type TYPE]  # Generate all configs for project type

Examples:
    devinit gitignore
    devinit pyproject
    devinit --all --type python
    devinit --all --type node
"""

import argparse
import sys
from pathlib import Path

# Rich for beautiful output
try:
    from rich.console import Console
    from rich.table import Table

    RICH_AVAILABLE = True
except ImportError:
    RICH_AVAILABLE = False

console = Console() if RICH_AVAILABLE else None

# ============================================
# Configuration Templates
# ============================================

TEMPLATES = {
    "golangci": {
        "filename": ".golangci.yml",
        "description": "GolangCI linter configuration",
        "content": """version: "1"

run:
  timeout: 5m
  modules-download-mode: readonly

linters:
  enable:
    - bodyclose
    - dogsled
    - dupl
    - errcheck
    - goconst
    - gocritic
    - godox
    - gofmt
    - goimports
    - gosec
    - gosimple
    - govet
    - ineffassign
    - misspell
    - nakedret
    - prealloc
    - staticcheck
    - unconvert
    - unused
    - whitespace

issues:
  max-issues-per-linter: 0
  max-same-issues: 0
""",
    },
    "pyproject": {
        "filename": "pyproject.toml",
        "description": "Python project configuration",
        "content": """[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src"]

[project.scripts]
change-to-your-script = "src.main:main"

[project]
name = "your-project-name"
version = "0.1.0"
description = "A brief description of your project"
readme = "README.md"
requires-python = ">=3.10"
license = {text = "MIT"}
authors = [
    {name = "Your Name", email = "your.email@example.com"}
]
keywords = ["keyword1", "keyword2"]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

dependencies = [
    # your runtime dependencies here
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "black>=22.0",
    "flake8>=5.0",
    "mypy>=0.990",
]

[project.urls]
Homepage = "https://github.com/yourusername/your-project"
Repository = "https://github.com/yourusername/your-project"
Documentation = "https://your-project.readthedocs.io"

[tool.black]
line-length = 124
target-version = ['py310']

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
""",
    },
    "flake8": {
        "filename": ".flake8",
        "description": "Flake8 linter configuration",
        "content": """[flake8]
max-line-length = 124
extend-ignore = E203, E266, E501, W503
exclude =
    .git,
    __pycache__,
    .venv,
    venv,
    env,
    build,
    dist,
    *.egg-info,
    .pytest_cache,
    .mypy_cache,
    .tox,
    docs
max-complexity = 10
per-file-ignores =
    __init__.py:F401
""",
    },
    "aider": {
        "filename": ".aider.conf.yml",
        "description": "Aider AI coding assistant configuration",
        "content": """# Read only files
read:
  - README.md

# Always say yes to every confirmation
yes-always: true

# Git settings
git: true
auto-commits: false

# Disable thinking tokens
thinking-tokens: "0"

# Disable automatic linting
auto-lint: false

# Enable prompt caching
cache-prompts: true

# Repository map with token budget
map-tokens: "1024"

# Default model configuration
model: openai/qwen3-coder-plus
weak-model: mistral/codestral-latest

# Disable model warnings
check-model-accepts-settings: false
show-model-warnings: false

alias:
  - "gmf:gemini/gemini-2.5-flash"
  - "d32:deepseek/deepseek-v3.2"
  - "d31:ollama_chat/deepseek-v3.1:671b-cloud"
  - "gml:ollama_chat/glm-4.6:cloud"
  - "dc:deepseek/deepseek-coder"
  - "mc:mistral/codestral-latest"
  - "qwen:openai/qwen3-coder-plus"
""",
    },
    "editorconfig": {
        "filename": ".editorconfig",
        "description": "EditorConfig for consistent coding styles",
        "content": """# EditorConfig is awesome: https://EditorConfig.org

root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
indent_style = space
indent_size = 4

[*.{js,jsx,ts,tsx,json,yml,yaml}]
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab

[*.go]
indent_style = tab
""",
    },
    "prettier": {
        "filename": ".prettierrc.json",
        "description": "Prettier code formatter configuration",
        "content": """{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "endOfLine": "lf"
}
""",
    },
    "eslint": {
        "filename": ".eslintrc.json",
        "description": "ESLint JavaScript linter configuration",
        "content": """{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "eslint:recommended"
  ],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "rules": {
    "indent": ["error", 2],
    "linebreak-style": ["error", "unix"],
    "quotes": ["error", "single"],
    "semi": ["error", "always"],
    "no-unused-vars": "warn",
    "no-console": "warn"
  }
}
""",
    },
    "typescript": {
        "filename": "tsconfig.json",
        "description": "TypeScript compiler configuration",
        "content": """{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020", "DOM"],
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "preserve",
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "build"]
}
""",
    },
    "dockerfile": {
        "filename": "Dockerfile",
        "description": "Docker container configuration",
        "content": """# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["node", "dist/index.js"]
""",
    },
    "dockerignore": {
        "filename": ".dockerignore",
        "description": "Docker ignore file",
        "content": """node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.env.local
.DS_Store
dist
build
coverage
.vscode
.idea
*.log
""",
    },
    "gitignore": {
        "filename": ".gitignore",
        "description": "Git ignore file",
        "content": """# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
out/
*.exe
*.dll
*.so
*.dylib

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Logs
*.log
logs/

# Testing
coverage/
.nyc_output/
.pytest_cache/
__pycache__/

# OS
Thumbs.db
""",
    },
    "gitattributes": {
        "filename": ".gitattributes",
        "description": "Git attributes file",
        "content": """* text=auto eol=lf

*.sh text eol=lf
*.bat text eol=crlf

*.jpg binary
*.png binary
*.gif binary
*.ico binary
*.mov binary
*.mp4 binary
*.mp3 binary
*.flv binary
*.fla binary
*.swf binary
*.gz binary
*.zip binary
*.7z binary
*.ttf binary
*.eot binary
*.woff binary
*.pyc binary
*.pdf binary
*.exe binary
*.dll binary
*.so binary
*.dylib binary
""",
    },
    "vscode": {
        "filename": ".vscode/settings.json",
        "description": "VSCode workspace settings",
        "content": """{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  },
  "files.eol": "\\n",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter"
  },
  "[go]": {
    "editor.defaultFormatter": "golang.go"
  }
}
""",
    },
    "makefile": {
        "filename": "Makefile",
        "description": "Makefile for project automation",
        "content": """.PHONY: help install build test clean run

help:
\t@echo "Available commands:"
\t@echo "  make install    - Install dependencies"
\t@echo "  make build      - Build the project"
\t@echo "  make test       - Run tests"
\t@echo "  make clean      - Clean build artifacts"
\t@echo "  make run        - Run the application"

install:
\t@echo "Installing dependencies..."
\tnpm install

build:
\t@echo "Building project..."
\tnpm run build

test:
\t@echo "Running tests..."
\tnpm test

clean:
\t@echo "Cleaning build artifacts..."
\trm -rf dist build node_modules

run:
\t@echo "Running application..."
\tnpm start
""",
    },
    "github-actions": {
        "filename": ".github/workflows/ci.yml",
        "description": "GitHub Actions CI workflow",
        "content": """name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18.x, 20.x]

    steps:
    - uses: actions/checkout@v4

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'

    - name: Install dependencies
      run: npm ci

    - name: Run linter
      run: npm run lint

    - name: Run tests
      run: npm test

    - name: Build
      run: npm run build
""",
    },
    "cargo": {
        "filename": "Cargo.toml",
        "description": "Rust Cargo configuration",
        "content": """[package]
name = "your-project"
version = "0.1.0"
edition = "2021"
authors = ["Your Name <your.email@example.com>"]
description = "A brief description of your project"
license = "MIT"
repository = "https://github.com/yourusername/your-project"

[dependencies]

[dev-dependencies]
""",
    },
    "jest": {
        "filename": "jest.config.js",
        "description": "Jest test runner configuration",
        "content": """module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/tests'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/*.test.ts',
  ],
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
};
""",
    },
}

# Project type mappings
PROJECT_TYPES = {
    "node": [
        "editorconfig",
        "gitignore",
        "gitattributes",
        "vscode",
        "prettier",
        "eslint",
        "typescript",
        "jest",
        "dockerfile",
        "dockerignore",
        "makefile",
        "github-actions",
    ],
    "python": [
        "editorconfig",
        "gitignore",
        "gitattributes",
        "vscode",
        "pyproject",
        "flake8",
        "aider",
        "makefile",
    ],
    "go": [
        "editorconfig",
        "gitignore",
        "gitattributes",
        "vscode",
        "golangci",
        "dockerfile",
        "dockerignore",
        "makefile",
    ],
    "rust": [
        "editorconfig",
        "gitignore",
        "gitattributes",
        "vscode",
        "cargo",
        "makefile",
    ],
    "full": list(TEMPLATES.keys()),
}

# ============================================
# Helper Functions
# ============================================


def print_success(message: str):
    if RICH_AVAILABLE:
        console.print(f"[green]✓[/green] {message}")
    else:
        print(f"✓ {message}")


def print_error(message: str):
    if RICH_AVAILABLE:
        console.print(f"[red]✗[/red] {message}")
    else:
        print(f"✗ {message}", file=sys.stderr)


def print_warning(message: str):
    if RICH_AVAILABLE:
        console.print(f"[yellow]![/yellow] {message}")
    else:
        print(f"! {message}")


def print_info(message: str):
    if RICH_AVAILABLE:
        console.print(f"[blue]→[/blue] {message}")
    else:
        print(f"→ {message}")


# ============================================
# Main Functions
# ============================================


def write_config(template_name: str, output_path: str = None) -> bool:
    """Write a configuration file from template."""
    template_name = template_name.lower().replace("-", "").replace("_", "")

    # Find matching template
    template = None
    for key, value in TEMPLATES.items():
        if key.replace("-", "").replace("_", "") == template_name:
            template = value
            template_name = key
            break

    if not template:
        print_error(f"Template '{template_name}' not found")
        return False

    filename = output_path or template["filename"]

    # Create parent directories if needed
    parent = Path(filename).parent
    if parent and str(parent) != ".":
        parent.mkdir(parents=True, exist_ok=True)

    try:
        with open(filename, "w", encoding="utf-8", newline="\n") as f:
            f.write(template["content"])
        print_success(f"{template['description']} → {filename}")
        return True
    except Exception as e:
        print_error(f"Failed to create {filename}: {e}")
        return False


def list_templates():
    """List all available templates."""
    if RICH_AVAILABLE:
        table = Table(title="Available Templates")
        table.add_column("Template", style="cyan")
        table.add_column("Filename", style="green")
        table.add_column("Description", style="white")

        for name, template in sorted(TEMPLATES.items()):
            table.add_row(name, template["filename"], template["description"])

        console.print(table)

        console.print("\n[bold]Project Types:[/bold]")
        for ptype, templates in PROJECT_TYPES.items():
            console.print(
                f"  [cyan]{ptype}[/cyan]: {', '.join(templates[:5])}{'...' if len(templates) > 5 else ''}"
            )
    else:
        print("Available Templates:")
        print("-" * 60)
        for name, template in sorted(TEMPLATES.items()):
            print(f"  {name:15} {template['filename']:25} {template['description']}")

        print("\nProject Types:")
        for ptype, templates in PROJECT_TYPES.items():
            print(
                f"  {ptype}: {', '.join(templates[:5])}{'...' if len(templates) > 5 else ''}"
            )


def generate_all(project_type: str = "full"):
    """Generate all configuration files for a project type."""
    project_type = project_type.lower()

    if project_type not in PROJECT_TYPES:
        print_error(f"Unknown project type: {project_type}")
        print_info(f"Available types: {', '.join(PROJECT_TYPES.keys())}")
        return False

    templates = PROJECT_TYPES[project_type]
    print_info(f"Generating {project_type} project configuration files...")
    print()

    success_count = 0
    for template_name in templates:
        if write_config(template_name):
            success_count += 1

    print()
    print_success(f"Generated {success_count}/{len(templates)} configuration files")
    return success_count == len(templates)


def main():
    parser = argparse.ArgumentParser(
        description="DevInit - Development Configuration File Generator",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  devinit gitignore              Generate .gitignore
  devinit pyproject              Generate pyproject.toml
  devinit --list                 List all available templates
  devinit --all                  Generate all configs
  devinit --all --type python    Generate Python project configs
  devinit --all --type node      Generate Node.js project configs
        """,
    )

    parser.add_argument(
        "template",
        nargs="?",
        help="Template name to generate (e.g., gitignore, pyproject, eslint)",
    )

    parser.add_argument(
        "-l", "--list", action="store_true", help="List all available templates"
    )

    parser.add_argument(
        "-a", "--all", action="store_true", help="Generate all configuration files"
    )

    parser.add_argument(
        "-t",
        "--type",
        choices=list(PROJECT_TYPES.keys()),
        default="full",
        help="Project type for --all (default: full)",
    )

    parser.add_argument("-o", "--output", help="Custom output path for single template")

    args = parser.parse_args()

    if args.list:
        list_templates()
    elif args.all:
        generate_all(args.type)
    elif args.template:
        write_config(args.template, args.output)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
