package com.example.swee16

import io.flutter.embedding.android.FlutterActivity
import android.media.AudioManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.audio_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "muteSounds") {
                val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
                audioManager.setStreamMute(AudioManager.STREAM_SYSTEM, true)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}

