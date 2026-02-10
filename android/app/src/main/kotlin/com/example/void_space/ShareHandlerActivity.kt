package `in`.devh.void

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class ShareHandlerActivity : FlutterFragmentActivity() {
    private val CHANNEL = "void/share"
    private var sharedText: String? = null
    private var sharedFile: Map<String, String>? = null

    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
        return FlutterActivityLaunchConfigs.BackgroundMode.transparent
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        window.setBackgroundDrawableResource(android.R.color.transparent)
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        val action = intent.action
        val type = intent.type
        
        Log.d("ShareHandler", "Action: $action, Type: $type")

        when (action) {
            Intent.ACTION_PROCESS_TEXT -> {
                sharedText = intent.getStringExtra(Intent.EXTRA_PROCESS_TEXT)
                Log.d("ShareHandler", "Process text: $sharedText")
            }
            Intent.ACTION_SEND -> {
                when {
                    "text/plain" == type -> {
                        sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
                        Log.d("ShareHandler", "Shared text: $sharedText")
                    }
                    type?.startsWith("image/") == true || 
                    type?.startsWith("application/") == true ||
                    type?.startsWith("text/") == true -> {
                        val uri: Uri? = intent.getParcelableExtra(Intent.EXTRA_STREAM)
                        uri?.let {
                            val mimeType = intent.type
                            sharedFile = mapOf(
                                "path" to copyFileToCache(it, getFileNameFromUri(it) ?: "shared_file"),
                                "mimeType" to (mimeType ?: "*/*"),
                                "uri" to it.toString()
                            )
                            Log.d("ShareHandler", "Shared file: $sharedFile")
                        }
                    }
                }
            }
            Intent.ACTION_SEND_MULTIPLE -> {
                // For simplicity, just handle the first file for now
                val uris: ArrayList<Uri>? = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM)
                uris?.firstOrNull()?.let {
                    val mimeType = intent.type
                    sharedFile = mapOf(
                        "path" to copyFileToCache(it, getFileNameFromUri(it) ?: "shared_file"),
                        "mimeType" to (mimeType ?: "*/*"),
                        "uri" to it.toString()
                    )
                    Log.d("ShareHandler", "Shared multiple files, handling first: $sharedFile")
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSharedText" -> result.success(sharedText)
                "getSharedFile" -> result.success(sharedFile)
                "done" -> {
                    finishAndRemoveTask()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun copyFileToCache(uri: Uri, filename: String): String {
        val cacheDir = cacheDir!!
        val extension = getFileExtension(filename)
        val timestamp = System.currentTimeMillis()
        val file = File(cacheDir, "${filename}_$timestamp$extension")
        
        Log.d("ShareHandler", "Copying file from $uri to ${file.absolutePath}")
        
        contentResolver.openInputStream(uri)?.use { input ->
            FileOutputStream(file).use { output ->
                input.copyTo(output)
            }
        } ?: run {
            Log.e("ShareHandler", "Failed to open input stream for $uri")
        }
        
        return file.absolutePath
    }

    private fun getFileNameFromUri(uri: Uri): String? {
        val contentResolver = contentResolver
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                val index = cursor.getColumnIndex(android.provider.OpenableColumns.DISPLAY_NAME)
                if (index >= 0) {
                    return cursor.getString(index)
                }
            }
        }
        return null
    }

    private fun getFileExtension(filename: String): String {
        val lastDot = filename.lastIndexOf('.')
        return if (lastDot >= 0) {
            filename.substring(lastDot)
        } else {
            ""
        }
    }
}
