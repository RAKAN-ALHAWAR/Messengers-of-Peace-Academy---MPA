import 'package:flutter/material.dart';

import '../../../../Config/config.dart';
import '../../widget.dart';

class LessonItemOnAccordion extends StatelessWidget {
  const LessonItemOnAccordion({
    super.key,
    required this.icon,
    required this.name,
    this.videoDuration,
    this.isCompleted = false,
    this.showDownloadIcon = false,
    this.isDownloading = false,
    this.downloadProgress,
    this.onTap,
  });
  final IconData icon;
  final String name;
  final String? videoDuration;
  final bool isCompleted;

  /// A file row: shows a download icon while it is neither done nor running
  final bool showDownloadIcon;

  /// The file is downloading now: shows the percent and a ring
  final bool isDownloading;

  /// 0..1 while [isDownloading], null when the total size is unknown
  /// (indeterminate ring, no percent text)
  final double? downloadProgress;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 12),
                Expanded(child: TextX(name, style: TextStyleX.titleSmall)),
                SizedBox(width: 12),
                if (videoDuration != null && videoDuration!.isNotEmpty)
                  TextX(
                    videoDuration!,
                    style: TextStyleX.labelLarge,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                if (!isCompleted && isDownloading) ..._downloading(context),
                if (!isCompleted && !isDownloading && showDownloadIcon)
                  _downloadIcon(context),
                if (isCompleted)
                  Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: EdgeInsetsDirectional.only(start: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        gradient: ColorX.primaryGradient2,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(IconX.check, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }

  /// The ring, plus the percent when the total size is known. The percent is
  /// kept left to right so Arabic reads «45%», not «%45».
  List<Widget> _downloading(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final progress = downloadProgress;
    return [
      if (progress != null)
        Directionality(
          textDirection: TextDirection.ltr,
          child: TextX(
            '${(progress * 100).floor()}%',
            style: TextStyleX.labelLarge,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      Container(
        width: 24,
        height: 24,
        margin: EdgeInsetsDirectional.only(start: 12),
        padding: const EdgeInsets.all(2),
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 2.5,
          color: color,
          backgroundColor: color.withValues(alpha: 0.15),
        ),
      ),
    ];
  }

  /// Same 24 size as the completed mark, an outlined circle with the icon
  Widget _downloadIcon(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
      child: Container(
        width: 24,
        height: 24,
        margin: EdgeInsetsDirectional.only(start: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          shape: BoxShape.circle,
        ),
        child: Center(child: Icon(IconX.download, size: 14, color: color)),
      ),
    );
  }
}
