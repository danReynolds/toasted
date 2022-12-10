import 'package:flutter/material.dart';
import 'package:toasted/toasted.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ToastedProvider(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class ToastContainer extends StatelessWidget {
  final String text;

  const ToastContainer({
    super.key,
    required this.text,
  });

  @override
  build(context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              child: const Text('Show toast'),
              onPressed: () {
                ToastedMessenger.of(context)!.show(
                  Toasted(
                    duration: const Duration(seconds: 3),
                    child: const Align(
                      alignment: Alignment.bottomRight,
                      child: ToastContainer(
                        text: 'This is a default fade toast',
                      ),
                    ),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Enqueue two toasts'),
              onPressed: () {
                ToastedMessenger.of(context)!.show(
                  Toasted(
                    duration: const Duration(seconds: 3),
                    child: const Align(
                      alignment: Alignment.bottomRight,
                      child: ToastContainer(
                        text: 'This is the first toast',
                      ),
                    ),
                  ),
                );
                ToastedMessenger.of(context)!.show(
                  Toasted(
                    duration: const Duration(seconds: 3),
                    child: const Align(
                      alignment: Alignment.bottomRight,
                      child: ToastContainer(
                        text: 'This is the second toast',
                      ),
                    ),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Show slide transition'),
              onPressed: () {
                ToastedMessenger.of(context)!.show(
                  Toasted(
                    duration: const Duration(seconds: 3),
                    transitionBuilder: (context, animation, child) {
                      return Positioned(
                        bottom: 0,
                        right: 0,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: const Align(
                      alignment: Alignment.bottomRight,
                      child: ToastContainer(
                        text: 'This is a slide transition toast',
                      ),
                    ),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Show size transition'),
              onPressed: () {
                ToastedMessenger.of(context)!.show(
                  Toasted(
                    duration: const Duration(seconds: 3),
                    transitionBuilder: (context, animation, child) =>
                        Positioned(
                      bottom: 0,
                      right: 0,
                      child: ScaleTransition(
                        alignment: Alignment.bottomCenter,
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                          reverseCurve: Curves.easeIn,
                        ),
                        child: child,
                      ),
                    ),
                    child: const Align(
                      alignment: Alignment.bottomRight,
                      child: ToastContainer(
                        text: 'This is a size transition toast',
                      ),
                    ),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Dismiss toast'),
              onPressed: () {
                ToastedMessenger.of(context)!.dismiss();
              },
            ),
          ],
        ),
      ),
    );
  }
}
