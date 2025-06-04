package com.example.swee16

import android.media.AudioManager
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.audio_channel"
    private lateinit var audioManager: AudioManager

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "muteSounds" -> {
                    muteSystemSounds()
                    result.success(null)
                }
                "unmuteSounds" -> {
                    unmuteSystemSounds()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
        muteSystemSounds()
    }

    private fun muteSystemSounds() {
        try {
            audioManager.setStreamMute(AudioManager.STREAM_SYSTEM, true)
            audioManager.adjustStreamVolume(
                AudioManager.STREAM_NOTIFICATION,
                AudioManager.ADJUST_MUTE,
                0
            )
            audioManager.adjustStreamVolume(
                AudioManager.STREAM_ALARM,
                AudioManager.ADJUST_MUTE,
                0
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun unmuteSystemSounds() {
        try {
            audioManager.setStreamMute(AudioManager.STREAM_SYSTEM, false)
            audioManager.adjustStreamVolume(
                AudioManager.STREAM_NOTIFICATION,
                AudioManager.ADJUST_UNMUTE,
                0
            )
            audioManager.adjustStreamVolume(
                AudioManager.STREAM_ALARM,
                AudioManager.ADJUST_UNMUTE,
                0
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        unmuteSystemSounds() // Restore sounds when app closes
        super.onDestroy()
    }
}