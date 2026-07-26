# sandbox ディレクトリ構成メモ

このディレクトリには、**S3 に画像をアップロードしたら Lambda で白黒化して同じバケットの別 prefix に保存する** 実験用構成を置いています。

## 全体像

```text
sandbox/
├── environment/dev/                 # Terraform の dev ルートモジュール
├── modules/s3-image-grayscale/      # S3 + Lambda + 通知の Terraform モジュール
└── lambda/s3-image-grayscale/       # Lambda の TypeScript 実装
```

処理の流れは次のとおりです。

1. S3 バケットの `uploads/` 配下に画像をアップロードする
2. S3 イベント通知で Lambda が起動する
3. Lambda が画像を取得して白黒化する
4. 同じバケットの `grayscale/` 配下に変換後画像を保存する

`uploads/` と `grayscale/` を分けることで、変換後ファイル保存時の再帰実行を防いでいます。

## environment/dev

`sandbox/environment/dev/` は、この sandbox をデプロイするための Terraform ルートです。

| ファイル | 役割 |
| --- | --- |
| `backend.tf` | Terraform state を S3 backend (`sandbox/dev/terraform.tfstate`) に保存します。 |
| `provider.tf` | AWS provider と default tags を定義します。 |
| `variables.tf` | prefix、S3 prefix、Lambda メモリ・タイムアウトなどの入力変数を定義します。 |
| `terraform.tfvars` | dev 環境で使う実値を設定します。 |
| `main.tf` | `../../modules/s3-image-grayscale` を呼び出し、Lambda のビルド成果物パスもここで渡します。 |
| `outputs.tf` | 作成されたバケット名、Lambda 名、入力/出力 prefix を確認できるようにします。 |
| `.terraform.lock.hcl` | `aws` と `archive` provider の lock file です。 |

### `main.tf` のポイント

- `lambda_dist_file` として `sandbox/lambda/s3-image-grayscale/dist/index.js` を参照します
- `lambda_zip_path` として `sandbox/environment/dev/s3-image-grayscale.zip` を生成対象にします
- Terraform ルート自身はリソースを直接持たず、モジュール呼び出しに寄せています

## modules/s3-image-grayscale

`sandbox/modules/s3-image-grayscale/` は、S3 と Lambda の連携一式をまとめた Terraform モジュールです。

| ファイル | 役割 |
| --- | --- |
| `main.tf` | AWS リソース本体を定義します。 |
| `variables.tf` | モジュール入力値を定義します。 |
| `outputs.tf` | バケット名、Lambda 名、監視 prefix などを外へ返します。 |

### `main.tf` で作っているもの

- S3 バケット
  - 画像アップロード先と白黒画像保存先を兼ねる単一バケット
  - Public Access Block、有効化された Versioning、AES256 のサーバーサイド暗号化付き
- Lambda 実行 IAM
  - CloudWatch Logs 出力
  - バケット内オブジェクトの `GetObject` / `PutObject`
- CloudWatch Logs
  - Lambda 用ロググループ
- Lambda 関数
  - `archive_file` で `dist/index.js` を zip 化してデプロイ
  - 環境変数で `SOURCE_BUCKET_NAME`、`INPUT_PREFIX`、`OUTPUT_PREFIX` を渡す
- S3 通知
  - `uploads/` のような入力 prefix に対してだけ `s3:ObjectCreated:*` をトリガー
  - `input_prefix` と `output_prefix` が同じ場合は precondition で弾く

### バケット名の付け方

バケット名は次の要素を組み合わせて生成しています。

- `prefix`
- `bucket_name_suffix`
- AWS アカウント ID

これにより、S3 のグローバル一意制約に引っかかりにくくしています。

## lambda/s3-image-grayscale

`sandbox/lambda/s3-image-grayscale/` は Lambda のアプリケーションコードです。

| ファイル | 役割 |
| --- | --- |
| `package.json` | 依存関係と build/typecheck スクリプトを定義します。 |
| `package-lock.json` | npm lock file です。 |
| `tsconfig.json` | TypeScript のコンパイル設定です。 |
| `src/index.ts` | Lambda ハンドラ本体です。 |
| `dist/index.js` | `npm run build` で生成される bundle 済みファイルです。Terraform はこれを zip 化します。 |

### `src/index.ts` の中身

主な処理は次のとおりです。

1. S3 イベントからアップロードされたオブジェクトキーを取得
2. `uploads/` 配下かを確認し、対象外ならスキップ
3. S3 から元画像を取得
4. `Jimp` で JPEG / PNG を白黒化
5. `grayscale/` 配下へ保存

補助関数も入れています。

- `normalizePrefix`  
  prefix の先頭・末尾スラッシュを整えます
- `decodeS3Key`  
  S3 イベントのキーをデコードします
- `resolveMimeType`  
  Content-Type または拡張子から JPEG / PNG を判定します
- `streamToBuffer`  
  S3 `GetObject` の Body を `Buffer` に変換します

## ビルドとデプロイ

### Lambda を再ビルドする

```bash
cd sandbox/lambda/s3-image-grayscale
npm run build
```

TypeScript の型チェックも行う場合:

```bash
npm run typecheck
```

### Terraform を確認する

```bash
cd sandbox/environment/dev
terraform init -backend=false
terraform validate
terraform plan
```

## 運用上の注意

- 現在サポートしている画像形式は **JPEG / PNG** です
- S3 通知は input prefix にだけかかるため、`grayscale/` に保存された画像では再度 Lambda は起動しません
- Lambda の TypeScript を変更したら、`terraform plan/apply` の前に `npm run build` を実行してください
