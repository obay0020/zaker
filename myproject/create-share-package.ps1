# Script to create a shareable package (excluding unnecessary files)

Write-Host "Creating shareable package..." -ForegroundColor Yellow

$packageName = "laravel-chat-shareable"
$tempDir = ".\$packageName"

# Create temporary directory
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

Write-Host "Copying files..." -ForegroundColor Yellow

# Copy essential files
$filesToCopy = @(
    "app",
    "bootstrap",
    "config",
    "database",
    "public",
    "resources",
    "routes",
    "storage",
    "tests",
    "artisan",
    "composer.json",
    "composer.lock",
    "package.json",
    "vite.config.js",
    "phpunit.xml",
    "Dockerfile",
    "docker-compose.yml",
    ".dockerignore",
    "docker",
    "docker-start.ps1",
    "docker-start.sh",
    "DOCKER.md",
    "DOCKER_SHARE.md"
)

foreach ($item in $filesToCopy) {
    if (Test-Path $item) {
        Copy-Item -Path $item -Destination $tempDir -Recurse -Force
        Write-Host "  Copied: $item" -ForegroundColor Gray
    }
}

# Clean up storage logs
if (Test-Path "$tempDir\storage\logs") {
    Get-ChildItem "$tempDir\storage\logs\*" -Exclude ".gitkeep" | Remove-Item -Force
}

# Create .gitkeep files where needed
$storagePaths = @("storage/logs", "storage/framework/cache", "storage/framework/sessions", "storage/framework/views")
foreach ($path in $storagePaths) {
    $fullPath = "$tempDir\$path"
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
    if (-not (Get-ChildItem $fullPath)) {
        New-Item -ItemType File -Path "$fullPath\.gitkeep" -Force | Out-Null
    }
}

# Create README for the package
$readmeLines = @(
    "# Laravel Chat Application - Shareable Package",
    "",
    "## Quick Start",
    "",
    "1. Extract this package",
    "2. Open terminal in the extracted folder",
    "3. Run: .\docker-start.ps1",
    "",
    "Or manually:",
    "",
    "```powershell",
    "docker-compose up -d --build",
    "docker-compose exec app composer install",
    "docker-compose exec app php artisan key:generate",
    "docker-compose exec app php artisan migrate",
    "```",
    "",
    "## Important Notes",
    "",
    "- Make sure Docker Desktop is running",
    "- Create a .env file with database settings:",
    "  - DB_HOST=db",
    "  - DB_DATABASE=laravel",
    "  - DB_USERNAME=laravel",
    "  - DB_PASSWORD=root",
    "",
    "## Access",
    "",
    "- Web: http://localhost:8000",
    "- API: http://localhost:8000/api"
)

$readmeLines -join "`r`n" | Out-File -FilePath "$tempDir\README.md" -Encoding utf8

# Create ZIP file
$zipFile = "$packageName.zip"
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

Write-Host "Creating ZIP file..." -ForegroundColor Yellow
Compress-Archive -Path $tempDir\* -DestinationPath $zipFile -Force

# Clean up temp directory
Remove-Item -Recurse -Force $tempDir

$zipSize = (Get-Item $zipFile).Length / 1MB
Write-Host "Package created successfully!" -ForegroundColor Green
Write-Host "File: $PWD\$zipFile" -ForegroundColor Cyan
Write-Host "Size: $([math]::Round($zipSize, 2)) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now share this ZIP file with your friend!" -ForegroundColor Yellow
