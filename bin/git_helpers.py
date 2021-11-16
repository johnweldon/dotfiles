import os
import subprocess


ignored_dirs = list(filter(None, ["node_modules", ".terraform", "dist"] + os.getenv("GIT_ALL_IGNORE").split(":")))


def all_git_dirs(action: str, start_dir="."):
    for root, dirs, files in os.walk(start_dir):
        for ig in ignored_dirs:
            if f"/{ig}/" in root:
                break
        else:
            if ".git" in dirs:
                cmd = f"bash -lc '( cd {root}; {action} )'"
                subprocess.run(cmd, shell=True)
