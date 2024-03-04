::�������ӹ���
::@author FB
::@version 1.0.0

::Script:Argument.Parser.CMD::
::Script:Common.Echo.CMD::
::Script:Common.IsAdmin.CMD::
::Script:Config.FileRead.CMD::
::Script:File.HasAttrib.CMD::
::Script:File.IsHardLink.CMD::
::Script:Map.ListChild.CMD::
::Script:Path.GetAbsolutePath.CMD::
::Script:Path.GetFileNameExt.CMD::
::Script:Path.GetPath.CMD::

::��ʼ������
@ECHO OFF
SETLOCAL
SET "PATH=%~dp0Bin;%~dp0Script;%PATH%"
SET "_EXIT_CODE=0"
::�������
ECHO.
ECHO ============================================
ECHO =======         �������ӹ���         =======
ECHO ============================================
::��������
CALL Argument.Parser.CMD "_ARG" %*
::��ȡ�����ļ���
IF "%_ARG.PARAM.0%" == "" (
  SET "_CONFIG=%~dpn0.ini"
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
CALL Common.Echo.CMD "93" "***** ע��: ������������ƻ�ϵͳ! *****"
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
CALL Common.Echo.CMD "1" "�����ļ�: %_CONFIG%"
IF NOT EXIST "%_CONFIG%" (
  ECHO.
  CALL Common.Echo.CMD "93;41" "***** ����: �����ļ�������! *****"
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
  CALL Common.Echo.CMD "93;41" "***** ����: ��Ҫ����ԱȨ��! *****"
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
ECHO.
GOTO :EOF

::::::::::::
::����\����    ����         ������
::Backup       ����,����    ����
::Override     ɾ��,����    ����
::Skip         ����         ����
::::::::::::
:MAKE_LINK
::�������Ŀ��
IF NOT EXIST "%_TARGET%" (
  CALL Common.Echo.CMD "93;41" "***** ����: ����Ŀ�겻����! *****"
  EXIT /B 1
)
::������������
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
  CALL Common.Echo.CMD "93;41" "***** ����: �޷�ʶ��`Type`����! *****"
  EXIT /B 1
)
::��������λ��
IF EXIST "%_LINK%" (
  IF /I "%_EXISTED%" == "Backup" (
    IF EXIST "%_LINK%.BACKUP" CALL :REMOVE "%%_LINK%%.BACKUP" || (
      CALL Common.Echo.CMD "93;41" "***** ����: ɾ���ɱ���ʧ��! *****"
      EXIT /B 1
    )
    ::  ��ΪMOVE�����޷�����`��ʧĿ���������`, ֻ��ʹ��RENAME����.
    CALL Path.GetFileNameExt.CMD "%%_LINK%%"
    CALL RENAME "%%_LINK%%" "%%@%%.BACKUP" 1>NUL || (
      CALL Common.Echo.CMD "93;41" "***** ����: ��������ʧ��! *****"
      EXIT /B 1
    )
  ) ELSE IF /I "%_EXISTED%" == "Override" (
    CALL :REMOVE "%%_LINK%%" || (
      CALL Common.Echo.CMD "93;41" "***** ����: ɾ��������ʧ��! *****"
      EXIT /B 1
    )
  ) ELSE IF /I "%_EXISTED%" == "Skip" (
    CALL Common.Echo.CMD "94" "����ִ��."
    EXIT /B 0
  ) ELSE (
    CALL Common.Echo.CMD "93;41" "***** ����: �޷�ʶ��`Existed`����! *****"
    EXIT /B 1
  )
) ELSE IF NOT EXIST "%_LINK%\.." (
  MKDIR "%_LINK%\.." 1>NUL || (
    CALL Common.Echo.CMD "93;41" "***** ����: �����ϼ�Ŀ¼ʧ��! *****"
    EXIT /B 1
  )
)
::��������
MKLINK %_MKLINK_ARG% "%_LINK%" "%_TARGET%" 1>NUL || (
  CALL Common.Echo.CMD "93;41" "***** ����: ��������ʧ��! *****"
  EXIT /B 1
)
CALL Common.Echo.CMD "92" "ִ�����."
EXIT /B 0

::::::::::::
::����\����     ����    �ļ�    ������
::Backup(��)    �ָ�    ����    ����
::Backup(��)    ɾ��    ����    ����
::Override      ɾ��    ����    ����
::Skip          ɾ��    ����    ����
:::::::::::::
:UNDO_LINK
::��������λ��
CALL :IS_LINK "%%_LINK%%" && (
  CALL :REMOVE "%%_LINK%%" || (
    CALL Common.Echo.CMD "93;41" "***** ����: ɾ������ʧ��! *****"
    EXIT /B 1
  )
  IF /I "%_EXISTED%" == "Backup" IF EXIST "%_LINK%.BACKUP" (
    ::  ��ΪMOVE�����޷�����`��ʧĿ���������`, ֻ��ʹ��RENAME����.
    CALL Path.GetFileNameExt.CMD "%%_LINK%%"
    CALL RENAME "%%_LINK%%.BACKUP" "%%@%%" 1>NUL || (
      CALL Common.Echo.CMD "93;41" "***** ����: �ָ�����ʧ��! *****"
      EXIT /B 1
    )
  )
) || (
  CALL Common.Echo.CMD "94" "����ִ��."
  EXIT /B 0
)
CALL Common.Echo.CMD "92" "ִ�����."
EXIT /B 0

:REMOVE
CALL File.HasAttrib.CMD "%~1" "D" && (
  RD /S /Q "%~1" 1>NUL || EXIT /B 1
) || (
  DEL /F /Q "%~1" 1>NUL || EXIT /B 1
)
EXIT /B 0

:IS_LINK
CALL File.HasAttrib.CMD "%~1" "L" && EXIT /B 0
CALL File.IsHardLink.CMD "%~1" && EXIT /B 0
EXIT /B 1
