# 符号链接设置

批量添加 Windows 符号链接的工具.

根据配置文件设置 Windows 符号链接, 当前工作目录为配置文件所在目录.

## 配置文件

配置文件为非标准 INI 格式, 使用 ANSI 编码.

默认配置文件名与脚本同名但扩展名不同, 配置文件扩展名`.ini`.

### 格式

- 注释行

  以`#`或者`;`开头的行.

- 无效行

  不含`=`或者键值为空.

- 段

  以`[]`包裹的行.

- 键

  行第一个`=`左边的字符串.

- 值

  行第一个`=`右边的字符串.

### 内容

- 段名

  段名可以随意指定, 但不能包含特殊符号(如: 空格,`&`,`|`,`%`等). 仅起到标记作用, 无实际意义.

- 链接(Link)

  段内键值, 键`Link`, 值为链接路径. 链接会创建到此路径, 相对路径会自动补全.

- 目标(Target)

  段内键值, 键`Target`, 值为目标路径. 链接目标的路径, 相对路径会自动补全.

- 类型(Type)

  段内键值, 键`Type`, 可选值`SymbolicLink/Junction/HardLink`, 默认值`SymbolicLink`. 链接的类型, 会根据此参数创建链接. 其中`SymbolicLink`支持目录和文件, `Junction`仅支持目录, `HardLink`仅支持文件.

- 冲突操作(Existed)

  在段外为全局设置, 在段内为局部设置, 局部设置优先. 键`Existed`, 可选值`Backup/Override/Skip`, 默认值`Backup`. 明确定义目标存在时的操作, `Backup`为备份, `Override`为覆盖, `Skip`为跳过.

- 变量和转义

  配置文件中`%`包裹的变量, 在执行时会被展开. 需要保留`%`时, 用`%%`方式进行转义.

### 执行顺序

会根据配置文件顺序执行.

### 示例

```ini
Existed=Backup

[XXX]
Link=dir/or/file
Target=dir/or/file
Type=SymbolicLink
Existed=Skip

[YYY]
Link=dir/or/file
Target=dir/or/file
Type=Junction
Existed=Override
```

```ini
[XXX]
Link=dir/or/file
Target=dir/or/file

[YYY]
Link=dir/or/file
Target=dir/or/file
```

## 命令行:

命令行: WinLink.cmd [配置文件[.ini]] [/o|-o <1|2|3>] [/h|-h]

- 配置文件

  指定配置文件, 可以省略`.ini`, 默认配置文件`WinLink.ini`.

- `/o` | `-o`

  指定要执行的操作. 必选参数, `1`创建符号链接, `2`移除符号链接, `3`退出. 默认为等待用户选择.

- `/h` | `-h`

  显示帮助

### 示例

```bat
WinLink.cmd
WinLink.cmd XXX
WinLink.cmd XXX.ini
WinLink.cmd XXX /o 1
WinLink.cmd XXX.ini /o 2
```
