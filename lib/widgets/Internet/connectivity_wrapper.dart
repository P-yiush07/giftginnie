import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/connectivity_service.dart';
import '../Error/no_internet_widget.dart';

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, _) {
        if (!connectivityService.isConnected) {
          return NoInternetWidget(
            onRetry: onRetry ?? () {
              if (connectivityService.isConnected) {
                // Default retry behavior
                context.findAncestorStateOfType<State>()?.setState(() {});
              }
            },
          );
        }
        return child;
      },
    );
  }
}