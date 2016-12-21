set "mypath=%cd%" 
curl -O http://mirlab.org/dataset/public/MIR-1K.rar
curl -O https://www.netzmechanik.de/dl/4/winrar-x64-540d.exe             
%cd%\winrar-x64-540d.exe                                         
cd %PROGRAMFILES%
"%cd%\WinRAR\UnRAR.exe" x %mypath%\MIR-1K.rar %mypath%