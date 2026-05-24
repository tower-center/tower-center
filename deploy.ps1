$versionFile = "lib\version.dart"

# Read version file
$content = Get-Content -Path $versionFile -Raw
# Extract version using regex
if ($content -match 'const String appVersion = "V(\d+)\.(\d+)\.(\d+)";') {
    $major = [int]$Matches[1]
    $minor = [int]$Matches[2]
    $patch = [int]$Matches[3]
    
    # Increment patch
    $patch++
    
    $newVersion = "V$major.$minor.$patch"
    $replacement = 'const String appVersion = "' + $newVersion + '";'
    $newContent = $content -replace 'const String appVersion = "V\d+\.\d+\.\d+";', $replacement
    
    Set-Content -Path $versionFile -Value $newContent
    Write-Host "================================" -ForegroundColor Green
    Write-Host " Bumping version to $newVersion..." -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    
    Write-Host "`n[1/3] Building Flutter Web..." -ForegroundColor Cyan
    flutter build web --release
    
    Write-Host "`n[2/3] Deploying Firestore Indexes..." -ForegroundColor Cyan
    firebase deploy --only firestore:indexes
    
    Write-Host "`n[3/3] Deploying Firebase Hosting..." -ForegroundColor Cyan
    firebase deploy --only hosting
    
    Write-Host "`n Deployment Complete ($newVersion)! " -ForegroundColor Green
} else {
    Write-Host "Error parsing version file!" -ForegroundColor Red
}
