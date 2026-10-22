import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Core/Extension/date_time.dart';
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
          requestKey: (controller, TranslationX.getLanguageCode),

          /// Loading state
          loading: const BlogLoading(),

          /// Data state
          child:
              (_) => Obx(() {
                final data = List<BlogX>.of(controller.blogs);
                final loadingMore = controller.isLoadingMore.value;
                final hasMore = controller.hasMore.value;
                final error = controller.loadMoreError.value;
                if (data.isEmpty && !hasMore) {
                  return const EmptyMessage('No blogs currently');
                }
                return ListView.builder(
                  padding: StyleX.paddingApp,
                  itemCount: data.length + 1,
                  itemBuilder: (context, index) {
                    if (index < data.length) {
                      final blog = data[index];
                      return KeyedSubtree(
                        key: ValueKey(blog.id),
                        child: _article(context, blog),
                      );
                    }
                    if (loadingMore) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!hasMore) {
                      return const SizedBox();
                    }
                    return Column(
                      children: [
                        if (error != null)
                          TextX(
                            'Unable to load more articles. Please try again.',
                          ),
                        TextButton(
                          onPressed: controller.loadMore,
                          child: TextX(
                            error == null ? 'Load more' : 'Try again',
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
        ),
      ),
    );
  }

  Widget _article(BuildContext context, BlogX blog) => GestureDetector(
    onTap: () => controller.onArticleDetails(blog),
    child: ContainerX(
      radius: StyleX.radiusLg,
      padding: EdgeInsets.all(12),
      width: double.maxFinite,
      child: Row(
        children: [
          /// Blog image
          ImageNetworkX(
            imageUrl: blog.imageUrlWithoutWebservice ?? blog.imageUrl,
            width: 100,
            height: 100,
            radius: StyleX.radiusLg,
            failed: Container(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                TextX(blog.subject, style: TextStyleX.titleMedium),

                /// Spacer
                SizedBox(height: 4, width: double.infinity),

                /// Blog date
                TextX(
                  blog.createdAt != null
                      ? blog.createdAt!.formatDateAndTime(
                        TranslationX.getLanguageCode,
                      )
                      : '',
                  style: TextStyleX.labelMedium,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ).fadeAnimation150.marginOnly(bottom: 16);
}
