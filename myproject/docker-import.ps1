# Script to import Docker image from file

param(
    [Parameter(Mandatory=$true)]
    [string]$ImageFile
)

if (-not (Test-Path $ImageFile)) {
    Write-Host "❌ Error: File not found: $ImageFile" -ForegroundColor Red
    exit 1
}

Write-Host "📥 Importing Docker image from $ImageFile..." -ForegroundColor Yellow

# Load the image
docker load < $ImageFile

Write-Host "✅ Image imported successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 You can now run:" -ForegroundColor Yellow
Write-Host "   docker-compose up -d" -ForegroundColor Cyan

