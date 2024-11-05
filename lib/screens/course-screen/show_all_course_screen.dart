
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
import '../../providers/registration_provider.dart';
import '../../generated/l10n.dart';
import '../../providers/all_courses_provider.dart';
import '../../widgets/course-widget/course_list_widget.dart';
import '../search-screen/search_engine_screen.dart';

class AllCoursesScreen extends StatefulWidget {
  const AllCoursesScreen({super.key});

  @override
  State<AllCoursesScreen> createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen>
    with SingleTickerProviderStateMixin {
  final PageStorageBucket _bucket = PageStorageBucket();
  late RegistrationProvider registrationProvider;

  @override
  void initState() {
    super.initState();

    registrationProvider =
        Provider.of<RegistrationProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localization = S.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          localization.allCourses,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            tooltip: localization.searchCourses,
            splashRadius: 20,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SearchEnginePage()),
              );
            },
            icon: const Icon(Icons.search, size: 26),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Consumer<AllCoursesProvider>(
            builder: (context, provider, child) {
              if (provider.categories.isEmpty ||
                  provider.tabController == null) {
                return const SizedBox.shrink();
              }

              return TabBar(
                onTap: (index) {
                  provider.onTabTapped(index);
                },
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  return states.contains(WidgetState.focused)
                      ? null
                      : Colors.transparent;
                }),
                indicator: RectangularIndicator(
                    bottomLeftRadius: 100,
                    bottomRightRadius: 100,
                    topLeftRadius: 100,
                    topRightRadius: 100,
                    verticalPadding: 5,
                    color: Colors.blueAccent.shade400.withOpacity(.3)),
                indicatorColor: Colors.blueAccent[500],
                controller: provider.tabController,
                isScrollable: true,
                tabs: provider.categories
                    .map((category) => Tab(
                          text: category.title,
                          height: 40,
                        ))
                    .toList(),
              );
            },
          ),
        ),
      ),
      body: Consumer<AllCoursesProvider>(
        builder: (context, provider, child) {
          if (provider.categories.isEmpty || provider.tabController == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return PageStorage(
            bucket: _bucket,
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: provider.tabController,
              children: provider.categories.map((category) {
                final index = provider.categories.indexOf(category);
                return CourseListWidget(
                  categoryId: category.id,
                  index: index,
                  registrationProvider: registrationProvider,
                  allCoursesProvider: provider,
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
