# Script to export Docker image for sharing

Write-Host "📦 Exporting Docker image..." -ForegroundColor Yellow

# Build the image first
Write-Host "🔨 Building Docker image..." -ForegroundColor Yellow
docker-compose build

# Export the image
$imageName = "laravel-chat-app"
$exportFile = "laravel-chat-app.tar"

Write-Host "💾 Saving image to $exportFile..." -ForegroundColor Yellow
docker save $imageName > $exportFile

$fileSize = (Get-Item $exportFile).Length / 1GB
Write-Host "✅ Image exported successfully!" -ForegroundColor Green
Write-Host "📊 File size: $([math]::Round($fileSize, 2)) GB" -ForegroundColor Cyan
Write-Host "📁 File location: $PWD\$exportFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "📤 You can now share this file with your friend." -ForegroundColor Yellow
Write-Host "💡 To compress it, use: Compress-Archive -Path $exportFile -DestinationPath laravel-chat-app.zip" -ForegroundColor Gray

