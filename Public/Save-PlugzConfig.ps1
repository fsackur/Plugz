function Save-PlugzConfig
{
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'Pipeline')]
    param
    (
        [Parameter(ParameterSetName = 'Pipeline', ValueFromPipeline, Position = 0)]
        [Collections.IDictionary]$Config,

        [Parameter(ParameterSetName = 'Named')]
        [string[]]$PluginPath,

        [Parameter(ParameterSetName = 'Named')]
        [string[]]$RunFirst,

        [Parameter(ParameterSetName = 'Named')]
        [Collections.IDictionary[]]$RunWhen
    )

    if ($PSCmdlet.ParameterSetName -eq 'Pipeline')
    {
        $PluginPath = $Config.PluginPath
        $RunFirst   = $Config.RunFirst
        $RunWhen    = $Config.RunWhen
    }


    $RunWhen = $RunWhen | ForEach-Object {

        $Run = [ordered]@{}

        $Condition = $_.Condition -as [scriptblock]
        if ($Condition)
        {
            $Run.Condition = $Condition
        }

        $Run.Script = [string]$_.Script

        $Run
    }


    $Config = [Collections.Specialized.OrderedDictionary]::new()

    $Config.PluginPath = $PluginPath
    $Config.RunFirst   = $RunFirst
    $Config.RunWhen    = $RunWhen


    $Config | Export-Configuration
}
