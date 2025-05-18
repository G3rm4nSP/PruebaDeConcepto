param(
    [string]$NgrokToken
)

# Cambiar al directorio Descargas
Set-Location $env:USERPROFILE\Downloads

# Verificar si OpenSSH Server está instalado
$openssh = Get-WindowsCapability -Online | Where-Object { $_.Name -like "OpenSSH.Server*" }
if ($openssh.State -ne "Installed") {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
}

# Iniciar y configurar el servicio sshd si no está corriendo
if ((Get-Service sshd -ErrorAction SilentlyContinue).Status -ne 'Running') {
    Start-Service sshd
}
Set-Service -Name sshd -StartupType Automatic

# Crear regla de firewall solo si no existe
if (-not (Get-NetFirewallRule -Name "sshd" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH SSH Server' -Enabled True `
        -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

# Descargar ngrok si no existe
if (-not (Test-Path ".\ngrok.exe")) {
    Write-Host "Descargando ngrok..."
    Invoke-WebRequest -Uri "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip" -OutFile "ngrok.zip"
    Expand-Archive ngrok.zip -DestinationPath . -Force
    Remove-Item ngrok.zip
}

# Autenticación de ngrok (solo si no está ya autenticado)
$authFile = "$env:APPDATA\ngrok\ngrok.yml"
if (-not (Test-Path $authFile) -or -not (Select-String -Path $authFile -Pattern $NgrokToken -Quiet)) {
    .\ngrok.exe authtoken $NgrokToken
}

# Ejecutar ngrok
Start-Process -NoNewWindow -FilePath .\ngrok.exe -ArgumentList "tcp 22"
