from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from openai import OpenAI
import os
from dotenv import load_dotenv
import base64
import firebase_admin
from firebase_admin import credentials, storage
import tempfile
from datetime import datetime

# 載入環境變數
load_dotenv()

# 檢查 API 金鑰是否正確載入
api_key = os.getenv("OPENAI_API_KEY")
if not api_key:
    print("警告：OPENAI_API_KEY 未設定！")
    print("請確保在 backend/.env 檔案中設定了 OPENAI_API_KEY")
else:
    print("API 金鑰已成功載入")

# 初始化 Firebase
cred = credentials.Certificate("firebase-credentials.json")
firebase_admin.initialize_app(cred, {
    'storageBucket': 'toefl-90-days.firebasestorage.app'  # 使用你的 Firebase 專案 ID
})

# 測試 Storage 連接
try:
    bucket = storage.bucket()
    print("Firebase Storage 連接成功")
    # 列出所有可用的 buckets
    buckets = list(storage.bucket().list_blobs())
    print(f"當前 bucket 中的檔案數量: {len(buckets)}")
except Exception as e:
    print(f"Firebase Storage 連接失敗: {str(e)}")
    print("請確認：")
    print("1. Firebase Console 中已啟用 Storage")
    print("2. 專案 ID 是否正確")
    print("3. firebase-credentials.json 是否正確")
    print("4. 是否已在 Firebase Console 中建立 Storage bucket")

app = FastAPI()

# 設定 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 在生產環境中應該設定具體的域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 初始化 OpenAI 客戶端
client = OpenAI(api_key=api_key)

class ImageRequest(BaseModel):
    prompt: str
    word: str  # 添加單字參數，用於檔案命名

@app.post("/generate-image")
async def generate_image(request: ImageRequest):
    try:
        if not api_key:
            raise HTTPException(status_code=500, detail="OpenAI API key not configured")
            
        print(f"開始生成圖片，單字: {request.word}")
        result = client.images.generate(
            model="gpt-image-1",
            prompt=request.prompt
        )
        print("圖片生成成功")
        
        # 獲取 base64 圖片數據
        image_base64 = result.data[0].b64_json
        print("成功獲取 base64 圖片數據")
        
        # 將 base64 轉換為圖片檔案
        image_data = base64.b64decode(image_base64)
        print("成功將 base64 轉換為圖片數據")
        
        # 建立臨時檔案
        with tempfile.NamedTemporaryFile(delete=False, suffix='.png') as temp_file:
            temp_file.write(image_data)
            temp_file_path = temp_file.name
        print(f"成功建立臨時檔案: {temp_file_path}")
        
        try:
            # 上傳到 Firebase Storage
            bucket = storage.bucket()
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            blob_name = f"word_images/{request.word}_{timestamp}.png"
            print(f"準備上傳檔案到: {blob_name}")
            
            blob = bucket.blob(blob_name)
            print("成功建立 blob 物件")
            
            # 上傳檔案
            blob.upload_from_filename(temp_file_path)
            print("成功上傳檔案")
            
            # 設定公開存取權限
            blob.make_public()
            print("成功設定公開存取權限")
            
            # 獲取下載 URL
            download_url = blob.public_url
            print(f"成功獲取下載 URL: {download_url}")
            
            return {
                "image_url": download_url,
                "message": "Image generated and uploaded successfully"
            }
            
        finally:
            # 清理臨時檔案
            os.unlink(temp_file_path)
            print("成功清理臨時檔案")
            
    except Exception as e:
        print(f"錯誤：{str(e)}")
        print(f"錯誤類型：{type(e)}")
        import traceback
        print(f"錯誤堆疊：{traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 