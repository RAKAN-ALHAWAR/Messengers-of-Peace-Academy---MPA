part of '../../widget.dart';

/// Searchable country code dropdown widget
class SearchableCountryCodeDropdown extends StatelessWidget {
  final String? value;
  final List<PhoneCode> phoneCodesList;
  final Function(String) onChanged;
  final bool onlyEnglish;

  const SearchableCountryCodeDropdown({
    super.key,
    required this.value,
    required this.phoneCodesList,
    required this.onChanged,
    this.onlyEnglish = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSearchableDialog(context),
      child: ContainerX(
        height: StyleX.inputHeight,
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        isBorder: true,
        color: Theme.of(context).cardTheme.color,
        child: Row(
          children: [
            Expanded(
              child: TextX(
                value ?? '',
                style: TextStyleX.titleSmall,
                textDirection: onlyEnglish ? TextDirection.ltr : null,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 15),
          ],
        ),
      ),
    );
  }

  void _showSearchableDialog(BuildContext context) {
    final searchController = TextEditingController();
    final filteredList = phoneCodesList.obs;

    Get.bottomSheet(
      backgroundColor: Get.theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(StyleX.radiusLg),
        ),
      ),
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Center(
                child: Container(
                  height: 3,
                  width: 60,
                  decoration: BoxDecoration(
                    color: ColorX.grey.shade200,
                    borderRadius: BorderRadius.circular(StyleX.radiusLg),
                  ),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 16.0,
                start: StyleX.bottomSheetPadding,
                end: StyleX.bottomSheetPadding,
                bottom: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextX(
                      'Select Country Code'.tr,
                      style: TextStyleX.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Search field
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: StyleX.bottomSheetPadding,
              ),
              child: TextFieldX(
                controller: searchController,
                hint: 'Search by country name or code'.tr,
                icon: Icons.search,
                onChanged: (query) {
                  if (query.isEmpty) {
                    filteredList.value = phoneCodesList;
                  } else {
                    filteredList.value =
                        phoneCodesList.where((phoneCode) {
                          final searchLower = query.toLowerCase();
                          return phoneCode.name.toLowerCase().contains(
                                searchLower,
                              ) ||
                              phoneCode.dialCode.toLowerCase().contains(
                                searchLower,
                              ) ||
                              phoneCode.code.toLowerCase().contains(
                                searchLower,
                              );
                        }).toList();
                  }
                },
                margin: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            // List of country codes
            Flexible(
              child: Obx(
                () =>
                    filteredList.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: TextX(
                            'No results found'.tr,
                            style: TextStyleX.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredList.length,
                          padding: EdgeInsets.only(
                            bottom:
                                StyleX.bottomSheetPadding +
                                MediaQuery.of(context).padding.bottom,
                          ),
                          itemBuilder: (context, index) {
                            final phoneCode = filteredList[index];
                            final isSelected = phoneCode.dialCode == value;
                            return InkWell(
                              onTap: () {
                                onChanged(phoneCode.dialCode);
                                Get.back();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: StyleX.bottomSheetPadding,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.1)
                                          : null,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.1),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextX(
                                            phoneCode.name,
                                            style: TextStyleX.titleSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          TextX(
                                            phoneCode.dialCode,
                                            style: TextStyleX.bodySmall
                                                .copyWith(
                                                  color:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                            textDirection:
                                                onlyEnglish
                                                    ? TextDirection.ltr
                                                    : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        size: 24,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );

    // Initialize filtered list
    filteredList.value = phoneCodesList;
  }
}
