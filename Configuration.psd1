@{
    PluginPath = @(
        # Paths are searched in order for scripts and modules
        # "~/Documents/Powershell/Modules/Plugz"
    )
    RunFirst = @(
        # You can add code here that influences what's run in RunWhen
        # "SetupVariables.ps1"
    )
    RunWhen  = @(
        # @{
        #     Condition = {$true}
        #     Script    = "Plugin2.ps1"
        # }
    )
}