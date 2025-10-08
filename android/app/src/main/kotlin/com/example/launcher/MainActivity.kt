package com.example.launcher

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.launcher/apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstalledApps" -> {
                        result.success(getInstalledApps())
                    }
                    "launchApp" -> {
                        val packageName = call.argument<String>("packageName")
                        launchApp(packageName)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val packages: List<PackageInfo> = pm.getInstalledPackages(0)
        val apps = mutableListOf<Map<String, Any?>>()

        for (packageInfo in packages) {
            val appInfo: ApplicationInfo = packageInfo.applicationInfo ?: continue
            if (pm.getLaunchIntentForPackage(packageInfo.packageName) != null) {
                val map = mutableMapOf<String, Any?>()
                map["appName"] = pm.getApplicationLabel(appInfo).toString()
                map["packageName"] = packageInfo.packageName
                map["iconBase64"] = getIconBase64(pm, appInfo)
                apps.add(map)
            }
        }
        return apps
    }

    private fun getIconBase64(pm: PackageManager, appInfo: ApplicationInfo): String {
        return try {
            val drawable = pm.getApplicationIcon(appInfo)
            if (drawable is BitmapDrawable) {
                val bitmap: Bitmap = drawable.bitmap
                val outputStream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
                val byteArray = outputStream.toByteArray()
                Base64.encodeToString(byteArray, Base64.NO_WRAP)
            } else {
                ""
            }
        } catch (e: Exception) {
            ""
        }
    }

    private fun launchApp(packageName: String?) {
        if (packageName == null) return
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
}
