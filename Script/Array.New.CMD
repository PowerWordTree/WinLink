::@author FB
::@version 0.1.0

::������֯: A.1=* A.2=* A.3=*
::���ݳ���: %A.@ARRAY%
::���ݴ���: CALL Array.New.CMD A;
::��������: CALL Array_Push.CMD A "*";
::���ݷ���: CALL Array_Get.CMD A 1; CALL :ARRAY_POP A 2;
::���ݱ���: CALL Array_List.CMD A "ECHO {0} {1}";
::��������: CALL Array_Destroy.CMD A;

::����
::  ����1: ʵ������

::Script:Array.Destroy.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL Array.Destroy.CMD "%~1"
SET /A "%~1.@ARRAY=0"
EXIT /B