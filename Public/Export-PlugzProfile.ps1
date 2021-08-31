function Export-PlugzProfile
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string[]]$Plugin
    )

    $Config = Get-PlugzConfig

    $Config.PluginPath += $Script:PSProfilePath


    $Scripts = [System.Collections.Generic.List[string]]::new()

    if ($Plugin)
    {
        $Scripts.AddRange($Plugin)
    }
    else
    {
        foreach ($Script in $Config.RunFirst)
        {
            $Scripts.Add($Script)
        }

        foreach ($Plug in $Config.RunWhen)
        {
            $Scripts.Add($Plug.Script)
        }
    }


    $Scripts = foreach ($Script in $Scripts)
    {
        if (-not [System.IO.Path]::IsPathRooted($Script))
        {
            $Script = $Config.PluginPath |
                Join-Path -ChildPath $Script |
                Where-Object {Test-Path $_} |
                Select-Object -First 1
        }
        $Script
    }

    $Scripts | ForEach-Object {
        "#region $_"
        Get-Content $_
        "#endregion $_"
        ""
    }
}
