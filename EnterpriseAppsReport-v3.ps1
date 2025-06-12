
#Instel o Modulo Ms Graph antes de executar o Script

#Instalar modulos
#Install-Module Microsoft.Graph -Scope CurrentUser

#Atualizar GRaph
#Update-Module Microsoft.Graph

# Conectar ao Microsoft Graph
Connect-MgGraph -Scopes "Application.Read.All", "Application.Read.All"

#Criar pasta para guardar o .csv
New-Item -ItemType Directory -Path "C:\relatorio" -Force

Write-Host " Conectando...." -ForegroundColor Yellow

Clear-Host
Write-Host "=============================================================================="
Write-Host " O arquivo foi gerado e armazenando no caminho abaixo:" -ForegroundColor Yellow
Write-Host "=============================================================================="
Clear-Host

# Recuperar todos os aplicativos empresariais (Service Principals)
$apps = @()
$servicePrincipals = Get-MgServicePrincipal -All

foreach ($sp in $servicePrincipals) {
    # Tentar obter a aplicação associada pelo AppId (pode falhar para apps externos)
    try {
        $app = Get-MgApplication -Filter "appId eq '$($sp.AppId)'" -ErrorAction Stop
    } catch {
        $app = $null
    }

    # Certificados (se houver)
    $certDates = @()
    if ($app) {
        foreach ($key in $app.KeyCredentials) {
            if ($key.Type -eq "AsymmetricX509Cert") {
                $certDates += "NotBefore: $($key.StartDateTime.ToString("u")) - NotAfter: $($key.EndDateTime.ToString("u"))"
            }
        }
    }

    $apps += [PSCustomObject]@{
        DisplayName     = $sp.DisplayName
        AppId           = $sp.AppId
        ObjectId        = $sp.Id
        Publisher       = $sp.PublisherName
        CreatedDate     = $sp.CreatedDateTime
        CertificateInfo = ($certDates -join " | ")
        AppRoles        = ($sp.AppRoles | ForEach-Object { $_.DisplayName }) -join ", "
    }
}

# Exportar para CSV
$csvPath = "C:\relatorio\EnterpriseApplications_Detalhado.csv"
$apps | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8 -Force

Write-Host "O arquivo foi gerado e armazenando no caminho abaixo:" -ForegroundColor Yellow
Write-Host
Write-Host "Exportação concluída: $csvPath"
Write-Host
Write-Host "Um momento.  Vamos abrir a pasta para você..." -ForegroundColor Yellow 

Start C:\relatorio
