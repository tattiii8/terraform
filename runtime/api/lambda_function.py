import json
import requests

def lambda_handler(event, context):
    # ──────────────────────────────────────────────────
    # 1. API Gateway 経由では event["body"] に JSON文字列 が入る
    # ──────────────────────────────────────────────────
    try:
        # event["body"] がある場合はそれを JSON へパース
        body = json.loads(event["body"])
    except Exception:
        # 単体テスト（Lambda コンソールから直接 event={"key1":"..." }）のケース
        body = event

    # ──────────────────────────────────────────────────
    # 2. body から key1 を取得（存在しなければ空文字などを使う）
    # ──────────────────────────────────────────────────
    key1_value = body.get("key1", "")

    # ──────────────────────────────────────────────────
    # 3. LINE へプッシュするメッセージを組み立て
    # ──────────────────────────────────────────────────
    resmessage = [
        {
            'type': 'text',
            'text': key1_value
        }
    ]
    payload = {
        'to': 'U76fa75ec9245bb347fb1957d2dbf14d9',
        'messages': resmessage
    }

    headers = {
        'content-type': 'application/json',
        'Authorization': 'Bearer QOVEq60NB8/dqOh+7rY+5/7msZt3eVrWGE4tONm2WkumOx+xYNzF4Szu57GJ7AvHHdWmybjmE5JhkgL5JVusGw+ttLFBAKdYfybXReL+kW+l4/GZDmy5bIePdvMVY0uwU11VRNdnzRbkCREZJb56+wdB04t89/1O/w1cDnyilFU='
    }

    r = requests.post(
        "https://api.line.me/v2/bot/message/push",
        headers=headers,
        data=json.dumps(payload)
    )
    print("LINE Response:", r.status_code, r.text)

    # ──────────────────────────────────────────────────
    # 4. API Gateway Proxy Integration 向けに返却形式を整形
    # ──────────────────────────────────────────────────
    return {
        "statusCode": 200,
        "body": json.dumps("Complete")
    }
