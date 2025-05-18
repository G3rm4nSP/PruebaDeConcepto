param(
    [string]$NgrokToken
)

# Cambiar al directorio Descargas para que los archivos queden ahí
Set-Location $env:USERPROFILE\Downloads

# Instalar OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0;

# Iniciar y configurar el servicio SSH para que arranque siempre
Start-Service sshd;
Set-Service -Name sshd -StartupType 'Automatic';

# Abrir puerto 22 en el firewall para permitir conexiones SSH
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH SSH Server' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22;

# Descargar ngrok
Invoke-WebRequest -Uri https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip -OutFile ngrok.zip;

# Extraer ngrok
Expand-Archive ngrok.zip -DestinationPath . -Force;

# Borrar archivo zip descargado
Remove-Item ngrok.zip;

# ⚠️ Esperar un momento por si la extracción tarda
Start-Sleep -Seconds 2

# Configurar el token de autenticación de ngrok
.\ngrok.exe authtoken $NgrokToken

# Ejecutar ngrok para abrir túnel TCP en el puerto 22
Start-Process -NoNewWindow -FilePath .\ngrok.exe -ArgumentList "tcp 22"
