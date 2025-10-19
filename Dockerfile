# escape=`
# Windows Container for Backup API
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Instala PowerShell 5.1 (já incluso no Server Core)
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Cria diretórios
RUN New-Item -ItemType Directory -Path C:\backup\scripts, C:\backup\logs, C:\backup\repos, C:\backup\status

# Copia scripts e configs
COPY scripts\* C:\backup\scripts\
COPY logs\.gitkeep C:\backup\logs\
COPY repos\.gitkeep C:\backup\repos\
COPY status\.gitkeep C:\backup\status\

# Define diretório de trabalho
WORKDIR C:\backup\scripts

# Porta da API
EXPOSE 8080

# Comando padrão: inicia o servidor API
ENTRYPOINT ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "C:\\backup\\scripts\\api-server.ps1"]
