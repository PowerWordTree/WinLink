::@author FB
::@version 0.1.0

::10.0.10586	1511
::10.0.18363	1909

::��չ���
::  ����1: ��ʾ����(��`;`�ָ�)
::  ����2: ��ʾ�ı�
::  ���: ������չ���ı�

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