::@author FB
::@version 0.1.0

::À©Õ¹Êä³ö
::  ²ÎÊý1: ÏÔÊ¾²ÎÊý(ÓÃ`;`·Ö¸ô)
::  ²ÎÊý2: ÏÔÊ¾ÎÄ±¾
::  Êä³ö: ¾­¹ýÀ©Õ¹µÄÎÄ±¾

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
