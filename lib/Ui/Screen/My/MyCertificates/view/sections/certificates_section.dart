import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Other/label.dart';
import '../../../../../Widget/Custom/Card/certificate_card.dart';
import '../../../../../Widget/Custom/Other/empty_message.dart';
import '../../controller/controller.dart';

class CertificatesSection extends GetView<MyCertificatesController> {
  const CertificatesSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
        child: Column(
          children: [
            /// Certificates label
            LabelX(
              "List of certificates I have obtained",
            ).fadeAnimation200.marginOnly(bottom: 12),

            /// If there are no certificates, show empty message
            if (controller.certificates.isEmpty)
              EmptyMessage(
                'No certificates',
              ).fadeAnimation250.marginOnly(top: 150),

            /// If there are certificates, show them
            if (controller.certificates.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// Certificates list cards
                      for (var certificate in controller.certificates)
                        CertificateCard(
                          certificate: certificate,
                          onShareCertificate: controller.onShareCertificate,
                          onDownloadCertificate:
                              controller.onDownloadCertificate,
                        ).fadeAnimation200,
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
