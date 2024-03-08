#!/bin/bash

# 定義 input 和 output 目錄
inputDir="/path/to/input"
outputDir="/path/to/output"

# 使用 inotifywait 監控 input 目錄下的所有檔案變化
/usr/bin/inotifywait -m -e create -e moved_to -r "$inputDir" --format '%w%f' |
    while read file; do
        # 檢查是否為壓縮檔（zip 或 rar）
        if [[ $file == *.zip ]] || [[ $file == *.rar ]]; then
            # 提取檔案名（不含路徑和擴展名）
            filename=$(basename "$file" .zip)
            filename=$(basename "$filename" .rar)
            # 創建解壓目標資料夾
            mkdir -p "$inputDir/$filename"
            
            # 根據檔案類型解壓檔案
            if [[ $file == *.zip ]]; then
                unzip -o "$file" -d "$inputDir/$filename"
            elif [[ $file == *.rar ]]; then
                unrar x "$file" "$inputDir/$filename"
            fi

            # 處理解壓後的所有圖片，轉換格式並移動到對應的 output 資料夾
            find "$inputDir/$filename" -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.tif -o -iname \*.tiff \) -exec sh -c '
                file="{}"
                outputFile="${file/$inputDir/$outputDir}"
                outputDir=$(dirname "$outputFile")
                mkdir -p "$outputDir"
                /path/to/nconvert -out png -o "$outputFile" "$file"
                if [ $? -eq 0 ]; then
                    echo "Converted $file into $outputFile OK"
                    # 刪除原始檔案
                    rm "$file"
                else
                    echo "Failed to convert $file"
                fi
            ' \;

            # 將處理後的資料夾重新壓縮
            pushd "$outputDir" > /dev/null
            zip -r "${filename}.zip" "$filename" > /dev/null
            popd > /dev/null

            # 刪除原始壓縮檔和解壓後的資料夾
            rm "$file"
            rm -r "$inputDir/$filename"
            echo "Processed and removed original compressed file $file"
        fi
    done
