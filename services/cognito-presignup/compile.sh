#!/bin/bash

OUT_ZIP=$PWD/cognito-presignup.zip
(cd myvenv/lib/python3.8/site-packages && zip -r "$OUT_ZIP" .)
zip -g "$OUT_ZIP" lambda_function.py
