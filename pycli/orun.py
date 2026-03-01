#!/usr/bin/env python
"""
Ollama Run - CLI with Tools, Markdown Output, and Thinking Model Support

Commands:
    ask "your question"     Ask the AI a question (default)
    shell "command"         Execute a shell command via AI
    time                    Get current date/time
    models                  List available Ollama models
    chat                    Start interactive chat session

Usage:
    orun ask "what time is it?"
    orun ask "calculate 123 * 456" --model=llama3
    orun ask "solve this step by step" --think          # Enable thinking display
    orun ask "quick answer" --nothink                   # Disable thinking
    orun shell "find . -name '*.py'"
    orun time
    orun models
    orun chat
    orun "what is 2+2?"     # Bare prompt (backward compatible)
"""

import sys
import os
import argparse
import requests
import json
import subprocess
import shutil
import re
from datetime import datetime
from typing import List, Dict, Any, Optional, Tuple

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
    from rich.table import Table
    from rich.panel import Panel

    RICH_AVAILABLE = True
except ImportError:
    RICH_AVAILABLE = False
    print("Note: Install 'rich' for better output: pip install rich")

if RICH_AVAILABLE:
    console = Console(force_terminal=True, legacy_windows=False)

# Configuration
OLLAMA_URL = "http://localhost:11434/api/chat"
OLLAMA_LIST_URL = "http://localhost:11434/api/tags"
DEFAULT_MODEL = "gpt-oss:120b-cloud"
MAX_TURNS = 10

# Thinking model configuration
THINKING_MODELS = {
    "deepseek-r1",
    "qwen3:latest",
}

THINK_START_TOKENS = ["<thinking>", "<reasoning>", "<thought>"]
THINK_END_TOKENS = ["</thinking>", "</reasoning>", "</thought>"]


# ============================================
# Tool Definitions
# ============================================


def get_current_date() -> str:
    """Get the current date and time."""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def run_command(command: str) -> str:
    """Run a shell command."""
    cmd = []
    if sys.platform == "win32":
        shell = "pwsh" if shutil.which("pwsh") else "powershell"
        cmd = [shell, "-Command", command]
    else:
        cmd = ["bash", "-c", command]

    try:
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


# ============================================
# Thinking Content Parser
# ============================================


class ThinkingParser:
    """Parse and separate thinking content from regular response content."""

    def __init__(self):
        self.thinking_content = []
        self.regular_content = []
        self.in_thinking_block = False
        self.current_thinking_buffer = ""
        self.current_regular_buffer = ""

    def parse_stream_chunk(self, chunk: str) -> Tuple[Optional[str], Optional[str]]:
        """
        Parse a streaming chunk and return (thinking_chunk, regular_chunk).
        Either can be None if no content of that type in this chunk.
        """
        thinking_output = None
        regular_output = None

        # Check for thinking start tokens
        if not self.in_thinking_block:
            for start_token in THINK_START_TOKENS:
                if start_token in chunk:
                    self.in_thinking_block = True
                    parts = chunk.split(start_token, 1)
                    if parts[0]:  # Content before thinking tag
                        self.current_regular_buffer += parts[0]
                        regular_output = parts[0]
                    self.current_thinking_buffer = parts[1] if len(parts) > 1 else ""
                    thinking_output = (
                        self.current_thinking_buffer
                        if self.current_thinking_buffer
                        else None
                    )
                    return (thinking_output, regular_output)

            # No thinking tag found, it's regular content
            self.current_regular_buffer += chunk
            return (None, chunk)

        # We're inside a thinking block, look for end token
        for end_token in THINK_END_TOKENS:
            if end_token in chunk:
                self.in_thinking_block = False
                parts = chunk.split(end_token, 1)
                self.current_thinking_buffer += parts[0]
                thinking_output = parts[0] if parts[0] else None

                if len(parts) > 1 and parts[1]:  # Content after thinking tag
                    self.current_regular_buffer += parts[1]
                    regular_output = parts[1]
                return (thinking_output, regular_output)

        # Still in thinking block
        self.current_thinking_buffer += chunk
        return (chunk, None)

    def get_full_thinking(self) -> str:
        """Get the complete thinking content accumulated so far."""
        return self.current_thinking_buffer

    def get_full_response(self) -> str:
        """Get the complete regular response content accumulated so far."""
        return self.current_regular_buffer


# ============================================
# Core Chat Engine
# ============================================


class OllamaClient:
    """Handles all Ollama API communication with thinking support."""

    def __init__(self, model: str = DEFAULT_MODEL, show_thinking: bool = True):
        self.model = model
        self.messages: List[Dict[str, Any]] = []
        self.show_thinking = show_thinking
        self.is_thinking_model = any(
            t_model in model.lower() for t_model in THINKING_MODELS
        )

    def add_system_message(self, content: str):
        """Add a system message to the conversation."""
        self.messages.append({"role": "system", "content": content})

    def add_user_message(self, content: str):
        """Add a user message to the conversation."""
        self.messages.append({"role": "user", "content": content})

    def add_tool_result(self, content: str):
        """Add a tool result to the conversation."""
        self.messages.append({"role": "tool", "content": content})

    def execute_tool_call(self, tool_name: str, args) -> str:
        """Execute a tool call and return the result."""
        if RICH_AVAILABLE:
            console.print(f"[yellow]🔧 Running tool:[/yellow] {tool_name} args={args}")
        else:
            print(f"🔧 Running tool: {tool_name} args={args}")

        func = AVAILABLE_FUNCTIONS.get(tool_name)
        if not func:
            return f"Error: Tool {tool_name} not found"

        try:
            if isinstance(args, str):
                try:
                    args = json.loads(args)
                except ValueError:
                    pass

            if isinstance(args, dict):
                return str(func(**args))
            else:
                return str(func())
        except Exception as e:
            return f"Error: {str(e)}"

    def _display_thinking(self, thinking_content: str, is_streaming: bool = False):
        """Display thinking content with proper formatting."""
        if not thinking_content or not self.show_thinking:
            return

        if RICH_AVAILABLE:
            if is_streaming:
                # For streaming, update live display
                thinking_panel = Panel(
                    Markdown(thinking_content),
                    title="[italic yellow]🧠 Thinking...[/italic yellow]",
                    border_style="yellow",
                    padding=(1, 2),
                )
                return thinking_panel
            else:
                # Final thinking display
                console.print(
                    Panel(
                        Markdown(thinking_content),
                        title="[bold yellow]🧠 Reasoning Process[/bold yellow]",
                        border_style="yellow",
                        padding=(1, 2),
                    )
                )
        else:
            if not is_streaming:
                print(f"\n{'=' * 50}")
                print("🧠 THINKING PROCESS:")
                print(f"{'=' * 50}")
                print(thinking_content)
                print(f"{'=' * 50}\n")

    def _clean_thinking_tags(self, content: str) -> str:
        """Remove thinking tags from content for message history."""
        cleaned = content
        for start, end in zip(THINK_START_TOKENS, THINK_END_TOKENS):
            pattern = f"{start}.*?{end}"
            cleaned = re.sub(pattern, "", cleaned, flags=re.DOTALL)
            # Also remove standalone tags if any remain
            cleaned = cleaned.replace(start, "").replace(end, "")
        return cleaned.strip()

    def stream_chat(self) -> tuple[str, str, List[Dict]]:
        """
        Stream a chat response from Ollama with thinking support.
        Returns: (full_content, thinking_content, tool_calls)
        """
        payload = {
            "model": self.model,
            "messages": self.messages,
            "stream": True,
            "tools": TOOL_DEFINITIONS,
        }

        try:
            response = requests.post(OLLAMA_URL, json=payload, stream=True, timeout=120)
            response.raise_for_status()

            full_content = ""
            thinking_content = ""
            tool_calls = []
            parser = ThinkingParser()

            if RICH_AVAILABLE:
                # Setup live display areas for thinking and response
                thinking_display = ""
                response_display = ""

                with Live(console=console, refresh_per_second=10) as live:
                    for line in response.iter_lines():
                        if not line:
                            continue
                        try:
                            data = json.loads(line.decode("utf-8"))
                            if data.get("done", False):
                                break

                            msg = data.get("message", {})
                            chunk = msg.get("content", "")

                            if chunk:
                                full_content += chunk

                                # Parse thinking vs regular content
                                think_chunk, regular_chunk = parser.parse_stream_chunk(
                                    chunk
                                )

                                if think_chunk:
                                    thinking_content = parser.get_full_thinking()
                                    if self.show_thinking:
                                        thinking_display = thinking_content

                                if regular_chunk:
                                    response_display = parser.get_full_response()

                                # Build display
                                display_elements = []

                                # Show thinking if enabled and available
                                if self.show_thinking and thinking_display:
                                    think_panel = Panel(
                                        Markdown(thinking_display),
                                        title="[italic yellow]🧠 Thinking...[/italic yellow]"
                                        if parser.in_thinking_block
                                        else "[bold yellow]🧠 Reasoning Process[/bold yellow]",
                                        border_style="yellow",
                                        padding=(1, 2),
                                    )
                                    display_elements.append(think_panel)

                                # Show regular response
                                if response_display:
                                    display_elements.append(Markdown(response_display))

                                if display_elements:
                                    from rich.layout import Layout

                                    layout = Layout()
                                    if len(display_elements) == 2:
                                        layout.split_column(
                                            Layout(display_elements[0], size=None),
                                            Layout(display_elements[1]),
                                        )
                                        live.update(layout)
                                    else:
                                        live.update(display_elements[0])

                            if "tool_calls" in msg and msg["tool_calls"]:
                                tool_calls.extend(msg["tool_calls"])

                        except json.JSONDecodeError:
                            continue

                # Final newline after streaming
                console.print()

            else:
                # Non-rich fallback
                in_thinking = False
                current_thinking = ""

                for line in response.iter_lines():
                    if not line:
                        continue
                    try:
                        data = json.loads(line.decode("utf-8"))
                        if data.get("done", False):
                            break

                        msg = data.get("message", {})
                        chunk = msg.get("content", "")

                        if chunk:
                            full_content += chunk

                            # Simple tag-based detection for non-rich mode
                            if any(tag in chunk for tag in THINK_START_TOKENS):
                                in_thinking = True
                                if self.show_thinking:
                                    print(f"\n{'=' * 50}")
                                    print("🧠 THINKING PROCESS:")
                                    print(f"{'=' * 50}")

                            if in_thinking:
                                if any(tag in chunk for tag in THINK_END_TOKENS):
                                    in_thinking = False
                                    if self.show_thinking:
                                        print(f"\n{'=' * 50}")
                                else:
                                    # Extract content between tags (simplified)
                                    clean_chunk = chunk
                                    for tag in THINK_START_TOKENS + THINK_END_TOKENS:
                                        clean_chunk = clean_chunk.replace(tag, "")
                                    if clean_chunk and self.show_thinking:
                                        print(clean_chunk, end="", flush=True)
                                        current_thinking += clean_chunk
                            else:
                                print(chunk, end="", flush=True)

                            thinking_content = current_thinking

                        if "tool_calls" in msg and msg["tool_calls"]:
                            tool_calls.extend(msg["tool_calls"])

                    except json.JSONDecodeError:
                        continue
                print()

            return full_content, thinking_content, tool_calls

        except requests.exceptions.ConnectionError:
            print(f"❌ Error: Cannot connect to Ollama at {OLLAMA_URL}")
            print("Make sure Ollama is running: ollama serve")
            sys.exit(1)
        except Exception as e:
            print(f"❌ Error: {e}")
            sys.exit(1)

    def chat_with_tools(
        self, user_prompt: str, system_prompt: Optional[str] = None
    ) -> Tuple[str, str]:
        """
        Run a complete chat session with tool support and thinking display.
        Returns: (final_response, thinking_content)
        """
        if system_prompt:
            self.add_system_message(system_prompt)

        self.add_user_message(user_prompt)

        final_thinking = ""

        for turn in range(MAX_TURNS):
            content, thinking, tool_calls = self.stream_chat()
            final_thinking = thinking if thinking else final_thinking

            # Build assistant message (clean of thinking tags for history)
            clean_content = self._clean_thinking_tags(content)
            assistant_msg = {"role": "assistant", "content": clean_content}
            if tool_calls:
                assistant_msg["tool_calls"] = tool_calls
            self.messages.append(assistant_msg)

            if not tool_calls:
                return clean_content, final_thinking

            # Execute tools and continue
            for tc in tool_calls:
                fn = tc["function"]
                result = self.execute_tool_call(fn["name"], fn["arguments"])
                self.add_tool_result(result)

        return clean_content, final_thinking


# ============================================
# Command Handlers
# ============================================


class Commands:
    """All CLI commands organized as static methods."""

    @staticmethod
    def ask(args):
        """Ask the AI a question."""
        system_prompt = """
        You are a helpful AI assistant.
        - Be concise, accurate, and practical.
        - You have access to tools (run_command, get_current_date).
        - Use 'run_command' to solve math problems, check files, or get system info.
        - Answer in plain language unless the user explicitly asks for code.
        """

        # Add thinking encouragement for thinking models
        if args.think:
            system_prompt += "\n- Show your reasoning process step by step before giving the final answer."

        client = OllamaClient(model=args.model, show_thinking=args.think)
        response, thinking = client.chat_with_tools(args.prompt, system_prompt)

        # If thinking was disabled but we got thinking content, show summary
        if not args.think and thinking and RICH_AVAILABLE:
            console.print(
                f"[dim]💡 Tip: Use --think to see the model's reasoning process ({len(thinking)} chars)[/dim]"
            )

    @staticmethod
    def shell(args):
        """Execute a shell command with AI assistance."""
        system_prompt = """
        You are a shell command expert.
        - The user wants to run a shell command.
        - Execute it using the run_command tool.
        - Explain what the command does and what the output means.
        - If there are errors, explain what went wrong.
        """

        client = OllamaClient(model=args.model, show_thinking=args.think)
        client.chat_with_tools(
            f"Execute this command and explain the results: {args.command}",
            system_prompt,
        )

    @staticmethod
    def time(args):
        """Get current date and time."""
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        if RICH_AVAILABLE:
            console.print(f"[green]🕐 Current time:[/green] {now}")
        else:
            print(f"🕐 Current time: {now}")

    @staticmethod
    def models(args):
        """List available Ollama models with thinking indicator."""
        try:
            response = requests.get(OLLAMA_LIST_URL, timeout=10)
            response.raise_for_status()
            data = response.json()

            models = data.get("models", [])

            if RICH_AVAILABLE:
                table = Table(title="Available Ollama Models")
                table.add_column("Name", style="cyan")
                table.add_column("Size", style="green")
                table.add_column("Modified", style="yellow")
                table.add_column("Features", style="magenta")

                for m in models:
                    name = m.get("name", "unknown")
                    size = m.get("size", 0)
                    # Convert bytes to human readable
                    size_str = (
                        f"{size / 1e9:.2f} GB" if size > 1e9 else f"{size / 1e6:.2f} MB"
                    )
                    modified = m.get("modified_at", "unknown")[:10]  # Just date

                    # Check if thinking model
                    features = ""
                    if any(t in name.lower() for t in THINKING_MODELS):
                        features += "🧠 thinking"

                    table.add_row(name, size_str, modified, features)

                console.print(table)
                console.print(
                    "\n[dim]Models with 🧠 support reasoning/thinking output. Use --think flag to display it.[/dim]"
                )
            else:
                print("Available Models:")
                for m in models:
                    name = m.get("name", "unknown")
                    size = m.get("size", 0)
                    size_str = (
                        f"{size / 1e9:.2f} GB" if size > 1e9 else f"{size / 1e6:.2f} MB"
                    )
                    thinking_indicator = (
                        " [thinking]"
                        if any(t in name.lower() for t in THINKING_MODELS)
                        else ""
                    )
                    print(f"  • {name} ({size_str}){thinking_indicator}")

        except requests.exceptions.ConnectionError:
            print(f"❌ Error: Cannot connect to Ollama at {OLLAMA_URL}")
            sys.exit(1)
        except Exception as e:
            print(f"❌ Error: {e}")
            sys.exit(1)

    @staticmethod
    def chat(args):
        """Start an interactive chat session."""
        system_prompt = """
        You are a helpful AI assistant.
        - Be concise, accurate, and practical.
        - You have access to tools (run_command, get_current_date).
        - Use tools when needed to answer questions accurately.
        """

        if args.think:
            system_prompt += "\n- Show your reasoning process step by step before giving the final answer."

        client = OllamaClient(model=args.model, show_thinking=args.think)
        client.add_system_message(system_prompt)

        if RICH_AVAILABLE:
            console.print("[bold blue]💬 Interactive Chat Mode[/bold blue]")
            if args.think:
                console.print("[yellow]🧠 Thinking display enabled[/yellow]")
            console.print("[dim]Type 'exit', 'quit', or press Ctrl+C to exit[/dim]\n")
        else:
            print("💬 Interactive Chat Mode")
            if args.think:
                print("🧠 Thinking display enabled")
            print("Type 'exit', 'quit', or press Ctrl+C to exit\n")

        while True:
            try:
                if RICH_AVAILABLE:
                    user_input = console.input("[bold green]You:[/bold green] ")
                else:
                    user_input = input("You: ")

                if user_input.lower() in ("exit", "quit", "q"):
                    break

                if not user_input.strip():
                    continue

                print()
                if RICH_AVAILABLE:
                    console.print("[bold blue]Assistant:[/bold blue]")
                else:
                    print("Assistant:")

                client.add_user_message(user_input)
                content, thinking, tool_calls = client.stream_chat()

                # Handle tool calls in interactive mode
                clean_content = client._clean_thinking_tags(content)
                assistant_msg = {"role": "assistant", "content": clean_content}
                if tool_calls:
                    assistant_msg["tool_calls"] = tool_calls
                    client.messages.append(assistant_msg)

                    for tc in tool_calls:
                        fn = tc["function"]
                        result = client.execute_tool_call(fn["name"], fn["arguments"])
                        client.add_tool_result(result)

                    # Get final response after tool execution
                    content, thinking, _ = client.stream_chat()
                    clean_content = client._clean_thinking_tags(content)
                    client.messages.append(
                        {"role": "assistant", "content": clean_content}
                    )
                else:
                    client.messages.append(assistant_msg)

                print()

            except KeyboardInterrupt:
                print("\n👋 Goodbye!")
                break
            except EOFError:
                break


# ============================================
# CLI Setup with Bare Prompt Support
# ============================================


def preprocess_argv():
    """
    Preprocess sys.argv to handle bare prompts (backward compatibility).
    If the first argument after script name is not a command or flag,
    inject 'ask' command before it.
    """
    if len(sys.argv) > 1:
        first_arg = sys.argv[1]
        known_commands = {
            "ask",
            "shell",
            "time",
            "models",
            "chat",
            "-h",
            "--help",
            "-m",
            "--model",
            "--think",
            "--nothink",
        }

        # If it doesn't start with - and isn't a known command, treat as bare prompt
        if not first_arg.startswith("-") and first_arg not in known_commands:
            sys.argv.insert(1, "ask")


def create_parser():
    """Create the argument parser with subcommands."""
    parser = argparse.ArgumentParser(
        prog="orun",
        description="Ollama Run - CLI with Tools, Markdown Output, and Thinking Support",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  orun "what is 2+2?"                      # Bare prompt (backward compatible)
  orun ask "what is 2+2?"                  # Explicit ask command
  orun ask "solve step by step" --think    # Enable thinking display
  orun ask "quick answer" --nothink        # Disable thinking (default for non-thinking models)
  orun ask "calculate 1245*1457" --model=deepseek-r1:14b --think
  orun shell "ls -la" --think
  orun time
  orun models                              # Shows 🧠 indicator for thinking models
  orun chat --think                        # Interactive mode with thinking
        """,
    )

    # Global options
    parser.add_argument(
        "--model",
        "-m",
        type=str,
        default=DEFAULT_MODEL,
        help=f"Model to use (default: {DEFAULT_MODEL})",
    )

    # Thinking control - default is True for thinking models, but can be disabled
    thinking_group = parser.add_mutually_exclusive_group()
    thinking_group.add_argument(
        "--think",
        action="store_true",
        default=True,
        help="Enable thinking/reasoning display (default: enabled for thinking models)",
    )
    thinking_group.add_argument(
        "--nothink", action="store_true", help="Disable thinking/reasoning display"
    )

    # Subcommands
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # ask command
    ask_parser = subparsers.add_parser(
        "ask",
        help="Ask the AI a question",
        description="Send a prompt to the AI and get a response with tool support.",
    )
    ask_parser.add_argument("prompt", help="The question or prompt to ask")
    ask_parser.set_defaults(func=Commands.ask)

    # shell command
    shell_parser = subparsers.add_parser(
        "shell",
        help="Execute a shell command with AI assistance",
        description="Run a shell command and get AI explanation of the results.",
    )
    shell_parser.add_argument("command", help="The shell command to execute")
    shell_parser.set_defaults(func=Commands.shell)

    # time command
    time_parser = subparsers.add_parser(
        "time",
        help="Get current date and time",
        description="Display the current system date and time.",
    )
    time_parser.set_defaults(func=Commands.time)

    # models command
    models_parser = subparsers.add_parser(
        "models",
        help="List available Ollama models",
        description="Show all downloaded Ollama models.",
    )
    models_parser.set_defaults(func=Commands.models)

    # chat command
    chat_parser = subparsers.add_parser(
        "chat",
        help="Start interactive chat session",
        description="Start an interactive chat session with the AI.",
    )
    chat_parser.set_defaults(func=Commands.chat)

    return parser


def main():
    # Preprocess to handle bare prompts
    preprocess_argv()

    parser = create_parser()
    args = parser.parse_args()

    # Handle --nothink flag
    if args.nothink:
        args.think = False

    if args.command is None:
        parser.print_help()
        sys.exit(1)

    # Run the command
    args.func(args)


if __name__ == "__main__":
    main()
