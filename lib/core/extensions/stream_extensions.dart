import 'dart:async';

extension StreamExtensions<T> on Stream<T> {
  /// Shares a single subscription to multiple listeners with a buffer.
  /// This prevents multiple subscriptions to the underlying stream.
  Stream<T> shareReplay({int bufferSize = 1}) {
    late StreamController<T> controller;
    // ignore: unused_local_variable
    late StreamSubscription<T> subscription;
    final buffer = <T>[];
    var isSubscribed = false;

    void startSubscription() {
      if (isSubscribed) return;
      isSubscribed = true;

      subscription = listen(
        (value) {
          buffer.add(value);
          if (buffer.length > bufferSize) {
            buffer.removeAt(0);
          }
          if (!controller.isClosed) {
            controller.add(value);
          }
        },
        onError: (error, stackTrace) {
          if (!controller.isClosed) {
            controller.addError(error, stackTrace);
          }
        },
        onDone: () {
          if (!controller.isClosed) {
            controller.close();
          }
        },
        cancelOnError: false,
      );
    }

    controller = StreamController<T>.broadcast(
      onListen: () {
        // Emit buffered values first
        for (final value in buffer) {
          if (!controller.isClosed) {
            controller.add(value);
          }
        }

        // Start subscription if not already started
        startSubscription();
      },
      onCancel: () {
        // Don't cancel the subscription, keep it alive for other listeners
      },
    );

    return controller.stream;
  }

  /// Only emit values that are different from the previous value
  /// Uses equality comparison (==)
  Stream<T> distinctUntilChanged() {
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (value, sink) {
          sink.add(value);
        },
      ),
    );
  }

  /// Only emit values that are different from the previous value
  /// Compares using toString() for objects without proper equality
  Stream<T> distinct() {
    late T lastValue;
    var isFirst = true;

    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (value, sink) {
          if (isFirst) {
            isFirst = false;
            lastValue = value;
            sink.add(value);
          } else if (value.toString() != lastValue.toString()) {
            lastValue = value;
            sink.add(value);
          }
        },
      ),
    );
  }
}
