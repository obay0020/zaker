# اختبار API للمصادقة وإنشاء المحادثات
# PowerShell Script لاختبار API

$baseUrl = "http://localhost:8000/api"

Write-Host "=== اختبار API ===" -ForegroundColor Green
Write-Host ""

# الخطوة 1: تسجيل مستخدم جديد
Write-Host "1. تسجيل مستخدم جديد..." -ForegroundColor Yellow
$registerBody = @{
    name = "Test User"
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/register" -Method Post -Body $registerBody -ContentType "application/json"
    Write-Host "✓ تم التسجيل بنجاح" -ForegroundColor Green
    Write-Host "   User ID: $($registerResponse.user.id)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "✗ خطأ في التسجيل: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "   التفاصيل: $($errorDetails.message)" -ForegroundColor Red
    }
    Write-Host ""
}

# الخطوة 2: تسجيل الدخول
Write-Host "2. تسجيل الدخول..." -ForegroundColor Yellow
$loginBody = @{
    email = "test@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $loginResponse.token
    Write-Host "✓ تم تسجيل الدخول بنجاح" -ForegroundColor Green
    Write-Host "   Token: $($token.Substring(0, 20))..." -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "✗ خطأ في تسجيل الدخول: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# الخطوة 3: إنشاء محادثة (مع Token)
Write-Host "3. إنشاء محادثة جديدة (مع Token)..." -ForegroundColor Yellow
$chatBody = @{
    text = "Hello, this is my first message in the chat"
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $chatResponse = Invoke-RestMethod -Uri "$baseUrl/chats" -Method Post -Body $chatBody -Headers $headers
    Write-Host "✓ تم إنشاء المحادثة بنجاح" -ForegroundColor Green
    Write-Host "   Chat ID: $($chatResponse.chat.id)" -ForegroundColor Cyan
    Write-Host "   Title: $($chatResponse.chat.title)" -ForegroundColor Cyan
    Write-Host "   Date: $($chatResponse.chat.date)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "✗ خطأ في إنشاء المحادثة: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "   التفاصيل: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

# الخطوة 4: محاولة إنشاء محادثة بدون Token (يجب أن تفشل)
Write-Host "4. محاولة إنشاء محادثة بدون Token (يجب أن تفشل)..." -ForegroundColor Yellow
try {
    $chatResponse = Invoke-RestMethod -Uri "$baseUrl/chats" -Method Post -Body $chatBody -ContentType "application/json"
    Write-Host "✗ يجب أن يفشل هذا الطلب!" -ForegroundColor Red
} catch {
    Write-Host "✓ تم رفض الطلب كما هو متوقع (لا يوجد Token)" -ForegroundColor Green
    Write-Host "   الرسالة: $($_.Exception.Message)" -ForegroundColor Cyan
    Write-Host ""
}

# الخطوة 5: الحصول على جميع المحادثات
Write-Host "5. الحصول على جميع المحادثات..." -ForegroundColor Yellow
try {
    $chatsResponse = Invoke-RestMethod -Uri "$baseUrl/chats" -Method Get -Headers $headers
    Write-Host "✓ تم الحصول على المحادثات بنجاح" -ForegroundColor Green
    Write-Host "   عدد المحادثات: $($chatsResponse.data.Count)" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "✗ خطأ في الحصول على المحادثات: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host "=== انتهى الاختبار ===" -ForegroundColor Green

