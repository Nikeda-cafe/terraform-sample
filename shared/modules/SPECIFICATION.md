# RDS MySQL + EC2 Bastion インフラストラクチャ 実装仕様書

## 1. 概要

このドキュメントは、shared ディレクトリに RDS (MySQL) と EC2 踏み台サーバーを構築するための実装仕様です。
各ファイルに記載すべき内容、設定項目、リソース定義を詳細に定義します。

---

## 2. RDS モジュール仕様

### 2.1 モジュールディレクトリ構成

```
shared/modules/rds/
├── variables.tf          # 入力変数の定義
├── main.tf              # ローカル変数、データソース、プロバイダ設定
├── security_group.tf    # セキュリティグループ定義
├── subnet_group.tf      # DB Subnet Group 定義
├── db_instance.tf       # RDS インスタンス定義
└── outputs.tf           # 出力値定義
```

### 2.2 variables.tf - 入力変数定義

**記載内容**:

| 変数名 | 型 | デフォルト値 | 説明 |
|--------|-----|-------------|------|
| `environment` | string | "dev" | 環境名 (dev/prod) |
| `prefix` | string | "dev-" | リソース名プレフィックス |
| `region` | string | "ap-northeast-1" | AWS リージョン |
| `vpc_name` | string | "udemy-aws-container-vpc" | 既存 VPC 名 |
| `subnet_tag_names` | list(string) | 既存プライベートサブネット名リスト | DB Subnet Group 用サブネット |
| `db_name` | string | "app" | 作成するデータベース名 |
| `db_master_username` | string | "app" | RDS マスターユーザー名 |
| `db_master_password` | string (sensitive) | - | RDS マスターパスワード（最小8文字） |
| `allocated_storage` | number | 20 | ストレージ容量（GB） |
| `storage_type` | string | "gp3" | ストレージタイプ（gp3推奨） |
| `engine_version` | string | "8.0" | MySQL エンジンバージョン |
| `backup_retention_period` | number | 0 | バックアップ保持期間（0=無効） |
| `multi_az` | bool | false | Multi-AZ 有効化 |
| `skip_final_snapshot` | bool | true | 削除時のスナップショット作成をスキップ |
| `publicly_accessible` | bool | false | 公開アクセス（常に false） |
| `tags` | map(string) | {} | 追加タグ |

### 2.3 main.tf - ローカル変数とデータソース

**記載内容**:

1. **locals ブロック**
   - `prefix` = var.prefix
   - `region` = var.region
   - `environment` = var.environment
   - `common_tags` = Environment, ManagedBy タグを含むマップ

2. **データソース: aws_vpc**
   - フィルタ: Name タグで `var.vpc_name` を検索
   - 出力: VPC ID を取得

3. **データソース: aws_subnets**
   - フィルタ: VPC ID、Name タグで私有サブネット検索
   - 出力: サブネット ID リストを取得

### 2.4 security_group.tf - セキュリティグループ定義

**リソース: aws_security_group**

名前: `{prefix}rds-sg`

**Inbound Rules**:
- Protocol: tcp
- From Port: 3306
- To Port: 3306
- Source: Bastion セキュリティグループ ID（参照）
- Description: "Allow MySQL from Bastion"

**Outbound Rules**:
- Protocol: -1
- CIDR: 0.0.0.0/0
- Description: "Allow all outbound"

### 2.5 subnet_group.tf - DB Subnet Group 定義

**リソース: aws_db_subnet_group**

| 項目 | 値 |
|------|-----|
| 名前 | `{prefix}rds-db-subnet-group` |
| 説明 | "DB subnet group for RDS MySQL" |
| サブネット ID リスト | データソース `aws_subnets.this.ids` |
| タグ | common_tags + Name タグ |

### 2.6 db_instance.tf - RDS インスタンス定義

**リソース: aws_db_instance**

| 項目 | 値 |
|------|-----|
| `identifier` | `{prefix}mysql-db` |
| `engine` | "mysql" |
| `engine_version` | `var.engine_version` |
| `instance_class` | "db.t3.micro" |
| `allocated_storage` | `var.allocated_storage` |
| `storage_type` | `var.storage_type` |
| `db_name` | `var.db_name` |
| `username` | `var.db_master_username` |
| `password` | `var.db_master_password` |
| `db_subnet_group_name` | `aws_db_subnet_group.this.name` |
| `vpc_security_group_ids` | `[aws_security_group.rds.id]` |
| `publicly_accessible` | false |
| `port` | 3306 |
| `skip_final_snapshot` | `var.skip_final_snapshot` |
| `backup_retention_period` | `var.backup_retention_period` |
| `multi_az` | `var.multi_az` |
| `auto_minor_version_upgrade` | true |
| `storage_encrypted` | true |
| `parameter_group_name` | "default.mysql8.0" |
| `tags` | common_tags + Name タグ |

### 2.7 outputs.tf - 出力値定義

| 出力名 | 値 | 説明 |
|--------|-----|------|
| `rds_endpoint` | `aws_db_instance.this.endpoint` | RDS エンドポイント |
| `rds_address` | `aws_db_instance.this.address` | RDS ホストアドレス |
| `rds_port` | `aws_db_instance.this.port` | RDS ポート（3306） |
| `rds_database_name` | `aws_db_instance.this.db_name` | データベース名 |
| `rds_security_group_id` | `aws_security_group.rds.id` | RDS セキュリティグループ ID |
| `db_subnet_group_name` | `aws_db_subnet_group.this.name` | DB Subnet Group 名 |

---

## 3. EC2 Bastion モジュール仕様

### 3.1 モジュールディレクトリ構成

```
shared/modules/bastion/
├── variables.tf         # 入力変数の定義
├── main.tf             # ローカル変数、データソース、プロバイダ設定
├── iam.tf              # IAM ロール、ポリシー定義
├── security_group.tf   # セキュリティグループ定義
├── ec2.tf              # EC2 インスタンス定義
├── user_data.sh        # ユーザーデータスクリプト
└── outputs.tf          # 出力値定義
```

### 3.2 variables.tf - 入力変数定義

| 変数名 | 型 | デフォルト値 | 説明 |
|--------|-----|-------------|------|
| `environment` | string | "dev" | 環境名 |
| `prefix` | string | "dev-" | リソース名プレフィックス |
| `region` | string | "ap-northeast-1" | AWS リージョン |
| `vpc_id` | string | - | VPC ID（RDS モジュールから参照） |
| `vpc_cidr` | string | - | VPC CIDR ブロック |
| `public_subnet_id` | string | - | 公開サブネット ID |
| `instance_type` | string | "t3.micro" | EC2 インスタンスタイプ |
| `rds_security_group_id` | string | - | RDS セキュリティグループ ID（参照） |
| `tags` | map(string) | {} | 追加タグ |

### 3.3 main.tf - ローカル変数とデータソース

**記載内容**:

1. **locals ブロック**
   - `prefix`, `region`, `environment` の定義
   - `common_tags` = Environment, ManagedBy タグ

2. **データソース: aws_ami**
   - Amazon Linux 2 の最新 AMI を取得
   - フィルタ: owner "amazon", name "amzn2-ami-hvm-*"

### 3.4 iam.tf - IAM ロールとポリシー定義

**リソース: aws_iam_role**
- 名前: `{prefix}bastion-role`
- AssumeRolePolicyDocument: EC2 サービスプリンシパル
- タグ: common_tags

**リソース: aws_iam_role_policy_attachment**
- ロール: `aws_iam_role.bastion.name`
- ポリシーARN: "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

**リソース: aws_iam_instance_profile**
- 名前: `{prefix}bastion-profile`
- ロール: `aws_iam_role.bastion.name`

### 3.5 security_group.tf - セキュリティグループ定義

**リソース: aws_security_group**

名前: `{prefix}bastion-sg`

**Inbound Rules**:
- なし（Session Manager でアクセス）

**Outbound Rules**:
1. MySQL (3306)
   - Destination: RDS セキュリティグループ ID
   - Protocol: tcp
   - Port: 3306
   
2. HTTPS (443)
   - Destination: 0.0.0.0/0
   - Protocol: tcp
   - Port: 443
   - Description: "Allow HTTPS for Systems Manager"

### 3.6 ec2.tf - EC2 インスタンス定義

**リソース: aws_instance**

| 項目 | 値 |
|------|-----|
| `ami` | `data.aws_ami.amazon_linux_2.id` |
| `instance_type` | `var.instance_type` |
| `subnet_id` | `var.public_subnet_id` |
| `vpc_security_group_ids` | `[aws_security_group.bastion.id]` |
| `iam_instance_profile` | `aws_iam_instance_profile.bastion.name` |
| `user_data` | ファイル参照 (`user_data.sh`) |
| `associate_public_ip_address` | true |
| `monitoring` | true |
| `root_block_device` | 20GB gp3 |
| `tags` | common_tags + Name タグ |

### 3.7 user_data.sh - ユーザーデータスクリプト

**内容**:

```bash
#!/bin/bash
set -e

# システム更新
yum update -y

# MySQL クライアント インストール
yum install -y mysql

# SSM エージェント確認・起動
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# ログ出力
echo "Bastion host initialized at $(date)" >> /var/log/user-data.log
```

### 3.8 outputs.tf - 出力値定義

| 出力名 | 値 | 説明 |
|--------|-----|------|
| `instance_id` | `aws_instance.bastion.id` | EC2 インスタンス ID |
| `instance_private_ip` | `aws_instance.bastion.private_ip` | プライベート IP |
| `instance_public_ip` | `aws_instance.bastion.public_ip_address` | パブリック IP |
| `security_group_id` | `aws_security_group.bastion.id` | セキュリティグループ ID |
| `iam_role_name` | `aws_iam_role.bastion.name` | IAM ロール名 |

---

## 4. dev 環境統合仕様

### 4.1 ファイル構成

```
shared/environment/dev/
├── main.tf                  # モジュール呼び出し
├── variables.tf             # 環境変数定義
├── terraform.tfvars         # 環境固有設定（.gitignore に追加）
├── outputs.tf              # 環境レベル出力
├── provider.tf             # AWS プロバイダ設定（既存）
├── backend.tf              # Terraform バックエンド設定（既存）
└── .gitignore              # 更新
```

### 4.2 main.tf - モジュール呼び出し

**RDS モジュール呼び出し**:
```hcl
module "rds" {
  source = "../../modules/rds"
  
  environment              = var.environment
  prefix                   = var.prefix
  region                   = var.region
  vpc_name                 = "udemy-aws-container-vpc"
  subnet_tag_names         = [...]
  db_name                  = var.db_name
  db_master_username       = var.db_master_username
  db_master_password       = var.db_master_password
  allocated_storage        = var.allocated_storage
  storage_type             = var.storage_type
  engine_version           = var.engine_version
  backup_retention_period  = var.backup_retention_period
  skip_final_snapshot      = var.skip_final_snapshot
  tags                     = var.tags
}
```

**Bastion モジュール呼び出し**:
```hcl
module "bastion" {
  source = "../../modules/bastion"
  
  environment              = var.environment
  prefix                   = var.prefix
  region                   = var.region
  vpc_id                   = data.aws_vpc.this.id
  vpc_cidr                 = data.aws_vpc.this.cidr_block
  public_subnet_id         = data.aws_subnet.public.id
  instance_type            = var.bastion_instance_type
  rds_security_group_id    = module.rds.rds_security_group_id
  tags                     = var.tags
}
```

### 4.3 variables.tf - 環境変数

| 変数名 | 型 | デフォルト | 説明 |
|--------|-----|----------|------|
| `environment` | string | "dev" | 環境 |
| `prefix` | string | "dev-" | プレフィックス |
| `region` | string | "ap-northeast-1" | リージョン |
| `db_name` | string | "app" | DB 名 |
| `db_master_username` | string | "app" | DB ユーザー |
| `db_master_password` | string | - | DB パスワード（.tfvars）|
| `allocated_storage` | number | 20 | ストレージ GB |
| `storage_type` | string | "gp3" | ストレージタイプ |
| `engine_version` | string | "8.0" | MySQL バージョン |
| `backup_retention_period` | number | 0 | バックアップ保持日数 |
| `bastion_instance_type` | string | "t3.micro" | インスタンスタイプ |
| `tags` | map(string) | {} | タグ |

### 4.4 terraform.tfvars - 環境固有設定（新規作成）

**記載内容**:

```hcl
environment = "dev"
prefix      = "dev-"
region      = "ap-northeast-1"

# RDS configuration
db_name                = "app"
db_master_username     = "app"
db_master_password     = "secret"  # supplied by user (sensitive)
allocated_storage      = 20
storage_type           = "gp3"
engine_version         = "8.0"
backup_retention_period = 0

# EC2 Bastion configuration
bastion_instance_type  = "t3.micro"

# Tags
tags = {
  Project     = "TerraformProject"
  Environment = "dev"
  ManagedBy   = "Terraform"
}
```

### 4.5 outputs.tf - 環境レベル出力

**記載内容**:

```hcl
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_address" {
  description = "RDS address"
  value       = module.rds.rds_address
}

output "rds_port" {
  description = "RDS port"
  value       = module.rds.rds_port
}

output "rds_database_name" {
  description = "Database name"
  value       = module.rds.rds_database_name
}

output "bastion_instance_id" {
  description = "Bastion instance ID"
  value       = module.bastion.instance_id
}

output "bastion_private_ip" {
  description = "Bastion private IP"
  value       = module.bastion.instance_private_ip
}

output "bastion_public_ip" {
  description = "Bastion public IP"
  value       = module.bastion.instance_public_ip
}

output "connection_command" {
  description = "Command to connect to Bastion via Session Manager"
  value       = "aws ssm start-session --target ${module.bastion.instance_id}"
}
```

### 4.6 .gitignore - 更新

**追加内容**:

```
# Terraform
terraform.tfvars
terraform.tfvars.json
*.tfvars
*.tfvars.json
*.tf.json
```

---

## 5. 主なデータフロー

```
dev/main.tf
    ├── RDS モジュール呼び出し
    │   ├── VPC データソース参照
    │   ├── サブネット データソース参照
    │   ├── セキュリティグループ作成
    │   ├── DB Subnet Group 作成
    │   └── RDS インスタンス作成
    │
    └── Bastion モジュール呼び出し
        ├── AMI データソース参照
        ├── IAM ロール・ポリシー作成
        ├── セキュリティグループ作成
        ├── EC2 インスタンス作成
        └── ユーザーデータ実行
```

---

## 6. 実装チェックリスト

### RDS モジュール
- [ ] variables.tf - 全変数定義
- [ ] main.tf - locals、データソース定義
- [ ] security_group.tf - セキュリティグループ定義
- [ ] subnet_group.tf - DB Subnet Group 定義
- [ ] db_instance.tf - RDS インスタンス定義
- [ ] outputs.tf - 出力値定義

### Bastion モジュール
- [ ] variables.tf - 全変数定義
- [ ] main.tf - locals、AMI データソース定義
- [ ] iam.tf - IAM ロール・ポリシー定義
- [ ] security_group.tf - セキュリティグループ定義
- [ ] ec2.tf - EC2 インスタンス定義
- [ ] user_data.sh - ユーザーデータスクリプト
- [ ] outputs.tf - 出力値定義

### dev 環境統合
- [ ] variables.tf - 環境変数定義
- [ ] main.tf - モジュール呼び出し
- [ ] outputs.tf - 環境出力定義
- [ ] terraform.tfvars - 環境設定（新規）
- [ ] .gitignore - terraform.tfvars を追加

---

## 7. 次のステップ

1. **RDS モジュール実装** - 各ファイルを上記仕様に従って作成
2. **Bastion モジュール実装** - 各ファイルを上記仕様に従って作成
3. **dev 環境統合** - モジュール呼び出しと環境設定
4. **terraform validate** - 構文検証
5. **terraform plan** - 実行計画確認
6. **動作確認** - 接続テスト
