# Terraform レビュー 参照資料

## AWS リソース別の推奨設定

### ECS

- **タスク定義**: CPU とメモリの組み合わせが有効か（例: 256 CPU + 512 MB）
- **Container Insights**: prod では有効化を推奨
- **デプロイ設定**: Blue/Green の bake_time が適切か
- **ログ保持**: CloudWatch Logs の retention が設定されているか

### ALB

- **リスナー**: HTTPS がデフォルトで、HTTP はリダイレクト推奨
- **ターゲットグループ**: ヘルスチェックの path と interval が適切か
- **サブネット**: マルチAZ のパブリックサブネットに配置されているか

### VPC / ネットワーク

- **サブネット**: プライベートサブネットに ECS タスク、パブリックサブネットに ALB
- **セキュリティグループ**: 必要なポートのみ開放（例: コンテナポート、HTTPS）

### IAM

- **タスク実行ロール**: ECR プル、CloudWatch Logs 書き込みに必要な最小限の権限
- **タスクロール**: アプリが AWS API を呼ぶ場合のみ付与、最小権限

## Terraform の一般的なアンチパターン

- **ハードコード**: リージョン、アカウントID、ARN を変数化する
- **巨大モジュール**: 単一責任の原則に従い、適切に分割する
- **count の多用**: `for_each` の方が状態管理が安定する場合がある
- **depends_on の過剰使用**: 暗黙の依存関係を活用する
- **local-exec の乱用**: 可能な限り Terraform リソースで完結させる

## 本プロジェクトの命名規則・タグ規約

- **prefix**: `dev-` または `prod-`
- **リソース名**: `${prefix}${app_name}-<種別>`（例: `dev-express-app-cluster`）
- **タグ**: `Name`, `Environment`（dev / prod）を付与
- **ECR リポジトリ**: 環境に応じて `dev-express-app` / `prod-express-app` 等
- **state キー**: `{service}/{env}/terraform.tfstate`（例: `express-app/dev/terraform.tfstate`）
