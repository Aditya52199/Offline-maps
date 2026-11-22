package com.example.my_offline_gps

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.my_offline_gps/asset_extractor"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "extractAsset") {
                val assetPath = call.argument<String>("assetPath")
                val targetPath = call.argument<String>("targetPath")
                if (assetPath == null || targetPath == null) {
                    result.error("INVALID_ARGS", "assetPath and targetPath are required", null)
                    return@setMethodCallHandler
                }

                Thread {
                    try {
                        val targetFile = File(targetPath)
                        if (targetFile.exists() && targetFile.length() > 0) {
                            runOnUiThread { result.success(targetFile.absolutePath) }
                            return@Thread
                        }

                        targetFile.parentFile?.mkdirs()

                        // Flutter assets bundled in the APK are located under flutter_assets/
                        val apkAssetPath = "flutter_assets/$assetPath"
                        val inputStream = context.assets.open(apkAssetPath)
                        val outputStream = FileOutputStream(targetFile)
                        val buffer = ByteArray(64 * 1024) // 64 KB memory-safe streaming buffer
                        var bytesRead: Int
                        while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                            outputStream.write(buffer, 0, bytesRead)
                        }
                        outputStream.flush()
                        outputStream.close()
                        inputStream.close()

                        runOnUiThread { result.success(targetFile.absolutePath) }
                    } catch (e: Exception) {
                        runOnUiThread { result.error("EXTRACT_FAILED", e.message, null) }
                    }
                }.start()
            } else {
                result.notImplemented()
            }
        }
    }
}
