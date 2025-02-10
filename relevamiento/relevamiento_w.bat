set DOWNLOAD_URL=https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.1.0.0/OpenSSH-Win64.zip

powershell -Command "Expand-Archive -Path 'OpenSSH-Win64.zip'"

cd OpenSSH-Win64

powershell -ExecutionPolicy Bypass -File install-sshd.ps1

net start sshd

sc config sshd start= auto
netsh advfirewall firewall add rule name="OpenSSH Server (sshd)" protocol=TCP dir=in localport=22 action=allow

pause
