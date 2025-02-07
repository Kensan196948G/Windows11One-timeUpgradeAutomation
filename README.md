# 🖥️ Windows 11 一括アップグレード ガイド

## 📁 ファイル構成

1. **Windows11Upgrade.psm1**
   - 📦 モジュールファイル
   - 🔧 各種チェック機能やアップグレードロジックを含む

2. **Windows11Upgrade.ps1**
   - 🚀 メインスクリプト
   - 📥 モジュールを読み込み、アップグレードプロセスを管理

3. **Windows11Upgrade_Guide.txt**
   - 📖 当説明書

4. **PC_List.txt**
   - 📋 対象PCのリスト
   - 🔍 絶対パス: `C:\kitting\Windows11UpgradeBatchProcess\PC_List.txt`

## 📝 PC_List.txtの記入例

> ⚠️ PC_List.txt にはコンピューター名またはIPアドレスのどちらかを記入します。

```plaintext
PC001
PC002
192.168.1.10
192.168.1.11
```

## ✅ 前提条件

1. 🔷 Windows 10 Pro/Enterprise (バージョン 21H2 以上)
2. 👑 管理者権限
3. 🌐 ネットワーク接続 (100Mbps 推奨)
4. 💾 Cドライブに **20GB 以上**の空き容量

## 🔒 WinRM設定

1. WinRMが**有効化**されている必要があります
2. ファイアウォールで**TCP 5985**が許可されている必要があります
3. スクリプトがWinRMを自動的に有効化します

## 🛠️ PsTools設定

1. PsToolsをインストールする必要があります
2. インストール先: `C:\kitting\Pstools`
3. ダウンロード先: [https://download.sysinternals.com/files/PSTools.zip](https://download.sysinternals.com/files/PSTools.zip)
4. インストール手順:
   - 📥 ダウンロードしたZIPを`C:\kitting\Pstools`に展開
   - ⚙️ システムのPATHに`C:\kitting\Pstools`を追加

## 📥 インストール手順

1. `Windows11Upgrade.psm1` と `Windows11Upgrade.ps1` を `C:\kitting\Windows11UpgradeBatchProcess` フォルダに配置
2. `PC_List.txt` を同一フォルダに配置し、対象PCをリスト化
3. PsToolsをインストールし、PATHを設定

## ▶️ 実行手順

1. PowerShell を**管理者権限**で開く
2. スクリプトがあるフォルダに移動
3. 次のコマンドを実行:
   ```powershell
   .\Windows11Upgrade.ps1
   ```

## 📊 ログ確認

1. ログファイルは `C:\kitting\Windows11UpgradeBatchProcess` フォルダに生成されます
2. ファイル名: `Windows11UpgradeLog_YYYYMMDD_HHMMSS.log`
3. ログを確認し、エラーがなければ正常完了

## ⚠️ エラーハンドリング

1. 各ステップでエラーを捕捉し、ログに記録
2. エラー発生時は、ログを確認し対処

## ❗ 注意事項

1. 🔄 スクリプト実行後は、PCを再起動不要
2. ✔️ アップグレード完了後、PCの動作を確認
3. 💾 バックアップが正常に実行されたことを確認

---
*このガイドは定期的に更新されます。最新版をご確認ください。*
