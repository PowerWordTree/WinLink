::@author FB
::@version 0.1.0

::使用(SET "@=%*")也可以达到同样目的
::但存在无法使用双引号包裹参数问题, 遇到特殊符号会产生歧义

::去首尾空格
::  参数1: 目标字符串
::  返回@: 处理后的字符串

::Script:String.TrimStart.CMD::
::Script:String.TrimEnd.CMD::

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET "@=%~1"
CALL String.TrimStart.CMD "%%@%%"
CALL String.TrimEnd.CMD "%%@%%"
EXIT /B
