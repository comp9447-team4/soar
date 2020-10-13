#!/bin/bash
token="${TOKEN}"
for (( ; ; )); do \
curl 'https://6jztqidvd6.execute-api.us-east-1.amazonaws.com/qa/mysfits/33e1fbd4-2fd8-45fb-a42f-f92551694506/like' \
  -X 'POST' \
  -H "authorization: ${token}" \
  --compressed; \
done
