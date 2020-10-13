#!/bin/bash
token="${TOKEN}"
url="${URL}"
for (( ; ; )); do \
curl "${url}" \
  -X 'POST' \
  -H "authorization: ${token}" \
  --compressed; \
done
