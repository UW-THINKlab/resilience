import 'package:flutter/material.dart';
import 'package:support_sphere/constants/string_catalog.dart';
import 'package:support_sphere/data/services/offline_cache.dart';
import 'package:support_sphere/presentation/components/snackbars.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A strip shown above [child] while screens show saved data because the
/// server is unreachable. Also reports writes that failed for that reason.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  @override
  void initState() {
    super.initState();
    OfflineCache.lastFailedWrite.addListener(_showFailedWrite);
  }

  @override
  void dispose() {
    OfflineCache.lastFailedWrite.removeListener(_showFailedWrite);
    super.dispose();
  }

  void _showFailedWrite() {
    if (OfflineCache.lastFailedWrite.value == null || !mounted) return;
    showErrorSnackBar(context, OfflineStrings.needsConnection);
    OfflineCache.lastFailedWrite.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<DateTime?>(
          valueListenable: OfflineCache.showingSavedSince,
          builder: (context, savedAt, _) {
            if (savedAt == null) return const SizedBox.shrink();
            return Material(
              color: Colors.blueGrey.shade700,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        OfflineStrings.showingSaved(timeago.format(savedAt)),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
