::@author FB
::@version 0.1.0

::扩展输出
::  参数1: 显示参数(用`;`分隔)
::  参数2: 显示文本
::  输出: 经过扩展的文本

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF "%_VIRTUAL_TERMINAL_PROCESSING%" == "" (
  FOR /F "tokens=4 usebackq delims=[] " %%A IN (
    `VER 2^>NUL`
  ) DO (
    IF "%%~A" GTR "10.0.10586.0000" (
      SET "_VIRTUAL_TERMINAL_PROCESSING=Enabled"
    ) ELSE (
      SET "_VIRTUAL_TERMINAL_PROCESSING=Disabled"
    )
  )
)
IF /I "%_VIRTUAL_TERMINAL_PROCESSING%" == "Enabled" (
  ECHO.[%~1m%~2[0m
) ELSE (
  ECHO.%~2
)
EXIT /B
