# Android 7.1 ActivityManagerService 屏幕旋转流程分析 (四)

# 四、Activity的更新（旋转）

sendNewConfiguration（）会调用到ActivityManagerService的updateConfiguration（）来update Configuration，并根据应用的配置来判断是否要重新lunch应用。

```java
void sendNewConfiguration() {
        try {
            mActivityManager.updateConfiguration(null);
        } catch (RemoteException e) {
        }
    }
```

```java
public void updateConfiguration(Configuration values) {
        enforceCallingPermission(android.Manifest.permission.CHANGE_CONFIGURATION,
                "updateConfiguration()");
 
        synchronized(this) {
            if (values == null && mWindowManager != null) {
                // sentinel: fetch the current configuration from the window manager
                values = mWindowManager.computeNewConfiguration();
            }
 
            if (mWindowManager != null) {
                mProcessList.applyDisplaySize(mWindowManager);
            }
 
            final long origId = Binder.clearCallingIdentity();
            if (values != null) {
                Settings.System.clearConfiguration(values);
            }
            updateConfigurationLocked(values, null, false);
            Binder.restoreCallingIdentity(origId);
        }
    }
```

先看一下总体时序图，后面详细展开：

![img](https://upload-images.jianshu.io/upload_images/2088926-76246859d6d7741a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 1）updateConfigurationLocked（）

**updateConfigurationLocked（）**
（1）获取Configuration数据保存在mConfiguration
（2）调用ActivityThread的scheduleConfigurationChanged（）
（3）发送ACTION_CONFIGURATION_CHANGED广播
（4）获取当前最上面活动的Activity，调用ActivityStack的ensureActivityConfigurationLocked（）函数根据应用配置判断是否要重新luncher应用

```java
private boolean updateConfigurationLocked(Configuration values, ActivityRecord starting,
            boolean initLocale, boolean persistent, int userId, boolean deferResume) {
        int changes = 0;
 
        if (mWindowManager != null) {
            mWindowManager.deferSurfaceLayout();
        }
        if (values != null) {
            Configuration newConfig = new Configuration(mConfiguration);
            changes = newConfig.updateFrom(values);
            if (changes != 0) {
                if (DEBUG_SWITCH || DEBUG_CONFIGURATION) Slog.i(TAG_CONFIGURATION,
                        "Updating configuration to: " + values);
 
                EventLog.writeEvent(EventLogTags.CONFIGURATION_CHANGED, changes);
 
                if (!initLocale && !values.getLocales().isEmpty() && values.userSetLocale) {
                    final LocaleList locales = values.getLocales();
                    int bestLocaleIndex = 0;
                    if (locales.size() > 1) {
                        if (mSupportedSystemLocales == null) {
                            mSupportedSystemLocales =
                                    Resources.getSystem().getAssets().getLocales();
                        }
                        bestLocaleIndex = Math.max(0,
                                locales.getFirstMatchIndex(mSupportedSystemLocales));
                    }
                    SystemProperties.set("persist.sys.locale",
                            locales.get(bestLocaleIndex).toLanguageTag());
                    LocaleList.setDefault(locales, bestLocaleIndex);
                    mHandler.sendMessage(mHandler.obtainMessage(SEND_LOCALE_TO_MOUNT_DAEMON_MSG,
                            locales.get(bestLocaleIndex)));
                }
 
                mConfigurationSeq++;
                if (mConfigurationSeq <= 0) {
                    mConfigurationSeq = 1;
                }
                newConfig.seq = mConfigurationSeq;
                mConfiguration = newConfig;
                Slog.i(TAG, "Config changes=" + Integer.toHexString(changes) + " " + newConfig);
                mUsageStatsService.reportConfigurationChange(newConfig,
                        mUserController.getCurrentUserIdLocked());
                //mUsageStatsService.noteStartConfig(newConfig);
 
                final Configuration configCopy = new Configuration(mConfiguration);
 
                // TODO: If our config changes, should we auto dismiss any currently
                // showing dialogs?
                mShowDialogs = shouldShowDialogs(newConfig, mInVrMode);
 
                AttributeCache ac = AttributeCache.instance();
                if (ac != null) {
                    ac.updateConfiguration(configCopy);
                }
 
                // Make sure all resources in our process are updated
                // right now, so that anyone who is going to retrieve
                // resource values after we return will be sure to get
                // the new ones.  This is especially important during
                // boot, where the first config change needs to guarantee
                // all resources have that config before following boot
                // code is executed.
                mSystemThread.applyConfigurationToResources(configCopy);
 
                if (persistent && Settings.System.hasInterestingConfigurationChanges(changes)) {
                    Message msg = mHandler.obtainMessage(UPDATE_CONFIGURATION_MSG);
                    msg.obj = new Configuration(configCopy);
                    msg.arg1 = userId;
                    mHandler.sendMessage(msg);
                }
 
                final boolean isDensityChange = (changes & ActivityInfo.CONFIG_DENSITY) != 0;
                if (isDensityChange) {
                    // Reset the unsupported display size dialog.
                    mUiHandler.sendEmptyMessage(SHOW_UNSUPPORTED_DISPLAY_SIZE_DIALOG_MSG);
 
                    killAllBackgroundProcessesExcept(Build.VERSION_CODES.N,
                            ActivityManager.PROCESS_STATE_FOREGROUND_SERVICE);
                }
 
                for (int i=mLruProcesses.size()-1; i>=0; i--) {
                    ProcessRecord app = mLruProcesses.get(i);
                    try {
                        if (app.thread != null) {
                            if (DEBUG_CONFIGURATION) Slog.v(TAG_CONFIGURATION, "Sending to proc "
                                    + app.processName + " new config " + mConfiguration);
                            app.thread.scheduleConfigurationChanged(configCopy);
                        }
                    } catch (Exception e) {
                    }
                }
                Intent intent = new Intent(Intent.ACTION_CONFIGURATION_CHANGED);
                intent.addFlags(Intent.FLAG_RECEIVER_REGISTERED_ONLY
                        | Intent.FLAG_RECEIVER_REPLACE_PENDING
                        | Intent.FLAG_RECEIVER_FOREGROUND);
                broadcastIntentLocked(null, null, intent, null, null, 0, null, null,
                        null, AppOpsManager.OP_NONE, null, false, false,
                        MY_PID, Process.SYSTEM_UID, UserHandle.USER_ALL);
                if ((changes&ActivityInfo.CONFIG_LOCALE) != 0) {
                    intent = new Intent(Intent.ACTION_LOCALE_CHANGED);
                    intent.addFlags(Intent.FLAG_RECEIVER_FOREGROUND);
                if (initLocale || !mProcessesReady) {
                        intent.addFlags(Intent.FLAG_RECEIVER_REGISTERED_ONLY);
                    }
                    broadcastIntentLocked(null, null, intent,
                            null, null, 0, null, null, null, AppOpsManager.OP_NONE,
                            null, false, false, MY_PID, Process.SYSTEM_UID, UserHandle.USER_ALL);
                }
            }
            // Update the configuration with WM first and check if any of the stacks need to be
            // resized due to the configuration change. If so, resize the stacks now and do any
            // relaunches if necessary. This way we don't need to relaunch again below in
            // ensureActivityConfigurationLocked().
            if (mWindowManager != null) {
                final int[] resizedStacks = mWindowManager.setNewConfiguration(mConfiguration);
                if (resizedStacks != null) {
                    for (int stackId : resizedStacks) {
                        final Rect newBounds = mWindowManager.getBoundsForNewConfiguration(stackId);
                        mStackSupervisor.resizeStackLocked(
                                stackId, newBounds, null, null, false, false, deferResume);
                    }
                }
            }
        }
 
        boolean kept = true;
        final ActivityStack mainStack = mStackSupervisor.getFocusedStack();
        // mainStack is null during startup.
        if (mainStack != null) {
            if (changes != 0 && starting == null) {
                // If the configuration changed, and the caller is not already
                // in the process of starting an activity, then find the top
                // activity to check if its configuration needs to change.
                starting = mainStack.topRunningActivityLocked();
            }
 
            if (starting != null) {
                kept = mainStack.ensureActivityConfigurationLocked(starting, changes, false);
                // And we need to make sure at this point that all other activities
                // are made visible with the correct configuration.
                mStackSupervisor.ensureActivitiesVisibleLocked(starting, changes,
                        !PRESERVE_WINDOWS);
            }
        }
        if (mWindowManager != null) {
            mWindowManager.continueSurfaceLayout();
        }
        return kept;
    }
```

# 五、总结

总流程图如下

![img](https://upload-images.jianshu.io/upload_images/2088926-5412a6aa9c08e90a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)