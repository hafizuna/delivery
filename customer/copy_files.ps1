# Copy essential files from old app to new app

$oldApp = "..\..\Applications\customer"
$newApp = "."

Write-Host "Copying theme files..." -ForegroundColor Green
Copy-Item -Path "$oldApp\lib\themes\*" -Destination "$newApp\lib\themes\" -Recurse -Force

Write-Host "Copying widget files..." -ForegroundColor Green
Copy-Item -Path "$oldApp\lib\widget\gradiant_text.dart" -Destination "$newApp\lib\widget\" -Force
Copy-Item -Path "$oldApp\lib\widget\my_separator.dart" -Destination "$newApp\lib\widget\" -Force
Copy-Item -Path "$oldApp\lib\widget\permission_dialog.dart" -Destination "$newApp\lib\widget\" -Force

Write-Host "Copying utils files..." -ForegroundColor Green
Copy-Item -Path "$oldApp\lib\utils\preferences.dart" -Destination "$newApp\lib\utils\" -Force
Copy-Item -Path "$oldApp\lib\utils\dark_theme_provider.dart" -Destination "$newApp\lib\utils\" -Force
Copy-Item -Path "$oldApp\lib\utils\dark_theme_preference.dart" -Destination "$newApp\lib\utils\" -Force
Copy-Item -Path "$oldApp\lib\utils\network_image_widget.dart" -Destination "$newApp\lib\utils\" -Force

Write-Host "Copying service files..." -ForegroundColor Green
Copy-Item -Path "$oldApp\lib\services\cart_provider.dart" -Destination "$newApp\lib\services\" -Force
Copy-Item -Path "$oldApp\lib\services\database_helper.dart" -Destination "$newApp\lib\services\" -Force

Write-Host "Copying constant files..." -ForegroundColor Green
Copy-Item -Path "$oldApp\lib\constant\show_toast_dialog.dart" -Destination "$newApp\lib\constant\" -Force

Write-Host "All files copied successfully!" -ForegroundColor Cyan
