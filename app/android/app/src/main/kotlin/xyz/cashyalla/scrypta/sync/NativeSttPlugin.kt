package xyz.cashyalla.scrypta.sync

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/// MethodChannel: xyz.cashyalla.scrypta.sync/stt
/// Android does not support file-based speech recognition via SpeechRecognizer API.
/// isAvailable always returns false → Flutter falls back to server-side transcription.
/// TODO: Replace with Vosk offline STT for file-based recognition.
class NativeSttPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "xyz.cashyalla.scrypta.sync/stt")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAvailable" -> result.success(false)
            "transcribeFile" -> result.error(
                "NOT_AVAILABLE",
                "Native file-based STT is not supported on Android",
                null
            )
            else -> result.notImplemented()
        }
    }
}
