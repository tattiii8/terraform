import json
import requests
from pprint import pprint

def lambda_handler(event, context):
    #===========================
    # Create Push Message to Line
    #===========================
    resmessage = [
        {'type':'text','text':event["key1"]}
    ]
    payload = {'to': 'U76fa75ec9245bb347fb1957d2dbf14d9', 'messages': resmessage}
    # カスタムヘッダーの生成(dict形式)
    headers = {'content-type': 'application/json', 'Authorization': 'Bearer QOVEq60NB8/dqOh+7rY+5/7msZt3eVrWGE4tONm2WkumOx+xYNzF4Szu57GJ7AvHHdWmybjmE5JhkgL5JVusGw+ttLFBAKdYfybXReL+kW+l4/GZDmy5bIePdvMVY0uwU11VRNdnzRbkCREZJb56+wdB04t89/1O/w1cDnyilFU='}
    # headersにカスタムヘッダーを指定
    r = requests.post("https://api.line.me/v2/bot/message/push", headers=headers, data=json.dumps(payload))
    print("LINE Response:" + r.text)
    return "Complete"