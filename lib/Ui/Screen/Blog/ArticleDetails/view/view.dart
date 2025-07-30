import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Widget/Custom/Other/html_widget.dart';
import '../controller/controller.dart';

class ArticleDetailsView extends GetView<ArticleDetailsController> {
  const ArticleDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    /// Article details
    return Scaffold(
      appBar: AppBarX(title: 'Article Details'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: StyleX.paddingApp,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Article date
              TextX(
                controller.blog.createdAt != null
                    ? "${DateFormat('d MMMM', 'ar').format(controller.blog.createdAt!)} . ${DateFormat('hh:mm a', 'ar').format(controller.blog.createdAt!)}"
                    : '',
                style: TextStyleX.labelMedium,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ).fadeAnimation150,

              /// Spacer
              SizedBox(height: 6),

              /// Article subject
              TextX(
                controller.blog.subject,
                style: TextStyleX.titleLarge,
              ).fadeAnimation200,

              /// Spacer
              SizedBox(height: 24),

              /// Article image
              ImageNetworkX(
                imageUrl:
                    controller.blog.imageUrlWithoutWebservice ??
                    controller.blog.imageUrl,
                width: double.infinity,
                height: 210,
                radius: StyleX.radiusLg,
                failed: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              ).fadeAnimation200,

              /// Spacer
              SizedBox(height: 24),

              /// Article content
              HtmlWidgetX(
                html: controller.blog.summary,
                textStyle: TextStyleX.labelLarge,
              ).fadeAnimation250,
            ],
          ),
        ),
      ),
    );
  }
}
