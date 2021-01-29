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


    $FunctionModule  = [Management.Automation.FunctionInfo].GetProperty("Module")
    $AliasModule     = [Management.Automation.AliasInfo].GetProperty("Module")
    $AttributesField = if ($PSVersionTable.PSVersion.Major -le 5)
    {
        [psvariable].GetField("attributes", "Nonpublic, Instance")
    }
    else
    {
        [psvariable].GetField("_attributes", "Nonpublic, Instance")
    }


    foreach ($Script in $RunFirst)
    {
        if (-not [System.IO.Path]::IsPathRooted($Script))
        {
            $Script = $PluginPath |
                Join-Path -ChildPath $Script |
                Where-Object {Test-Path $_} |
                Select-Object -First 1

            if (-not $Script) {continue}
        }

        if (Test-Path $Script)
        {
            $ScriptModule = New-Module {. $args} $Script
            & $ScriptModule {Export-ModuleMember -Variable * -Function * -Alias *}

            foreach ($Function in $ScriptModule.ExportedFunctions.Values)
            {
                # Use reflection to remove the DynamicModule as source
                $FunctionModule.SetValue($Function, $null)

                $Name = $Function.Name
                Set-Item function:global:$Name $Function
            }

            foreach ($Variable in $ScriptModule.ExportedVariables.Values)
            {
                $Splat = @{
                    Name        = $Variable.Name
                    Description = $Variable.Description
                    Value       = $Variable.Value
                    Visibility  = $Variable.Visibility
                    Option      = $Variable.Options
                    Scope       = "Global"
                }
                $NewVariable = Set-Variable @Splat -PassThru

                # Use reflection to retroactively apply any type constraints, validation, etc
                $AttributesField.SetValue($NewVariable, $Variable.Attributes)
            }

            foreach ($Alias in $ScriptModule.ExportedAliases.Values)
            {
                $Splat = @{
                    Name        = $Alias.Name
                    Description = $Alias.Description
                    Value       = $Alias.Definition
                    Option      = $Alias.Options
                    Scope       = "Global"
                }
                $NewAlias = Set-Alias @Splat -PassThru

                # Use reflection to remove the DynamicModule as source
                $AliasModule.SetValue($NewAlias, $null)
            }
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