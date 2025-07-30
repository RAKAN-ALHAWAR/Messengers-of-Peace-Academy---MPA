import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../../Data/Model/blog.dart';
import '../../../../Widget/Basic/Utils/future_builder.dart';
import '../../../../Widget/Custom/Other/empty_message.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class BlogView extends GetView<BlogController> {
  const BlogView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: 'Blog'),
      body: SafeArea(
        /// Get data from the controller
        child: FutureBuilderX<List<BlogX>>(
          future: controller.getData,

          /// Loading state
          loading: const BlogLoading(),

          /// Data state
          child: (data) {
            /// Empty message
            if (data.isEmpty) {
              return const EmptyMessage('No blogs currently');
            }

            /// Content
            return SingleChildScrollView(
              padding: StyleX.paddingApp,
              child: Column(
                children: [
                  /// Blog cards
                  for (var blog in data)
                    GestureDetector(
                      onTap: () => controller.onArticleDetails(blog),
                      child: ContainerX(
                        radius: StyleX.radiusLg,
                        padding: EdgeInsets.all(12),
                        width: double.maxFinite,
                        child: Row(
                          children: [
                            /// Blog image
                            ImageNetworkX(
                              imageUrl:
                                  blog.imageUrlWithoutWebservice ??
                                  blog.imageUrl,
                              width: 100,
                              height: 100,
                              radius: StyleX.radiusLg,
                              failed: Container(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerLow,
                                child: Icon(Icons.image_not_supported_outlined),
                              ),
                            ),

                            /// Spacer
                            SizedBox(width: 16),

                            /// Blog subject and date
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Blog subject
                                  TextX(
                                    blog.subject,
                                    style: TextStyleX.titleMedium,
                                  ),

                                  /// Spacer
                                  SizedBox(height: 4, width: double.infinity),

                                  /// Blog date
                                  TextX(
                                    blog.createdAt != null
                                        ? "${DateFormat('d MMMM', 'ar').format(blog.createdAt!)} . ${DateFormat('hh:mm a', 'ar').format(blog.createdAt!)}"
                                        : '',
                                    style: TextStyleX.labelMedium,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).fadeAnimation150.marginOnly(bottom: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
