import 'package:flutter/material.dart';
import '../../di/dependency_injection.dart';
import 'base_viewmodel.dart';

class BaseView<T extends BaseViewModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget? child) builder;
  final Function(T model)? onModelReady;
  final Function(T model)? onModelDispose;
  final Widget? child;

  const BaseView({
    super.key,
    required this.builder,
    this.onModelReady,
    this.onModelDispose,
    this.child,
  });

  @override
  State<BaseView<T>> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseViewModel> extends State<BaseView<T>> {
  late final T _model;

  @override
  void initState() {
    super.initState();
    _model = locator<T>();
    if (widget.onModelReady != null) {
      widget.onModelReady!(_model);
    }
  }

  @override
  void dispose() {
    if (widget.onModelDispose != null) {
      widget.onModelDispose!(_model);
    }
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _model,
      builder: (context, child) => widget.builder(context, _model, child),
      child: widget.child,
    );
  }
}
