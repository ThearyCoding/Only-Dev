import 'package:e_leaningapp/providers/categories_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../export/export.dart';

class CategoryWidget extends StatefulWidget {
  final CategoriesProvider categoriesProvider;
  final ScrollController scrollController;

  const CategoryWidget({
    super.key,
    required this.categoriesProvider,
    required this.scrollController,
  });

  @override
  CategoryWidgetState createState() => CategoryWidgetState();
}

class CategoryWidgetState extends State<CategoryWidget> {
  Timer? _scrollTimer;
  bool _isHovered = false;
  final Duration _scrollInterval =
      const Duration(seconds: 5);
  final Duration _scrollAnimationDuration =
      const Duration(seconds: 5);

  @override
  void initState() {
    super.initState();

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(_scrollInterval, (timer) {
      if (_isHovered) return;

      final scrollController = widget.scrollController;
      if (scrollController.hasClients) {
        final maxScrollExtent = scrollController.position.maxScrollExtent;
        final currentScrollPosition = scrollController.offset;
        final scrollOffset =
            currentScrollPosition >= maxScrollExtent ? 0 : maxScrollExtent;

        scrollController.animateTo(
          scrollOffset.toDouble(),
          duration: _scrollAnimationDuration,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          double widgetHeight;
          double widgetWidth = 200;
          double fontSize = 16;
          if (constraints.maxWidth < 360) {
            widgetHeight = 80.0;
            fontSize = 10;
          } else if (constraints.maxWidth < 480) {
            widgetHeight = 90.0;
            widgetWidth = 180;
            fontSize = 12;
          } else if (constraints.maxWidth < 600) {
            widgetHeight = 120.0;
            widgetWidth = 200.0;
            fontSize = 16;
          } else {
            widgetHeight = 160.0;
            widgetWidth = 220.0;
            fontSize = 18;
          }

          return SizedBox(
              height: widgetHeight,
              child: Consumer<CategoriesProvider>(
                builder: (context, value, child) {
                  if (widget.categoriesProvider.categories.isEmpty &&
                      !widget.categoriesProvider.isLoading) {
                    return const Center(
                      child: Text("No Categories Found yet!"),
                    );
                  }
                  if (widget.categoriesProvider.isLoading) {
                    return const BuildCategoriesShimmerWidget();
                  }
                  return ListView.builder(
                    controller: widget.scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.categoriesProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category =
                          widget.categoriesProvider.categories[index];
                      return Container(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 10.0 : 0.0,
                          top: 10,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            context.push(RoutesPath.courseScreen, extra: {
                              'cateogoryId': category.id,
                              'title': category.title,
                            });
                          },
                          child: CategoryCard(
                            imageUrl: category.imageUrl,
                            title: category.title,
                            widgetWidth: widgetWidth,
                            fontSize: fontSize,
                          ),
                        ),
                      );
                    },
                  );
                },
              ));
        },
      ),
    );
  }
}
