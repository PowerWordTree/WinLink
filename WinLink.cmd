::符号链接管理
::@author FB
::@version 0.1.0

::Script:Argument.Parser.CMD::
::Script:Common.IsAdmin.CMD::
::Script:Config.FileRead.CMD::
::Script:File.HasAttrib.CMD::
::Script:File.IsHardLink.CMD::
::Script:Map.ListChild.CMD::
::Script:Path.GetAbsolutePath.CMD::
::Script:Path.GetPath.CMD::

::初始化环境
@ECHO OFF
SETLOCAL
CD /D "%~dp0"
SET "PATH=%~dp0Bin;%~dp0Script;%PATH%"
SET /A "_EXIT_CODE=0"
::输出标题
ECHO.
ECHO ============================================
ECHO =======         符号链接管理          ======
ECHO ============================================
::解析参数
CALL Argument.Parser.CMD "_ARG" %*
::获取配置文件名
IF "%_ARG.PARAM.0%" == "" (
  SET "_CONFIG=%~n0.ini"
) ELSE IF /I "%_ARG.PARAM.0:~-4%" == ".ini" (
  SET "_CONFIG=%_ARG.PARAM.0%"
) ELSE (
  SET "_CONFIG=%_ARG.PARAM.0%.ini"
)
::获取选项参数
IF "%_ARG.OPTION.O%" == "1" (
  SET "_OPTION=/D 1 /T 0"
) ELSE IF "%_ARG.OPTION.O%" == "2" (
  SET "_OPTION=/D 2 /T 0"
) ELSE IF "%_ARG.OPTION.O%" == "3" (
  SET "_OPTION=/D 3 /T 0"
) ELSE (
  SET "_OPTION="
)
::输出帮助
IF /I "%_ARG.OPTION.H%" == "TRUE" (
  ECHO.
  ECHO 命令行: %~nx0 [配置文件[.ini]] [/o^|-o ^<1^|2^|3^>] [/h^|-h]
  ECHO.
  ECHO - 配置文件
  ECHO   指定配置文件路径, 可以省略`.ini`.
  ECHO   备份文件会根据配置文件名生成, 扩展名为`.old`.
  ECHO   默认配置文件`%~n0.ini`, 默认备份文件`%~n0.old`.
  ECHO.
  ECHO - /o ^| -o
  ECHO   指定要执行的操作.
  ECHO   必选参数: `1`创建符号链接, `2`移除符号链接, `3`退出.
  ECHO   默认操作为等待用户选择.
  ECHO.
  ECHO - /h ^| -h
  ECHO   显示帮助
  ECHO.
  GOTO :EXIT
)
::选择菜单
ECHO.
ECHO ***** 注意: 错误操作可能对系统造成破坏! *****
ECHO.
ECHO 1:创建符号链接
ECHO 2:移除符号链接
ECHO 3:退出
ECHO.
CHOICE /C:123 %_OPTION% /M "请选择:"
IF "%ERRORLEVEL%" == "1" (
  SET "_OPTION=MAKE_LINK"
) ELSE IF "%ERRORLEVEL%" == "2" (
  SET "_OPTION=UNDO_LINK"
) ELSE (
  GOTO :EXIT
)
::读取配置文件
ECHO.
ECHO 配置文件: %_CONFIG%
IF NOT EXIST "%_CONFIG%" (
  ECHO.
  ECHO ***** 错误, 配置文件不存在! *****
  SET /A "_EXIT_CODE=-1"
  GOTO :EXIT
)
CALL Path.GetAbsolutePath.CMD "%%_CONFIG%%"
SET "_CONFIG=%@%"
CALL Path.GetPath.CMD "%%_CONFIG%%"
CD /D "%@%"
CALL Config.FileRead.CMD "_CONFIG" "%%_CONFIG%%"
::检查管理员权限
CALL Common.IsAdmin.CMD || (
  ECHO.
  ECHO ***** 错误, 需要管理员权限! *****
  SET /A "_EXIT_CODE=-1"
  GOTO :EXIT
)
::遍历执行
CALL Map.ListChild.CMD "_CONFIG"
FOR %%A IN (%@%) DO (
  CALL :READ_SECTION "%%~A"
  CALL :%_OPTION% || SET /A "_EXIT_CODE+=1"
)
::退出
:EXIT
IF "%_ARG.OPTION.O%" == "" (
  ECHO.
  ECHO 按任意键结束……
  PAUSE >NUL
)
ENDLOCAL & EXIT /B %_EXIT_CODE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:READ_SECTION
::读取段并展开变量
CALL CALL Path.GetAbsolutePath.CMD "%%_CONFIG.%~1.LINK%%"
SET "_LINK=%@%"
CALL CALL Path.GetAbsolutePath.CMD "%%_CONFIG.%~1.TARGET%%"
SET "_TARGET=%@%"
CALL CALL SET "_TYPE=%%_CONFIG.%~1.TYPE%%"
IF "%_TYPE%" == "" SET "_TYPE=SymbolicLink"
CALL CALL SET "_EXISTED=%%_CONFIG.%~1.EXISTED%%"
IF "%_EXISTED%" == "" CALL SET "_EXISTED=%_CONFIG.EXISTED%"
IF "%_EXISTED%" == "" SET "_EXISTED=Backup"
::输出段信息
ECHO.
ECHO [%~1]
ECHO Link: %_LINK%
ECHO Target: %_TARGET%
ECHO Type: %_TYPE%
ECHO Existed: %_EXISTED%
GOTO :EOF

::::::::::::
::操作\链接    存在         不存在
::Backup       移动,链接    链接
::Override     删除,链接    链接
::Skip         跳过         链接
::::::::::::
:MAKE_LINK
::处理链接位置
IF EXIST "%_LINK%" (
  IF /I "%_EXISTED%" == "Backup" (
    MOVE /Y "%_LINK%" "%_LINK%.BACKUP" 1>NUL || (
      ECHO.
      ECHO ***** 错误, 备份`Target`失败! *****
      EXIT /B 1
    )
  ) ELSE IF /I "%_EXISTED%" == "Override" (
    CALL File.HasAttrib.CMD "%%_LINK%%" "D" && (
      SET "_COMMAND=RMDIR /S /Q"
    ) || (
      SET "_COMMAND=DEL /F /Q"
    )
    CALL %%_COMMAND%% "%%_LINK%%" 1>NUL || (
      ECHO.
      ECHO ***** 错误, 删除`Target`失败! *****
      EXIT /B 1
    )
  ) ELSE IF /I "%_EXISTED%" == "Skip" (
    ECHO.
    ECHO 目标已经存在, 跳过.
    EXIT /B 0
  ) ELSE (
    ECHO.
    ECHO ***** 错误, 无法识别`Existed`参数! *****
    EXIT /B 1
  )
) ELSE IF NOT EXIST "%_LINK%\.." (
  MKDIR "%_LINK%\.." 1>NUL || (
    ECHO.
    ECHO ***** 错误, 创建`Target`上级目录失败! *****
    EXIT /B 1
  )
)
::创建链接
IF /I "%_TYPE%" == "SymbolicLink" (
  IF EXIST "%_LINK%\" (
    SET "_COMMAND=MKLINK /D"
  ) ELSE (
    SET "_COMMAND=MKLINK"
  )
) ELSE IF /I "%_TYPE%" == "Junction" (
  SET "_COMMAND=MKLINK /J"
) ELSE IF /I "%_TYPE%" == "HardLink" (
  SET "_COMMAND=MKLINK /H"
) ELSE (
  ECHO.
  ECHO ***** 错误, 无法识别`Type`参数! *****
  EXIT /B 1
)
CALL %%_COMMAND%% "%%_LINK%%" "%%_TARGET%%" 1>NUL || (
  ECHO.
  ECHO ***** 错误, 创建链接失败! *****
  EXIT /B 1
)
ECHO.
ECHO 操作完成.
EXIT /B 0

::::::::::::
::操作\链接     链接    文件    不存在
::Backup(有)    移动    跳过    跳过
::Backup(无)    删除    跳过    跳过
::Override      删除    跳过    跳过
::Skip          删除    跳过    跳过
:::::::::::::
:UNDO_LINK
::处理链接
(CALL File.HasAttrib.CMD "%%_LINK%%" "L" ^
  || CALL File.IsHardLink.CMD "%%_LINK%%") && (
  CALL File.HasAttrib.CMD "%%_LINK%%" "D" && (
    SET "_COMMAND=RMDIR /S /Q"
  ) || (
    SET "_COMMAND=DEL /F /Q"
  )
  CALL %%_COMMAND%% "%%_LINK%%" 1>NUL || (
    ECHO.
    ECHO ***** 错误, 删除`Target`失败! *****
    EXIT /B 1
  )
  IF /I "%_EXISTED%" == "Backup" IF EXIST "%_LINK%.BACKUP" (
    MOVE /Y "%_LINK%.BACKUP" "%_LINK%" 1>NUL || (
      ECHO.
      ECHO ***** 错误, 恢复`Target`失败! *****
      EXIT /B 1
    )
  )
) || (
  ECHO.
  ECHO 目标不是链接, 跳过.
  EXIT /B 0
)
ECHO.
ECHO 操作完成.
EXIT /B 0
