import json
import os

import boto3

connect = boto3.client("connect")


def handler(event, context):
    """Amazon Connect のアウトバウンド発信をトリガーする。

    JSON ボディを想定: {"phone_number": "+819012345678"}
    """
    try:
        body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return _response(400, {"message": "invalid JSON body"})

    phone_number = body.get("phone_number")
    if not phone_number:
        return _response(400, {"message": "phone_number is required"})

    kwargs = {
        "DestinationPhoneNumber": phone_number,
        "ContactFlowId": os.environ["CONTACT_FLOW_ID"],
        "InstanceId": os.environ["INSTANCE_ID"],
        "QueueId": os.environ["QUEUE_ID"],
    }
    source_phone_number = os.environ.get("SOURCE_PHONE_NUMBER")
    if source_phone_number:
        kwargs["SourcePhoneNumber"] = source_phone_number

    try:
        result = connect.start_outbound_voice_contact(**kwargs)
    except Exception as exc:  # noqa: BLE001 - Connect API のエラーはそのまま呼び出し元へ返す
        return _response(500, {"message": str(exc)})

    return _response(200, {"contact_id": result["ContactId"]})


def _response(status_code, payload):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(payload),
    }
