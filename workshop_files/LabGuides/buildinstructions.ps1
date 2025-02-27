$file = ".\..\PublishedLabInstructions\K8s%20Instructions\instructions.md"
$fileList = @(
    'modules-list.md' 
    ,'azure-pass-subscription.md' 
    ,'module1-instructions.md' 
    ,'module2-instructions.md' 
    ,'module3-instructions.md' 
    ,'module4-instructions.md' 
    ,'module5a-instructions.md'
    ,'module5b-instructions.md'
    ,'module6-instructions.md'
    )
$filelist | Foreach-Object { Write-Output '===' (Get-Content $_ -Raw) } | Set-Content -Path $file

Get-Content $file | Select-Object -Skip 1 | Set-Content "$file-temp"
Move-Item "$file-temp" $file -Force
Copy-Item ".\content" -Destination ".\..\PublishedLabInstructions\K8s%20Instructions" -Recurse -Force