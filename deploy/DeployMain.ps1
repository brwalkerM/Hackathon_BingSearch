Clear-Host
#Connect-AzAccount -tenant $env:NEW_AZURE_TENANT_ID -Subscription $env:NEW_AZURE_SUBSCRIPTION_ID

# User Defined Parameters
$templateFile = 'Main.bicep'
$location = 'eastus2'
$OHUsers = @('user02','user03') # all lower case, no dashes or underscores due to service naming limitations
$sqlAdmin = 'brwalker'

# Credentials store configs
$AKVName = 'akv-brwalker-ME'
$SP_AKV_AdminGroupID = 'AADGlobalAdminGroupID'
$AdminPWD = 'AdminPWD'

# Derived Parameters - Pull information from AKV
$APwd = Get-AzKeyVaultSecret -VaultName $AKVName -Name $AdminPWD -AsPlainText
$sqlAdminPassword = ConvertTo-SecureString $APwd -AsPlainText -Force
$AdminGroup_objId = Get-AzKeyVaultSecret -VaultName $AKVName -Name $SP_AKV_AdminGroupID -AsPlainText

foreach ($user in $OHUsers)
    {
        $RGName = "rg-bsoh-${user}"

        # Create Resource Group for the deployment
      #  write-host (Get-Date -format "yyyy-MM-dd HH:mm:ss.fff") "  |Creating Resource Group:       |" $RGName
      #  New-AzResourceGroup -Name $RGName -Location $location

        # Set Deployment Name
        $today = Get-Date -Format 'MM-dd-yyyy-HHmmss'
        $deploymentName = "$RGName-$today"

        Write-host (Get-Date -format "yyyy-MM-dd HH:mm:ss.fff") "  |Starting Deployment:           | " $deploymentName
        Write-host (Get-Date -format "yyyy-MM-dd HH:mm:ss.fff") "  |in Region:                     | " $location

        New-AzSubscriptionDeployment `
        -Name $deploymentName `
        -TemplateFile $templateFile `
        -RGName $RGName `
        -OHUser $user `
        -location $location `
        -AdminGroup_objId $AdminGroup_objId  `
        -sqlAdmin $sqlAdmin `
        -sqlAdminPassword $sqlAdminPassword
       
    }

