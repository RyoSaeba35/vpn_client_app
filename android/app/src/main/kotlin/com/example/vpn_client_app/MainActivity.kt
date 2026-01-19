package com.example.vpn_client_app

import android.content.Intent
import android.net.VpnService
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "vpn/singbox"
    private val VPN_REQUEST_CODE = 1

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVpn" -> {
                    val config = call.argument<String>("config") ?: run {
                        result.error("INVALID_CONFIG", "Config is null", null)
                        return@setMethodCallHandler
                    }
                    val intent = VpnService.prepare(this)
                    if (intent != null) {
                        startActivityForResult(intent, VPN_REQUEST_CODE)
                        _pendingResult = result
                        _pendingConfig = config
                    } else {
                        startVpnService(config, result)
                    }
                }
                "stopVpn" -> {
                    stopVpnService(result)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VPN_REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                val config = _pendingConfig ?: run {
                    _pendingResult?.error("NO_CONFIG", "No pending config", null)
                    return
                }
                startVpnService(config, _pendingResult)
            } else {
                _pendingResult?.error("USER_CANCELED", "User canceled VPN permission", null)
            }
            _pendingResult = null
        }
    }

    private var _pendingConfig: String? = null
    private var _pendingResult: MethodChannel.Result? = null

    private fun startVpnService(config: String, result: MethodChannel.Result) {
        val intent = Intent(this, MyVpnService::class.java).apply {
            action = "start"
            putExtra("config", config)
        }
        startService(intent)
        result.success(true)
    }

    private fun stopVpnService(result: MethodChannel.Result) {
        val intent = Intent(this, MyVpnService::class.java).apply {
            action = "stop"
        }
        startService(intent)
        result.success(true)
    }
}
