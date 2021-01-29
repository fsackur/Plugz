
Get-ChildItem $PSScriptRoot/Public  -Filter *.ps1 -ErrorAction SilentlyContinue | ForEach-Object {. $_.FullName}
Get-ChildItem $PSScriptRoot/Private -Filter *.ps1 -ErrorAction SilentlyContinue | ForEach-Object {. $_.FullName}


$Script:PSProfiles = @(
    $profile,
    $profile.CurrentUserCurrentHost,
    $profile.CurrentUserAllHosts,
    $profile.AllUsersCurrentHost,
    $profile.AllUsersAllHosts
)

# Containing folders of PS Profiles are added to plugin path
[Collections.Generic.HashSet[string]]$Deduplicate = @()
$Script:PSProfilePath = $Script:PSProfiles | Split-Path | Where-Object {$Deduplicate.Add($_)}
Remove-Variable Deduplicate


# When module imported from a profile script, auto-import plugins
$Caller = (Get-PSCallStack)[1]
$IsImportedFromUserProfile = $Caller.ScriptName -in $Script:PSProfiles
if ($IsImportedFromUserProfile)
{
    Import-Plugz
}
