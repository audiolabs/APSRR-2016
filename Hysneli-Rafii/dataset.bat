@echo off
rem bitsadmin /create downloadJob
rem bitsadmin /transfer downloadJob /download /priority normal http://mirlab.org/dataset/public/MIR-1K.rar  C:\Temp\MIR-1K.rar
rem "C:\Program Files\WinRAR\UnRAR.exe" x C:\Temp\MIR-1K.rar C:\Temp\
set mypath=%cd%
cd %mypath%\dataset
set mypath=%cd%
move C:\Temp\MIR-1K\Wavfile %mypath%
pause