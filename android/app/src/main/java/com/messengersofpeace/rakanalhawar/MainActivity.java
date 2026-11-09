package com.messengersofpeace.rakanalhawar;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import java.util.HashMap;
import java.util.Map;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "mopa/package_info")
            .setMethodCallHandler((call, result) -> {
                if (!call.method.equals("getVersion")) {
                    result.notImplemented();
                    return;
                }
                try {
                    result.success(installedRelease());
                } catch (PackageManager.NameNotFoundException error) {
                    result.error("package_info_unavailable", null, null);
                }
            });
    }

    @SuppressWarnings("deprecation")
    private Map<String, String> installedRelease() throws PackageManager.NameNotFoundException {
        PackageInfo info = getPackageManager().getPackageInfo(getPackageName(), 0);
        long build = Build.VERSION.SDK_INT >= Build.VERSION_CODES.P
            ? info.getLongVersionCode()
            : info.versionCode;
        Map<String, String> release = new HashMap<>();
        release.put("version", info.versionName);
        release.put("buildNumber", Long.toString(build));
        return release;
    }
}
