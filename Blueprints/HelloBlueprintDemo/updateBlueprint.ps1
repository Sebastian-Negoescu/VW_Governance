################ This script is responsible for updating the Azure Blueprint whenever a modification is being made towards the development of a new version

##### Connect to Azure
Write-Host "Step 1 - Connect to the Azure Cloud" -ForegroundColor "DarkYellow"
$password = Read-Host "Your AzDevOps SP's Password..." -AsSecureString
$credential = New-Object -TypeName System.Management.Automation.PSCredential("http://AzDevOps", $password)
$tenant = "sebinego.onmicrosoft.com"
$connection = Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenant -WarningAction SilentlyContinue
If ($connection) {
    Write-Host "Connection successful!"
} Else { 
    Write-Host "Connection failed. Check details below"
    $connection
}

##### Collect information
Write-Host "Step 2 - Collect necessary information" -ForegroundColor "DarkYellow"
$targetSubscription = Get-AzSubscription | Where-Object Name -eq "VSEnterprise_DEV"
$bpName = "HelloBlueprintDemo"
$bpCodeDirectory = (Get-ChildItem -Recurse -Filter "Blueprint.json" | Where-Object FullName -Like "*$bpName*").DirectoryName
$blueprint = Get-AzBlueprint -Name $bpName -SubscriptionId $targetSubscription.Id
$bpLastVersion = [Double] $blueprint.Versions[$blueprint.Version.Length-1]
$bpNewVersion = $bpLastVersion + 0.1

##### Show collected information
Write-Host "Azure Blueprint Details" -ForegroundColor DarkCyan
Write-Host "Blueprint Name: $bpName" -ForegroundColor DarkCyan
Write-Host "Blueprint Target: Subscription $($targetSubscription.Name) with ID $($targetSubscription.Id)" -ForegroundColor DarkCyan
Write-Host "Blueprint Code Directory: $bpCodeDirectory" -ForegroundColor DarkCyan
Write-Host "Blueprint Last Version: $bpLastVersion" -ForegroundColor DarkCyan
Write-Host "Blueprint New Version: $bpNewVersion" -ForegroundColor DarkCyan

Write-Host "Importing the new Blueprint as Draft" -ForegroundColor "DarkYellow"
Import-AzBlueprintWithArtifact -Name $bpName -SubscriptionId $targetSubscription.Id -InputPath $targetDirectory
Write-Host "Publishing the Blueprint as version $bpNewVersion" -ForegroundColor "DarkYellow"
Publish-AzBlueprint -Blueprint $blueprint -Version $bpNewVersion