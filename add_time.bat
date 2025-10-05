@echo off

set op_=
if /i "%~1"=="/subtract" set op_=-
if /i "%~1"=="/add" set op_=+

if "%op_%" NEQ "" goto validate_arg_ok1

echo:ERROR:invalid first argument

goto :eof

:validate_arg_ok1

echo %~2| findstr /v "^[0-9]*$" >NUL&&(echo:ERROR:invalid second argument&goto :eof)

set "add_seconds=%~2"
set /a add_seconds=add_seconds*60

call :setok & goto validate_arg_ok2

:setok

exit /b 0

:validate_arg_ok2
set time_str=
for /f "tokens=2 delims=^=" %%i in ('wmic os get localdatetime /value') do set time_str=%%i
if "%time_str%"=="" echo ERROR:failed to get time&goto :eof
set hours_str=%time_str:~8,2%
set minutes_str=%time_str:~10,2%
set seconds_str=%time_str:~12,2%

Set /a total_seconds=0
set /a total_seconds=(hours_str*60*60)+total_seconds
if %errorlevel% NEQ 0 echo ERROR:illegal operation&goto :eof
set /a total_seconds=(minutes_str*60)+total_seconds
if %errorlevel% NEQ 0 echo ERROR:illegal operation&goto :eof
set /a total_seconds=(seconds_str)+total_seconds
if %errorlevel% NEQ 0 echo ERROR:illegal operation&goto :eof
set /a total_seconds=total_seconds %op_% add_seconds
if %errorlevel% NEQ 0 echo ERROR:illegal operation&goto :eof

set /a result_hours=total_seconds / 3600
set /a result_hours_modulus=total_seconds %% 3600
set /a result_minutes=result_hours_modulus / 60
set /a result_seconds=result_hours_modulus %% 60

if %result_hours% LSS 10 set result_hours=0%result_hours%
if %result_minutes% LSS 10 set result_minutes=0%result_minutes%
if %result_seconds% LSS 10 set result_seconds=0%result_seconds%

echo %result_hours%:%result_minutes%:%result_seconds%