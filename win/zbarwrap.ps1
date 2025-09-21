param([string]$img)
Set-Clipboard ((&"C:\Program Files (x86)\ZBar\bin\zbarimg.exe" $img) -replace '^QR-Code:', '')
