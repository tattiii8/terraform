import json
import requests
import os  # 環境変数を使うために必要

def lambda_handler(event, context):
    try:
        body = json.loads(event["body"])
    except Exception:
        body = event

    message_value = body.get("message", "")

    resmessage = [
        {
            'type': 'text',
            'text': message_value
        }
    ]
    payload = {
        'messages': resmessage
    }

    # トークンを環境変数から取得
    line_token = os.environ.get("LINE_CHANNEL_ACCESS_TOKEN", "")

    headers = {
        'content-type': 'application/json',
        'Authorization': f'Bearer {line_token}'
    }

    r = requests.post(
        "https://api.line.me/v2/bot/message/broadcast",
        headers=headers,
        data=json.dumps(payload)
    )
    print("LINE Response:", r.status_code, r.text)

    return {
        "statusCode": 200,
        "body": json.dumps("Complete")
    }

    
