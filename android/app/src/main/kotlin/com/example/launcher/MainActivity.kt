package com.example.launcher

import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.yourlauncher/apps"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    result.success(getAllInstalledApps())
                }
                "openApp" -> {
                    val packageName = call.argument<String>("package")
                    if (packageName != null) openApp(packageName)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getAllInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        val apps = mutableListOf<Map<String, Any>>()

        val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        for (app in packages) {
            try {
                // Only include apps with a launch intent (user and system apps)
                val launchIntent = pm.getLaunchIntentForPackage(app.packageName)
                if (launchIntent != null) {
                    val name = pm.getApplicationLabel(app).toString()
                    val icon = pm.getApplicationIcon(app)
                    val iconBase64 = drawableToBase64(icon)
                    val isSystemApp = (app.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0

                    // Include both user and system apps
                    apps.add(
                        mapOf(
                            "name" to name,
                            "package" to app.packageName,
                            "isSystemApp" to isSystemApp,
                            "icon" to iconBase64
                        )
                    )
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        return apps.sortedBy { it["name"].toString().lowercase() }
    }

    private fun drawableToBase64(drawable: Drawable): String {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val bmp = Bitmap.createBitmap(
                drawable.intrinsicWidth.coerceAtLeast(1),
                drawable.intrinsicHeight.coerceAtLeast(1),
                Bitmap.Config.ARGB_8888
            )
            val canvas = android.graphics.Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }

        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        // 🛠️ FIX: Use Base64.NO_WRAP to prevent newline characters from being added.
        return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP)
    }

    private fun openApp(packageName: String) {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        if (launchIntent != null) {
            startActivity(launchIntent)
        }
    }
}