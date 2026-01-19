package com.example.vpn_client_app

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import libbox.BoxService
import libbox.PlatformInterfaceImpl
import libbox.TunOptions

class MyVpnService : VpnService() {
    private var boxService: BoxService? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "start" -> {
                val config = intent.getStringExtra("config") ?: return START_NOT_STICKY
                startVpn(config)
            }
            "stop" -> {
                stopVpn()
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?) = null

    private fun startVpn(config: String) {
        val builder = Builder()
        builder.setSession("VulcainVPN")
        builder.addAddress("172.19.0.1", 24)
        builder.addDnsServer("8.8.8.8")
        builder.addRoute("0.0.0.0", 0)
        val tunFd = builder.establish() ?: return

        val platformInterface = PlatformInterfaceImpl()
        val tunOptions = TunOptions()
        val fd = platformInterface.openTun(tunFd.fd, tunOptions)
        boxService = BoxService.start(this, platformInterface, config, fd)
    }

    private fun stopVpn() {
        boxService?.close()
        boxService = null
    }
}
