# Connect インスタンス作成時に自動生成されるデフォルトキューを参照する
data "aws_connect_queue" "default" {
  instance_id = aws_connect_instance.this.id
  name        = "BasicQueue"
}
