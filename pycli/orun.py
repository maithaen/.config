#!/usr/bin/env python
"""
Ollama Run - CLI with Tools and Markdown Output

Usage:
    orun "your question here"
    orun "your question" -md=model_name
    orun -m "your question" --model=model_name

Examples:
    orun "what time is it?"
    orun "calculate 123 * 456"
    orun "list files in current directory"
"""

import sys
import os
import argparse
import requests
import json
import subprocess
import shutil
from datetime import datetime

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

if RICH_AVAILABLE:
    console = Console(force_terminal=True, legacy_windows=False)

# Configuration
OLLAMA_URL = "http://localhost:11434/api/chat"
DEFAULT_MODEL = "mistral-large-3:675b-cloud"


# ============================================
# Tool Definitions
# ============================================


def get_current_date() -> str:
    """Get the current date and time."""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def run_command(command: str) -> str:
    """Run a shell command."""
    # Determine shell
    cmd = []
    if sys.platform == "win32":
        shell = "pwsh"
        if shutil.which("pwsh") is None:
            shell = "powershell"
        cmd = [shell, "-Command", command]
    else:
        cmd = ["bash", "-c", command]

    try:
        # Run command
        result = subprocess.run(cmd, capture_output=True, text=True, check=False)

        output_parts = []
        if result.stdout:
            output_parts.append(result.stdout.strip())
        if result.stderr:
            output_parts.append(f"stderr: {result.stderr.strip()}")

        return (
            "\n".join(output_parts) if output_parts else "Command executed (no output)"
        )
    except Exception as e:
        return f"Error executing command: {str(e)}"


TOOL_DEFINITIONS = [
    {
        "type": "function",
        "function": {
            "name": "get_current_date",
            "description": "Get the current date and time",
            "parameters": {"type": "object", "properties": {}, "required": []},
        },
    },
    {
        "type": "function",
        "function": {
            "name": "run_command",
            "description": "Run a shell command (pwsh on Windows, bash on Linux). Use this for calculations, checking files, or system tasks.",
            "parameters": {
                "type": "object",
                "required": ["command"],
                "properties": {
                    "command": {
                        "type": "string",
                        "description": "The command line to execute",
                    }
                },
            },
        },
    },
]

AVAILABLE_FUNCTIONS = {
    "get_current_date": get_current_date,
    "run_command": run_command,
}


def execute_tool_call(tool_name: str, args) -> str:
    """Execute a single tool call and return result string."""
    if RICH_AVAILABLE:
        console.print(f"[yellow]Running tool: {tool_name}[/yellow] args={args}")
    else:
        print(f"Running tool: {tool_name} args={args}")

    func = AVAILABLE_FUNCTIONS.get(tool_name)
    if not func:
        return f"Error: Tool {tool_name} not found"

    try:
        # Handle argument variations (some models might send strings)
        if isinstance(args, str):
            try:
                args = json.loads(args)
            except ValueError:
                pass  # Try passing as is if not json

        if isinstance(args, dict):
            return str(func(**args))
        else:
            return str(func())  # No args fallback
    except Exception as e:
        return f"Error: {str(e)}"


# ============================================
# Chat Logic
# ============================================


def run_chat(prompt: str, model: str) -> None:  # noqa: C901
    """Run chat loop with tool support and streaming."""

    system_prompt = """
    **You are a helpful AI assistant.**
    - **Be concise, accurate, and practical.**
    - **You have access to tools (run_command, get_current_date).**
    - **Use 'run_command' to solve math problems (e.g. using echo or python), check files, or get system info.**
    - **Answer in plain language unless the user explicitly asks for code.**
    """

    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": prompt},
    ]

    # Max turns to prevent infinite loops
    MAX_TURNS = 10
    # uncomment this if you want to see the model name
    # if RICH_AVAILABLE:
    #     console.print(f"[dim]Using model: {model}[/dim]")

    for _ in range(MAX_TURNS):
        payload = {
            "model": model,
            "messages": messages,
            "stream": True,  # Process with streaming
            "tools": TOOL_DEFINITIONS,
        }

        try:
            response = requests.post(OLLAMA_URL, json=payload, stream=True, timeout=120)
            response.raise_for_status()

            full_content = ""
            tool_calls = []

            # Streaming loop
            if RICH_AVAILABLE:
                with Live(Markdown(""), console=console, refresh_per_second=10) as live:
                    for line in response.iter_lines():
                        if not line:
                            continue
                        try:
                            data = json.loads(line.decode("utf-8"))
                            if data.get("done", False):
                                break

                            msg = data.get("message", {})

                            # Accumulate content for display
                            chunk_content = msg.get("content", "")
                            if chunk_content:
                                full_content += chunk_content
                                live.update(Markdown(full_content))

                            # Setup for tool calls
                            # Note: Ollama might stream tool calls. We collect them.
                            if "tool_calls" in msg and msg["tool_calls"]:
                                for tc in msg["tool_calls"]:
                                    tool_calls.append(tc)

                        except json.JSONDecodeError:
                            continue
                console.print()  # Newline after live
            else:
                # Plain text fallback
                for line in response.iter_lines():
                    if not line:
                        continue
                    try:
                        data = json.loads(line.decode("utf-8"))
                        if data.get("done", False):
                            break

                        msg = data.get("message", {})

                        chunk_content = msg.get("content", "")
                        if chunk_content:
                            print(chunk_content, end="", flush=True)
                            full_content += chunk_content

                        if "tool_calls" in msg and msg["tool_calls"]:
                            for tc in msg["tool_calls"]:
                                tool_calls.append(tc)

                    except json.JSONDecodeError:
                        continue
                print()

            # Construct the assistant message for history
            assistant_msg = {"role": "assistant", "content": full_content}
            if tool_calls:
                assistant_msg["tool_calls"] = tool_calls
                messages.append(assistant_msg)

                # Execute tools
                for tool_call in tool_calls:
                    fn = tool_call["function"]
                    result_content = execute_tool_call(fn["name"], fn["arguments"])

                    messages.append(
                        {
                            "role": "tool",
                            "content": result_content,
                        }
                    )

                # Continue loop to process tool results
                continue

            else:
                # No tools used, session done
                return

        except requests.exceptions.ConnectionError:
            print(f"Error: Cannot connect to Ollama at {OLLAMA_URL}")
            print("Make sure Ollama is running: ollama serve")
            sys.exit(1)
        except Exception as e:
            print(f"Error: {e}")
            sys.exit(1)


def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Ollama Run - CLI with Markdown Output",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  orun "how to create new branch"
  orun "calculate 1245*1457"  # Uses run_command tool
  orun "what time is it"      # Uses get_current_date tool
  orun -md="llama3" "hello"
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
        sys.exit(1)

    model = args.model
    # Switch main logic to chat loop
    run_chat(prompt, model)


if __name__ == "__main__":
    main()
