function Import-Plugz
{
    [CmdletBinding()]
    param ()

    $Config = Import-Configuration

    [string[]]$PluginPath = $Config.PluginPath
    [string[]]$RunFirst   = $Config.RunFirst
    [hashtable[]]$RunWhen = if ($Config.RunWhen) {$Config.RunWhen}

    if (-not $PluginPath)
    {
        $PluginPath = $MyInvocation.MyCommand.Module.ModuleBase
    }

    foreach ($Script in $RunFirst)
    {
        if (-not [System.IO.Path]::IsPathRooted($Script))
        {
            $Script = $PluginPath |
                Join-Path -ChildPath $Script |
                Where-Object {Test-Path $_} |
                Select-Object -First 1
        }

        if (Test-Path $Script)
        {
            . $Script
        }
        else
        {
            Write-Verbose "Can't find script '$Script'."
        }
    }


    foreach ($Run in $RunWhen)
    {
        $Script = $Run.Script

        if ($Run.Condition -and -not (& $Run.Condition))
        {
            continue
        }

        if (-not [System.IO.Path]::IsPathRooted($Script))
        {
            $Script = $PluginPath |
                Join-Path -ChildPath $Script |
                Where-Object {Test-Path $_} |
                Select-Object -First 1
        }

        if (Test-Path $Script)
        {
            . $Script
        }
        else
        {
            Write-Verbose "Can't find script '$Script'."
        }
    }
}