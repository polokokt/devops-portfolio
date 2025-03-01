#!/bin/bash

ZIP_FILE="lambda_function.zip"

zip "$ZIP_FILE" lambda_function.py

unzip -l "$ZIP_FILE"