Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "          USUÁRIO DO AD CREATOR           " -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Yellow

Import-Module ActiveDirectory

function CriarUsuario {
    $primeiroNome = Read-Host -Prompt "Digite o primeiro nome"
    $sobrenomes = Read-Host -Prompt "Digite todos os sobrenomes"

    $partesSobrenome = $sobrenomes -split ' '
    $ultimoSobrenome = $partesSobrenome[-1]

    $usuario = ("$primeiroNome.$ultimoSobrenome").ToLower()

    Write-Host "Carregando Unidades Organizacionais..."
    $ous = Get-ADOrganizationalUnit -Filter * -Properties Name, DistinguishedName | Select-Object Name, DistinguishedName
    $index = 0
    $ous | ForEach-Object { Write-Host "$index. $($_.Name)" -ForegroundColor Cyan; $index++ }
    $selectedOUIndex = Read-Host -Prompt "Selecione o número da Unidade Organizacional"
    $ou = $ous[$selectedOUIndex].DistinguishedName

    $senhaPlana = Read-Host -Prompt "Digite a senha" -AsSecureString
    $senha = ConvertTo-SecureString $senhaPlana -AsPlainText -Force

    try {
        New-ADUser -Name "$primeiroNome $sobrenomes" -GivenName $primeiroNome -Surname $ultimoSobrenome -SamAccountName $usuario -Path $ou -AccountPassword $senha -Enabled $true -PasswordNeverExpires $false -ChangePasswordAtLogon $true -DisplayName "$primeiroNome $sobrenomes" -ErrorAction Stop

        Write-Host "Usuário '$usuario' criado com sucesso no Active Directory." -ForegroundColor Green
    } catch {
        Write-Host "Erro ao criar usuário: $_" -ForegroundColor Red
    }
}

do {
    CriarUsuario
    $criarOutro = Read-Host "Deseja criar outro usuário? (s/n)"
} while ($criarOutro -eq 's')

Write-Host "Finalizando a criação de usuários." -ForegroundColor Yellow
