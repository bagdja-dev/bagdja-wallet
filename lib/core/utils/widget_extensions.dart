import 'package:flutter/material.dart';

extension WidgetListExtension on List<Widget> {
  List<Widget> withGap(double gap) {
    if (length <= 1) return this;

    final List<Widget> spacedChildren = [];
    for (int i = 0; i < length; i++) {
      spacedChildren.add(this[i]);
      if (i != length - 1) {
        spacedChildren.add(SizedBox(width: gap, height: gap));
      }
    }
    return spacedChildren;
  }

  List<Widget> withHorizontalGap(double gap) {
    if (length <= 1) return this;

    final List<Widget> spacedChildren = [];
    for (int i = 0; i < length; i++) {
      spacedChildren.add(this[i]);
      if (i != length - 1) {
        spacedChildren.add(SizedBox(width: gap));
      }
    }
    return spacedChildren;
  }

  List<Widget> withVerticalGap(double gap) {
    if (length <= 1) return this;

    final List<Widget> spacedChildren = [];
    for (int i = 0; i < length; i++) {
      spacedChildren.add(this[i]);
      if (i != length - 1) {
        spacedChildren.add(SizedBox(height: gap));
      }
    }
    return spacedChildren;
  }
}
