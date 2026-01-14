package com.example.launcher

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import android.net.Uri
import android.provider.Settings


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.yourlauncher/apps"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstalledApps" -> {
                        val apps = getAllInstalledApps()
                        result.success(apps)
                    }

                    "openApp" -> {
                        val packageName = call.argument<String>("package")
                        if (packageName != null) openApp(packageName)
                        result.success(null)
                    }

                    // --- ADD THIS BLOCK ---
                    "openAppInfo" -> {
                        val packageName = call.argument<String>("package")
                        if (packageName != null) {
                            openAppInfo(packageName)
                            result.success(null)
                        } else {
                            result.error("ERROR", "Package name null", null)
                        }
                    }
                    // ----------------------

                    else -> result.notImplemented()
                }
            }
    }

    /**
     * ✅ Fetches all launchable apps (system + user) with Base64 icons
     */
    private fun getAllInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        val apps = mutableListOf<Map<String, Any>>()
        val packageNames = mutableSetOf<String>()

        // Intent to get all apps with launcher icons
        val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }

        val activities = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(
                mainIntent,
                PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_ALL.toLong())
            )
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(mainIntent, PackageManager.MATCH_ALL)
        }

        // Add all launchable apps
        for (info in activities) {
            val packageName = info.activityInfo.packageName
            if (packageNames.contains(packageName)) continue

            try {
                val appInfo = pm.getApplicationInfo(packageName, 0)
                val name = pm.getApplicationLabel(appInfo).toString()
                val icon = pm.getApplicationIcon(appInfo)
                val iconBase64 = drawableToBase64(icon)
                val isSystemApp =
                    (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

                apps.add(
                    mapOf(
                        "name" to name,
                        "package" to packageName,
                        "isSystemApp" to isSystemApp,
                        "icon" to iconBase64
                    )
                )
                packageNames.add(packageName)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        // Optionally: also add system apps with launcher intents
        val systemApps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        for (appInfo in systemApps) {
            val packageName = appInfo.packageName
            if (packageNames.contains(packageName)) continue
            val launchIntent = pm.getLaunchIntentForPackage(packageName)
            if (launchIntent != null) {
                try {
                    val name = pm.getApplicationLabel(appInfo).toString()
                    val icon = pm.getApplicationIcon(appInfo)
                    val iconBase64 = drawableToBase64(icon)
                    val isSystemApp =
                        (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

                    apps.add(
                        mapOf(
                            "name" to name,
                            "package" to packageName,
                            "isSystemApp" to isSystemApp,
                            "icon" to iconBase64
                        )
                    )
                    packageNames.add(packageName)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }

        Log.d("Launcher", "Found ${apps.size} launchable apps")
        return apps.sortedBy { it["name"].toString().lowercase() }
    }

    /**
     * Converts Drawable icons to Base64-encoded PNG strings for Flutter display
     */
    private fun drawableToBase64(drawable: Drawable): String {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val width = drawable.intrinsicWidth.takeIf { it > 0 } ?: 1
            val height = drawable.intrinsicHeight.takeIf { it > 0 } ?: 1
            val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = android.graphics.Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }

        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
    }

    /**
     * Launches an app by its package name
     */

     private fun openAppInfo(packageName: String) {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
            intent.data = Uri.parse("package:$packageName")
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        } catch (e: Exception) {
            Log.e("Launcher", "Could not open settings for $packageName", e)
        }
    }
    private fun openApp(packageName: String) {
        try {
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(launchIntent)
            } else {
                Log.w("Launcher", "No launch intent for $packageName")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
