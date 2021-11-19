import os
import subprocess


ignored_dirs = os.getenv("GIT_ALL_IGNORE", "").split(":")
ignored_dirs = list(filter(None, ["node_modules", ".terraform", "dist", ".git", ".idea"] + ignored_dirs))


def all_git_dirs(action: str, start_dir="."):
    for root, dirs, files in os.walk(start_dir):
        for ig in ignored_dirs:
            if root.endswith(f"/{ig}"):
                break
            if f"/{ig}/" in root:
                break
        else:
            if ".git" in dirs:
                cmd = f"bash -lc '( cd {root}; {action} )'"
                subprocess.run(cmd, shell=True)
