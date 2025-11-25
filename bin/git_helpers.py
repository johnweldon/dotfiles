"""Git repository bulk operations helper.

This module provides utilities for running shell commands across multiple
git repositories in a directory tree. It automatically discovers git repos
and executes commands in each one while avoiding commonly ignored directories.

Environment Variables:
    GIT_ALL_IGNORE: Colon-separated list of additional directories to ignore
                    beyond the defaults (node_modules, .terraform, dist, .git, .idea)

Example:
    import git_helpers
    git_helpers.all_git_dirs("git status")
    git_helpers.all_git_dirs("git fetch --all", start_dir="/projects")
"""

import os
import shlex
import subprocess
import sys


ignored_dirs = os.getenv("GIT_ALL_IGNORE", "").split(":")
ignored_dirs = list(
    filter(None, ["node_modules", ".terraform", "dist", ".git", ".idea"] + ignored_dirs)
)


def all_git_dirs(action: str, start_dir: str = ".") -> None:
    """Execute a shell command in all git repositories under start_dir.

    Walks the directory tree starting from start_dir and executes the given
    shell command in any directory containing a .git subdirectory. Automatically
    skips commonly ignored directories to improve performance.

    Args:
        action: Shell command to execute in each git repository.
                The command is executed in a bash login shell.
        start_dir: Root directory to search for git repositories.
                   Defaults to current directory (".").

    Returns:
        None. Prints warnings to stderr if commands fail.

    Example:
        all_git_dirs("git status")
        all_git_dirs("git fetch --all", start_dir="/home/user/projects")

    Note:
        - Commands are executed with bash -lc, so bash login files are sourced
        - Failed commands print warnings but don't stop execution
        - Directories in ignored_dirs list are not traversed for performance
    """
    for root, dirs, files in os.walk(start_dir):
        # Check if this is a git repository before filtering
        if ".git" in dirs:
            cmd = f"bash -lc '( cd {shlex.quote(root)}; {action} )'"
            try:
                result = subprocess.run(cmd, shell=True, check=False)
                if result.returncode != 0:
                    print(
                        f"Warning: Command failed in {root} with exit code {result.returncode}",
                        file=sys.stderr,
                    )
            except Exception as e:
                print(f"Error running command in {root}: {e}", file=sys.stderr)

        # Remove ignored directories from dirs to prevent descending into them
        dirs[:] = [d for d in dirs if d not in ignored_dirs]
