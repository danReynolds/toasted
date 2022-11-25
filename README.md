# 🥪 Toasted 

Displays toasts in a queue similar to the default SnackBar but with more extensive customization including:

* Intrinsically sized toasts ([SnackBar](https://api.flutter.dev/flutter/material/SnackBar-class.html]) needs a fixed-width for some reason).
* Custom toast animations
* Custom toast positioning.

![Demo 1](./demo.gif).

## Usage

To enable toast support, wrap your app in a `ToastedProvider` widget:

```dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ToastedProvider(
      child: MaterialApp(
        title: 'MyApp',
        home: Container(),
      ),
    );
  }
}
```

You can then show toasts from anywhere in the build tree using the [ToastedMessenger](https://github.com/danReynolds/toasted/blob/master/lib/toasted_messenger.dart):

```dart
ToastedMessenger.of(context)!.show(
  Toasted(
    context: context,
    duration: const Duration(seconds: 3),
    child: Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: black,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(color: white),
        ),
      ),
    ),
  ),
);
```

Check out this working example and others in the [demo app](./example/lib/main.dart).

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
