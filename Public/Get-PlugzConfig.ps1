function Get-PlugzConfig
{
    [CmdletBinding()]
    param ()

    $Config = Import-Configuration

    [ordered]@{
        PluginPath = [string[]]$Config.PluginPath
        RunFirst   = [string[]]$Config.RunFirst
        RunWhen    = [Collections.IDictionary[]]$Config.RunWhen
    }
}
