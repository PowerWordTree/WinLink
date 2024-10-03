::符号链接管理
::@Authors FB
::@Version 1.1.0
::@Description
::  批量添加 Windows 符号链接的工具.
::  根据配置文件创建 Windows 符号链接, 当前工作目录为配置文件所在目录.
::@Variables
::  @*, _ANSI_*, _EXIT_CODE, _ARG, _NOWAIT, _OPTION, _NOWAIT, _CONFIG,
::  _LINK, _TARGET, _TYPE, _EXISTING, _MKLINK_ARG
::@Syntax
::  WinLink.cmd [配置文件[.ini]] [/o^|-o ^<1^|2^|3^>]
::    [/NoWait^|-NoWait] [/NoLogo^|-NoLogo] [/NoAnsi^|-NoAnsi] [/h^|-h]
::@Arguments
::  %1: 配置文件
::    指定配置文件路径, 可以省略`.ini`, 默认备份文件`%~n0.old`.
::  o: 指定要执行的操作
::    必选参数: `1`创建符号链接, `2`移除符号链接, `3`退出.
::    默认操作为等待用户选择.
::  NoWait: 执行结束时无等待.
::  NoLogo: 执行前不显示Logo.
::  NoAnsi: 禁用转义序列显示.
::  h: 显示帮助
::@Outputs
::  FILE:
::    符号链接文件或者备份文件.
::  STDOUT: 支持ANSI的交互信息.
::  STDERR: 警告和错误信息.
::@Returns
::  0: 执行成功.
::  N: 执行失败的数量.
::@Examples
::  WinLink.cmd
::  WinLink.cmd XXX
::  WinLink.cmd XXX.ini
::  WinLink.cmd XXX /o 1
::  WinLink.cmd XXX.ini /o 2

::Script:Argument.Parser.CMD::
::Script:Common.AnsiEscape.CMD::
::Script:Common.IsAdmin.CMD::
::Script:Config.FileRead.CMD::
::Script:File.HasAttrib.CMD::
::Script:File.IsExist.CMD::
::Script:File.IsHardLink.CMD::
::Script:File.Remove.CMD::
::Script:Map.ListChild.CMD::
::Script:Path.GetAbsolutePath.CMD::
::Script:Path.GetFileNameExt.CMD::
::Script:Path.GetPath.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::初始化环境
@ECHO OFF
SETLOCAL
SET "PATH=%~dp0Bin;%~dp0Script;%PATH%"
SET "_EXIT_CODE=0"
::解析参数
CALL Argument.Parser.CMD "_ARG" %*
SET "_NOWAIT=%_ARG.OPTION.NoWait%"
IF /I NOT "%_ARG.OPTION.NoAnsi%" == "TRUE" (
  CALL Common.AnsiEscape.CMD "True"
) ELSE (
  CALL Common.AnsiEscape.CMD "False"
)
IF /I NOT "%_ARG.OPTION.NoLogo%" == "TRUE" CALL :SHOW_LOGO
IF /I "%_ARG.OPTION.H%" == "TRUE" (
  CALL :SHOW_HELP
  GOTO :EXIT
)
IF "%_ARG.OPTION.O%" == "1" (
  SET "_OPTION=/D 1 /T 0"
  SET "_NOWAIT=TRUE"
) ELSE IF "%_ARG.OPTION.O%" == "2" (
  SET "_OPTION=/D 2 /T 0"
  SET "_NOWAIT=TRUE"
) ELSE IF "%_ARG.OPTION.O%" == "3" (
  SET "_OPTION=/D 3 /T 0"
  SET "_NOWAIT=TRUE"
) ELSE (
  SET "_OPTION="
)
IF "%_ARG.PARAM.0%" == "" (
  SET "_CONFIG=%~dpn0.ini"
) ELSE IF /I "%_ARG.PARAM.0:~-4%" == ".ini" (
  SET "_CONFIG=%_ARG.PARAM.0%"
) ELSE (
  SET "_CONFIG=%_ARG.PARAM.0%.ini"
)
CALL Path.GetAbsolutePath.CMD "%%_CONFIG%%"
SET "_CONFIG=%@%"
::选择菜单
CALL :SHOW_MENU
CHOICE /C:123 %_OPTION% /M "请选择:"
IF "%ERRORLEVEL%" == "1" (
  SET "_OPTION=MAKE_LINK"
) ELSE IF "%ERRORLEVEL%" == "2" (
  SET "_OPTION=UNDO_LINK"
) ELSE (
  GOTO :EXIT
)
::读取配置文件
CALL :ECHO_LIGHT 配置文件: %%_CONFIG%%
IF NOT EXIST "%_CONFIG%" (
  CALL :ECHO_ERROR ***** 错误: 配置文件不存在! *****
  SET /A "_EXIT_CODE=-1"
  GOTO :EXIT
)
CALL Path.GetPath.CMD "%%_CONFIG%%"
CD /D "%@%"
CALL Config.FileRead.CMD "_CONFIG" "%%_CONFIG%%"
::检查管理员权限
CALL Common.IsAdmin.CMD || (
  CALL :ECHO_ERROR ***** 错误: 需要管理员权限! *****
  SET /A "_EXIT_CODE=-1"
  GOTO :EXIT
)
::遍历执行
CALL Map.ListChild.CMD "_CONFIG"
FOR %%A IN (%@%) DO (
  CALL :READ_SECTION "%%~A"
  CALL :SHOW_SECTION "%%~A"
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

::输出Logo
::@Outputs
::  STDOUT: 帮助
:SHOW_LOGO
ECHO.
ECHO ============================================
ECHO =======         符号链接管理         =======
ECHO ============================================
GOTO :EOF

::输出Help
::@Outputs
::  STDOUT: 帮助
:SHOW_HELP
ECHO.
ECHO 命令行: %~nx0 [配置文件[.ini]] [/o^|-o ^<1^|2^|3^>]
ECHO   [/NoWait^|-NoWait] [/NoLogo^|-NoLogo] [/NoAnsi^|-NoAnsi] [/h^|-h]
ECHO.
ECHO - 配置文件
ECHO   指定配置文件路径, 可以省略`.ini`.
ECHO   默认配置文件`%~n0.ini`.
ECHO.
ECHO - /o ^| -o
ECHO   指定要执行的操作.
ECHO   必选参数: `1`创建符号链接, `2`移除符号链接, `3`退出.
ECHO   默认操作为等待用户选择.
ECHO.
ECHO - /NoWait ^| -NoWait
ECHO   执行结束时无等待.
ECHO.
ECHO - /NoLogo ^| -NoLogo
ECHO   执行前不显示Logo.
ECHO.
ECHO - /NoAnsi ^| -NoAnsi
ECHO   禁用转义序列显示.
ECHO.
ECHO - /h ^| -h
ECHO   显示帮助
ECHO.
GOTO :EOF

::输出Menu
::@Outputs
::  STDOUT: 菜单
::  STDERR: 警告信息
:SHOW_MENU
ECHO.
CALL :ECHO_WARNING ***** 注意: 错误操作可能破坏系统! *****
ECHO.
ECHO 1:创建符号链接
ECHO 2:移除符号链接
ECHO 3:退出
ECHO.
GOTO :EOF

::读取段信息
::@Variables
::  @*, _CONFIG, _LINK, _TARGET, _TYPE, _EXISTING
::@Arguments
::  %1: 配置段名称
::  %_CONFIG%: 配置实例
::@Outputs
::  %_LINK%: 链接路径
::  %_TARGET%: 目标路径
::  %_TYPE%: 链接类型
::  %_EXISTING%: 存在时处理方式
:READ_SECTION
::读取段并展开变量
CALL CALL Path.GetAbsolutePath.CMD "%%_CONFIG.%~1.LINK%%"
SET "_LINK=%@%"
CALL CALL Path.GetAbsolutePath.CMD "%%_CONFIG.%~1.TARGET%%"
SET "_TARGET=%@%"
CALL CALL SET "_TYPE=%%_CONFIG.%~1.TYPE%%"
IF "%_TYPE%" == "" SET "_TYPE=SymbolicLink"
CALL CALL SET "_EXISTING=%%_CONFIG.%~1.EXISTING%%"
IF "%_EXISTING%" == "" CALL SET "_EXISTING=%_CONFIG.EXISTING%"
IF "%_EXISTING%" == "" SET "_EXISTING=Backup"
GOTO :EOF

::输出段信息
::@Variables
::  _LINK, _TARGET, _TYPE, _EXISTING
::@Arguments
::  %1: 配置段名称
::  %_LINK%: 链接路径
::  %_TARGET%: 目标路径
::  %_TYPE%: 链接类型
::  %_EXISTING%: 存在时处理方式
::@Outputs
::  STDOUT: 段信息
:SHOW_SECTION
ECHO.
ECHO [%~1]
ECHO Link: %_LINK%
ECHO Target: %_TARGET%
ECHO Type: %_TYPE%
ECHO Existing: %_EXISTING%
GOTO :EOF

::创建符号链接
::@Variables
::  @*, _LINK, _TARGET, _TYPE, _EXISTING, _MKLINK_ARG
::@Arguments
::  %_LINK%: 链接路径
::  %_TARGET%: 目标路径
::  %_TYPE%: 链接类型
::  %_EXISTING%: 存在时处理方式
::@Outputs
::  STDOUT: 成功或者跳过信息.
::  STDERR: 错误信息
::@Returns
::  0: 执行成功
::  1: 执行失败
::@Notes
::  Backup: 删除旧备份, 执行备份, 创建链接.
::  Override: 删除链接, 创建链接.
::  Skip: 跳过执行.
:MAKE_LINK
::检查链接目标
IF NOT EXIST "%_TARGET%" (
  CALL :ECHO_ERROR ***** 错误: 链接目标不存在! *****
  EXIT /B 1
)
::处理链接类型
IF /I "%_TYPE%" == "SymbolicLink" (
  IF EXIST "%_TARGET%\" (
    SET "_MKLINK_ARG=/D"
  ) ELSE (
    SET "_MKLINK_ARG="
  )
) ELSE IF /I "%_TYPE%" == "Junction" (
  SET "_MKLINK_ARG=/J"
) ELSE IF /I "%_TYPE%" == "HardLink" (
  SET "_MKLINK_ARG=/H"
) ELSE (
  CALL :ECHO_ERROR ***** 错误: 无法识别`Type`参数! *****
  EXIT /B 1
)
::处理链接位置
IF EXIST "%_LINK%" (
  IF /I "%_EXISTING%" == "Backup" (
    CALL File.Remove.CMD "%%_LINK%%.BACKUP" || (
      CALL :ECHO_ERROR ***** 错误: 删除旧备份失败! *****
      EXIT /B 1
    )
    ::::因为MOVE命令无法处理`丢失目标的软链接`, 只能使用RENAME命令.
    CALL Path.GetFileNameExt.CMD "%%_LINK%%"
    CALL RENAME "%%_LINK%%" "%%@%%.BACKUP" 1>NUL || (
      CALL :ECHO_ERROR ***** 错误: 创建备份失败! *****
      EXIT /B 1
    )
  ) ELSE IF /I "%_EXISTING%" == "Override" (
    CALL File.Remove.CMD "%%_LINK%%" || (
      CALL :ECHO_ERROR ***** 错误: 删除旧链接失败! *****
      EXIT /B 1
    )
  ) ELSE IF /I "%_EXISTING%" == "Skip" (
    CALL :ECHO_SKIP 跳过执行.
    EXIT /B 0
  ) ELSE (
    CALL :ECHO_ERROR ***** 错误: 无法识别`Existing`参数! *****
    EXIT /B 1
  )
) ELSE IF NOT EXIST "%_LINK%\.." (
  MKDIR "%_LINK%\.." 1>NUL || (
    CALL :ECHO_ERROR ***** 错误: 创建上级目录失败! *****
    EXIT /B 1
  )
)
::创建链接
MKLINK %_MKLINK_ARG% "%_LINK%" "%_TARGET%" 1>NUL || (
  CALL :ECHO_ERROR ***** 错误: 创建链接失败! *****
  EXIT /B 1
)
CALL :ECHO_SUCCESS 执行完成.
EXIT /B 0

::移除符号链接
::@Variables
::  @*, _LINK, _EXISTING
::@Arguments
::  %_LINK%: 链接路径
::  %_EXISTING%: 存在时处理方式
::@Outputs
::  STDOUT: 成功或者跳过信息.
::  STDERR: 错误信息
::@Returns
::  0: 执行成功
::  1: 执行失败
::@Notes
::  当链接存在, 并且是软连接或硬链接, 执行删除操作.
::  删除后, 判断冲突处理是backup时, 恢复备份.
:UNDO_LINK
CALL File.IsExist.CMD "%%_LINK%%" && (
  CALL File.HasAttrib.CMD "%%_LINK%%" "L" || CALL File.IsHardLink.CMD "%%_LINK%%"
) && (
  CALL File.Remove.CMD "%%_LINK%%" || (
    CALL :ECHO_ERROR ***** 错误: 删除链接失败! *****
    EXIT /B 1
  )
  IF /I "%_EXISTING%" == "Backup" IF EXIST "%_LINK%.BACKUP" (
    ::  因为MOVE命令无法处理`丢失目标的软链接`, 只能使用RENAME命令.
    CALL Path.GetFileNameExt.CMD "%%_LINK%%"
    CALL RENAME "%%_LINK%%.BACKUP" "%%@%%" 1>NUL || (
      CALL :ECHO_ERROR ***** 错误: 恢复备份失败! *****
      EXIT /B 1
    )
  )
  CALL :ECHO_SUCCESS 执行完成.
  EXIT /B 0
)
CALL :ECHO_SKIP 跳过执行.
EXIT /B 0

::输出高亮文本
::@Arguments
::  %*: 文本
::@Outputs
::  STDOUT: 高亮文本
:ECHO_LIGHT
ECHO.
ECHO %ANSI_LIGHT%%*%ANSI_RESET%
GOTO :EOF

::输出成功文本
::@Arguments
::  %*: 文本
::@Outputs
::  STDOUT: 成功文本
:ECHO_SUCCESS
ECHO.
ECHO %ANSI_FG_BRIGHT_GREEN%%*%ANSI_RESET%
GOTO :EOF

::输出跳过文本
::@Arguments
::  %*: 文本
::@Outputs
::  STDOUT: 跳过文本
:ECHO_SKIP
ECHO.
ECHO %ANSI_FG_BRIGHT_BLUE%%*%ANSI_RESET%
GOTO :EOF

::输出警告文本
::@Arguments
::  %*: 文本
::@Outputs
::  STDERR: 警告文本
:ECHO_WARNING
ECHO.
1>&2 ECHO %ANSI_FG_BRIGHT_YELLOW%%*%ANSI_RESET%
GOTO :EOF

::输出错误文本
::@Arguments
::  %*: 文本
::@Outputs
::  STDERR: 错误文本
:ECHO_ERROR
ECHO.
1>&2 ECHO %ANSI_FG_BRIGHT_YELLOW%%ANSI_BG_RED%%*%ANSI_RESET%
GOTO :EOF
