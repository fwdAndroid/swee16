package com.example.swee16

import android.media.AudioManager
import android.os.Bundle
import android.content.Context
import android.provider.Settings
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.audio_channel"
    private lateinit var audioManager: AudioManager

    // Store original volumes to restore them
    private var originalSystemVolume: Int = 0
    private var originalNotificationVolume: Int = 0
    private var originalMusicVolume: Int = 0
    private var originalAlarmVolume: Int = 0
    private var originalRingtoneVolume: Int = 0

    // Store original sound effects setting
    private var originalSoundEffectsEnabled: Int = 0

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // Keep your existing methods if you still use them elsewhere, but they are not used by SpeechProvider anymore
                "disableAllSounds" -> {
                    disableAllSounds()
                    result.success(true)
                }
                "restoreSounds" -> {
                    restoreSounds()
                    result.success(true)
                }
                // --- New methods for SpeechProvider ---
                "setMediaVolumeFull" -> {
                    setMediaVolumeFull()
                    result.success(null)
                }
                "muteSounds" -> { // This will now mute system/notification sounds for speech recognition
                    muteSystemSounds()
                    result.success(null)
                }
                "unmuteSounds" -> { // This will now unmute system/notification sounds
                    unmuteSystemSounds()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // --- Original methods (unchanged as per your request) ---
    private fun disableAllSounds() {
        try {
            // Store original volumes before muting
            originalSystemVolume = audioManager.getStreamVolume(AudioManager.STREAM_SYSTEM)
            originalNotificationVolume = audioManager.getStreamVolume(AudioManager.STREAM_NOTIFICATION)
            originalMusicVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
            originalAlarmVolume = audioManager.getStreamVolume(AudioManager.STREAM_ALARM)
            originalRingtoneVolume = audioManager.getStreamVolume(AudioManager.STREAM_RING)
            originalSoundEffectsEnabled = Settings.System.getInt(contentResolver, Settings.System.SOUND_EFFECTS_ENABLED, 1)

            // 1. Mute all audio streams
            audioManager.setStreamMute(AudioManager.STREAM_SYSTEM, true)
            audioManager.setStreamMute(AudioManager.STREAM_NOTIFICATION, true)
            audioManager.setStreamMute(AudioManager.STREAM_MUSIC, true)
            audioManager.setStreamMute(AudioManager.STREAM_ALARM, true)
            audioManager.setStreamMute(AudioManager.STREAM_RING, true)
            
            // 2. Disable touch sounds and haptic feedback (FLAG_FULLSCREEN is not about haptic feedback)
            // This line likely intended to hide status bar/navigation, not control sounds/haptics
            // window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN) 
            
            // 3. Disable system sound effects
            Settings.System.putInt(contentResolver, Settings.System.SOUND_EFFECTS_ENABLED, 0)
            
            // 4. Disable vibration (by setting SYSTEM stream volume to 0, which also mutes it)
            audioManager.setStreamVolume(AudioManager.STREAM_SYSTEM, 0, 0)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun restoreSounds() {
        try {
            // Restore all audio streams to their original levels
            audioManager.setStreamVolume(AudioManager.STREAM_SYSTEM, originalSystemVolume, 0)
            audioManager.setStreamVolume(AudioManager.STREAM_NOTIFICATION, originalNotificationVolume, 0)
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, originalMusicVolume, 0)
            audioManager.setStreamVolume(AudioManager.STREAM_ALARM, originalAlarmVolume, 0)
            audioManager.setStreamVolume(AudioManager.STREAM_RING, originalRingtoneVolume, 0)
            
            // Restore window flags (if they were set by disableAllSounds)
            // window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN) 
            
            // Restore system sound effects
            Settings.System.putInt(contentResolver, Settings.System.SOUND_EFFECTS_ENABLED, originalSoundEffectsEnabled)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    // --- End of original methods ---


    // --- New methods for SpeechProvider integration ---
    private fun setMediaVolumeFull() {
        try {
            val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, maxVolume, 0)
            println("Android: Media volume set to full: $maxVolume")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun muteSystemSounds() {
        try {
            // Adjust system stream volume (e.g., button clicks)
            audioManager.adjustStreamVolume(AudioManager.STREAM_SYSTEM, AudioManager.ADJUST_MUTE, 0)
            // Adjust notification stream volume
            audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_MUTE, 0)
            println("Android: System and Notification sounds muted.")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun unmuteSystemSounds() {
        try {
            // Adjust system stream volume (e.g., button clicks)
            audioManager.adjustStreamVolume(AudioManager.STREAM_SYSTEM, AudioManager.ADJUST_UNMUTE, 0)
            // Adjust notification stream volume
            audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_UNMUTE, 0)
            println("Android: System and Notification sounds unmuted.")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        // IMPORTANT: Remove disableAllSounds() from onCreate()
        // If you keep this here, it will mute STREAM_MUSIC at app start,
        // conflicting with setting it to full.
        // The SpeechProvider will now manage muting/unmuting specific streams.
        // If you have a specific reason to disable all sounds at onCreate that
        // is separate from speech recognition, consider how it interacts.
        // disableAllSounds() // <--- REMOVE OR COMMENT THIS OUT
    }

    override fun onDestroy() {
        // Restore sounds only if you called disableAllSounds manually at some point.
        // If disableAllSounds() is removed from onCreate, you might not need restoreSounds() here
        // or you need to re-evaluate when it's called.
        // However, SpeechProvider will handle unmuting for its specific streams.
        restoreSounds() // <--- Re-evaluate if this is still needed based on your app's flow
        super.onDestroy()
    }
}