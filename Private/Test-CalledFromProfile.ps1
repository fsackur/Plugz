function Test-CalledFromProfile
{
    $Origin = (Get-PSCallStack).ScriptName | where {$_} | select -Last 1
    return $Origin -in $Script:PSProfiles
}