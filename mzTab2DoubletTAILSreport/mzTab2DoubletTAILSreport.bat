@ECHO OFF

rem Script to create a report from mzTab file

rem script directory
rem The script path consists of drive (d) and path (p) of the zeroth argument (0) i.e. the script itselfs.
SET SCRIPT_PATH=%~dp0

IF "%1"=="" (
  ECHO Please specify a file.
  rem Exit the script without closing the terminal
  EXIT /B
)

IF NOT EXIST %1 (
  ECHO File does not exist.
  EXIT /B
)

SET CURRENT_PATH=%CD%
SET FILE=%1
rem The absolute path consists of drive (d), path (p), name (n) and extension (x) of the first argument (1).
SET FILE_ABSOLUTE=%~dpnx1
rem The file path consists of drive (d) and path (p) of the first argument (1).
SET FILE_PATH=%~dp1
rem The base name consists only of the name (n) of the first argument (1).
SET FILE_BASE=%~n1

ECHO Generating TAILS report from mzTab file %FILE_BASE%.
rem Unique directory to avoid name clashes in `analysis.mzTab` etc. when 
rem running multiple processes at once.
SET WORK_DIRECTORY=%SCRIPT_PATH%\%FILE_BASE%
mkdir %WORK_DIRECTORY%
CD /d %WORK_DIRECTORY%

rem copy mzTab
cp %FILE_ABSOLUTE% data.mzTab

rem  replace dummy FILE_NAME_DUMMY by file name %FILE_BASE%
(for /f "delims=" %%i in (%SCRIPT_PATH%\mzTab2DoubletTAILSreport.Snw) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    set "line=!line:FILE_NAME_DUMMY=%FILE_BASE%!"
    echo(!line!
    endlocal
))>"mzTab2DoubletTAILSreport_temp.Snw"

rem  Run the R code
R -e "Sweave('mzTab2DoubletTAILSreport_temp.Snw')"

rem Small 5 sec pause.
timeout /t 5 /NOBREAK

rem  Run LaTeX code
pdflatex mzTab2DoubletTAILSreport_temp.tex

rem  Copy final report and table to the input folder
MOVE mzTab2DoubletTAILSreport_temp.pdf %FILE_PATH%\%FILE_BASE%.pdf
MOVE data.tsv %FILE_PATH%\%FILE_BASE%.tsv

rem  clean-up
DEL data*
DEL FcLogIntensity*
DEL frequency*
DEL mzTab2DoubletTAILSreport_temp*

rem  Jump back to original folder
CD /d %CURRENT_PATH%
