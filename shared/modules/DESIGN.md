# RDS MySQL + EC2 Bastion インフラストラクチャ 設計書

## 1. 概要

このドキュメントは、AWS 上に構築する RDS (MySQL) と EC2 踏み台サーバーのアーキテクチャ、ネットワーク構成、セキュリティ設計を記載します。

---

## 2. アーキテクチャ概要

### 2.1 全体構成図

```
┌─────────────────────────────────────────────────────────────┐
│                    udemy-aws-container-vpc                   │
│                    (CIDR: 10.0.0.0/16)                       │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Public Subnet (ap-northeast-1a)            │   │
│  │                                                      │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │         EC2 Bastion Instance                  │  │   │
│  │  │ • Instance Type: t3.micro                     │  │   │
│  │  │ • OS: Amazon Linux 2                          │  │   │
│  │  │ • IAM Role: AmazonSSMManagedInstanceCore      │  │   │
│  │  │ • SG: bastion-sg (Outbound to RDS:3306)      │  │   │
│  │  │ • Access: Session Manager (No SSH keys)      │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  │                      ↓ TCP:3306                       │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │        Private Subnets (DB Subnet Group)             │   │
│  │  • Private 1a: udemy-aws-container-...private1...    │   │
│  │  • Private 1c: udemy-aws-container-...private2...    │   │
│  │                                                      │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │      RDS MySQL Database Instance              │  │   │
│  │  │ • Engine: MySQL 8.0                           │  │   │
│  │  │ • Instance Class: db.t3.micro                 │  │   │
│  │  │ • Storage: 20GB gp3 (SSD)                     │  │   │
│  │  │ • Backup: 0 days (disabled)                   │  │   │
│  │  │ • Multi-AZ: false                             │  │   │
│  │  │ • SG: rds-sg (Inbound from Bastion:3306)     │  │   │
│  │  │ • Database: app                             │  │   │
│  │  │ • Master User: app                          │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  │                                                      │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. ネットワーク設計

### 3.1 VPC 構成

| 項目 | 値 |
|------|-----|
| **VPC 名** | `udemy-aws-container-vpc` |
| **CIDR ブロック** | `10.0.0.0/16`（既存） |
| **リージョン** | `ap-northeast-1`（東京） |

### 3.2 サブネット配置

#### 公開サブネット（Bastion 用）

| 項目 | 値 |
|------|-----|
| **AZ** | ap-northeast-1a |
| **用途** | EC2 Bastion ホスト |
| **タイプ** | パブリックサブネット（インターネットゲートウェイ経由） |

#### プライベートサブネット（RDS 用）

| 項目 | 値 |
|------|-----|
| **AZ 1** | ap-northeast-1a |
| **AZ 2** | ap-northeast-1c |
| **タグ名 1** | `udemy-aws-container-subnet-private1-ap-northeast-1a` |
| **タグ名 2** | `udemy-aws-container-subnet-private2-ap-northeast-1c` |
| **用途** | RDS インスタンス（DB Subnet Group） |
| **インターネット接続** | なし（NATゲートウェイ経由、または不要） |

### 3.3 ルーティング

#### Public Subnet Route Table

| 送信元 | 宛先 | ターゲット |
|--------|------|----------|
| `10.0.0.0/16` | Local | Local |
| `0.0.0.0/0` | Internet Gateway | IGW |

#### Private Subnet Route Table

| 送信元 | 宛先 | ターゲット |
|--------|------|----------|
| `10.0.0.0/16` | Local | Local |
| オプション: `0.0.0.0/0` | NAT Gateway | NAT（Systems Manager アクセス用） |

---

## 4. セキュリティ設計

### 4.1 セキュリティグループ設計

#### RDS Security Group (`dev-rds-sg`)

**目的**: RDS MySQL インスタンスへのアクセス制御

| ルール | プロトコル | ポート | ソース/宛先 | 説明 |
|--------|----------|--------|-----------|------|
| **Inbound** | TCP | 3306 | Bastion SG ID | MySQL アクセス（Bastion のみ） |
| **Outbound** | すべて | すべて | 0.0.0.0/0 | すべてのアウトバウンド許可 |

#### Bastion Security Group (`dev-bastion-sg`)

**目的**: EC2 Bastion インスタンスのアクセス制御

| ルール | プロトコル | ポート | ソース/宛先 | 説明 |
|--------|----------|--------|-----------|------|
| **Inbound** | なし | - | - | Session Manager 経由のみ（SSH キー不要） |
| **Outbound** | TCP | 3306 | RDS SG ID | MySQL（RDS への接続） |
| **Outbound** | TCP | 443 | 0.0.0.0/0 | HTTPS（Systems Manager API） |
| **Outbound** | TCP | 443 | 0.0.0.0/0 | HTTPS（yum パッケージダウンロード） |

### 4.2 IAM 設計

#### Bastion EC2 IAM ロール

**ロール名**: `dev-bastion-role`

**信頼関係**: EC2 サービスプリンシパル
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**アタッチ済み管理ポリシー**:
- `AmazonSSMManagedInstanceCore` - Systems Manager Session Manager 機能提供

**ポリシー内容**（AWS 管理ポリシー）:
- `ssm:UpdateInstanceInformation` - SSM エージェント登録
- `ssm:ListAssociations` - 設定情報取得
- `ssm:ListInstanceAssociations` - インスタンス設定確認
- `ssm:GetDocument` - SSM ドキュメント取得
- `ssm:DescribeDocument` - ドキュメント説明取得
- `ec2messages:AcknowledgeMessage` - EC2 メッセージ確認
- `ec2messages:DeleteMessage` - EC2 メッセージ削除
- `ec2messages:FailMessage` - EC2 メッセージ失敗報告
- `ec2messages:GetEndpoint` - エンドポイント取得
- `ec2messages:GetMessages` - メッセージ取得

### 4.3 アクセス方式

#### Session Manager 経由アクセス（推奨）

**特徴**:
- SSH キーペアが不要
- IAM ロールのみで認可
- CloudTrail ログに記録
- Session Manager Logs への送信対応

**アクセス方法**:
```bash
aws ssm start-session --target i-xxxxxxxxx
```

**ユースケース**:
- 開発者が Bastion に接続
- Bastion から RDS へ mysql コマンドで接続

---

## 5. RDS 設計

### 5.1 RDS インスタンス仕様

| 項目 | 値 | 理由 |
|------|-----|------|
| **DB エンジン** | MySQL | 汎用、広くサポート |
| **エンジンバージョン** | 8.0（最新） | 最新の安定版 |
| **DB インスタンスクラス** | db.t3.micro | 最小スペック、バースト性パフォーマンス |
| **ストレージ容量** | 20 GB | 最小サイズ |
| **ストレージタイプ** | gp3 | 最新の汎用ストレージ、価格競争力 |
| **ストレージ IOPS** | 3000（デフォルト） | gp3 デフォルト IOPS |
| **Multi-AZ** | false | dev 環境、コスト削減 |
| **バックアップ保持期間** | 0 日（無効） | dev 環境、コスト削減 |
| **暗号化** | true（AWS 管理キー） | デフォルト暗号化 |
| **自動マイナーバージョン更新** | true | セキュリティパッチ適用 |
| **削除時スナップショット** | スキップ | 本番ではない |
| **公開アクセス** | false | プライベートサブネット配置 |
| **IAM DB 認証** | 無効 | ユーザー名/パスワード認証使用 |

### 5.2 DB インスタンス詳細

| 項目 | 値 |
|------|-----|
| **DB インスタンス識別子** | `dev-mysql-db` |
| **リージョン** | ap-northeast-1 |
| **アベイラビリティゾーン** | ap-northeast-1a（単一 AZ） |
| **DB Subnet Group** | `dev-rds-db-subnet-group` |

### 5.3 データベース設定

| 項目 | 値 |
|------|-----|
| **初期データベース名** | `app` |
| **マスターユーザー名** | `app` |
| **マスターパスワード** | terraform.tfvars で管理（8文字以上） |
| **デフォルトポート** | `3306` |
| **文字セット** | `utf8mb4`（MySQL 8.0 デフォルト） |
| **DB パラメータグループ** | `default.mysql8.0` |
| **DB オプショングループ** | `default:mysql8.0` |

### 5.4 DB Subnet Group

| 項目 | 値 |
|------|-----|
| **名前** | `dev-rds-db-subnet-group` |
| **説明** | "DB subnet group for RDS MySQL in dev environment" |
| **サブネット** | プライベートサブネット 2 つ（1a, 1c） |
| **アベイラビリティゾーン** | ap-northeast-1a, ap-northeast-1c |

---

## 6. EC2 Bastion 設計

### 6.1 EC2 インスタンス仕様

| 項目 | 値 | 理由 |
|------|-----|------|
| **AMI** | Amazon Linux 2（最新） | 軽量、AWS サポート充実、無料枠対応 |
| **インスタンスタイプ** | t3.micro | 最小スペック、バースト性パフォーマンス |
| **EBS ボリューム** | 20 GB gp3 | 汎用ストレージ |
| **ネットワーク** | パブリックサブネット配置 | Internet Gateway 経由アクセス |
| **パブリック IP** | 自動割り当て（必要に応じ） | Session Manager 接続用 |
| **IAM ロール** | `dev-bastion-role` | Systems Manager Session Manager 権限 |
| **詳細モニタリング** | 基本（CloudWatch） | デフォルトメトリクス収集 |

### 6.2 EC2 インスタンス詳細

| 項目 | 値 |
|------|-----|
| **インスタンス名（タグ）** | `dev-bastion` |
| **アベイラビリティゾーン** | ap-northeast-1a |
| **VPC** | `udemy-aws-container-vpc` |
| **セキュリティグループ** | `dev-bastion-sg` |

### 6.3 ユーザーデータ処理

**実行内容**:

1. **システムパッケージ更新**
   ```bash
   yum update -y
   ```

2. **MySQL クライアントインストール**
   ```bash
   yum install -y mysql
   ```
   - RDS への接続ツール提供
   - SQL 実行可能

3. **SSM エージェント確認・起動**
   ```bash
   systemctl enable amazon-ssm-agent
   systemctl start amazon-ssm-agent
   ```
   - Amazon Linux 2 では事前インストール
   - Session Manager アクセス有効化

4. **ログ出力**
   ```bash
   echo "Bastion host initialized at $(date)" >> /var/log/user-data.log
   ```

---

## 7. アクセス方式

### 7.1 RDS アクセスフロー

```
ローカル開発マシン
    ↓ AWS CLI / AWS Management Console
    ↓ IAM 認証
Session Manager
    ↓ (ポート 443 HTTPS)
Bastion EC2 (Session)
    ↓ (ポート 3306 TCP)
RDS MySQL
    ↓
Application Database
```

### 7.2 接続手順

**1. Session Manager 経由 Bastion へ接続**

```bash
aws ssm start-session --target i-xxxxxxxxx
```

**2. Bastion 内から RDS へ接続**

```bash
mysql -h dev-mysql-db.xxxxxxxxx.ap-northeast-1.rds.amazonaws.com \
       -u app \
       -p \
       app
```

**3. ローカルからのポートフォワード接続（オプション）**

```bash
aws ssm start-session --target i-xxxxxxxxx \
    --document-name AWS-StartPortForwardingSession \
    --parameters "localPortNumber=3306,portNumber=3306,host=dev-mysql-db.xxxxxxxxx.ap-northeast-1.rds.amazonaws.com"
```

その後、ローカルホストから接続：
```bash
mysql -h 127.0.0.1 -P 3306 -u app -p app
```

### 7.3 アプリケーション接続

同一 VPC 内のアプリケーション（ECS など）:

```
Connection String:
mysql://app:secret@dev-mysql-db.xxxxxxxxx.ap-northeast-1.rds.amazonaws.com:3306/app
```

---

## 8. コスト概算（月額）

| リソース | スペック | 時間単価 | 月額（730 時間） |
|---------|---------|---------|----------------|
| **RDS（db.t3.micro）** | 1 vCPU, 1 GB RAM | $0.0116 | ~$8.47 |
| **RDS ストレージ（gp3）** | 20 GB | $0.115/GB | $2.30 |
| **EC2（t3.micro）** | 1 vCPU, 1 GB RAM | $0.0104 | ~$7.59 |
| **EBS ボリューム（gp3）** | 20 GB | $0.10/GB | $2.00 |
| **その他（データ転送等）** | - | - | ~$1.00 |
| **合計** | - | - | ~**$21.36** |

※ AWS フリーティア対象リソースの場合、実質無料になる可能性あり

---

## 9. セキュリティベストプラクティス

### 9.1 実施事項

- ✅ RDS をプライベートサブネットに配置
- ✅ Bastion ホストを経由したアクセス
- ✅ セキュリティグループで最小権限アクセス
- ✅ Session Manager で SSH キー不要
- ✅ IAM ロールで認可管理
- ✅ ストレージ暗号化（AWS 管理キー）
- ✅ パスワードは terraform.tfvars で管理
- ✅ 本番ではないため、バックアップ無効

### 9.2 本番環境での改善（将来）

- [ ] Multi-AZ 有効化
- [ ] バックアップ保持期間設定（7〜30日）
- [ ] CloudWatch ログ監視
- [ ] slow query ログ有効化
- [ ] 顧客マネージド KMS キー使用
- [ ] IAM DB 認証有効化
- [ ] Enhanced Monitoring 有効化
- [ ] Read Replica 検討

---

## 10. トラブルシューティング

### 10.1 Session Manager 接続できない

**原因**: IAM ロール権限不足、VPC エンドポイント未設定

**対応**:
- IAM ロール `dev-bastion-role` に `AmazonSSMManagedInstanceCore` が アタッチ されているか確認
- VPC エンドポイント設定確認（`shared/modules/vpc-endpoints` 参照）
- セキュリティグループアウトバウンド TCP 443 許可確認

### 10.2 RDS 接続できない

**原因**: セキュリティグループ設定、パスワード誤入力

**対応**:
- Bastion セキュリティグループが RDS セキュリティグループへの 3306 アクセス許可確認
- RDS セキュリティグループが Bastion SG からの 3306 インバウンド許可確認
- パスワード確認（terraform.tfvars 参照）
- RDS が起動完了まで待機（数分要する）

---

## 11. ファイル参照

実装詳細は以下を参照：
- **実装仕様書**: `shared/modules/SPECIFICATION.md`
- **RDS モジュール**: `shared/modules/rds/` (実装予定)
- **Bastion モジュール**: `shared/modules/bastion/` (実装予定)
- **環境設定**: `shared/environment/dev/` (実装予定)
