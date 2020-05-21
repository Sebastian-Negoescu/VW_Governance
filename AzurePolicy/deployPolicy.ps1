################ Script made to VALIDATE (1) the ARM Templates && DEPLOY (2) the Policies && Initiatives if validations pass.

##### Connect to the Azure Account
$pwd = Read-Host "Your AzDevOps SP's Password..." -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential("http://AzDevOps", $pwd)
$tenant = "sebinego.onmicrosoft.com"
Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenant -Subscription "VSEnterprise_DEV"

##### Validate ARM Templates
$deploymentFile = "$(Get-Location)/deployDefinitions.json"
$location = (Get-Content -Path $deploymentFile | ConvertFrom-Json).parameters.location.defaultValue
$validation = Test-AzDeployment -Location $location -TemplateFile $deploymentFile

If ($validation.Code) {
    Write-Host "Oops... Look like there are some errors."
    Write-Host "Error code: $($validation.Code)"
    Write-Host "Error Message: $($validation.Message)"
    Write-Host "Error Details: $($validation.Details)"
} Else {
    $deployment = New-AzDeployment -Location $location -TemplateFile $deploymentFile
    Write-Host "Deployment finished. See you next time!"
}