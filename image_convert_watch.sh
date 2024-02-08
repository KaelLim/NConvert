#!/bin/bash

# 定義 input 和 output 目錄
inputDir="/path/to/input"
outputDir="/path/to/output"

# 使用 inotifywait 監控 input 目錄下的所有檔案變化
/usr/bin/inotifywait -m -e create -e moved_to -r "$inputDir" --format '%w%f' |
    while read file; do
        # 提取檔案名（不含路徑）
        filename=$(basename "$file")
        # 設定輸出檔案的路徑和名稱（更改擴展名為 .png）
        outputFile="$outputDir/${filename%.*}.png"
        # 使用 NConvert 進行格式轉換，將圖片轉換為 PNG 格式
        /path/to/nconvert -out png -o "$outputFile" "$file"
        if [ $? -eq 0 ]; then
            echo "Conversion of $file into $outputFile OK"
            # 如果轉檔成功，刪除原始檔案
            rm "$file"
            echo "Deleted original file $file"
        else
            echo "Failed to convert $file"
        fi
    done
