#!/usr/bin/env python
"""
Ollama Run - Streaming CLI with Rich Markdown Output

Usage:
    orun "your question here"
    orun "your question" -md=model_name
    orun -m "your question" --model=model_name

Examples:
    orun "how to create new branch"
    orun "give me hello world in cpp" -md=glm-4.6:cloud
    orun -m "explain python decorators" --model=mistral:latest
"""

import sys
import os
import argparse
import requests
import json

# Fix Windows encoding issues
if sys.platform == "win32":
    os.environ["PYTHONIOENCODING"] = "utf-8"
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

# Rich library for beautiful markdown output
try:
    from rich.console import Console
    from rich.markdown import Markdown
    from rich.live import Live

    RICH_AVAILABLE = True
except ImportError:
    RICH_AVAILABLE = False
    print("Note: Install 'rich' for better output: pip install rich")

# Configuration
OLLAMA_URL = "http://localhost:11434/api/chat"
DEFAULT_MODEL = "gpt-oss:120b-cloud"
# DEFAULT_MODEL = "mistral:latest"
# DEFAULT_MODEL = "ministral-3:14b-cloud"


def stream_ollama(prompt: str, model: str) -> None:
    """Stream response from Ollama with markdown formatting."""
    # Add system prompt to make it short and simple
    system_prompt = """
    **You are a AI assistant help full to write code**
    - **Answer only with code, clear examples, or direct fixes.**
    - **Explain minimally, only if necessary.**
    - **Prioritize accuracy, brevity, and practicality.**
    - **Use comments in code for context, not paragraphs.**
    """
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt},
        ],
        "stream": True,
    }

    try:
        response = requests.post(OLLAMA_URL, json=payload, stream=True, timeout=120)  # noqa: E501
        response.raise_for_status()
    except requests.exceptions.ConnectionError:
        print(f"Error: Cannot connect to Ollama at {OLLAMA_URL}")
        print("Make sure Ollama is running: ollama serve")
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
        sys.exit(1)

    full_response = ""

    # Detect if output is being piped/redirected
    is_piped = not sys.stdout.isatty()

    if RICH_AVAILABLE and not is_piped:
        console = Console(force_terminal=True, legacy_windows=False)
        with Live(Markdown(""), console=console, refresh_per_second=8) as live:
            for line in response.iter_lines():
                if line:
                    try:
                        data = json.loads(line.decode("utf-8"))
                        if "message" in data:
                            content = data["message"].get("content", "")
                            full_response += content
                            live.update(Markdown(full_response))
                        if data.get("done", False):
                            break
                    except json.JSONDecodeError:
                        continue

        console.print("\n")
    else:
        # Plain text output (for piping/redirecting to files)
        for line in response.iter_lines():
            if line:
                try:
                    data = json.loads(line.decode("utf-8"))
                    if "message" in data:
                        content = data["message"].get("content", "")
                        print(content, end="", flush=True)
                    if data.get("done", False):
                        break
                except json.JSONDecodeError:
                    continue

        print("\n")


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Ollama Run - Streaming CLI with Markdown Output",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  orun "how to create new branch"
  orun "give me hello world in cpp" -md="glm-4.6:cloud"
  orun -m "explain decorators" --model="mistral"
  # Create a text file with the response
  orun "give me hello world in cpp" > hello.txt
  # Append to existing file
  orun "explain the code" >> hello.txt
        """,
    )

    parser.add_argument(
        "prompt", nargs="?", help="The prompt/question to send to Ollama"
    )

    parser.add_argument(
        "-m",
        "--message",
        type=str,
        help="Alternative way to specify the prompt/message",
    )

    parser.add_argument(
        "-md",
        "--model",
        type=str,
        default=DEFAULT_MODEL,
        help=f"Model to use (default: {DEFAULT_MODEL})",
    )

    return parser.parse_args()


def main():
    args = parse_args()

    # Get prompt from either positional arg or -m flag
    prompt = args.prompt or args.message

    if not prompt:
        print("Error: No prompt provided!")
        print('Usage: orun "your question here"')
        print('       orun -m "your question" --model=model_name')
        print('       orun "your question" -md=model_name')
        sys.exit(1)

    model = args.model
    stream_ollama(prompt, model)


if __name__ == "__main__":
    main()
