import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';

class BuildBackgroundAnimation extends StatefulWidget {
  const BuildBackgroundAnimation({Key? key}) : super(key: key);

  @override
  BuildBackgroundAnimationState createState() => BuildBackgroundAnimationState();
}

class BuildBackgroundAnimationState extends State<BuildBackgroundAnimation> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    // final color = colorScheme.brightness == Brightness.dark
    //     ? Colors.black.withOpacity(.5)
    //     : Colors.black26;
    
    return AnimatedBackground(
      behaviour: RandomParticleBehaviour(
        options: const ParticleOptions(
          baseColor: Colors.blue,
          spawnMinRadius: 5.0,
          spawnMaxRadius: 15.0,
          spawnMinSpeed: 10.0,
          spawnMaxSpeed: 50.0,
        
        ),
        paint: Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = 0.5,
      ),
      vsync: this,
      child: const SizedBox.expand(),
    );
  }
}