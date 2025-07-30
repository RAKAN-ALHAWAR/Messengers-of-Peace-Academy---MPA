import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Core/Error/error.dart';
import '../../../../Data/data.dart';
import '../../../Section/GeneralState/empty.dart';
import '../../../Section/GeneralState/error.dart';
import 'prototype_height.dart';

class ScrollRefreshLoadMoreX<T> extends StatefulWidget {
  final Widget Function(T data, int index) itemBuilder;

  final Future<List<T>> Function(ScrollRefreshLoadMoreParametersX parameters)
  fetchData;

  final List<T> firstFixedData;
  final List<T> lastFixedData;
  final bool isShowFixedDataAsInitLoading;

  final VoidCallback? onRefresh;
  final Function(
    bool isInitLoading,
    bool isLoadMoreLoading,
    bool isRefreshLoading,
  )?
  onLoading;

  final Map<String, dynamic>? filters;
  final int pageSize;
  final int initPage;
  final String? orderBy;
  final ScrollController? scrollController;

  final Widget? header;
  final bool isHideHeaderIfEmpty;
  final bool isHideHeaderIfError;
  final bool isHideHeaderIfInitLoading;
  final bool isHeaderPadding;
  final bool isScrollingHeader;

  final Widget? empty;
  final String? emptyMessage;
  final Widget? emptySearch;
  final String? emptySearchMessage;
  final bool isHideEmpty;
  final bool isEmptyCenter;
  final bool isEmptySearchCenter;
  final Widget Function(String error)? errorWidget;

  final Widget? noMoreData;
  final String? noMoreDataMessage;
  final bool isShowNoMoreData;

  final Widget? initLoading;
  final bool isScrollingInitLoading;
  final Widget? loadMoreLoading;
  final bool isShowLoadMoreLoading;

  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double spaceBetweenHeaderAndContent;

  final String? searchQuery;
  final TextEditingController? searchQueryController;

  final bool asWrap;
  final double runSpacingWrap;
  final double spacingWrap;

  late final bool isExpanded;
  final bool isGetMoreEnabled;
  final double? height;
  final double? width;
  final BoxConstraints? constraints;
  final Axis scrollDirection;
  final ScrollController? parentScrollController;
  late final bool isScrollEnabled;

  ScrollRefreshLoadMoreX({
    super.key,
    required this.fetchData,
    required this.itemBuilder,
    this.firstFixedData = const [],
    this.lastFixedData = const [],
    this.isShowFixedDataAsInitLoading = false,
    this.empty,
    this.emptySearch,
    this.emptyMessage,
    this.emptySearchMessage,
    this.noMoreData,
    this.initLoading,
    this.isScrollingInitLoading = true,
    this.isScrollingHeader = false,
    this.loadMoreLoading,
    this.isShowLoadMoreLoading = true,
    this.errorWidget,
    this.padding,
    this.margin,
    this.pageSize = 10,
    this.initPage = 1,
    this.scrollController,
    this.onRefresh,
    this.searchQuery,
    this.searchQueryController,
    this.filters,
    this.orderBy,
    this.onLoading,
    this.noMoreDataMessage,
    this.isShowNoMoreData = true,
    this.asWrap = false,
    this.runSpacingWrap = 10,
    this.spacingWrap = 10,
    this.isEmptyCenter = false,
    this.isEmptySearchCenter = false,
    bool isExpanded = true,
    this.isGetMoreEnabled = true,
    this.scrollDirection = Axis.vertical,
    this.height,
    this.width,
    this.spaceBetweenHeaderAndContent = 10,
    this.header,
    this.isHideHeaderIfEmpty = false,
    this.isHideHeaderIfError = false,
    this.isHideHeaderIfInitLoading = true,
    this.isHeaderPadding = true,
    this.isHideEmpty = false,
    this.constraints,
    this.parentScrollController,
    bool isScrollEnabled = false,
  }) {
    this.isScrollEnabled =
        this.parentScrollController != null ? true : isScrollEnabled;
    this.isExpanded = this.parentScrollController != null ? false : isExpanded;
  }

  @override
  State<ScrollRefreshLoadMoreX<T>> createState() =>
      ScrollRefreshLoadMoreXState<T>();
}

class ScrollRefreshLoadMoreXState<T> extends State<ScrollRefreshLoadMoreX<T>> {
  List<T> items = [];
  late int currentPage;
  bool isInitLoading = false;
  bool isLoadMoreLoading = false;
  late bool hasMoreData;
  bool isRefreshing = false;
  ErrorX? error;
  String? lastSearchQuery;
  late ScrollController scrollController;
  bool shouldShowLoadMore = false;
  bool shouldShowNoMoreData = false;
  Map<String, dynamic> filters = {};
  bool isListenerAdded = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    hasMoreData = widget.isGetMoreEnabled;
    if (widget.filters != null) {
      filters.addAll(widget.filters!);
    }
    currentPage = widget.initPage;
    scrollController = widget.scrollController ?? ScrollController();
    if (widget.isShowFixedDataAsInitLoading) {
      items = [...widget.firstFixedData, ...widget.lastFixedData];
    }
    await loadData(isInit: !widget.isShowFixedDataAsInitLoading);

    if (!isListenerAdded && mounted) {
      if (widget.parentScrollController != null) {
        widget.parentScrollController!.addListener(_scrollListener);
      } else {
        scrollController.addListener(_scrollListener);
      }
      isListenerAdded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await checkIfNeedScroll();
      });
    }

    if (widget.searchQueryController != null) {
      lastSearchQuery = "";
      widget.searchQueryController!.addListener(() {
        if (_debounce?.isActive ?? false) _debounce!.cancel();

        _debounce = Timer(const Duration(milliseconds: 500), () async {
          if (lastSearchQuery!.trim() !=
              widget.searchQueryController!.text.trim()) {
            lastSearchQuery = widget.searchQueryController!.text;
            await resetData(search: widget.searchQueryController!.text);
          }
        });
      });
    }
  }

  Future<void> _scrollListener() async {
    if (!mounted) return;
    await checkGetMoreData();
    if (!mounted) return;
    updateShouldShowLoadMore();
  }

  Future<void> checkIfNeedScroll() async {
    if (!mounted) return;
    if (items.isNotEmpty && scrollController.hasClients) {
      while (true) {
        if (scrollController.hasClients &&
            scrollController.position.maxScrollExtent == 0 &&
            hasMoreData) {
          updateShouldShowLoadMore(isShowLoadMore: true);
          await checkGetMoreData();
        } else {
          break;
        }
      }
    }
  }

  // تحديث عنصر باستخدام الفهرس
  void updateItemByIndex(int index, T newItem) {
    setState(() {
      items[index] = newItem;
    });
  }

  // تحديث عنصر باستخدام شرط
  void updateItemByCondition(bool Function(T) condition, T newItem) {
    setState(() {
      int index = items.indexWhere(condition);
      if (index != -1) {
        items[index] = newItem;
      }
    });
  }

  // دالة لإضافة عنصر جديد مع إمكانية تحديد index
  void addItem(T newItem, {int? index}) {
    setState(() {
      if (index != null && index >= 0 && index < items.length) {
        items.insert(index, newItem); // إدراج العنصر في الـ index المحدد
      } else {
        items.add(
          newItem,
        ); // إضافة العنصر في نهاية القائمة إذا لم يتم تحديد index صحيح
      }
    });
  }

  // حذف عنصر باستخدام الفهرس
  void removeItemByIndex(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  // حذف عنصر باستخدام شرط
  void removeItemByCondition(bool Function(T) condition) {
    setState(() {
      items.removeWhere(condition);
    });
  }

  Future<void> refresh() async {
    setState(() {
      items = [];
      currentPage = widget.initPage;
      hasMoreData = widget.isGetMoreEnabled;
      isInitLoading = true; // عرض حالة التحميل الأولي
      isLoadMoreLoading = false;
      isRefreshing = false;
      error = null;
    });

    await loadData(isInit: true); // إعادة تحميل البيانات
  }

  @override
  void didUpdateWidget(covariant ScrollRefreshLoadMoreX<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initPage != oldWidget.initPage ||
        widget.searchQuery != oldWidget.searchQuery ||
        widget.searchQueryController != oldWidget.searchQueryController ||
        (widget.filters != oldWidget.filters &&
            filters.toString() != widget.filters.toString()) ||
        widget.orderBy != oldWidget.orderBy) {
      if (widget.filters != null && widget.filters != oldWidget.filters) {
        filters.clear();
        filters.addAll(widget.filters!);
      }
      resetData();
    }
  }

  Future<void> loadData({
    bool isInit = false,
    bool isRefresh = false,
    bool isLoadMore = false,
    String? search,
  }) async {
    setState(() {
      isInitLoading = isInit;
      isRefreshing = isRefresh;
      isLoadMoreLoading = isLoadMore;
      error = null;
      if (isInit || isRefresh) {
        hasMoreData = widget.isGetMoreEnabled;
        currentPage = widget.initPage;
        items = [];
      }
      widget.onLoading?.call(isInit, isLoadMore, isRefresh);
    });
    try {
      List<T> newData = await widget.fetchData(
        ScrollRefreshLoadMoreParametersX(
          page: currentPage,
          perPage: widget.pageSize,
          searchQuery:
              search ??
              widget.searchQueryController?.text ??
              widget.searchQuery,
          filters: widget.filters,
          orderBy: widget.orderBy,
        ),
      );
      setState(() {
        if (isInit || isRefresh) {
          items = [
            ...widget.firstFixedData,
            ...newData,
            ...widget.lastFixedData,
          ];
        } else {
          items.insertAll(items.length - widget.lastFixedData.length, newData);
        }
        hasMoreData = newData.length == widget.pageSize;
        currentPage++;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toErrorX;
          shouldShowLoadMore = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isInitLoading = false;
          isRefreshing = false;
          isLoadMoreLoading = false;
        });
      }
      widget.onLoading?.call(isInit, isLoadMore, isRefresh);
      if (isRefresh) {
        widget.onRefresh?.call();
      }
    }
  }

  Future<void> resetData({String? search}) async {
    if (!isRefreshing && mounted) {
      setState(() {
        items = [];
        currentPage = widget.initPage;
        hasMoreData = true;
      });
      await loadData(isInit: true, search: search);
    }
  }

  Future<void> checkGetMoreData() async {
    if (widget.isGetMoreEnabled &&
        ((widget.parentScrollController != null &&
                widget.parentScrollController!.position.pixels ==
                    widget.parentScrollController!.position.maxScrollExtent) ||
            (scrollController.hasClients &&
                scrollController.position.pixels ==
                    scrollController.position.maxScrollExtent)) &&
        hasMoreData &&
        !isLoadMoreLoading) {
      await loadData(isLoadMore: true);
    }
  }

  void updateShouldShowLoadMore({bool? isShowLoadMore}) {
    if (!widget.isGetMoreEnabled) {
      setState(() {
        shouldShowLoadMore = false;
      });
    } else if (isShowLoadMore != null ||
        (!scrollController.hasClients && hasMoreData && !isRefreshing)) {
      setState(() {
        shouldShowLoadMore = isShowLoadMore ?? true;
      });
    } else if (error == null &&
        ((widget.parentScrollController != null &&
                widget.parentScrollController!.hasClients) ||
            scrollController.hasClients)) {
      setState(() {
        shouldShowLoadMore =
            (widget.parentScrollController?.position.maxScrollExtent ??
                scrollController.position.maxScrollExtent) >
            10;
      });
    }
    setState(() {
      shouldShowNoMoreData =
          (widget.parentScrollController?.position.maxScrollExtent ??
              scrollController.position.maxScrollExtent) >
          10;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (isListenerAdded) {
      if (widget.parentScrollController != null) {
        widget.parentScrollController!.removeListener(_scrollListener);
      } else {
        scrollController.removeListener(_scrollListener);
      }
    }
    scrollController.dispose();
    super.dispose();
  }

  int countItems() {
    return items.length +
        1 +
        (widget.isScrollingHeader && widget.header != null ? 1 : 0);
  }

  ScrollPhysics get physics =>
      widget.isScrollEnabled
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics();

  Widget buildContent() {
    if (error != null && items.isEmpty) {
      return buildErrorView();
    }
    if (isInitLoading || (isRefreshing && items.isEmpty)) {
      return buildInitLoadingView();
    }
    if (items.isEmpty &&
        (widget.searchQuery?.isNotEmpty == true ||
            (widget.searchQueryController != null &&
                widget.searchQueryController!.text.isNotEmpty))) {
      return buildEmptySearchView();
    }
    if (items.isEmpty) {
      return buildEmptyView();
    }
    return widget.asWrap ? buildWrapContent() : buildListContent();
  }

  Widget buildErrorView() {
    if (widget.isHideHeaderIfError) {
      return const SizedBox();
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          double minHeight =
              widget.isScrollEnabled
                  ? 0
                  : constraints.maxHeight - (widget.padding?.vertical ?? 0);
          return Container(
            constraints: constraints,
            child: SingleChildScrollView(
              padding: widget.padding,
              physics: physics,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minHeight == double.infinity ? 0 : minHeight,
                ),
                child:
                    widget.errorWidget?.call(error!.message) ??
                    ErrorView(
                      error: error!,
                      onTapButton: () async => await loadData(isRefresh: true),
                    ),
              ),
            ),
          );
        },
      );
    }
  }

  Widget buildInitLoadingView() {
    return LayoutBuilder(
      builder:
          (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight - (widget.margin?.vertical ?? 0),
            ),
            child:
                widget.isScrollingInitLoading
                    ? SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: widget.padding?.bottom ?? 0,
                        left: widget.padding?.left ?? 0,
                        right: widget.padding?.right ?? 0,
                        top:
                            widget.isHideHeaderIfInitLoading
                                ? widget.padding?.top ?? 0
                                : 0,
                      ),
                      scrollDirection: widget.scrollDirection,
                      child:
                          widget.initLoading ??
                          const Center(child: CircularProgressIndicator()),
                    )
                    : widget.initLoading ??
                        const Center(child: CircularProgressIndicator()),
          ),
    );
  }

  Widget buildEmptyView() {
    if (widget.isHideEmpty) {
      return const SizedBox();
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          double minHeight =
              widget.isScrollEnabled
                  ? 0
                  : constraints.maxHeight - (widget.padding?.vertical ?? 0);
          return SingleChildScrollView(
            padding: widget.padding,
            physics: physics,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: minHeight == double.infinity ? 0 : minHeight,
              ),
              child: Align(
                alignment:
                    widget.isEmptyCenter
                        ? Alignment.center
                        : Alignment.topCenter,
                child:
                    widget.empty ??
                    EmptyView(
                      message: widget.emptyMessage ?? "No Data Available",
                      isMargin: false,
                    ),
              ),
            ),
          );
        },
      );
    }
  }

  Widget buildEmptySearchView() {
    return LayoutBuilder(
      builder:
          (context, constraints) => SingleChildScrollView(
            padding: widget.padding,
            physics: physics,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    widget.isScrollEnabled
                        ? 0
                        : constraints.maxHeight -
                            (widget.padding?.vertical ?? 0),
              ),
              child: Align(
                alignment:
                    widget.isEmptySearchCenter
                        ? Alignment.center
                        : Alignment.topCenter,
                child:
                    widget.emptySearch ??
                    EmptyView(
                      message:
                          widget.emptySearchMessage ??
                          "There are no search results.\nTry searching for something else",
                      isMargin: false,
                    ),
              ),
            ),
          ),
    );
  }

  Widget buildWrapContent() {
    return SingleChildScrollView(
      padding: widget.padding,
      physics: physics,
      scrollDirection: widget.scrollDirection,
      child: Column(
        children: [
          Wrap(
            runSpacing: widget.runSpacingWrap,
            spacing: widget.spacingWrap,
            children: List.generate(
              items.length,
              (index) => widget.itemBuilder(items[index], index),
            ),
          ),
          if (shouldShowLoadMore && hasMoreData && !isRefreshing)
            widget.isShowLoadMoreLoading
                ? widget.loadMoreLoading ??
                    const Center(child: CircularProgressIndicator())
                : const SizedBox(),
          if (widget.isGetMoreEnabled &&
              shouldShowLoadMore &&
              shouldShowNoMoreData &&
              widget.isShowNoMoreData &&
              !hasMoreData &&
              !isRefreshing &&
              widget.scrollDirection != Axis.horizontal)
            widget.noMoreData ?? const Center(child: TextX('No more data')),
        ],
      ),
    );
  }

  Widget buildListContent() {
    if (widget.scrollDirection == Axis.horizontal) {
      return Padding(
        padding: EdgeInsets.only(
          top: widget.padding?.top ?? 0,
          bottom: widget.padding?.bottom ?? 0,
        ),
        child: PrototypeHeight(
          prototype: widget.itemBuilder(items[0], 0),
          child: ListView.builder(
            physics: physics,
            scrollDirection: widget.scrollDirection,
            shrinkWrap: true,
            padding: EdgeInsets.only(
              right: widget.padding?.left ?? 0,
              left: widget.padding?.right ?? 0,
            ),
            controller: scrollController,
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == items.length) {
                if (shouldShowLoadMore && hasMoreData && !isRefreshing) {
                  return widget.isShowLoadMoreLoading
                      ? widget.loadMoreLoading ??
                          const Center(child: CircularProgressIndicator())
                      : const SizedBox();
                }
                if (shouldShowLoadMore &&
                    shouldShowNoMoreData &&
                    widget.isShowNoMoreData &&
                    !hasMoreData &&
                    !isRefreshing &&
                    widget.noMoreData != null) {
                  return widget.noMoreData;
                }
                return const SizedBox();
              }
              return widget.itemBuilder(items[index], index);
            },
          ),
        ),
      );
    }
    return ListView.builder(
      physics: physics,
      scrollDirection: widget.scrollDirection,
      shrinkWrap: true,
      padding: EdgeInsets.only(
        bottom: widget.padding?.bottom ?? 0,
        left: widget.padding?.left ?? 0,
        right: widget.padding?.right ?? 0,
        top:
            widget.header == null
                ? (widget.padding?.top ?? 0)
                : widget.isScrollingHeader
                ? (widget.padding?.top ?? 0)
                : 0,
      ),
      controller: scrollController,
      itemCount: countItems(),
      itemBuilder: (context, index) {
        if (widget.isScrollingHeader &&
            widget.header != null &&
            index == 0 &&
            !(widget.isHideHeaderIfError &&
                error != null &&
                items.isEmpty &&
                !isInitLoading) &&
            !(widget.isHideHeaderIfEmpty && items.isEmpty && !isInitLoading)) {
          return MediaQuery.removePadding(
            context: context,
            removeLeft: true,
            removeRight: true,
            removeBottom: true,
            removeTop: true,
            child: widget.header!,
          ).marginOnly(bottom: widget.spaceBetweenHeaderAndContent);
        }
        if (index == countItems() - 1) {
          if (shouldShowLoadMore && hasMoreData && !isRefreshing) {
            return widget.isShowLoadMoreLoading
                ? widget.loadMoreLoading ??
                    const Center(child: CircularProgressIndicator())
                : const SizedBox();
          }
          if (widget.isGetMoreEnabled &&
              shouldShowLoadMore &&
              shouldShowNoMoreData &&
              widget.isShowNoMoreData &&
              !hasMoreData &&
              !isRefreshing &&
              widget.scrollDirection != Axis.horizontal) {
            return widget.noMoreData ??
                const Center(child: TextX("No more data"));
          }
          return const SizedBox();
        }
        return widget.itemBuilder(
          items[widget.isScrollingHeader && widget.header != null
              ? index - 1
              : index],
          widget.isScrollingHeader && widget.header != null ? index - 1 : index,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? parentWidget = context.findAncestorWidgetOfExactType<Column>();
    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.margin,
      constraints: widget.constraints,
      child: RefreshIndicator(
        onRefresh: () async => await loadData(isRefresh: true),
        child: Column(
          children: [
            if (widget.header != null &&
                (!widget.isScrollingHeader ||
                    (widget.isScrollingHeader &&
                        !widget.isHideHeaderIfInitLoading &&
                        isInitLoading) ||
                    (widget.isScrollingHeader &&
                        !widget.isHideHeaderIfEmpty &&
                        items.isEmpty &&
                        !isInitLoading)) &&
                !(widget.isHideHeaderIfError &&
                    error != null &&
                    !isInitLoading &&
                    items.isEmpty) &&
                !(widget.isHideHeaderIfEmpty &&
                    items.isEmpty &&
                    !isInitLoading) &&
                !(widget.isHideHeaderIfInitLoading && isInitLoading))
              Padding(
                padding: EdgeInsets.only(
                  bottom: widget.spaceBetweenHeaderAndContent,
                  left: widget.isHeaderPadding ? widget.padding?.left ?? 0 : 0,
                  right:
                      widget.isHeaderPadding ? widget.padding?.right ?? 0 : 0,
                  top: widget.isHeaderPadding ? widget.padding?.top ?? 0 : 0,
                ),
                child: widget.header!.addParentX(
                  (child) => MediaQuery.removePadding(
                    context: context,
                    removeLeft: true,
                    removeRight: true,
                    removeBottom: true,
                    removeTop: true,
                    child: child,
                  ),
                  condition: widget.isScrollingHeader,
                ),
              ),
            buildContent().addParentX(
              (child) => Expanded(child: child),
              condition:
                  widget.isExpanded && widget.scrollDirection == Axis.vertical,
            ),
          ],
        ),
      ),
    ).addParentX(
      (child) => Expanded(child: child),
      condition:
          widget.isExpanded &&
          widget.scrollDirection == Axis.vertical &&
          parentWidget != null,
    );
  }
}
