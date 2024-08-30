adb wait-for-device
adb root

adb shell setprop persist.vendor.log.tel_dbg 1
adb shell setprop persist.log.tag.AT V
adb shell setprop persist.log.tag.RIL V
adb shell setprop persist.log.tag.ImsApp V
adb shell setprop persist.log.tag.IMS_RILA V
adb shell setprop persist.log.tag.ImsManager V
adb shell setprop persist.log.tag.ImsService V
adb shell setprop persist.log.tag.ImsCallProfile V
adb shell setprop persist.log.tag.ImsCallSession V
adb shell setprop persist.log.tag.Telecom V 
adb shell setprop persist.log.tag.MtkImsManager V
adb shell setprop persist.log.tag.MtkImsService V
adb shell setprop persist.log.tag.RtmCommSimCtrl V
adb shell setprop persist.log.tag.RmmImsCtlReqHdl V
adb shell setprop persist.log.tag.RmmImsCtlUrcHdl V
adb shell setprop persist.log.tag.RtmIms V
adb shell setprop persist.log.tag.RtmImsConfigController V
