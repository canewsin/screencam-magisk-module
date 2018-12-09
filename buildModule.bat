@echo off
::Env variables
set flavour=%1
set version=%2
set file=ScreenCam-Magisk-V%version%-%flavour%

powershell -Command $pword = read-host "Enter Keystore Password" -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword) ; ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) > .tmp.txt 
set /p keyPass=<.tmp.txt & del .tmp.txt

powershell -Command $pword = read-host "Enter Alias Password. Leave empty to use keystore password " -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword) ; ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) > .tmp.txt
set /p aliasPass=<.tmp.txt & del .tmp.txt
if [%aliasPass%] == [] set aliasPass=%keyPass%

echo.
echo Zipping module....
echo.
7z.exe a -tzip temp\%file%.zip * "-xr!.*" "-xr!Releases" "-xr!temp" "-x!*.bat" "-x!*.zip" "-x!system\priv-app\ScreenCam\PLACEHOLDER" 1> nul || goto :error

echo.
echo Signing zip
echo.
jarsigner -keystore %SigningKey% -storepass %keyPass% -sigfile CERT -tsa http://timestamp.comodoca.com/rfc3161 -digestalg SHA-1 -signedjar Releases\%file%-Signed.zip temp\%file%.zip %SigningKeyAlias% --key-pass %aliasPass%
DEL temp\%file%.zip

:error
exit /b