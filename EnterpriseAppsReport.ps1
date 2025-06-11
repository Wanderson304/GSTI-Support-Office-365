
<#
=============================================================================================
Name:           Get all enterprise apps and their owners 
Version:        1.0

============================================================================================
#>

#Get-InstalledModule Microsoft.Graph
#Get-InstalledModule
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

#Install-Module Microsoft.Graph.Beta -Repository PSGallery -Force
#Import-Module Microsoft.Graph -ErrorAction Stop



param (
    [string]$OutputPath = (Join-Path -Path (Get-Location) -ChildPath ("AppCredentialExpirations_{0}.csv" -f (Get-Date -Format "yyyyMMdd_HHmmss")))
)

try {
    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
        #Install-Module Microsoft.Graph -Scope CurrentUser -Force
    }
        #Import-Module Microsoft.Graph -ErrorAction Stop

    $Scopes = @("Application.Read.All")
    Write-Host "Autenticando no Microsoft Graph..."
    Connect-MgGraph -Scopes $Scopes -ErrorAction Stop

    Write-Host "Coletando aplicativos registrados..."
    $apps = Get-MgApplication -All

    $results = @()

    foreach ($app in $apps) {
        # Secrets (Client Secrets)
        foreach ($secret in $app.PasswordCredentials) {
            $results += [PSCustomObject]@{
                AppDisplayName = $app.DisplayName
                AppId          = $app.AppId
                CredentialType = "Client Secret"
                KeyId          = $secret.KeyId
                EndDateTime    = $secret.EndDateTime
                StartDateTime  = $secret.StartDateTime
                Hint           = $secret.Hint
            }
        }

        # Certificados (Key Credentials)
        foreach ($key in $app.KeyCredentials) {
            $results += [PSCustomObject]@{
                AppDisplayName = $app.DisplayName
                AppId          = $app.AppId
                CredentialType = "Certificate"
                KeyId          = $key.KeyId
                EndDateTime    = $key.EndDateTime
                StartDateTime  = $key.StartDateTime
                Hint           = $key.DisplayName
            }
        }
    }

    Write-Host ("Exportando relatório para '{0}'..." -f $OutputPath)
    $results | Sort-Object EndDateTime | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

    Write-Host "✅ Relatório exportado com sucesso."
}
catch {
    Write-Error ("❌ Ocorreu um erro: {0}" -f $_.Exception.Message)
}
finally {
    Disconnect-MgGraph | Out-Null
}


start C:\Windows\system32\AppCredentialExpirations_20250611_110501.csv
