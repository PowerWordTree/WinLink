::@author FB
::@version 0.1.0

::数据组织: A.1=* A.2=* A.3=*
::数据长度: %A.@ARRAY%
::数据创建: CALL Array.New.CMD A;
::数据添加: CALL Array_Push.CMD A "*";
::数据访问: CALL Array_Get.CMD A 1; CALL :ARRAY_POP A 2;
::数据遍历: CALL Array_List.CMD A "ECHO {0} {1}";
::数据销毁: CALL Array_Destroy.CMD A;

::创建
::  参数1: 实例名称

::Script:Array.Destroy.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL Array.Destroy.CMD "%~1"
SET /A "%~1.@ARRAY=0"
EXIT /B
