::@author FB
::@version 0.1.0

::判断文件是否为硬链接
::  参数1: 文件
::  返回@: TRUE,是; FALSE,否;
::  退出码: 0,是; 1,否;

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Fsutil.exe hardlink list "%~1" | MORE +1 | FINDSTR "." 1>NUL 2>&1 && (
  SET "@=TRUE" & EXIT /B 0
) || (
  SET "@=FALSE" & EXIT /B 1
)
