::@author FB
::@version 0.1.0

::判断管理员权限
::  返回@: TRUE,有权限; FALSE,无权限;
::  退出码: 0,有权限; 1,无权限;

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

NET SESSION 1>NUL 2>&1
IF "%ERRORLEVEL%" == "0" (
  SET "@=TRUE" & EXIT /B 0
) ELSE (
  SET "@=FALSE" & EXIT /B 1
)
