::�������ӹ���
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

::��ʼ������
@ECHO OFF
SETLOCAL
CD /D "%~dp0"
SET "PATH=%~dp0Bin;%~dp0Script;%PATH%"
SET /A "_EXIT_CODE=0"
::�������
ECHO.
ECHO ============================================
ECHO =======         �������ӹ���          ======
ECHO ============================================
::��������
CALL Argument.Parser.CMD "_ARG" %*
::��ȡ�����ļ���
IF "%_ARG.PARAM.0%" == "" (
  SET "_CONFIG=%~n0.ini"
) ELSE IF /I "%_ARG.PARAM.0:~-4%" == ".ini" (
  SET "_CONFIG=%_ARG.PARAM.0%"
) ELSE (
  SET "_CONFIG=%_ARG.PARAM.0%.ini"
)
::��ȡѡ�����
IF "%_ARG.OPTION.O%" == "1" (
  SET "_OPTION=/D 1 /T 0"
) ELSE IF "%_ARG.OPTION.O%" == "2" (
  SET "_OPTION=/D 2 /T 0"
) ELSE IF "%_ARG.OPTION.O%" == "3" (
  SET "_OPTION=/D 3 /T 0"
) ELSE (
  SET "_OPTION="
)
::�������
IF /I "%_ARG.OPTION.H%" == "TRUE" (
  ECHO.
  ECHO ������: %~nx0 [�����ļ�[.ini]] [/o^|-o ^<1^|2^|3^>] [/h^|-h]
  ECHO.
  ECHO - �����ļ�
  ECHO   ָ�������ļ�·��, ����ʡ��`.ini`.
  ECHO   �����ļ�����������ļ�������, ��չ��Ϊ`.old`.
  ECHO   Ĭ�������ļ�`%~n0.ini`, Ĭ�ϱ����ļ�`%~n0.old`.
  ECHO.
  ECHO - /o ^| -o
  ECHO   ָ��Ҫִ�еĲ���.
  ECHO   ��ѡ����: `1`������������, `2`�Ƴ���������, `3`�˳�.
  ECHO   Ĭ�ϲ���Ϊ�ȴ��û�ѡ��.
  ECHO.
  ECHO - /h ^| -h
  ECHO   ��ʾ����
  ECHO.
  GOTO :EXIT
)
::ѡ��˵�
ECHO.
ECHO ***** ע��: ����������ܶ�ϵͳ����ƻ�! *****
ECHO.
ECHO 1:������������
ECHO 2:�Ƴ���������
ECHO 3:�˳�
ECHO.
CHOICE /C:123 %_OPTION% /M "��ѡ��:"
IF "%ERRORLEVEL%" == "1" (
  SET "_OPTION=MAKE_LINK"
) ELSE IF "%ERRORLEVEL%" == "2" (
  SET "_OPTION=UNDO_LINK"
) ELSE (
  GOTO :EXIT
)
::��ȡ�����ļ�
ECHO.
ECHO �����ļ�: %_CONFIG%
IF NOT EXIST "%_CONFIG%" (
  ECHO.
  ECHO ***** ����, �����ļ�������! *****
  SET /A "_EXIT_CODE=-1"
  GOTO :EXIT
)
CALL Path.GetAbsolutePath.CMD "%%_CONFIG%%"
SET "_CONFIG=%@%"
CALL Path.GetPath.CMD "%%_CONFIG%%"
CD /D "%@%"
CALL Config.FileRead.CMD "_CONFIG" "%%_CONFIG%%"
::������ԱȨ��
CALL Common.IsAdmin.CMD || (
  ECHO.
  ECHO ***** ����, ��Ҫ����ԱȨ��! *****
  SET /A "_EXIT_CODE=-1"
  GOTO :EXIT
)
::����ִ��
CALL Map.ListChild.CMD "_CONFIG"
FOR %%A IN (%@%) DO (
  CALL :READ_SECTION "%%~A"
  CALL :%_OPTION% || SET /A "_EXIT_CODE+=1"
)
::�˳�
:EXIT
IF "%_ARG.OPTION.O%" == "" (
  ECHO.
  ECHO ���������������
  PAUSE >NUL
)
ENDLOCAL & EXIT /B %_EXIT_CODE%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:READ_SECTION
::��ȡ�β�չ������
CALL CALL Path.GetAbsolutePath.CMD "%%_CONFIG.%~1.LINK%%"
SET "_LINK=%@%"
CALL CALL Path.GetAbsolutePath.CMD "%%_CONFIG.%~1.TARGET%%"
SET "_TARGET=%@%"
CALL CALL SET "_TYPE=%%_CONFIG.%~1.TYPE%%"
IF "%_TYPE%" == "" SET "_TYPE=SymbolicLink"
CALL CALL SET "_EXISTED=%%_CONFIG.%~1.EXISTED%%"
IF "%_EXISTED%" == "" CALL SET "_EXISTED=%_CONFIG.EXISTED%"
IF "%_EXISTED%" == "" SET "_EXISTED=Backup"
::�������Ϣ
ECHO.
ECHO [%~1]
ECHO Link: %_LINK%
ECHO Target: %_TARGET%
ECHO Type: %_TYPE%
ECHO Existed: %_EXISTED%
GOTO :EOF

::::::::::::
::����\����    ����         ������
::Backup       �ƶ�,����    ����
::Override     ɾ��,����    ����
::Skip         ����         ����
::::::::::::
:MAKE_LINK
::��������λ��
IF EXIST "%_LINK%" (
  IF /I "%_EXISTED%" == "Backup" (
    MOVE /Y "%_LINK%" "%_LINK%.BACKUP" 1>NUL || (
      ECHO.
      ECHO ***** ����, ����`Target`ʧ��! *****
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
      ECHO ***** ����, ɾ��`Target`ʧ��! *****
      EXIT /B 1
    )
  ) ELSE IF /I "%_EXISTED%" == "Skip" (
    ECHO.
    ECHO Ŀ���Ѿ�����, ����.
    EXIT /B 0
  ) ELSE (
    ECHO.
    ECHO ***** ����, �޷�ʶ��`Existed`����! *****
    EXIT /B 1
  )
) ELSE IF NOT EXIST "%_LINK%\.." (
  MKDIR "%_LINK%\.." 1>NUL || (
    ECHO.
    ECHO ***** ����, ����`Target`�ϼ�Ŀ¼ʧ��! *****
    EXIT /B 1
  )
)
::��������
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
  ECHO ***** ����, �޷�ʶ��`Type`����! *****
  EXIT /B 1
)
CALL %%_COMMAND%% "%%_LINK%%" "%%_TARGET%%" 1>NUL || (
  ECHO.
  ECHO ***** ����, ��������ʧ��! *****
  EXIT /B 1
)
ECHO.
ECHO �������.
EXIT /B 0

::::::::::::
::����\����     ����    �ļ�    ������
::Backup(��)    �ƶ�    ����    ����
::Backup(��)    ɾ��    ����    ����
::Override      ɾ��    ����    ����
::Skip          ɾ��    ����    ����
:::::::::::::
:UNDO_LINK
::��������
(CALL File.HasAttrib.CMD "%%_LINK%%" "L" ^
  || CALL File.IsHardLink.CMD "%%_LINK%%") && (
  CALL File.HasAttrib.CMD "%%_LINK%%" "D" && (
    SET "_COMMAND=RMDIR /S /Q"
  ) || (
    SET "_COMMAND=DEL /F /Q"
  )
  CALL %%_COMMAND%% "%%_LINK%%" 1>NUL || (
    ECHO.
    ECHO ***** ����, ɾ��`Target`ʧ��! *****
    EXIT /B 1
  )
  IF /I "%_EXISTED%" == "Backup" IF EXIST "%_LINK%.BACKUP" (
    MOVE /Y "%_LINK%.BACKUP" "%_LINK%" 1>NUL || (
      ECHO.
      ECHO ***** ����, �ָ�`Target`ʧ��! *****
      EXIT /B 1
    )
  )
) || (
  ECHO.
  ECHO Ŀ�겻������, ����.
  EXIT /B 0
)
ECHO.
ECHO �������.
EXIT /B 0
