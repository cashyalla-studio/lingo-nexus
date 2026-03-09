package com.example.lingo_nexus

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    // 앱이 이미 실행 중일 때 파일 열기 → singleTop 덕분에 새 액티비티 없이 여기서 수신
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return

        val uri: Uri? = when (intent.action) {
            Intent.ACTION_VIEW -> intent.data
            Intent.ACTION_SEND -> intent.getParcelableExtra(Intent.EXTRA_STREAM)
            else -> return
        }
        uri ?: return

        val localPath = copyContentToLocal(uri) ?: return

        // Flutter shared_preferences는 Android에서 "flutter." prefix를 붙여 NSUserDefaults/SharedPreferences에 저장합니다.
        getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit()
            .putString("flutter.scripta_pending_open_file", localPath)
            .apply()
    }

    /** Content URI → 앱 내부 저장소로 복사 후 절대 경로 반환 */
    private fun copyContentToLocal(uri: Uri): String? {
        return try {
            val filename = resolveFilename(uri) ?: uri.lastPathSegment ?: return null
            val destDir = File(filesDir, "opened_files").also { it.mkdirs() }
            val destFile = File(destDir, filename)

            contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output)
                }
            }
            destFile.absolutePath
        } catch (e: Exception) {
            null
        }
    }

    /** ContentResolver로 실제 파일명 조회 */
    private fun resolveFilename(uri: Uri): String? {
        return contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (cursor.moveToFirst() && nameIndex >= 0) cursor.getString(nameIndex) else null
        }
    }
}
