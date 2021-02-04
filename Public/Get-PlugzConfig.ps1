function Get-PlugzConfig
{
    [CmdletBinding()]
    param ()

    $Config = Import-Configuration

    $Config = [ordered]@{
        PluginPath = [string[]]$Config.PluginPath
        RunFirst   = [string[]]$Config.RunFirst
        RunWhen    = [Collections.IDictionary[]]$Config.RunWhen
    }

    $Config | Add-Member ScriptMethod GetFullPluginPath {$this.PluginPath + $Script:PSProfilePath}

    $Config
}
