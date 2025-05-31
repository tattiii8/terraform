import json
import requests
from pprint import pprint

def lambda_handler(event, context):
    #===========================
    # LINEへのPUSHメッセージ作成
    #===========================
    resmessage = [
        {'type':'text','text':event["key1"]}
    ]
    payload = {'to': 'ユーザーID', 'messages': resmessage}
    # カスタムヘッダーの生成(dict形式)
    headers = {'content-type': 'application/json', 'Authorization': 'Bearer <チャネルアクセストークン>'}
    # headersにカスタムヘッダーを指定
    r = requests.post("https://api.line.me/v2/bot/message/push", headers=headers, data=json.dumps(payload))
    print("LINEレスポンス:" + r.text)
    return "送信完了"