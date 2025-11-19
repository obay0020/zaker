# دليل اختبار API مع Token Authentication

## المتطلبات
- Laravel Server يعمل على `http://localhost:8000`
- قاعدة البيانات مهيأة والـ migrations تم تنفيذها

## خطوات الاختبار

### 1. تشغيل الـ Server
```bash
php artisan serve
```

### 2. التأكد من تنفيذ الـ Migrations
```bash
php artisan migrate
```

### 3. اختبار الـ API

#### الطريقة 1: استخدام PowerShell Script
```powershell
cd myproject
.\test-api.ps1
```

#### الطريقة 2: اختبار يدوي باستخدام curl

**أ) تسجيل مستخدم جديد:**
```bash
curl -X POST http://localhost:8000/api/register ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Khaled\",\"email\":\"khaled@test.com\",\"password\":\"password123\"}"
```

**ب) تسجيل الدخول (الحصول على Token):**
```bash
curl -X POST http://localhost:8000/api/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"khaled@test.com\",\"password\":\"password123\"}"
```

**ج) إنشاء محادثة (مع Token):**
```bash
curl -X POST http://localhost:8000/api/chats ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  -H "Content-Type: application/json" ^
  -d "{\"text\":\"Hello, this is my first message\"}"
```

**د) الحصول على جميع المحادثات:**
```bash
curl -X GET http://localhost:8000/api/chats ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### الطريقة 3: استخدام Postman أو Insomnia

1. **Register:**
   - Method: `POST`
   - URL: `http://localhost:8000/api/register`
   - Body (JSON):
     ```json
     {
       "name": "Khaled",
       "email": "khaled@test.com",
       "password": "password123"
     }
     ```

2. **Login:**
   - Method: `POST`
   - URL: `http://localhost:8000/api/login`
   - Body (JSON):
     ```json
     {
       "email": "khaled@test.com",
       "password": "password123"
     }
     ```
   - احفظ الـ `token` من الاستجابة

3. **Create Chat:**
   - Method: `POST`
   - URL: `http://localhost:8000/api/chats`
   - Headers:
     - `Authorization: Bearer YOUR_TOKEN_HERE`
     - `Content-Type: application/json`
   - Body (JSON):
     ```json
     {
       "text": "Hello, this is my first message"
     }
     ```

4. **Get All Chats:**
   - Method: `GET`
   - URL: `http://localhost:8000/api/chats`
   - Headers:
     - `Authorization: Bearer YOUR_TOKEN_HERE`

## النتائج المتوقعة

### ✅ نجاح (مع Token):
```json
{
  "message": "Chat created",
  "chat": {
    "id": 1,
    "title": "Hello, this is my first",
    "date": "2025-01-19T10:30:00.000000Z"
  }
}
```

### ❌ فشل (بدون Token):
```json
{
  "message": "Unauthenticated."
}
```

## ملاحظات مهمة

1. **Token يجب أن يُرسل في Header:**
   ```
   Authorization: Bearer {token}
   ```

2. **كل محادثة يتم ربطها تلقائياً بالمستخدم المصادق عليه**

3. **المسارات المحمية:**
   - `GET /api/chats` - يحتاج Token
   - `POST /api/chats` - يحتاج Token
   - `GET /api/chats/{chat}/messages` - يحتاج Token
   - `POST /api/chats/{chat}/messages` - يحتاج Token

4. **المسارات العامة (لا تحتاج Token):**
   - `POST /api/register` - لا يحتاج Token
   - `POST /api/login` - لا يحتاج Token

