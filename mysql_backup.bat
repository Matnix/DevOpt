@echo off
cls
color 1E
title %date% %time:~,8% ����MYSQL���ݿ� BY:REKFAN 
::::::::::::::::::::::::��������Ҫ���õĲ���::::::::::::::::::::::::

        rem ���� MySql������root�˺ŵ�����,���������Ҫ����ǰ�������^,��!��>��|��^��&��* ��
        SET MySql_pw=HuaNeng@123
        rem ���� ���ݿⱸ��Ŀ¼
        SET BAK_Dir=E:\mysql_db_bak1230
        rem ���� ��Ҫ���ݵ�myisam��ʽ���ݿ�
        SET BAK_db_myisam=
        rem ���� ��Ҫ���ݵ�innodb��ʽ���ݿ�
        SET BAK_db_innodb=oxhide_storehouse,storehouse
        rem ���� �Զ�ɾ������ı���,0Ϊɾ������,����
        SET Bak_Time_ago=5
        rem ���� WinRARѹ�������·��
        ::SET RAR_Dir="C:\Program Files\WinRAR\WinRAR.exe"
		SET RAR_Dir="C:\Program Files (x86)\7-Zip\7z.exe"
        rem ���� ��2001-01-01��ʽ������Ϊ��Ŀ¼
        SET BAK_Dir2=%date:~0,4%-%date:~5,2%-%date:~8,2%
        rem ���� �����ļ���
        SET BAK_FILE=%%i_%BAK_Dir2%.sql
        rem ���� ��־�ļ���
        SET LOG_FILE=%BAK_Dir%\%BAK_Dir2%\MY_DBBAK.log

::::::::::::::::::::::::��������Ҫ���õĲ���::::::::::::::::::::::::

echo. �ԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡ�
echo. ��                                                                   ��
echo. �� ���ڱ��ű�                                                        ��
echo. �� ::���ű�ֻ���Զ���MySql_pw��BAK_Dir��Bak_Time_ago��RAR_Dir��ֵ    ��
echo. �� ::���ű���������ʱVBS����������ڼ���                             ��
echo. �� ::���ű�Ϊ���ݲ�ͬ�����ڸ�ʽ������reg����,ͳһ�������ڸ�ʽ        ��
echo. �� ::���ű��Զ��������ݿ�.sql�ű������Զ�ѹ��Ϊ.rar�ļ�              ��
echo. �� ::���ű��Զ�������־�ļ���x:\xxxx\0000-00-00\MY_DBBAK.log         ��
echo. �� ::���ű����ݿⱸ��·��Ϊx:\xxxx\0000-00-00\���ݿ���_0000-00-00.rar��
echo. �� ::���ű���������windows�ƻ�������ִ��,��ȥ���ű��������pause   ��
echo. �� ::��ÿ����������Mysql������һ��,���ݵĺ���������и���            ��
echo. �� ::���ű�û�а�Ȩ,���������Ϊ�Լ���Ҫ��Ч��,ת������ɾ����ע����䩧
echo. ��                                              		               ��
echo. �ԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡԡ�
echo.

if not defined MySql_pw (echo MySql_pw ��δ���壡) 
if not defined BAK_Dir (echo BAK_Dir ��δ���壡) 
if not defined Bak_Time_ago (echo Bak_Time_ago ��δ���壡)
if not defined RAR_Dir (RAR_Dir ��δ���壡)

:: ȡ�õ�ǰ�����ʱ��,�� yyyy-MM-dd ��ʽ��ʾ
for /f "skip=2 delims=" %%a in ('reg query "HKEY_CURRENT_USER\Control Panel\International" /v sShortDate') do (
SET RegDateOld=%%a
)
SET RegDateOld=%RegDateOld:~-8%
::ͨ���ı�ע���ı����������ڸ�ʽ
reg add "HKEY_CURRENT_USER\Control Panel\International" /v sShortDate /t REG_SZ /d yyyy-M-d /f>nul
>"%temp%\DstDate.vbs" echo LastDate=date()-%Bak_Time_ago%
>>"%temp%\DstDate.vbs" echo FmtDate=right(year(LastDate),4) ^& right("0" ^& month(LastDate),2) ^& right("0" ^& day(LastDate),2)
>>"%temp%\DstDate.vbs" echo wscript.echo FmtDate
for /f %%a in ('cscript /nologo "%temp%\DstDate.vbs"') do (
SET DstDate=%%a
)
::ɾ��ָ��ʱ��ǰ�ı���
SETlocal enabledelayedexpansion
echo. ɾ�� %BAK_Dir2%��%Bak_Time_ago%����ǰ�ı����ļ�
for /f "delims= " %%i in ('dir /ad/b %BAK_Dir%\????-??-??') do (
SET t1=%%i
SET t2=!t1:~0,4!!t1:~5,2!!t1:~8,2!
if /i !t2! leq %DstDate% (
DEL /F /A /Q \\?\%BAK_Dir%\!t1!\*.*
rd /q /s \\?\%BAK_Dir%\!t1!
echo. �����ļ���%BAK_Dir%\!t1!ɾ�����!) 
)
:: ��ԭ�����ע�������ڸ�ʽ
reg add "HKEY_CURRENT_USER\Control Panel\International" /v sShortDate /t REG_SZ /d %RegDateOld% /f>nul

echo. 
:: ��¼ʱ����־
echo ����ʱ��:%BAK_Dir2% %time:~0,8%  >> %LOG_FILE%
echo /++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ >> %LOG_FILE%
if not defined BAK_db_myisam (goto innodb) 
echo. ��ʼ�Ե�ǰ���ڴ����ļ���
if not exist %BAK_Dir%\%BAK_Dir2% md %BAK_Dir%\%BAK_Dir2%
cd /d %BAK_Dir%\%BAK_Dir2%
echo. ��ʼ��������(%BAK_Dir2%)�ı���
:: ���ݵĺ��Ĵ���
SETLocal DisableDelayedExpansion
for %%i in (%BAK_db_myisam%) do (
mysqldump -hlocalhost -uroot -p%MySql_pw% --default-character-set=GB2312 -R --triggers --hex-blob -x %%i >%BAK_FILE%
rem ���ϵĲ��������Լ����������,���ֲ��������뿴 http://blog.rekfan.com/?p=57 
%RAR_Dir% a %BAK_FILE:~0,-4%.rar %BAK_FILE%
DEL /F /A /Q %BAK_FILE% 
echo ���ݿ⡾%%i�� �Ѿ����ݵ�%BAK_Dir%\%BAK_Dir2%\%BAK_FILE%.rar >> %LOG_FILE%
)

:innodb
if not defined BAK_db_innodb (goto exitbat)
echo. ��ʼ�Ե�ǰ���ڴ����ļ���
if not exist %BAK_Dir%\%BAK_Dir2% md %BAK_Dir%\%BAK_Dir2%
cd /d %BAK_Dir%\%BAK_Dir2%
echo. ��ʼ��������(%BAK_Dir2%)�ı���
SETLocal DisableDelayedExpansion
for %%i in (%BAK_db_innodb%) do (
"D:\Program Files\MySQL\MySQL Server 5.6\bin\mysqldump" -h127.0.0.1 --port=3737 -uroot -p%MySql_pw% --default-character-set=utf8 -R --triggers --hex-blob --single-transaction -B %%i >%BAK_FILE%  
%RAR_Dir% a %BAK_FILE:~0,-4%.zip %BAK_FILE% 
DEL /F /A /Q %BAK_FILE% 
echo ���ݿ⡾%%i�� �Ѿ����ݵ�%BAK_Dir%\%BAK_Dir2%\%BAK_FILE%.zip >> %LOG_FILE%
)

:exitbat
echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++/ >> %LOG_FILE%
if exist php.ini DEL /F /A /Q php.ini
echo. ���б��ݽ������
:: �������
        SET MySql_pw=
        SET BAK_Dir=
        SET Bak_Time_ago=
        SET RAR_Dir=
        SET BAK_Dir2=
        SET BAK_FILE=
        SET LOG_FILE=

