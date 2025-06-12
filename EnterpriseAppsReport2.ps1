
#Instel o Modulo Ms Graph antes de executar o Script
#Instalar modulos s
#Install-Module Microsoft.Graph -Scope CurrentUser

#Atualizar GRaph
#Update-Module Microsoft.Graph

# Conectar ao Microsoft Graph com permissões adequadas
Connect-MgGraph -Scopes "Application.Read.All"

#Criar pasta para guardar o .csv
New-Item -ItemType Directory -Path "C:\relatorio" -Force

Clear-Host
Write-Host "=============================================================================="
Write-Host " O arquivo foi gerado e armazenando no caminho abaixo:" -ForegroundColor Yellow
Write-Host "=============================================================================="
Clear-Host

# Recuperar todos os aplicativos empresariais (Service Principals)
$apps = @()
$results = Get-MgServicePrincipal -All

foreach ($app in $results) {
    $apps += [PSCustomObject]@{
        DisplayName = $app.DisplayName
        AppId       = $app.AppId
        ObjectId    = $app.Id
        Publisher   = $app.PublisherName
        AppRoles    = ($app.AppRoles | ForEach-Object { $_.DisplayName }) -join ", "
    }
}

# Exportar para CSV
$csvPath = "C:\relatorio\EnterpriseApplications.csv"
$apps | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "O arquivo foi gerado e armazenando no caminho abaixo:" -ForegroundColor Yellow
Write-Host
Write-Host "Exportação concluída: $csvPath"
Write-Host
Write-Host "Um momento.  Vamos abrir a pasta para você..." -ForegroundColor Yellow

Start C:\relatorio
