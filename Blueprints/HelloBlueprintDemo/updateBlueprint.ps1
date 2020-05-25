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
$bpName = Read-Host "Name of the Azure Blueprint you want to update..."
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

##### Save the new Definition, Publish it as a new version and update the Assignment
Write-Host "Step 3 - Save Draft | Publish New Version | Update Assignment" -ForegroundColor "DarkYellow"
Write-Host "Importing the new Blueprint as Draft" -ForegroundColor "DarkYellow"
Import-AzBlueprintWithArtifact -Name $bpName -SubscriptionId $targetSubscription.Id -InputPath $bpCodeDirectory -Force -Confirm:$false -ErrorVariable $errr


######## OBSERVATION
<#
Might create an array with already existing Organizations
Read-Host for the Organization_Name -> if it doesn't exist, create another if/else statement to check if the user wants to create a new BP for that org;
If "yes" > create a new BP > add the organization name to already existing array

IDK just an idea
#>
If ($?) {
    Write-Host "Publishing the Blueprint as version $bpNewVersion" -ForegroundColor "DarkYellow"
    Publish-AzBlueprint -Blueprint $blueprint -Version $bpNewVersion
    
    $org = Read-Host "Name of your organization..."
    $newOrUpdate = Read-Host "Is this a new assignment?"
    If (($newOrUpdate -eq "Yes") -or ($newOrUpdate -eq "yes")) {
        If (($org -eq "Ostroveni") -or ($org -eq "TunariiVechi")) {
            Write-Host "Let's create the Blueprint Assignment first..." -ForegroundColor "DarkCyan"
            $updatedBlueprint = Get-AzBlueprint -Name $bpName -SubscriptionId $targetSubscription.Id -Version $bpNewVersion
            $assignmentFile = "$bpCodeDirectory/$($org)Assignment.json"
            New-AzBlueprintAssignment -Name "$bpName-$($org)Assignment" -SubscriptionId $targetSubscription.Id -Blueprint $updatedBlueprint -AssignmentFile $assignmentFile
        } Else {
            Write-Host "Organization does not exist." -ForegroundColor "DarkRed"
        }
    } Else {
        If (($org -eq "Ostroveni") -or ($org -eq "TunariiVechi")) {
            Write-Host "Update Blueprint Assignment for Organization $org" -ForegroundColor "DarkYellow"
            $updatedBlueprint = Get-AzBlueprint -Name $bpName -SubscriptionId $targetSubscription.Id -Version $bpNewVersion
            $assignmentFile = "$bpCodeDirectory/$($org)Assignment.json"
            Set-AzBlueprintAssignment -Name "$bpName-$($org)Assignment" -SubscriptionId $targetSubscription.Id -Blueprint $updatedBlueprint -AssignmentFile $assignmentFile
        } Else {
            Write-Host "Organization does not exist." -ForegroundColor "DarkRed"
        }
    }
} Else {
    Write-Host "Received Error: $errr"
}
