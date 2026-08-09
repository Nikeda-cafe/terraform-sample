# Amazon Connect アプリケーション (PoC)

Amazon Connect で「システムから電話番号に発信し、通話の録音データを取得する」ことを
検証するための最小構成です。本番運用は想定していません。

## できること

1. 外部システムから API Gateway のエンドポイントに電話番号を POST する
2. Lambda が Amazon Connect の `StartOutboundVoiceContact` を呼び出し、指定した番号に発信する
3. コンタクトフローが通話の録音を開始し、テストメッセージを再生後に切断する
4. 通話終了後、録音データ（音声ファイル）が S3 バケットに保存される

## 今回のスコープ外（次フェーズ）

- Contact Lens による文字起こし（追加課金が発生するため今回は無効）
- S3 に保存された録音データ・文字起こしデータを外部システム API へ自動連携（PUSH）する仕組み
  - 今回は S3 への保存確認までを対象とする
- カスタムキュー・ルーティングプロファイル（デフォルトの `BasicQueue` を使用）
- 発信先電話番号を DB から動的取得する仕組み（今回は API リクエストのパラメータで直接指定）

## 構成

```
connect-app/
├── modules/
│   ├── connect/                  # Connectインスタンス・電話番号・録音用S3・コンタクトフロー
│   └── connect-api/               # 発信トリガー用 Lambda + API Gateway (HTTP API)
└── environment/
    └── dev/                       # 検証環境の呼び出しコード
```

- state は他サービスと同様 S3 backend を使用（`connect-app/dev/terraform.tfstate`）
- provider は `hashicorp/aws` 6.30.0 系に統一

## 事前準備

1. `connect-app/environment/dev/terraform.tfvars.example` を `terraform.tfvars` にコピーし、
   `connect_instance_alias` を一意な値に変更する（Connect インスタンスのエイリアスは
   AWS アカウント内でグローバルに一意である必要があります）

   ```bash
   cd connect-app/environment/dev
   cp terraform.tfvars.example terraform.tfvars
   # connect_instance_alias を編集
   ```

2. 電話番号の国コード（`connect_phone_number_country_code`）はデフォルト `US` です。
   日本国内番号（JP）は AWS アカウント・リージョンによって対応していない場合があるため、
   `apply` 前に AWS マネジメントコンソールの Connect > 電話番号 の請求可能な番号種別を確認してください。
   非対応の場合は `US` 等のまま検証してください。

## デプロイ手順

```bash
cd connect-app/environment/dev
terraform init
terraform plan
terraform apply
```

適用後、以下の output が出力されます。

- `connect_instance_id`: Connect インスタンス ID
- `connect_phone_number`: 発信元として claim された電話番号
- `connect_recording_bucket_name`: 録音データ保存先の S3 バケット名
- `outbound_call_api_endpoint`: 発信をトリガーする API のフルURL

## 動作確認（発信テスト）

```bash
curl -X POST "$(terraform output -raw outbound_call_api_endpoint)" \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+819012345678"}'
```

- `phone_number` は自分の携帯電話番号（E.164形式）を指定してテストしてください
- 着信後、コンタクトフローによりテストメッセージが再生されます
- 通話終了後、`connect_recording_bucket_name` の S3 バケットに `recordings/` プレフィックスで
  録音ファイル（.wav）が保存されていることを確認してください

## 注意事項（コスト）

- Amazon Connect の電話番号は **保持しているだけで課金が発生** します
- 検証が完了したら、忘れずに以下を実行してリソースを削除してください

```bash
cd connect-app/environment/dev
terraform destroy
```

- S3 バケットにデータが残っている場合、`terraform destroy` が失敗することがあります。
  その場合は先にバケット内のオブジェクトを空にしてから再実行してください。

  ```bash
  aws s3 rm s3://<connect_recording_bucket_name> --recursive
  terraform destroy
  ```
