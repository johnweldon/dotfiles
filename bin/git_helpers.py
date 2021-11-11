import os
import subprocess


def all_git_dirs(action: str, start_dir="."):
    for root, dirs, files in os.walk(start_dir):
        if "node_modules" in root:
            continue
        if ".git" in dirs:
            cmd = f"bash -lc '( cd {root}; {action} )'"
            subprocess.run(cmd, shell=True)
