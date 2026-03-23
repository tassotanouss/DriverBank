import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.padding = const EdgeInsets.all(18),
    this.useScrollView = true,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;
  final bool useScrollView;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: useScrollView
          ? SingleChildScrollView(child: body)
          : body,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: actions,
      ),
      body: content,
    );
  }
}
