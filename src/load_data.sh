#!/bin/bash

OUTPUT_DIR="./data"
OUTPUT_FILE="$OUTPUT_DIR/the-lj-speech-dataset.zip"
DATASET_DIR="${OUTPUT_DIR}/LJSpeech-1.1"

if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p "$OUTPUT_DIR"
fi

if [ -d "$DATASET_DIR" ]; then
  echo "Dataset already exists: $DATASET_DIR"
  exit 0
fi

curl -L -o "$OUTPUT_FILE"\
  https://www.kaggle.com/api/v1/datasets/download/mathurinache/the-lj-speech-dataset

unzip "$OUTPUT_FILE" -d "./data/"

rm "$OUTPUT_FILE"
