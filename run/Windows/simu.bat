@echo off
rem ENTER YOUR PROJECT DIRECTORY NAME
set DIR_NAME=CPU_Project/cpu

rem ENTER YOUR BASH SCRIPT NAME (eg. simu.sh)
set SCRIPT_NAME=CPU_Project/run/Windows/simu.sh

rem ENTER UNIX PATH TO WINDOWS
set UNIX_C=/mnt/c

rem TOUCH AND YOU ARE DEAD
set SCRIPT_PATH=%cd%
set SCRIPT_PATH=%SCRIPT_PATH:\=/%
set SCRIPT_PATH=%UNIX_C%%SCRIPT_PATH:~2%
bash -c "%SCRIPT_PATH%/%SCRIPT_NAME% \"%SCRIPT_PATH%/%DIR_NAME%/simulation/%1\""