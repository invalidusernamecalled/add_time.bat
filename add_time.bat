@echo off
set /a add_seconds=0
set op_=
if /i "%~1"=="/t"  goto validate_arg_ok1
if /i "%~1"=="/m" goto validate_arg_ok1
if /i "%~1"=="/c" goto validate_arg_ok1
if /i "%~1"=="/p" goto validate_arg_ok1

echo %~1| findstr /v "[0-9][0-9]*$" >NUL&&(echo:ERROR:invalid first argument&goto :checksyntax) || (set "add_seconds=%~1")

:validate_arg_ok1

if "%~2"=="" call :setok & goto validate_arg_ok2
echo %~2| findstr /v "[0-9][0-9]*$" >NUL&&(echo: >NUL) || (set "add_seconds=%~2"&call :setok & goto validate_arg_ok2)
if /i "%~2"=="/t"  call :setok & goto validate_arg_ok2
if /i "%~2"=="/m" call :setok & goto validate_arg_ok2
if /i "%~2"=="/c" call :setok & goto validate_arg_ok2
if /i "%~2"=="/p" call :setok & goto validate_arg_ok2
echo:ERROR:invalid second argument
goto :eof

:setok

exit /b 0
:checksyntax
echo:"%~nx0" /{X} {Number}
echo:     Where {X} is:
echo:                               /c current time
echo:                               /t prints total time in seconds
echo:                               /m prints in format HH:mm
echo:                               /p convert seconds to time format
echo:     Where {Number} is:
echo:                               number of Minutes: any integer (not too large)
echo:                               number of Seconds: for only /p option
goto :eof
:validate_arg_ok2
if /i "%~2"=="/p" set /a "total_seconds=%~1"&goto :calculate_from_total_seconds
if /i "%~1"=="/p" set /a "total_seconds=%~2"&goto :calculate_from_total_seconds

set /a add_seconds=add_seconds*60
set time_str=

for /f "tokens=2 delims=^=" %%i in ('wmic os get localdatetime /value') do set time_str=%%i
if "%time_str%"=="" echo ERROR:failed to get time&goto :eof
set hours_str=%time_str:~8,2%
set minutes_str=%time_str:~10,2%
set seconds_str=%time_str:~12,2%
if /i "%~1"=="/c" (echo %hours_str%:%minutes_str%:%seconds_str%&goto :eof)
if /i "%~2"=="/c" (echo %hours_str%:%minutes_str%:%seconds_str%&goto :eof)

Set /a total_seconds=0
set /a total_seconds=(hours_str*60*60)+total_seconds
if %errorlevel% NEQ 0 echo ERROR:illegal operation&goto :eof
set /a total_seconds=(minutes_str*60)+total_seconds
if %errorlevel% NEQ 0 echo ERROR:illegal operation&goto :eof
set /a total_seconds=(seconds_str)+total_seconds
if %errorlevel% NEQ 0 echo ERROR:illegal operation&goto :eof
set /a total_seconds=total_seconds + add_seconds
if %errorlevel% NEQ 0 echo ERROR:illegal operation&goto :eof
:calculate_from_total_seconds
set /a result_hours=total_seconds / 3600
if %result_hours%==24 set /a result_hours=0
if %result_hours% GTR 24 set /a result_hours=result_hours %% 24
set /a result_hours_modulus=total_seconds %% 3600
set /a result_minutes=result_hours_modulus / 60
set /a result_seconds=result_hours_modulus %% 60

if %result_hours% LSS 10 set result_hours=0%result_hours%
if %result_minutes% LSS 10 set result_minutes=0%result_minutes%
if %result_seconds% LSS 10 set result_seconds=0%result_seconds%


if /i "%~2"=="/t" (echo %total_seconds%&goto :eof)
if /i "%~2"=="/m" (echo %result_hours%:%result_minutes%&goto :eof)

if /i "%~1"=="/t" (echo %total_seconds%&goto :eof)
if /i "%~1"=="/m" (echo %result_hours%:%result_minutes%&goto :eof)

echo %result_hours%:%result_minutes%:%result_seconds%
