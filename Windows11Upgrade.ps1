param (
    [string]$ISOPath = "C:\kitting\Windows11UpgradeBatchProcess\Windows11.iso",
    [string]$PCListPath = "C:\kitting\Windows11UpgradeBatchProcess\PC_List.txt",
    [string]$Username = "mirai.local\wsadmin",
    [string]$Password = "20mirai02"
)

# ログ出力先
$LogPath = "C:\kitting\Windows11UpgradeBatchProcess\Windows11_Upgrade_Log.csv"

# クレデンシャルを作成
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)

# ISOをマウントし、ドライブ文字を取得
try {
    $DriveLetter = (Mount-DiskImage -ImagePath $ISOPath -PassThru | Get-Volume).DriveLetter
} catch {
    Write-Error "ISOマウントに失敗しました: $($Error[0].Message)"
    exit 1
}

# PCリストを読み込み
$Computers = Get-Content -Path $PCListPath

foreach ($Computer in $Computers) {
    Write-Host "処理中: $Computer"
    
    # WinRMが有効か確認
    if (!(Test-WSMan -ComputerName $Computer -Credential $Credential -ErrorAction SilentlyContinue)) {
        Write-Warning "WinRMが有効ではありません: $Computer"
        # WinRMを有効化する
        . {
            Enable-PSRemoting -Force -ErrorAction Stop
            New-NetFirewallRule -Name "AllowWinRM" -DisplayName "Allow WinRM" -Enabled True -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow
        } | Invoke-Command -ComputerName $Computer -Credential $Credential
    }
    
    # アップグレードを実行
    try {
        $Result = Invoke-Command -ComputerName $Computer -Credential $Credential -ScriptBlock {
            param ($DriveLetter)
            Start-Process -FilePath "$($DriveLetter):\setup.exe" -ArgumentList "/auto upgrade /quiet /noreboot" -Wait
            return [PSCustomObject]@{
                ComputerName = $env:COMPUTERNAME
                Result      = "Success"
            }
        } -ArgumentList $DriveLetter
    } catch {
        $Result = [PSCustomObject]@{
            ComputerName = $Computer
            Result      = "Failed"
            ErrorMessage = $Error[0].Message
        }
    }
    
    # PsExecを使用して再試行(オプション)
    if ($Result.Result -eq "Failed") {
        if (Get-Command psexec -ErrorAction SilentlyContinue) {
            try {
                .\psexec.exe -accepteula "\\\\"$Computer -u $Username -p $Password "C:\Windows11Upgrade\setup.exe /auto upgrade /quiet /noreboot"
                $Result.Result = "Success"
                $Result.ErrorMessage = ""
            } catch {
                $Result.ErrorMessage += "PsExecで再試行も失敗しました: $($Error[0].Message)"
            }
        }
    }
    
    # 結果をCSVに出力
    $Result | Export-Csv -Path $LogPath -Append -NoTypeInformation
}

# アップグレード完了後の確認
$Computers | ForEach-Object {
    try {
        $Version = Invoke-Command -ComputerName $_ -Credential $Credential -ScriptBlock {
            Get-ComputerInfo | Select-Object -ExpandProperty WindowsVersion
        }
        Write-Host "成功: $_ の Windows バージョンは $Version です"
    } catch {
        Write-Host "確認失敗: $_ - $($Error[0].Message)"
    }
}

# ISOをアンマウント
Dismount-DiskImage -ImagePath $ISOPath