# Registers the testpoint:// URL scheme for the current user so GitHub sign-in
# can return to the app. Needed once per machine for development builds; an
# installer should write the same keys for release builds.
#
# Usage: powershell -File windows\register_url_scheme.ps1 -Exe <path to test_point.exe>
param(
  [string]$Exe = (Join-Path $PSScriptRoot '..\build\windows\x64\runner\Debug\test_point.exe')
)

$exe = (Resolve-Path $Exe).Path
$root = 'HKCU:\Software\Classes\testpoint'

New-Item -Path $root -Force | Out-Null
Set-ItemProperty -Path $root -Name '(Default)' -Value 'URL:Test Point'
Set-ItemProperty -Path $root -Name 'URL Protocol' -Value ''
New-Item -Path "$root\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "$root\shell\open\command" -Name '(Default)' -Value "`"$exe`" `"%1`""

Write-Host "Registered testpoint:// -> $exe"
