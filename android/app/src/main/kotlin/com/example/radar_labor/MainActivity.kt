package com.example.radar_labor

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var pendingFileResult: MethodChannel.Result? = null
    private val channelName = "radar_labor/workforce_files"
    private val requestCode = 4107

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "pick") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (pendingFileResult != null) {
                    result.error("picker_busy", "A file selection is already open", null)
                    return@setMethodCallHandler
                }
                pendingFileResult = result
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "*/*"
                    putExtra(Intent.EXTRA_MIME_TYPES, arrayOf(
                        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                        "text/csv",
                        "text/comma-separated-values",
                        "application/octet-stream"
                    ))
                }
                try {
                    startActivityForResult(intent, requestCode)
                } catch (error: Exception) {
                    pendingFileResult = null
                    result.error("picker_failed", "Could not open the document picker", error.message)
                }
            }
    }

    @Deprecated("Activity result is required by the existing Flutter embedding")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != this.requestCode) return
        val result = pendingFileResult ?: return
        pendingFileResult = null
        if (resultCode != Activity.RESULT_OK) {
            result.success(null)
            return
        }
        val uri: Uri = data?.data ?: run {
            result.error("file_missing", "No file was selected", null)
            return
        }
        try {
            val bytes = contentResolver.openInputStream(uri)?.use { input ->
                val output = java.io.ByteArrayOutputStream()
                val buffer = ByteArray(8192)
                var total = 0
                while (true) {
                    val count = input.read(buffer)
                    if (count < 0) break
                    total += count
                    if (total > 25 * 1024 * 1024) {
                        throw IllegalArgumentException("Selected file exceeds 25 MB")
                    }
                    output.write(buffer, 0, count)
                }
                output.toByteArray()
            }
                ?: throw IllegalStateException("Selected file could not be opened")
            val name = contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                val nameColumn = cursor.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME)
                if (cursor.moveToFirst() && nameColumn >= 0) cursor.getString(nameColumn) else null
            } ?: uri.lastPathSegment ?: "workforce.xlsx"
            result.success(mapOf("name" to name, "bytes" to bytes))
        } catch (error: Exception) {
            result.error("file_read_failed", "Could not read selected file", error.message)
        }
    }
}
