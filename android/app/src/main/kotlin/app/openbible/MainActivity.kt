package app.openbible

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channelName = "openbible/platform"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openExternalUrl", "openExternalUrlChooser" -> {
                        val url = call.argument<String>("url")
                        if (url.isNullOrBlank()) {
                            result.success(false)
                            return@setMethodCallHandler
                        }

                        try {
                            val baseIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                                addCategory(Intent.CATEGORY_BROWSABLE)
                            }

                            val launchIntent = if (call.method == "openExternalUrlChooser") {
                                Intent.createChooser(baseIntent, "Open link with")
                            } else {
                                baseIntent
                            }.apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }

                            val canOpen = baseIntent.resolveActivity(packageManager) != null
                            if (canOpen) {
                                startActivity(launchIntent)
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    }
                    "testNativeBridge" -> {
                        result.success("Native Bridge OK")
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
}
