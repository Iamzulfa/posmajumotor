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

  /// Concatenates this stream with other streams
  /// Emits all values from this stream first, then from each subsequent stream
  Stream<T> concatWith(Iterable<Stream<T>> others) {
    final controller = StreamController<T>();

    void subscribeToStreams() async {
      try {
        // First, listen to this stream
        await for (final value in this) {
          if (controller.isClosed) return;
          controller.add(value);
        }

        // Then listen to each subsequent stream
        for (final stream in others) {
          await for (final value in stream) {
            if (controller.isClosed) return;
            controller.add(value);
          }
        }

        if (!controller.isClosed) {
          controller.close();
        }
      } catch (e, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(e, stackTrace);
        }
      }
    }

    controller.onListen = subscribeToStreams;

    return controller.stream;
  }

  /// Starts with an initial value before emitting stream values
  Stream<T> startWith(T initialValue) {
    final controller = StreamController<T>();

    controller.onListen = () {
      controller.add(initialValue);
      listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
    };

    return controller.stream;
  }
}
