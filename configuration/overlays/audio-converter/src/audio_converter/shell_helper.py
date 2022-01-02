import subprocess


class ShellHelper:
    @staticmethod
    def cmd(cmd) -> str:
        return subprocess.check_output(cmd, shell=True, stderr=subprocess.PIPE).decode('utf-8')
