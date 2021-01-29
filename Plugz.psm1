
Get-ChildItem $PSScriptRoot/Public  -Filter *.ps1 -ErrorAction SilentlyContinue | ForEach-Object {. $_.FullName}
Get-ChildItem $PSScriptRoot/Private -Filter *.ps1 -ErrorAction SilentlyContinue | ForEach-Object {. $_.FullName}
