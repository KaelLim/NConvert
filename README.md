# NConvert

## 簡介
`image_convert_watch.sh` 是一個自動監控指定目錄下的圖片檔案變化，並將圖片自動轉換為 PNG 格式的 Bash 腳本。當新的圖片檔案被添加到輸入目錄時，腳本會自動進行格式轉換並將結果保存到輸出目錄，轉換成功後原始檔案將被刪除。

## 環境部署條件
- Linux 操作系統
- Bash shell 環境
- `inotify-tools` 套件：用於實時監控檔案系統事件。
- `NConvert` 工具：用於進行圖片格式轉換。

## 安裝所需套件
### 安裝 inotify-tools
在基於 Debian 的系統上：
```bash
sudo yum install epel-release -y
sudo yum install inotify-tools -y
```
### 安裝 NConvert
訪問[NConvert 官網](https://www.xnview.com/en/nconvert/) 下載適用於 Linux 的 NConvert 壓縮包，並解壓到適當目錄。

## 使用說明
1. 編輯 image_convert_watch.sh，設置 inputDir 和 outputDir 變數為你希望監控的目錄和存儲轉換後圖片的目錄路徑。
2. 確保腳本中的 NConvert 路徑指向你解壓的 NConvert 執行檔路徑。
3. 給予腳本執行權限：
```bash
chmod +x image_convert_watch.sh
```
4. 執行腳本開始監控和轉換工作：
```bash
./image_convert_watch.sh
```
