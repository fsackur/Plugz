function Import-Plugz
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]$Plugin
    )

    $Config = Get-PlugzConfig

    $Config.PluginPath += $Script:PSProfilePath


    $Scripts = [System.Collections.Generic.List[string]]::new()

    if ($Plugin)
    {
        $Scripts.Add($Plugin)
    }
    else
    {
        foreach ($Script in $Config.RunFirst)
        {
            $Scripts.Add($Script)
        }

        foreach ($Plug in $Config.RunWhen)
        {
            if ($Plug.Condition -and -not (& $Plug.Condition))
            {
                continue
            }

            $Scripts.Add($Plug.Script)
        }
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


    foreach ($Script in $Scripts)
    {
        if (-not [System.IO.Path]::IsPathRooted($Script))
        {
            $Script = $Config.PluginPath |
                Join-Path -ChildPath $Script |
                Where-Object {Test-Path $_} |
                Select-Object -First 1
        }

        if (-not ($Script -and (Test-Path $Script)))
        {
            $Message = "Can't find script '$foreach'."
            if (Test-CalledFromProfile)
            {
                # No-one wants red text in their profile
                Write-Verbose $Message
            }
            else
            {
                Write-Error $Message
            }
            continue
        }


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
}
