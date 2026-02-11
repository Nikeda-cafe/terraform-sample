# Terraform プロジェクト概要

このリポジトリは、環境（`dev` / `prod`）ごとに Terraform のルートモジュールを分け、共通部品を `modules/` 配下の再利用可能なモジュールとして管理する構成です。

## ディレクトリ構成

- **`environment/`**: 環境ごとのルートモジュール（ここで `terraform init/plan/apply` を実行）
  - **`environment/dev/`**: 開発環境
  - **`environment/prod/`**: 本番環境
- **`modules/`**: 環境から呼び出す子モジュール
  - **`modules/vpc/`**: VPC 作成
  - **`modules/ec2/`**: EC2 作成
  - **`modules/cloudfront/`**: CloudFront Distribution 作成

## 基本的な実行方法（dev の例）

`prod` でも同様に、ディレクトリを `environment/prod` に読み替えて実行します。

### 1) ディレクトリ移動

```bash
cd /Users/ikedanaoto/projects/terraform/environment/dev
```

### 2) 初期化（必須）

```bash
terraform init
```

このプロジェクトは `backend.tf` で S3 backend を使っています（例: `dev/terraform.tfstate`）。

### 3) 変更内容の確認（plan）

```bash
terraform plan
```

実リソースは作られず、「作成/変更/削除される予定」が表示されます。

### 4) 反映（apply）

```bash
terraform apply
```

### 5) 削除（destroy）

```bash
terraform destroy
```

## 環境側（ルートモジュール）の考え方

`environment/dev/main.tf`（および `prod/main.tf`）で、必要なモジュールを `module` ブロックとして呼び出します。

- `dev` では `vpc` / `ec2` / `cloudfront` を呼び出す構成になっています
- `cloudfront` は `origin_domain_name`（オリジンの DNS 名）を引数として受け取ります

## CloudFront モジュールの概要（`modules/cloudfront`）

`modules/cloudfront/main.tf` は `aws_cloudfront_distribution` を作成します。現状のデフォルトは「静的寄りの配信」を意識した設定です。

- **HTTPS 強制**: `viewer_protocol_policy = "redirect-to-https"`
- **オリジン接続は HTTPS のみ**: `origin_protocol_policy = "https-only"`
- **クエリ文字列と Cookie を転送しない**: `query_string = false` / `cookies.forward = "none"`
  - キャッシュが効きやすくなりやすい一方、クエリ/Cookie で内容が変わるアプリ/API には不向きです
- **証明書**: `cloudfront_default_certificate = true`（`*.cloudfront.net` 用）
  - 独自ドメインを使う場合は、ACM 証明書・`aliases` 等の追加設定が必要です

### 主な変数（`modules/cloudfront/variables.tf`）

- **`origin_domain_name`（必須）**: 配信元（ALB 等）の DNS 名
- **`default_root_object`（任意）**: 既定 `index.html`
- `env`, `prefix`: タグ/命名用

### 主な出力（`modules/cloudfront/outputs.tf`）

- `distribution_id`, `distribution_arn`
- `domain_name`（例: `dxxxx.cloudfront.net`）
- `hosted_zone_id`（Route 53 の Alias で利用）

## よくある注意点

- `plan` で差分確認してから `apply` するのが安全です
- `origin_domain_name` の `example.com` は仮値なので、実際のオリジンに置き換えてください

