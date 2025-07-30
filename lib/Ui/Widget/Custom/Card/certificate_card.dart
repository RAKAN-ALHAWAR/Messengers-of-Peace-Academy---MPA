import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Config/config.dart';
import '../../../../Data/Model/my_certificate.dart';
import '../../widget.dart';

class CertificateCard extends StatelessWidget {
  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onDownloadCertificate,
    required this.onShareCertificate,
  });

  /// Certificate
  final MyCertificate certificate;
  final Function(MyCertificate) onDownloadCertificate;
  final Function(MyCertificate) onShareCertificate;

  @override
  Widget build(BuildContext context) {
    return ContainerX(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Certificate icon
          ContainerX(
            width: 52,
            height: 52,
            padding: EdgeInsets.zero,
            isShadow: true,
            radius: StyleX.radiusMd,
            child: Center(
              child: Icon(
                IconX.certificate,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
          ),

          /// Spacer
          SizedBox(width: 16),

          /// Certificate name and course name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Certificate name
                TextX(certificate.name, style: TextStyleX.titleMedium),

                /// Spacer
                SizedBox(height: 4),

                /// Course name
                TextX(
                  "${"Course".tr} - ${certificate.courseName}",
                  style: TextStyleX.labelLarge,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),

                /// Spacer
                SizedBox(height: 4),

                /// Issued date
                TextX(
                  certificate.issuedDate,
                  style: TextStyleX.labelLarge,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),

                /// Dash line
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: DashLineX(
                    dashWith: 5,
                    dashHeight: 1,
                    fillRate: 0.6,
                    dashColor: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),

                /// Download and share buttons
                Row(
                  children: [
                    /// Download button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          onDownloadCertificate(certificate);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              /// Download icon
                              Icon(IconX.download, size: 20),

                              /// Spacer
                              SizedBox(width: 4),

                              /// Download text
                              TextX("Download"),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// Spacer
                    SizedBox(width: 12),

                    /// Share button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          onShareCertificate(certificate);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              /// Share icon
                              Icon(IconX.share, size: 20),

                              /// Spacer
                              SizedBox(width: 4),

                              /// Share text
                              TextX("Share"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
