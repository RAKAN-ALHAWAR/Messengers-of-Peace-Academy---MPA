import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
      child: Column(
        children: [
          LabelX(
            'List of certificates I have obtained',
          ).fadeAnimation200.marginOnly(bottom: 12),
          Expanded(
            child:
                controller.certificates.isEmpty
                    /// Empty state, in a Column so it sits at the top with the
                    /// original 150 margin instead of the page centre
                    ? Column(
                      children: [
                        EmptyMessage(
                          'No certificates',
                        ).fadeAnimation250.marginOnly(top: 150),
                      ],
                    )
                    : ListView.builder(
                      key: PageStorageKey((
                        LocalDataX.sessionRevision,
                        TranslationX.getLanguageCode,
                        'certificates',
                      )),
                      itemCount: controller.certificates.length,
                      itemBuilder:
                          (_, index) =>
                              CertificateCard(
                                certificate: controller.certificates[index],
                                onShareCertificate:
                                    controller.onShareCertificate,
                                onDownloadCertificate:
                                    controller.onDownloadCertificate,
                              ).fadeAnimation200,
                    ),
          ),
        ],
      ),
    );
  }
}
