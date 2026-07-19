import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Text(message, style: Theme.of(context).textTheme.titleMedium),
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('読み込みに失敗しました: $message'));
}
