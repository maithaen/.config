<#
.SYNOPSIS
    Configuration file generator for development tools and environments.

.DESCRIPTION
    Generates configuration files for various development tools including:
    - GolangCI (Go linter configuration)
    - Python pyproject.toml
    - Aider-chat configuration
    - Environment variables setup
    - EditorConfig
    - Prettier
    - ESLint
    - TypeScript
    - Docker
    - Git attributes and ignore
    - VSCode settings
    - Makefile
    - GitHub Actions

.NOTES
    Version: 3.0
    Author: Extended Script
#>

#Requires -Version 5.1

# ============================================
# Script Configuration
# ============================================
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================
# Helper Functions
# ============================================

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "Cyan"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-FileContent {
    param(
        [string]$Content,
        [string]$Path,
        [string]$Description
    )
    
    try {
        $Content | Out-File -FilePath $Path -Encoding utf8 -Force
        Write-ColorOutput "✓ $Description generated successfully at: $Path" "Green"
        return $true
    }
    catch {
        Write-Error "Failed to create $Description at ${Path}: $($_.Exception.Message)"
        return $false
    }
}

# ============================================
# Configuration Templates
# ============================================

$Templates = @{
    GolangCI = @'
version: "1"

run:
  timeout: 5m
  modules-download-mode: readonly

linters:
  enable:
    - bodyclose
    - deadcode
    - depguard
    - dogsled
    - dupl
    - errcheck
    - exportloopref
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
    - structcheck
    - typecheck
    - unconvert
    - unused
    - varcheck
    - whitespace

issues:
  max-issues-per-linter: 0
  max-same-issues: 0
'@

    PyProject = @'
[build-system]
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
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
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
target-version = ['py38']


[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"


[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
'@

    Flake8 = @'
[flake8]
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
'@

    Aider = @'
# Read only and use file: if you went to add and edit
# multiple files
# read: [CONVENTIONS.md, anotherfile.txt]
read:
  - README.md

## Always say yes to every confirmation
yes-always: true

# Disable looking for git repo
git: true

# Disable automatic commits
auto-commits: false

# Disable thinking tokens
thinking-tokens: "0"

# Disable automatic linting
auto-lint: false

# Enable prompt caching
cache-prompts: true

# Enable repository map with token budget
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

'@

    EditorConfig = @'
# EditorConfig is awesome: https://EditorConfig.org

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
'@

    Prettier = @'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "endOfLine": "lf"
}
'@

    ESLint = @'
{
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
'@

    TypeScript = @'
{
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
'@

    Dockerfile = @'
# Build stage
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
'@

    DockerIgnore = @'
node_modules
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
'@

    GitIgnore = @'
# Dependencies
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
'@

    GitAttributes = @'
* text=auto eol=lf

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
'@

    VSCode = @'
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "files.eol": "\n",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter"
  },
  "[go]": {
    "editor.defaultFormatter": "golang.go"
  }
}
'@

    Makefile = @'
.PHONY: help install build test clean run

help:
	@echo "Available commands:"
	@echo "  make install    - Install dependencies"
	@echo "  make build      - Build the project"
	@echo "  make test       - Run tests"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make run        - Run the application"

install:
	@echo "Installing dependencies..."
	npm install

build:
	@echo "Building project..."
	npm run build

test:
	@echo "Running tests..."
	npm test

clean:
	@echo "Cleaning build artifacts..."
	rm -rf dist build node_modules

run:
	@echo "Running application..."
	npm start
'@

    GitHubActions = @'
name: CI

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
    - uses: actions/checkout@v3
    
    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v3
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
'@

    RustConfig = @'
[package]
name = "your-project"
version = "0.1.0"
edition = "2021"
authors = ["Your Name <your.email@example.com>"]
description = "A brief description of your project"
license = "MIT"
repository = "https://github.com/yourusername/your-project"

[dependencies]

[dev-dependencies]
'@

    CargoConfig = @'
[build]
target-dir = "target"

[term]
color = "auto"
'@

    JestConfig = @'
module.exports = {
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
'@
}

# ============================================
# Main Functions
# ============================================

function Initialize-GolangCI {
    [CmdletBinding()]
    param([string]$OutputPath = ".golangci.yml")
    Write-FileContent -Content $Templates.GolangCI -Path $OutputPath -Description "GolangCI configuration"
}

function Initialize-PyProject {
    [CmdletBinding()]
    param([string]$OutputPath = "pyproject.toml")
    Write-FileContent -Content $Templates.PyProject -Path $OutputPath -Description "Python pyproject.toml"
}

function Initialize-Flake8 {
    [CmdletBinding()]
    param([string]$OutputPath = ".flake8")
    Write-FileContent -Content $Templates.Flake8 -Path $OutputPath -Description "Flake8 configuration"
}

function Initialize-Aider {
    [CmdletBinding()]
    param([string]$OutputPath = ".aider.conf.yml")
    Write-FileContent -Content $Templates.Aider -Path $OutputPath -Description "Aider configuration"
}

function Initialize-EditorConfig {
    [CmdletBinding()]
    param([string]$OutputPath = ".editorconfig")
    Write-FileContent -Content $Templates.EditorConfig -Path $OutputPath -Description "EditorConfig"
}

function Initialize-Prettier {
    [CmdletBinding()]
    param([string]$OutputPath = ".prettierrc.json")
    Write-FileContent -Content $Templates.Prettier -Path $OutputPath -Description "Prettier configuration"
}

function Initialize-ESLint {
    [CmdletBinding()]
    param([string]$OutputPath = ".eslintrc.json")
    Write-FileContent -Content $Templates.ESLint -Path $OutputPath -Description "ESLint configuration"
}

function Initialize-TypeScript {
    [CmdletBinding()]
    param([string]$OutputPath = "tsconfig.json")
    Write-FileContent -Content $Templates.TypeScript -Path $OutputPath -Description "TypeScript configuration"
}

function Initialize-Dockerfile {
    [CmdletBinding()]
    param([string]$OutputPath = "Dockerfile")
    Write-FileContent -Content $Templates.Dockerfile -Path $OutputPath -Description "Dockerfile"
}

function Initialize-DockerIgnore {
    [CmdletBinding()]
    param([string]$OutputPath = ".dockerignore")
    Write-FileContent -Content $Templates.DockerIgnore -Path $OutputPath -Description "Docker ignore file"
}

function Initialize-GitIgnore {
    [CmdletBinding()]
    param([string]$OutputPath = ".gitignore")
    Write-FileContent -Content $Templates.GitIgnore -Path $OutputPath -Description "Git ignore file"
}

function Initialize-GitAttributes {
    [CmdletBinding()]
    param([string]$OutputPath = ".gitattributes")
    Write-FileContent -Content $Templates.GitAttributes -Path $OutputPath -Description "Git attributes file"
}

function Initialize-VSCode {
    [CmdletBinding()]
    param([string]$OutputPath = ".vscode/settings.json")
    $dir = Split-Path -Parent $OutputPath
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Write-FileContent -Content $Templates.VSCode -Path $OutputPath -Description "VSCode settings"
}

function Initialize-Makefile {
    [CmdletBinding()]
    param([string]$OutputPath = "Makefile")
    Write-FileContent -Content $Templates.Makefile -Path $OutputPath -Description "Makefile"
}

function Initialize-GitHubActions {
    [CmdletBinding()]
    param([string]$OutputPath = ".github/workflows/ci.yml")
    $dir = Split-Path -Parent $OutputPath
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Write-FileContent -Content $Templates.GitHubActions -Path $OutputPath -Description "GitHub Actions workflow"
}

function Initialize-RustConfig {
    [CmdletBinding()]
    param([string]$OutputPath = "Cargo.toml")
    Write-FileContent -Content $Templates.RustConfig -Path $OutputPath -Description "Rust Cargo.toml"
}

function Initialize-CargoConfig {
    [CmdletBinding()]
    param([string]$OutputPath = ".cargo/config.toml")
    $dir = Split-Path -Parent $OutputPath
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Write-FileContent -Content $Templates.CargoConfig -Path $OutputPath -Description "Cargo configuration"
}

function Initialize-JestConfig {
    [CmdletBinding()]
    param([string]$OutputPath = "jest.config.js")
    Write-FileContent -Content $Templates.JestConfig -Path $OutputPath -Description "Jest configuration"
}

function Initialize-AllConfigs {
    <#
    .SYNOPSIS
        Generates all configuration files at once.
    
    .PARAMETER Type
        Type of project: 'node', 'python', 'go', 'rust', or 'full'
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('node', 'python', 'go', 'rust', 'full')]
        [string]$Type = 'full'
    )
    
    Write-ColorOutput "`n=== Initializing $Type project configuration files ===`n" "Yellow"
    
    # Common files
    Initialize-EditorConfig
    Initialize-GitIgnore
    Initialize-GitAttributes
    Initialize-VSCode
    
    switch ($Type) {
        'node' {
            Initialize-Prettier
            Initialize-ESLint
            Initialize-TypeScript
            Initialize-JestConfig
            Initialize-Dockerfile
            Initialize-DockerIgnore
            Initialize-Makefile
            Initialize-GitHubActions
        }
        'python' {
            Initialize-PyProject
            Initialize-Flake8
            Initialize-Aider
            Initialize-Makefile
        }
        'go' {
            Initialize-GolangCI
            Initialize-Dockerfile
            Initialize-DockerIgnore
            Initialize-Makefile
        }
        'rust' {
            Initialize-RustConfig
            Initialize-CargoConfig
            Initialize-Makefile
        }
        'full' {
            Initialize-GolangCI
            Initialize-PyProject
            Initialize-Flake8
            Initialize-Aider
            Initialize-Prettier
            Initialize-ESLint
            Initialize-TypeScript
            Initialize-Dockerfile
            Initialize-DockerIgnore
            Initialize-Makefile
            Initialize-GitHubActions
            Initialize-RustConfig
            Initialize-CargoConfig
            Initialize-JestConfig
        }
    }
    
    Write-ColorOutput "`n=== Configuration generation complete! ===`n" "Green"
}

# ============================================
# Aliases
# ============================================

Set-Alias -Name Init-Goci -Value Initialize-GolangCI
Set-Alias -Name Init-PyUV -Value Initialize-PyProject
Set-Alias -Name Init-Flake8 -Value Initialize-Flake8
Set-Alias -Name Init-Aider -Value Initialize-Aider
Set-Alias -Name Init-Editor -Value Initialize-EditorConfig
Set-Alias -Name Init-Prettier -Value Initialize-Prettier
Set-Alias -Name Init-ESLint -Value Initialize-ESLint
Set-Alias -Name Init-TS -Value Initialize-TypeScript
Set-Alias -Name Init-Docker -Value Initialize-Dockerfile
Set-Alias -Name Init-Git -Value Initialize-GitIgnore
Set-Alias -Name Init-VSCode -Value Initialize-VSCode
Set-Alias -Name Init-Make -Value Initialize-Makefile
Set-Alias -Name Init-GHA -Value Initialize-GitHubActions
Set-Alias -Name Init-Rust -Value Initialize-RustConfig
Set-Alias -Name Init-Jest -Value Initialize-JestConfig
Set-Alias -Name Init-All -Value Initialize-AllConfigs

# Example usage:
# Initialize-AllConfigs -Type 'node'
# Initialize-AllConfigs -Type 'python'
# Initialize-AllConfigs -Type 'go'
# Initialize-AllConfigs -Type 'rust'
# Initialize-AllConfigs -Type 'full'