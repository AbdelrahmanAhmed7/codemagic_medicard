package com.khusm.medicard

import android.app.Activity
import android.content.IntentSender
import androidx.activity.result.ActivityResult
import androidx.activity.result.IntentSenderRequest
import androidx.activity.result.contract.ActivityResultContracts
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationSettingsRequest
import com.google.android.gms.location.Priority
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity wires the native Google Play Services GPS resolution dialog
 * into Flutter via a MethodChannel.
 *
 * Channel: "com.khusm.medicard/location"
 * Method:  "requestGpsEnable"
 *   → result: "enabled"  — user accepted, GPS is now on
 *   → result: "rejected" — user dismissed the dialog
 *   → result: "error"    — ResolvableApiException could not be resolved
 *
 * Uses FlutterFragmentActivity (required for ActivityResultLauncher).
 */
class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val CHANNEL = "com.khusm.medicard/location"
    }

    // Pending Flutter result — held while the GPS dialog is shown.
    private var pendingResult: MethodChannel.Result? = null

    // ActivityResultLauncher registered at creation time (before any Activity result).
    private val gpsResolutionLauncher =
        registerForActivityResult(ActivityResultContracts.StartIntentSenderForResult()) { result: ActivityResult ->
            val pending = pendingResult ?: return@registerForActivityResult
            pendingResult = null

            if (result.resultCode == Activity.RESULT_OK) {
                pending.success("enabled")
            } else {
                pending.success("rejected")
            }
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestGpsEnable" -> handleRequestGpsEnable(result)
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Checks location settings via SettingsClient.
     * - If GPS is already on  → returns "enabled" immediately.
     * - If ResolvableApiException → shows the native in-app dialog.
     * - Otherwise               → returns "error".
     */
    private fun handleRequestGpsEnable(result: MethodChannel.Result) {
        // Only one pending request at a time.
        if (pendingResult != null) {
            result.success("rejected")
            return
        }

        val locationRequest = LocationRequest.Builder(
            Priority.PRIORITY_BALANCED_POWER_ACCURACY,
            10_000L,
        ).build()

        val settingsRequest = LocationSettingsRequest.Builder()
            .addLocationRequest(locationRequest)
            .setAlwaysShow(true) // always show the dialog even if partially satisfied
            .build()

        val settingsClient = LocationServices.getSettingsClient(this)

        settingsClient.checkLocationSettings(settingsRequest)
            .addOnSuccessListener {
                // GPS already enabled — resolve immediately.
                result.success("enabled")
            }
            .addOnFailureListener { exception ->
                if (exception is ResolvableApiException) {
                    try {
                        // Store the result so the ActivityResultLauncher can resolve it.
                        pendingResult = result
                        val intentSenderRequest = IntentSenderRequest
                            .Builder(exception.resolution.intentSender)
                            .build()
                        gpsResolutionLauncher.launch(intentSenderRequest)
                    } catch (sendEx: IntentSender.SendIntentException) {
                        pendingResult = null
                        result.success("error")
                    }
                } else {
                    // Not resolvable (e.g. no Google Play Services).
                    result.success("error")
                }
            }
    }
}
