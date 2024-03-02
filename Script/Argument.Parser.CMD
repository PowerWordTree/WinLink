::@author FB
::@version 0.1.1

::有序参数: 实例.PARAM, 保存为Array
::选项参数: 实例.OPTION, 保存为Map

::解析参数
::  参数1: 实例名称
::  参数N: 参数

::Script:Array.New.CMD::
::Script:Array.Push.CMD::
::Script:Map.New.CMD::
::Script:Map.Put.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET "@VAR=%~1"
CALL Array.New.CMD "%@VAR%.PARAM"
CALL Map.New.CMD "%@VAR%.OPTION"
:@ARGUMENT_PARSER_LOOP
SHIFT
IF "%1" == "" (SET "@VAR=" & EXIT /B)
SET "@=%~1"
ECHO.%@% | FINDSTR "^[-/]" 1>NUL 2>&1 && (
  ECHO.%~2 | FINDSTR /R /C:"^[-/]" /C:"^[ ]*$" 1>NUL 2>&1 && (
    CALL Map.Put.CMD "%@VAR%.OPTION" "%%@:~1%%" "TRUE"
    VERIFY 1>NUL 2>&1
  ) || (
    CALL Map.Put.CMD "%@VAR%.OPTION" "%%@:~1%%" "%~2"
    SHIFT
  )
  VERIFY 1>NUL 2>&1
) || (
  CALL Array.Push.CMD "%@VAR%.PARAM" "%%@%%"
)
GOTO :@ARGUMENT_PARSER_LOOP
