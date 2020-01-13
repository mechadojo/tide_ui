flutter build web
if %ERRORLEVEL% == 0 goto :next
echo "Error during building"
goto :end

:next
echo "Copy to tidechart website ..."
xcopy .\build ..\tidecharts\docs /e /i /y /s

:end
echo "Done."