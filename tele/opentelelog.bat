adb root
adb remount
adb shell setprop persist.log.tag.Dialer V
adb shell setprop persist.log.tag.TelecomFramework V
adb shell setprop persist.log.tag.Telecom V
adb shell setprop persist.log.tag.Telephony V
adb shell setprop persist.log.tag.SubscriptionController V
adb shell setprop persist.log.tag.SIMRecords V
adb shell setprop persist.log.tag.AdnRecord V
adb shell setprop persist.log.tag.QImsService V
adb shell setprop persist.log.tag.GsmCdmaPhone V
adb shell setprop persist.log.tag.PstnIncomingCallNotifier V
adb shell setprop persist.log.tag.ImsServiceCT V
adb shell setprop persist.log.tag.CallLogProvider V
adb shell setprop persist.log.tag.ContactsPerf V
adb shell setprop persist.log.tag.SQLiteQueryBuilder V
adb shell setprop persist.log.tag.ImsPhoneConnection V
adb shell setprop persist.log.tag.RILQ-Logger V
adb shell setprop persist.log.tag.QMI_RIL_UTF V
adb shell setprop persist.log.tag.RIL_UTF V
adb shell setprop persist.log.tag M
adb shell setprop persist.vendor.log.tel_dbg 1
adb reboot