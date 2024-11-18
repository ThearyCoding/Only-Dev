import 'package:e_leaningapp/widgets/cards/build_course_card_widget_ui_v2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../model/admin_model.dart';
import '../../providers/search_engine_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/registration_provider.dart';

class SearchEnginePage extends StatefulWidget {
  const SearchEnginePage({Key? key}) : super(key: key);

  @override
  SearchEnginePageState createState() => SearchEnginePageState();
}

class SearchEnginePageState extends State<SearchEnginePage> {
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          splashRadius: 20,
          tooltip: localization.back,
          icon: Icon(
            Icons.arrow_back_ios,
            size: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Provider.of<SearchEngineProvider>(context, listen: false)
                .clearSearch();
            context.pop();
          },
        ),
        title: Text(
          localization.searchCourses,
          style: TextStyle(
            fontSize: 20,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Consumer<SearchEngineProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextField(
                    controller: textController,
                    focusNode: focusNode,
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        provider.txtSearch = value;
                        provider.searchCourses(value);
                      }
                    },
                    decoration: InputDecoration(
                      icon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      hintText: localization.searchHint,
                      hintStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : !provider.searchAttempted
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search,
                                    size: 50, color: Colors.blue),
                                const SizedBox(height: 20),
                                Text(
                                  localization.startSearching,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : provider.courses.isEmpty
                            ? Center(
                                child: Text(
                                  localization.noResultsFound,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              )
                            : Consumer2<AdminProvider, RegistrationProvider>(
                                builder: (context, adminProvider,
                                    registrationProvider, child) {
                                  return ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    itemCount: provider.courses.length,
                                    itemBuilder: (context, index) {
                                      final course = provider.courses[index];
                                      final admin =
                                          adminProvider.admins.firstWhere(
                                        (admin) => admin.id == course.adminId,
                                        orElse: () => AdminModel(
                                            id: '',
                                            name: 'Unknown',
                                            email: '',
                                            imageUrl: ''),
                                      );
                                      final isRegistered = registrationProvider
                                          .registeredCourses
                                          .any(
                                        (register) =>
                                            register.courseId == course.id,
                                      );

                                      return CourseCardV2(
                                        course: course,
                                        admin: admin,
                                        quizCount: 10,
                                        isRegistered: isRegistered,
                                        totalLectures: 20,
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }
}
