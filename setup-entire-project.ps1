# PowerShell Script to Automate Full Project Setup
# This script sets up Azure infrastructure, Azure AD, and Azure DevOps.

# --- Step 1: User Configuration & Login ---
Write-Host "Step 1: Logging in to Azure and Azure DevOps..." -ForegroundColor Green

# Install Azure DevOps extension if not present
az extension add --name azure-devops --only-show-errors

# Login to Azure - this will open a browser window
az login

# Login to Azure DevOps - this will also open a browser window
az devops login

# Get current user and subscription details
$tenantId = (az account show --query "tenantId" --output tsv)
$subscriptionId = (az account show --query "id" --output tsv)
$devopsOrgUrl = (az devops organization list --query "[0].url" --output tsv)

Write-Host "Successfully logged in."
Write-Host "- Tenant ID: $tenantId"
Write-Host "- Subscription ID: $subscriptionId"
Write-Host "- DevOps Org: $devopsOrgUrl"

# --- Step 2: Deploy Azure Infrastructure with Terraform ---
Write-Host "`nStep 2: Deploying Azure infrastructure with Terraform..." -ForegroundColor Green
Write-Host "This will create the Resource Group, Storage, App Service Plan, and Function App."

Push-Location .\terraform-backend

terraform init
terraform apply -auto-approve

$functionAppName = (terraform output -raw function_app_name)

Pop-Location

Write-Host "Terraform deployment complete. Function App '$functionAppName' is ready."

# --- Step 3: Create and Configure Azure AD App Registrations ---
Write-Host "`nStep 3: Creating and configuring Azure AD App Registrations..." -ForegroundColor Green

# Create Backend API App Registration
Write-Host "Creating Backend API App Registration..."
$apiAppName = "CitizenPortal-API-Auto"
$apiApp = az ad app create --display-name $apiAppName --sign-in-audience AzureADMyOrg --output json | ConvertFrom-Json
$apiAppId = $apiApp.appId
$apiAppObjectId = $apiApp.id

# Expose an API scope for the backend
$permissionScopeId = (New-Guid).Guid
# MANUAL STEP REQUIRED:
# The Azure CLI does not support updating oauth2PermissionScopes via --set for existing apps.
# Please update the API App Registration's manifest to add the permission scope manually or via script as described in the README or ask for manifest automation help.
# az ad app update --id $apiAppId --set oauth2PermissionScopes=... (NOT SUPPORTED, DO NOT USE)

$apiIdentifierUri = "api://$apiAppId"
az ad app update --id $apiAppId --identifier-uris $apiIdentifierUri

Write-Host "Backend API App ('$apiAppName') created with ID: $apiAppId"

# Create Frontend UI App Registration
Write-Host "Creating Frontend UI App Registration..."
$uiAppName = "CitizenPortal-UI-Auto"
$uiApp = az ad app create --display-name $uiAppName --sign-in-audience AzureADMyOrg --output json | ConvertFrom-Json
$uiAppId = $uiApp.appId

# Configure SPA redirect URIs
# MANUAL STEP REQUIRED:
# The Azure CLI does not support updating SPA redirect URIs via --set for existing apps.
# Please update the UI App Registration's manifest to add the SPA redirect URI manually or via script as described in the README or ask for manifest automation help.
# az ad app update --id $uiAppId --set spa.redirectUris=... (NOT SUPPORTED, DO NOT USE)


Write-Host "Frontend UI App ('$uiAppName') created with ID: $uiAppId"

# Grant the Frontend App permission to call the Backend API
Write-Host "Granting API permissions..."
$apiPermission = az ad app permission add --id $uiAppId --api $apiAppId --api-permissions "$permissionScopeId=Scope"

# --- Step 4: Setup Azure DevOps ---
Write-Host "`nStep 4: Setting up Azure DevOps Project and Pipeline..." -ForegroundColor Green
$devopsProjectName = "kml_rg_main-13d212c7edd04114Portal-Auto"
$githubRepoUrl = "https://github.com/AamaniKuntamukkala/Azure-Project" # Replace if your repo URL is different

# Create DevOps Project
if (-not $devopsOrgUrl) {
    Write-Host "ERROR: Could not determine Azure DevOps organization URL. Please check your login and try again." -ForegroundColor Red
    exit 1
}
az devops project create --name $devopsProjectName --organization $devopsOrgUrl

# Create Service Connection
$serviceConnectionName = "Azure-Subscription-Connection-Auto"
$servicePrincipalName = "http://${devopsProjectName}-SPN"
$spn = az ad sp create-for-rbac --name $servicePrincipalName --role "Contributor" --scopes "/subscriptions/$subscriptionId" --output json | ConvertFrom-Json

if (-not $spn.appId) {
    Write-Host "ERROR: Service Principal creation failed. You may lack sufficient permissions to assign roles. Contact your Azure admin." -ForegroundColor Red
    exit 1
}
az devops service-endpoint azurerm create --azure-rm-service-principal-id $spn.appId --azure-rm-subscription-id $subscriptionId --azure-rm-subscription-name $spn.displayName --azure-rm-tenant-id $spn.tenant --name $serviceConnectionName --project $devopsProjectName --organization $devopsOrgUrl

# Create the Pipeline from the repo's YAML file
$pipelineName = "Deploy-Backend-API"
az devops pipeline create --name $pipelineName --project $devopsProjectName --organization $devopsOrgUrl --repository $githubRepoUrl --branch main --yml-path "/azure-serverless-api/azure-pipelines.yml"
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Pipeline creation failed. Please check the Azure DevOps portal and create the pipeline manually if needed." -ForegroundColor Yellow
}

Write-Host "Azure DevOps setup is complete."

# --- Step 5: Final Configuration Values ---
Write-Host "`n--- SETUP COMPLETE ---`n" -ForegroundColor Yellow
Write-Host "You can now run the pipeline in Azure DevOps to deploy the backend code."
Write-Host "After deployment, update your frontend 'authConfig.js' with these values:`n"

Write-Host "auth: {" -ForegroundColor Cyan
Write-Host "    clientId: \"$uiAppId\"," -ForegroundColor Cyan
Write-Host "    authority: \"https://login.microsoftonline.com/$tenantId\"" -ForegroundColor Cyan
Write-Host "}
" -ForegroundColor Cyan

Write-Host "loginRequest: {" -ForegroundColor Cyan
Write-Host "    scopes: [\"$apiIdentifierUri/api.access\"]" -ForegroundColor Cyan
Write-Host "}
" -ForegroundColor Cyan
