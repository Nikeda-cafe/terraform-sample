# Terraform プロジェクト概要

このリポジトリは、サービス別・環境別に Terraform のルートモジュールを分け、各サービスが独自の `modules/` を持つ構成です。

## ディレクトリ構成

```
terraform/
├── shared/                    # 共有インフラ（VPC Endpoints など）
│   ├── modules/
│   │   └── vpc-endpoints/
│   └── environment/
│       ├── dev/
│       └── prod/
├── nextjs-app/                # Next.js アプリケーション
│   ├── modules/
│   │   └── ecs/
│   └── environment/
│       ├── dev/
│       └── prod/
├── express-app/               # Express アプリケーション
│   ├── modules/
│   │   └── ecs/
│   └── environment/
│       ├── dev/
│       └── prod/
└── docs/
```

- **shared/**: ECR / CloudWatch Logs 用の VPC Endpoints（全サービスで共有）
- **nextjs-app/**, **express-app/**: 各アプリの ECS クラスター・サービス・ALB
- 各サービスの `environment/{dev|prod}/` で `terraform init/plan/apply` を実行

## デプロイ順序（重要）

VPC Endpoints は ECS タスクが ECR からイメージを取得するために必要です。

1. **shared** を先にデプロイ
2. **nextjs-app** をデプロイ
3. **express-app** をデプロイ

## 基本的な実行方法

### 1) shared（VPC Endpoints）

```bash
cd shared/environment/dev
terraform init
terraform plan
terraform apply
```

### 2) nextjs-app

```bash
cd nextjs-app/environment/dev
terraform init
terraform plan
terraform apply
```

### 3) express-app

```bash
cd express-app/environment/dev
terraform init
terraform plan
terraform apply
```

`prod` 環境の場合は、ディレクトリを `environment/prod` に読み替えて実行します。

## バックエンド（状態ファイル）

S3 backend を使用しています。state キーはサービス・環境ごとに異なります。

- `shared/dev/terraform.tfstate` / `shared/prod/terraform.tfstate`
- `nextjs-app/dev/terraform.tfstate` / `nextjs-app/prod/terraform.tfstate`
- `express-app/dev/terraform.tfstate` / `express-app/prod/terraform.tfstate`

## 既存状態の移行（environment/dev から移行する場合）

旧 `environment/dev` でデプロイ済みの場合、状態を分割して移行する必要があります。

1. **shared の状態を移行**（旧 state から vpc_endpoints を分離）
   - 旧設定で `terraform state pull` し、`module.vpc_endpoints` 配下のリソースを新 `shared` 用 state に移す
   - または、shared を新規適用してから旧 state から `module.vpc_endpoints` を削除する

2. **nextjs-app の状態を移行**
   - 旧 state の `module.ecs` 配下を `nextjs-app` 用 state に移す

3. **旧 environment の .terraform キャッシュ**
   - `environment/dev/.terraform/`、`environment/prod/.terraform/` は削除して問題ありません（init で再生成されます）

## よくある注意点

- `plan` で差分確認してから `apply` するのが安全です
- express-app の ECR リポジトリ名（`dev-express-app` / `prod-express-app`）は既存環境に合わせて `main.tf` で調整してください
- `ecs` モジュールは nextjs-app と express-app で同じ内容を持ちます。変更時は両方への反映が必要です
