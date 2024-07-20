::@y00185015#20111222# version 0.3
::修订内容：增加 以时间为 名称保存 文件
::@y00185925#20111223# version 0.4
::修订内容：增加8960平台下的log，导出dropbox、tombstones、corefile内容


echo 当前时间是：%time% 即 %time:~0,2%点%time:~3,2%分%time:~6,2%秒%time:~9,2%厘秒

set hh=%time:~0,2%
if "%hh:~0,1%"==" " (set "hh=%hh:~1,1%")

rem set date_time="%time:~3,2%"
set date_time="%date:~0,4%%date:~5,2%%date:~8,2%_%hh%%time:~3,2%"
set Folder="Logs_%date_time%_App&RilLog"
mkdir %Folder%
cd %Folder%


adb pull /data/log/android_logs/
adb pull /data/log/hilogs/
adb shell dumpsys activity service com.android.phone.TelephonyDebugService >  TelephonyDebugService.txt
adb shell dumpsys carrier_config > carrier.txt
adb shell dumpsys hwCarrierConfig > hwCarrier.txt
adb shell dumpsys telecom >telecom.txt
adb shell dumpsys telephony.registry >telephony.registry.txt
adb shell dumpsys telephony_ims >telephony_ims.txt
adb shell dumpsys iphonesubinfo >iphonesubinfo.txt
adb shell dumpsys phone >phone.txt
adb shell dumpsys phone_apdu >phone_apdu.txt
adb shell dumpsys simphonebook >simphonebook.txt
adb pull /data/system/dropbox/
adb pull /data/anr
adb pull /data/tombstones
adb pull data/user_de/0/com.android.providers.telephony/databases
adb pull data/data/com.android.providers.contacts/databases
adb pull data/system/users/0/settings_global.xml .
adb pull data/system/users/0/settings_system.xml .
adb pull data/system/users/0/settings_secure.xml .
adb pull /data/user_de/0/com.android.phone/shared_prefs/nr_switch.xml
adb shell getprop > prop.txt