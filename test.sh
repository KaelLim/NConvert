#!/bin/bash

# 定義 input 和 output 目錄
inputDir="/usr/local/sbin/NConvert/input"
outputDir="/usr/local/sbin/NConvert/output"

# 使用 inotifywait 監控 input 目錄下的所有檔案變化
/usr/bin/inotifywait -m -e create -e moved_to -r "$inputDir" --format '%w%f' |
    while read file; do
        # 檢查是否為 tar 壓縮檔（包括 .tar, .tar.gz, .tgz, .tar.bz2）
        if [[ $file == *.tar ]] || [[ $file == *.tar.gz ]] || [[ $file == *.tgz ]] || [[ $file == *.tar.bz2 ]]; then
            # 提取檔案名（不含路徑和擴展名）
            dirname=$(basename "$file" .tar)
            dirname=$(basename "$dirname" .tar.gz)
            dirname=$(basename "$dirname" .tgz)
            dirname=$(basename "$dirname" .tar.bz2)
            # 創建解壓目標資料夾
            mkdir -p "$inputDir/$dirname"
            
            # 解壓 tar 壓縮檔
            tar -xf "$file" -C "$inputDir/$dirname"

            # 處理解壓後的所有圖片，轉換格式並移動到對應的 output 資料夾
            find "$inputDir/$dirname" -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.tif -o -iname \*.tiff \) -exec sh -c '
                file="{}"
                outputFile="${file/$inputDir/$outputDir}"
                outputDir=$(dirname "$outputFile")
                mkdir -p "$outputDir"
                # 請確保已經正確設定了 nconvert 的路徑
                /usr/local/sbin/NConvert/nconvert -out png -o "$outputFile" "$file"
                if [ $? -eq 0 ]; then
                    echo "Converted $file into $outputFile OK"
                    # 刪除原始檔案
                    rm "$file"
                else
                    echo "Failed to convert $file"
                fi
            ' \;

            # 轉換完成後，將 output 目錄下的資料夾重新壓縮為 tar.gz
            pushd "$outputDir" > /dev/null
            tar -czf "${dirname}.tar.gz" "$dirname"
            popd > /dev/null

            # 刪除原始壓縮檔和解壓後的資料夾
            rm "$file"
            rm -r "$inputDir/$dirname"
            echo "Processed and removed original compressed file $file and its extracted contents"
        fi
    done
