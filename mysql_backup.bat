@echo off
cls
color 1E
title %date% %time:~,8% 备份MYSQL数据库 BY:REKFAN 
::::::::::::::::::::::::以下是需要配置的参数::::::::::::::::::::::::

        rem 设置 MySql服务器root账号的密码,特殊符号需要在其前添加两个^,如!、>、|、^、&、* 等
        SET MySql_pw=HuaNeng@123
        rem 设置 数据库备份目录
        SET BAK_Dir=E:\mysql_db_bak1230
        rem 设置 需要备份的myisam格式数据库
        SET BAK_db_myisam=
        rem 设置 需要备份的innodb格式数据库
        SET BAK_db_innodb=oxhide_storehouse,storehouse
        rem 设置 自动删除几天的备份,0为删除所有,慎用
        SET Bak_Time_ago=5
        rem 设置 WinRAR压缩软件的路径
        ::SET RAR_Dir="C:\Program Files\WinRAR\WinRAR.exe"
		SET RAR_Dir="C:\Program Files (x86)\7-Zip\7z.exe"
        rem 设置 以2001-01-01格式的日期为子目录
        SET BAK_Dir2=%date:~0,4%-%date:~5,2%-%date:~8,2%
        rem 设置 备份文件名
        SET BAK_FILE=%%i_%BAK_Dir2%.sql
        rem 设置 日志文件名
        SET LOG_FILE=%BAK_Dir%\%BAK_Dir2%\MY_DBBAK.log

::::::::::::::::::::::::以上是需要配置的参数::::::::::::::::::::::::

echo. ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡
echo. ┃                                                                   ┃
echo. ┃ 关于本脚本                                                        ┃
echo. ┃ ::本脚本只需自定义MySql_pw、BAK_Dir、Bak_Time_ago、RAR_Dir的值    ┃
echo. ┃ ::本脚本调用了临时VBS代码进行日期计算                             ┃
echo. ┃ ::本脚本为兼容不同的日期格式，调用reg命令,统一设置日期格式        ┃
echo. ┃ ::本脚本自动生成数据库.sql脚本，并自动压缩为.rar文件              ┃
echo. ┃ ::本脚本自动生成日志文件在x:\xxxx\0000-00-00\MY_DBBAK.log         ┃
echo. ┃ ::本脚本数据库备份路径为x:\xxxx\0000-00-00\数据库名_0000-00-00.rar┃
echo. ┃ ::本脚本如果想放在windows计划任务里执行,请去掉脚本里的所有pause   ┃
echo. ┃ ::因每个服务器的Mysql环境不一样,备份的核心语句自行更改            ┃
echo. ┃ ::本脚本没有版权,可以任意改为自己想要的效果,转载请勿删除该注释语句┃
echo. ┃                                              		               ┃
echo. ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡
echo.

if not defined MySql_pw (echo MySql_pw 尚未定义！) 
if not defined BAK_Dir (echo BAK_Dir 尚未定义！) 
if not defined Bak_Time_ago (echo Bak_Time_ago 尚未定义！)
if not defined RAR_Dir (RAR_Dir 尚未定义！)

:: 取得当前计算机时间,以 yyyy-MM-dd 格式显示
for /f "skip=2 delims=" %%a in ('reg query "HKEY_CURRENT_USER\Control Panel\International" /v sShortDate') do (
SET RegDateOld=%%a
)
SET RegDateOld=%RegDateOld:~-8%
::通过改变注册表改变计算机的日期格式
reg add "HKEY_CURRENT_USER\Control Panel\International" /v sShortDate /t REG_SZ /d yyyy-M-d /f>nul
>"%temp%\DstDate.vbs" echo LastDate=date()-%Bak_Time_ago%
>>"%temp%\DstDate.vbs" echo FmtDate=right(year(LastDate),4) ^& right("0" ^& month(LastDate),2) ^& right("0" ^& day(LastDate),2)
>>"%temp%\DstDate.vbs" echo wscript.echo FmtDate
for /f %%a in ('cscript /nologo "%temp%\DstDate.vbs"') do (
SET DstDate=%%a
)
::删除指定时间前的备份
SETlocal enabledelayedexpansion
echo. 删除 %BAK_Dir2%〔%Bak_Time_ago%〕天前的备份文件
for /f "delims= " %%i in ('dir /ad/b %BAK_Dir%\????-??-??') do (
SET t1=%%i
SET t2=!t1:~0,4!!t1:~5,2!!t1:~8,2!
if /i !t2! leq %DstDate% (
DEL /F /A /Q \\?\%BAK_Dir%\!t1!\*.*
rd /q /s \\?\%BAK_Dir%\!t1!
echo. 备份文件夹%BAK_Dir%\!t1!删除完成!) 
)
:: 还原计算机注册表的日期格式
reg add "HKEY_CURRENT_USER\Control Panel\International" /v sShortDate /t REG_SZ /d %RegDateOld% /f>nul

echo. 
:: 记录时间日志
echo 备份时间:%BAK_Dir2% %time:~0,8%  >> %LOG_FILE%
echo /++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ >> %LOG_FILE%
if not defined BAK_db_myisam (goto innodb) 
echo. 开始以当前日期创建文件夹
if not exist %BAK_Dir%\%BAK_Dir2% md %BAK_Dir%\%BAK_Dir2%
cd /d %BAK_Dir%\%BAK_Dir2%
echo. 开始建立今天(%BAK_Dir2%)的备份
:: 备份的核心代码
SETLocal DisableDelayedExpansion
for %%i in (%BAK_db_myisam%) do (
mysqldump -hlocalhost -uroot -p%MySql_pw% --default-character-set=GB2312 -R --triggers --hex-blob -x %%i >%BAK_FILE%
rem 以上的参数根据自己的需求更改,部分参数方法请看 http://blog.rekfan.com/?p=57 
%RAR_Dir% a %BAK_FILE:~0,-4%.rar %BAK_FILE%
DEL /F /A /Q %BAK_FILE% 
echo 数据库【%%i】 已经备份到%BAK_Dir%\%BAK_Dir2%\%BAK_FILE%.rar >> %LOG_FILE%
)

:innodb
if not defined BAK_db_innodb (goto exitbat)
echo. 开始以当前日期创建文件夹
if not exist %BAK_Dir%\%BAK_Dir2% md %BAK_Dir%\%BAK_Dir2%
cd /d %BAK_Dir%\%BAK_Dir2%
echo. 开始建立今天(%BAK_Dir2%)的备份
SETLocal DisableDelayedExpansion
for %%i in (%BAK_db_innodb%) do (
"D:\Program Files\MySQL\MySQL Server 5.6\bin\mysqldump" -h127.0.0.1 --port=3737 -uroot -p%MySql_pw% --default-character-set=utf8 -R --triggers --hex-blob --single-transaction -B %%i >%BAK_FILE%  
%RAR_Dir% a %BAK_FILE:~0,-4%.zip %BAK_FILE% 
DEL /F /A /Q %BAK_FILE% 
echo 数据库【%%i】 已经备份到%BAK_Dir%\%BAK_Dir2%\%BAK_FILE%.zip >> %LOG_FILE%
)

:exitbat
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++/ >> %LOG_FILE%
if exist php.ini DEL /F /A /Q php.ini
echo. 所有备份建立完毕
:: 清除变量
        SET MySql_pw=
        SET BAK_Dir=
        SET Bak_Time_ago=
        SET RAR_Dir=
        SET BAK_Dir2=
        SET BAK_FILE=
        SET LOG_FILE=

