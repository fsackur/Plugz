param ($ec)

Get-ChildItem $PSScriptRoot/Public  -Filter *.ps1 -ErrorAction SilentlyContinue | ForEach-Object {. $_.FullName}
Get-ChildItem $PSScriptRoot/Private -Filter *.ps1 -ErrorAction SilentlyContinue | ForEach-Object {. $_.FullName}

$Caller = (Get-PSCallStack)[1]
$Script:IsImportedFromUserProfile = $Caller.ScriptName -in ($profile.CurrentUserAllHosts, $profile.CurrentUserCurrentHost)

# $Script:SS = $ExecutionContext.SessionState
# $Script:M = [PSModuleInfo]::new($true)

$Flags = [System.Reflection.BindingFlags]"Nonpublic, Instance"
$Runspace = [runspace]::DefaultRunspace
$RunspaceType = $Runspace.GetType()

$EngineField = $RunspaceType.GetField("_engine", $Flags)
$Engine = $EngineField.GetValue($Runspace)
$EngineType = $Engine.GetType()
$ContextProperty = $EngineType.GetProperty("Context", $Flags)
$Context = $ContextProperty.GetValue($Engine)
$ContextType = $Context.GetType()
$SessionStateProperty = $ContextType.GetProperty("SessionState", $Flags)
$Script:GlobalSS = $SessionStateProperty.GetValue($Context)

$InvokeCommandProperty = $RunspaceType.GetProperty("DoInvokeCommand", $Flags)
$Script:InvokeCommand = $InvokeCommandProperty.GetValue($Runspace)

$Script:ec = $ec