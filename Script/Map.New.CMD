::@author FB
::@version 0.1.0

::������֯: A.XX=* A.YY=* A.ZZ=*
::Ԫ���б�: A.@LIST A.B.@LIST A.C.@LIST
::�����б�: A.@CHILD A.B.@CHILD A.C.@CHILD
::���ݴ���: CALL Map_New.CMD A;
::��������: CALL Map_Push.CMD A XX "*";
::���ݷ���: CALL Map_Get.CMD A XX; CALL :ARRAY_REMOVE A YY;
::���ݱ���: CALL Map_List.CMD A "ECHO {0} {1}";
::��������: CALL Map_Destroy.CMD A;

::����
::  ����1: ʵ������

::Script:Map.Destroy.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL Map.Destroy.CMD "%~1"
SET "%~1.@LIST=;"
SET "%~1.@CHILD=;"
EXIT /B