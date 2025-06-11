[cmdletbinding()]
param(
    [Parameter(Mandatory = $True)]
    [String]$CosmosAccount,
    [Parameter(Mandatory = $True)]
    [String]$CosmosRG,
    [Parameter(Mandatory = $True)]
    [String]$Principal,
    [Parameter(Mandatory = $True, ValidateSet('Read','Write'))]
    [String]$RoleType
)

if (-not (Get-Module -ListAvailable -Name 'Az.CosmosDB')){
    Write-Warning "Az.CosmosDB module not installed. Installing now..."
    Install-Module -Name "Az.CosmosDB" -Scope CurrentUser -Force
}
if (-not (Get-Module -ListAvailable -Name 'Az.Resources')){
    Write-Warning "Az.Resources module not installed. Installing now..."
    Install-Module -Name "Az.Resources" -Scope CurrentUser -Force
}

$DefinitionIds = (Get-AzCosmosDBSqlRoleDefinition -ResourceGroupNAme $CosmosRG -AccountName $CosmosAccount) | Select -expand Id
If ($RoleType -eq 'Read'){
    $RoleId = $DefinitionIds[0]
}
elseif ($RoleType -eq 'Writer'){
    $RoleId = $DefinitionIds[1]
}
$PrincipalId = Get-AzAdServicePrincipal -DisplayName $Principal | select -expand Id
$Scope = (Get-AzCosmosDBAccount -ResourceGroupName $CosmosRG -Name $CosmosAccount) | select -expand Id

$Params = @{
RoleDefinitionId = $RoleId
ResourceGroupName = $CosmosRg
AccountName = $CosmosAccount
PrincipalId = $PrincipalId
Scope = $Scope
}
New-AzCosmosDBSqlRoleAssignment @params