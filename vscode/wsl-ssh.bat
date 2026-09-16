@echo off
set v_params=%*
set v_params=%v_params:\=/%
set v_params=%v_params:c:=/mnt/c%
REM set v_params=%v_params:"=\"%
C:\Windows\system32\wsl.exe ssh %v_params%
