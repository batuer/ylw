adb shell pm clear com.yuliwen.systemserver
adb shell pm clear com.android.phone
adb shell pm clear com.android.providers.telephony
adb shell pm clear com.android.providers.contacts
adb shell rm -rf data/log/android_logs/*
adb shell rm -rf data/log/hilogs/*

adb reboot