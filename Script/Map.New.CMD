::@author FB
::@version 0.1.0

::数据组织: A.XX=* A.YY=* A.ZZ=*
::元素列表: A.@LIST A.B.@LIST A.C.@LIST
::子项列表: A.@CHILD A.B.@CHILD A.C.@CHILD
::数据创建: CALL Map_New.CMD A;
::数据添加: CALL Map_Push.CMD A XX "*";
::数据访问: CALL Map_Get.CMD A XX; CALL :ARRAY_REMOVE A YY;
::数据遍历: CALL Map_List.CMD A "ECHO {0} {1}";
::数据销毁: CALL Map_Destroy.CMD A;

::创建
::  参数1: 实例名称

::Script:Map.Destroy.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL Map.Destroy.CMD "%~1"
SET "%~1.@LIST=;"
SET "%~1.@CHILD=;"
EXIT /B
