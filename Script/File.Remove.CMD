::@author FB
::@version 0.1.0

::删除文件或目录
::  参数1: 文件或目录
::  返回@: TRUE,执行成功; FALSE,执行失败;
::  退出码: 0,执行成功; 1,执行失败;

::Script:File.HasAttrib.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

IF EXIST "%~1" CALL File.HasAttrib.CMD "%~1" "D" && (
  RD /S /Q "%~1" 1>NUL || (SET "@=FALSE" & EXIT /B 1)
) || (
  DEL /F /Q "%~1" 2>&1 1>NUL | FINDSTR "." 1>&2 && (SET "@=FALSE" & EXIT /B 1)
)
SET "@=TRUE"
EXIT /B 0
