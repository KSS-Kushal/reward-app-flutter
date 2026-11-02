import 'package:flutter/widgets.dart';

/// Reports full-screen page changes (push and pop) so an interstitial can be
/// shown now and then. Dialogs and bottom sheets are ignored.
class InterstitialRouteObserver extends NavigatorObserver {
  InterstitialRouteObserver(this._onScreenChanged);

  final VoidCallback _onScreenChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute && previousRoute != null) _onScreenChanged();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) _onScreenChanged();
  }
}
