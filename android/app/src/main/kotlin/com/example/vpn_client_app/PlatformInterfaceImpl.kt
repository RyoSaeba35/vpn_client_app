package com.example.vpn_client_app

import libbox.PlatformInterface
import libbox.NetworkInterfaceIterator
import java.net.NetworkInterface

class PlatformInterfaceImpl : PlatformInterface {
    override fun openTun(fd: Int, options: TunOptions): Int {
        return fd
    }

    override fun getInterfaces(): NetworkInterfaceIterator {
        return NetworkInterfaceIterator(NetworkInterface.getNetworkInterfaces().asIterator())
    }

    override fun closeDefaultInterfaceMonitor() {}
}
