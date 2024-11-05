import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class CachePage extends StatefulWidget {
  const CachePage({super.key});

  @override
  CachePageState createState() => CachePageState();
}

class CachePageState extends State<CachePage> {
  late BetterPlayerController _betterPlayerController;
  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cache"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          TextButton(
            child: const Text("Clear cache"),
            onPressed: () {
              _betterPlayerController.clearCache();
            
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Video cached there are clearn successfull")));
            },
          ),
        ],
      ),
    );
  }
}
