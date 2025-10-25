# Keppyann Terraform Infrastructure

新しいAWSアカウント(871950640338)にkeppyann APIインフラをデプロイするためのTerraform構成です。

## 構成概要

### リソース
- **API Gateway**: REST API (EDGE optimized)
  - `POST /message` → keppyann-api Lambda
  - `POST /mng` → keppyann-mng-api Lambda
  - CORS対応 (OPTIONS メソッド)
- **Lambda Functions**:
  - `keppyann-api`: Python 3.11, 128MB, 30秒タイムアウト
  - `keppyann-mng-api`: Python 3.11, 128MB, 3秒タイムアウト
- **IAM Roles**:
  - Lambda実行ロール (各Lambda用)
  - API Gateway実行ロール

## セットアップ手順

### 1. Lambda関数コードのダウンロード

既存のAWSアカウントから:

```bash
# 作業ディレクトリ作成
mkdir -p lambda-code

# keppyann-api のコードをダウンロード
aws lambda get-function --function-name keppyann-api --region ap-northeast-1 --query 'Code.Location' --output text | xargs curl -o lambda-code/keppyann-api.zip

# keppyann-mng-api のコードをダウンロード
aws lambda get-function --function-name keppyann-mng-api --region ap-northeast-1 --query 'Code.Location' --output text | xargs curl -o lambda-code/keppyann-mng-api.zip
```

### 2. AWS認証情報の設定

新しいアカウント(871950640338)の認証情報を設定:

```bash
# AWS CLIで新しいアカウントのプロファイルを設定
aws configure --profile keppyann-new

# または環境変数で設定
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-northeast-1"
```

### 3. Terraformの初期化

```bash
terraform init
```

### 4. 実行計画の確認

```bash
terraform plan
```

### 5. インフラのデプロイ

```bash
terraform apply
```

### 6. 出力の確認

デプロイ後、以下のエンドポイントが出力されます:

```bash
# エンドポイントURLの確認
terraform output api_gateway_url
terraform output message_endpoint
terraform output mng_endpoint
```

## 環境変数

`terraform.tfvars`ファイルに以下の変数が設定されています:

- `aws_region`: デプロイ先リージョン (ap-northeast-1)
- `aws_account_id`: 新しいAWSアカウントID (871950640338)
- `environment`: 環境名 (prod)
- `project_name`: プロジェクト名 (keppyann)
- `line_channel_access_token`: LINE Channel Access Token (keppyann-api用)
- `line_channel_access_token_mng`: LINE Channel Access Token (keppyann-mng-api用)

**⚠️ 注意**: `terraform.tfvars`には機密情報が含まれているため、Gitにコミットしないでください。

## ディレクトリ構成

```
keppyann-terraform/
├── main.tf              # メインのTerraform構成
├── variables.tf         # 変数定義
├── outputs.tf           # 出力定義
├── terraform.tfvars     # 変数の値 (機密情報含む)
├── .gitignore           # Git除外設定
├── README.md            # このファイル
└── lambda-code/         # Lambda関数コード
    ├── keppyann-api.zip
    └── keppyann-mng-api.zip
```

## エンドポイント

デプロイ後、以下のようなエンドポイントが利用可能になります:

```
https://{api-gateway-id}.execute-api.ap-northeast-1.amazonaws.com/prod/message
https://{api-gateway-id}.execute-api.ap-northeast-1.amazonaws.com/prod/mng
```

## クリーンアップ

インフラを削除する場合:

```bash
terraform destroy
```

## トラブルシューティング

### Lambda関数のデプロイエラー

Lambda関数コードが正しくダウンロードされているか確認:

```bash
ls -lh lambda-code/
```

### API Gatewayのテスト

デプロイ後、curlでテスト:

```bash
# メッセージエンドポイントのテスト
curl -X POST https://{api-gateway-id}.execute-api.ap-northeast-1.amazonaws.com/prod/message \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# 管理エンドポイントのテスト
curl -X POST https://{api-gateway-id}.execute-api.ap-northeast-1.amazonaws.com/prod/mng \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

### Lambda関数のログ確認

CloudWatch Logsでログを確認:

```bash
# keppyann-api のログ
aws logs tail /aws/lambda/keppyann-api --follow --region ap-northeast-1

# keppyann-mng-api のログ
aws logs tail /aws/lambda/keppyann-mng-api --follow --region ap-northeast-1
```

## セキュリティのベストプラクティス

### 1. 機密情報の管理

現在の`terraform.tfvars`にはLINE Channel Access Tokenが平文で含まれています。本番環境では以下の方法を推奨します:

#### AWS Secrets Managerを使用する場合

```bash
# シークレットを作成
aws secretsmanager create-secret \
  --name keppyann/line-channel-access-token \
  --secret-string "QOVEq60NB8/dqOh+7rY+5/7msZt3eVrWGE4tONm2WkumOx+xYNzF4Szu57GJ7AvHHdWmybjmE5JhkgL5JVusGw+ttLFBAKdYfybXReL+kW+l4/GZDmy5bIePdvMVY0uwU11VRNdnzRbkCREZJb56+wdB04t89/1O/w1cDnyilFU=" \
  --region ap-northeast-1

aws secretsmanager create-secret \
  --name keppyann/line-channel-access-token-mng \
  --secret-string "V84evZd9mh1QB0i+5doPlS2/PrpmiAGLc5EJu5YtwVsfVE7Qvbn2mtSaQ+B+UUdFva40vNzx40pYkxjTyo6ll0en4JuycF+HnQ4689fn7bWZHG5N6KccL2blNpZrqU6sxKsXYCO8icbqvenCh/OPZgdB04t89/1O/w1cDnyilFU=" \
  --region ap-northeast-1
```

その後、`main.tf`を更新してSecrets Managerから取得するように変更できます。

#### 環境変数を使用する場合

```bash
# terraform.tfvarsから機密情報を削除し、環境変数で設定
export TF_VAR_line_channel_access_token="..."
export TF_VAR_line_channel_access_token_mng="..."

terraform apply
```

### 2. API Gatewayのセキュリティ強化

必要に応じて以下を実装:

- API Keyの使用
- WAFの設定
- リクエストレート制限
- IP制限

## 更新とメンテナンス

### Lambda関数の更新

Lambda関数コードを更新する場合:

```bash
# 1. 新しいコードをダウンロード
aws lambda get-function --function-name keppyann-api --region ap-northeast-1 --query 'Code.Location' --output text | xargs curl -o lambda-code/keppyann-api.zip

# 2. Terraformで再デプロイ
terraform apply
```

### API Gatewayの設定変更

`main.tf`を編集後:

```bash
terraform plan
terraform apply
```

## コスト見積もり

このインフラの月額コスト概算:

- **Lambda**: 
  - 無料利用枠: 月100万リクエスト、40万GB-秒
  - 超過分: リクエスト100万件あたり$0.20
- **API Gateway**:
  - 無料利用枠: 月100万リクエスト(初年度)
  - 超過分: リクエスト100万件あたり$3.50
- **CloudWatch Logs**: 約$0.50/GB

## サポート

問題が発生した場合:

1. CloudWatch Logsでエラーを確認
2. API Gatewayのステージログを有効化
3. X-Rayトレーシングを有効化(デバッグ用)

## ライセンス

このTerraform構成は内部使用のために作成されています。