import 'package:flutter/material.dart';
import 'singbox_helper.dart';
import 'utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vulcain VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.myOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Vulcain VPN'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool running = false;
  bool loading = false;
  String status = "VPN stopped";

  Future<void> start() async {
    if (loading) return;
    setState(() {
      loading = true;
      status = "Starting VPN...";
    });

    try {
      final config = """
      {
        "log": {
          "level": "debug",
          "output": "/data/user/0/com.example.vpn_client_app/cache/sing-box.log"
        },
        "inbounds": [
          {
            "type": "tun",
            "tag": "tun-in",
            "sniff": true,
            "sniff_override_destination": true,
            "stack": "system",
            "endpoint_independent_nat": true
          }
        ],
        "outbounds": [
          {
            "type": "vmess",
            "tag": "proxy",
            "server": "your-server-address",
            "server_port": 443,
            "uuid": "your-uuid",
            "security": "auto",
            "alter_id": 0,
            "transport": {
              "type": "ws",
              "path": "/your-path",
              "headers": {
                "Host": "your-host"
              }
            }
          }
        ]
      }
      """;
      await SingBoxHelper.startVPN(config);
      setState(() {
        running = true;
        status = "VPN running";
      });
    } catch (e) {
      setState(() => status = "Failed to start VPN: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> stop() async {
    if (loading) return;
    setState(() {
      loading = true;
      status = "Stopping VPN...";
    });

    try {
      await SingBoxHelper.stopVPN();
      setState(() {
        running = false;
        status = "VPN stopped";
      });
    } catch (e) {
      setState(() => status = "Failed to stop VPN: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 600;
          Widget buttons = isWide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStartButton(),
                    const SizedBox(width: 20),
                    _buildStopButton(),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStartButton(),
                    const SizedBox(height: 12),
                    _buildStopButton(),
                  ],
                );
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    status,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  buttons,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: running || loading ? null : start,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 48),
      ),
      child: loading && !running
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text("Start VPN"),
    );
  }

  Widget _buildStopButton() {
    return ElevatedButton(
      onPressed: !running || loading ? null : stop,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 48),
      ),
      child: loading && running
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text("Stop VPN"),
    );
  }
}
