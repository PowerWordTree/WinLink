::@author FB
::@version 0.1.0

::数据结构为Map
::仅支持一级段, 由%包裹的变量不会被展开

::如果KEY是#或;开头,什么也不做
::如果VALUE不为空,保存到变量
::如果KEY被[]包裹,切换当前段

::读取配置文件
::  参数1: 实例名称
::  参数2: 配置文件
::  返回: 0,执行成功; 1,执行失败;

::Script:Map.New.CMD::
::Script:Map.NewChild.CMD::
::Script:Map.Put.CMD::
::Script:String.Trim.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET "@VAR=%~1" & SET "@SECTION=" & SET "@EXIT_CODE=0"
CALL Map.New.CMD "%~1"
FOR /F "tokens=1,* usebackq delims==" %%A IN (
  `TYPE "%~2" 2^>NUL ^|^| ECHO #@EXIT_CODE^=1`
) DO (
  SET "@KEY=%%~A" & SET "@VALUE=%%~B"
  CALL String.Trim.CMD "%%@KEY%%" & CALL SET "@KEY=%%@%%"
  CALL String.Trim.CMD "%%@VALUE%%" & CALL SET "@VALUE=%%@%%"
  CALL :@CONFIG_FILE_READ_PARSE
)
SET "@VALUE=" & SET "@KEY=" & SET "@SECTION=" & SET "@VAR="
SET "@EXIT_CODE=" & EXIT /B %@EXIT_CODE%

:@CONFIG_FILE_READ_PARSE
IF "%@KEY%" == "#@EXIT_CODE" SET "@EXIT_CODE=1"
IF "%@KEY%" == "" GOTO :EOF
IF "%@KEY:~,1%" == "#" GOTO :EOF
IF "%@KEY:~,1%" == ";" GOTO :EOF
IF NOT "%@VALUE%" == "" (
  CALL Map.Put.CMD "%%@VAR%%%%@SECTION%%" "%%@KEY%%" "%%@VALUE%%"
) ELSE IF "%@KEY:~,1%" == "[" IF "%@KEY:~-1%" == "]" (
  SET "@SECTION=.%@KEY:~1,-1%"
  CALL Map.NewChild.CMD "%%@VAR%%" "%%@KEY:~1,-1%%"
)
GOTO :EOF
