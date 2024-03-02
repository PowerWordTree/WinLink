::@author FB
::@version 0.1.0

::销毁
::  参数1: 实例名称

::Script:Map.Destroy.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CALL SET "@=%%%~1.@LIST%%"
FOR %%A IN (%@%) DO (
  SET "%~1.%%~A="
)
CALL SET "@=%%%~1.@CHILD%%"
FOR %%A IN (%@%) DO (
  CALL Map.Destroy.CMD "%~1.%%~A"
)
SET "%~1.@LIST=" & SET "%~1.@CHILD="
EXIT /B
