import { GetObjectCommand, PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import type { S3Event, S3Handler } from "aws-lambda";
import { Jimp } from "jimp";

// 接続の張り直しを避けるため、S3 クライアントは Lambda 実行間で使い回す。
const s3 = new S3Client({});

// Terraform から注入された実行時設定を読み込む。
const sourceBucketName = process.env.SOURCE_BUCKET_NAME;
const inputPrefix = normalizePrefix(process.env.INPUT_PREFIX ?? "uploads/");
const outputPrefix = normalizePrefix(process.env.OUTPUT_PREFIX ?? "grayscale/");

// この関数内で安全に再エンコードできる画像形式だけを扱う。
type SupportedMimeType = "image/jpeg" | "image/png";

const SUPPORTED_MIME_TYPES = new Set<SupportedMimeType>(["image/jpeg", "image/png"]);
const EXTENSION_TO_MIME: Record<string, SupportedMimeType> = {
  ".jpeg": "image/jpeg",
  ".jpg": "image/jpeg",
  ".png": "image/png",
};

export const handler: S3Handler = async (event: S3Event) => {
  // デプロイ設定が不足している場合はすぐに失敗させる。
  if (!sourceBucketName) {
    throw new Error("SOURCE_BUCKET_NAME environment variable is required.");
  }

  for (const record of event.Records) {
    // S3 イベントに含まれるオブジェクトキーをデコードする。
    const sourceKey = decodeS3Key(record.s3.object.key);

    // 設定されたアップロード用 prefix 外のオブジェクトは無視する。
    if (!sourceKey.startsWith(inputPrefix)) {
      console.log(`Skipping object outside input prefix: ${sourceKey}`);
      continue;
    }

    // uploads/ より下の相対パスを保ったまま出力先キーを組み立てる。
    const relativeKey = sourceKey.slice(inputPrefix.length);
    if (!relativeKey) {
      console.log(`Skipping prefix placeholder object: ${sourceKey}`);
      continue;
    }

    const outputKey = `${outputPrefix}${relativeKey}`;

    // 同じ処理を再度引き起こす可能性があるキーは防御的にスキップする。
    if (sourceKey === outputKey || sourceKey.startsWith(outputPrefix)) {
      console.log(`Skipping object to avoid recursive processing: ${sourceKey}`);
      continue;
    }

    // 元画像を S3 から取得する。
    const getObjectResponse = await s3.send(
      new GetObjectCommand({
        Bucket: sourceBucketName,
        Key: sourceKey,
      }),
    );

    if (!getObjectResponse.Body) {
      throw new Error(`S3 object body was empty for key: ${sourceKey}`);
    }

    // この関数でデコード・再エンコードできる画像形式だけを処理対象にする。
    const mimeType = resolveMimeType(sourceKey, getObjectResponse.ContentType);
    if (!mimeType) {
      console.log(`Skipping unsupported image type for key: ${sourceKey}`);
      continue;
    }

    // S3 のレスポンスを Buffer に変換し、Jimp で白黒画像へ変換する。
    const sourceBuffer = await streamToBuffer(getObjectResponse.Body);
    const image = await Jimp.read(sourceBuffer);
    image.greyscale();

    // 変換済み画像を出力形式に合わせて再エンコードする。
    const grayscaleBuffer = await image.getBuffer(mimeType);

    // 白黒化した画像を同じバケット内の出力 prefix に保存する。
    await s3.send(
      new PutObjectCommand({
        Bucket: sourceBucketName,
        Key: outputKey,
        Body: grayscaleBuffer,
        ContentType: mimeType,
      }),
    );

    console.log(`Saved grayscale image: ${outputKey}`);
  }
};

// prefix を "xxx/" の形にそろえて、後続の比較を安定させる。
function normalizePrefix(prefix: string): string {
  const trimmedPrefix = prefix.trim().replace(/^\/+|\/+$/g, "");
  return `${trimmedPrefix}/`;
}

// S3 イベントのキーは URL エンコードされ、空白は "+" で表現される。
function decodeS3Key(encodedKey: string): string {
  return decodeURIComponent(encodedKey.replace(/\+/g, " "));
}

// Content-Type を優先し、取れない場合は拡張子から画像形式を判定する。
function resolveMimeType(key: string, contentType?: string): SupportedMimeType | null {
  if (contentType === "image/jpeg" || contentType === "image/png") {
    return contentType;
  }

  const extension = key.slice(Math.max(0, key.lastIndexOf("."))).toLowerCase();
  return EXTENSION_TO_MIME[extension] ?? null;
}

// SDK のレスポンスボディを、実行環境ごとの差異を吸収して Buffer に変換する。
async function streamToBuffer(stream: unknown): Promise<Buffer> {
  if (stream instanceof Uint8Array) {
    return Buffer.from(stream);
  }

  if (typeof stream === "string") {
    return Buffer.from(stream);
  }

  if (isBlobLike(stream)) {
    const bytes = await stream.transformToByteArray();
    return Buffer.from(bytes);
  }

  if (!isAsyncIterable(stream)) {
    throw new Error("Unsupported S3 object body type.");
  }

  const chunks: Uint8Array[] = [];
  for await (const chunk of stream) {
    chunks.push(typeof chunk === "string" ? Buffer.from(chunk) : Buffer.from(chunk));
  }

  return Buffer.concat(chunks);
}

// 一部実行環境で返る Blob 風オブジェクトかどうかを判定する。
function isBlobLike(
  value: unknown,
): value is {
  transformToByteArray: () => Promise<Uint8Array>;
} {
  return (
    typeof value === "object" &&
    value !== null &&
    "transformToByteArray" in value &&
    typeof value.transformToByteArray === "function"
  );
}

// S3 GetObject が返す Node.js 風の async iterable ストリームかを判定する。
function isAsyncIterable(value: unknown): value is AsyncIterable<Uint8Array | string> {
  return (
    typeof value === "object" &&
    value !== null &&
    Symbol.asyncIterator in value &&
    typeof value[Symbol.asyncIterator] === "function"
  );
}
