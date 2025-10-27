
### Resource
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