import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/connectivity/connectivity_cubit.dart';
import '../cubits/connectivity/connectivity_state.dart';

class NoConnectivityBanner extends StatelessWidget {
  final Duration animationDuration;

  const NoConnectivityBanner({
    super.key,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      buildWhen: (previous, current) {
        final wasConnected =
            previous is! ConnectivityDisconnected;
        final isConnected =
            current is! ConnectivityDisconnected;
        return wasConnected != isConnected;
      },
      builder: (context, state) {
        if (state is ConnectivityDisconnected) {
          return AnimatedSlide(
            offset: Offset.zero,
            duration: animationDuration,
            child: Container(
              color: Colors.red.shade900,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No connectivity',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        context.read<ConnectivityCubit>().retryConnection(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Refresh',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox.shrink();
      },
    );
  }
}


