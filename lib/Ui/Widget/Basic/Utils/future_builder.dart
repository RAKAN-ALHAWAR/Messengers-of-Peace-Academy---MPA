import 'package:flutter/material.dart';

import '../../../Section/GeneralState/error.dart';

class FutureBuilderX<T> extends StatefulWidget {
  const FutureBuilderX({
    super.key,
    required this.future,
    this.loading,
    required this.child,
    this.onLoading,
    this.onError,
    this.onSuccess,
    this.onRetry,
    this.isHideIfError = false,
    this.isHideIfEmpty = false,
  });

  final Future<T> Function() future;
  final Widget? loading;
  final Widget Function(T data) child;

  final bool isHideIfError;
  final bool isHideIfEmpty;

  // Callbacks
  final VoidCallback? onLoading;
  final VoidCallback? onError;
  final VoidCallback? onSuccess;
  final VoidCallback? onRetry;

  @override
  State<FutureBuilderX<T>> createState() => FutureBuilderXState<T>();
}

class FutureBuilderXState<T> extends State<FutureBuilderX<T>> {
  late dynamic Function() _future;

  @override
  void initState() {
    super.initState();
    _future = widget.future;
  }

  Future<void> _reloadFuture() async {
    setState(() {
      _future = widget.future;
      widget.onRetry?.call();
    });
  }

  void onRefresh() {
    setState(() {
      _reloadFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future(),
      builder: (context, snapshot) {
        /// Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onLoading?.call();
          });
          return widget.loading ??
              const Center(child: CircularProgressIndicator());
        }

        /// Error State
        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onError?.call();
          });
          if (widget.isHideIfError) {
            return const SizedBox();
          } else {
            return ErrorView(error: snapshot.error, onTapButton: onRefresh);
          }
        }

        /// Success State
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onSuccess?.call();
        });
        if (widget.isHideIfEmpty && snapshot.data == null) {
          return const SizedBox();
        } else {
          return widget.child(snapshot.data as T);
        }
      },
    );
  }
}
