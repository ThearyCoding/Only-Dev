
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../providers/search_engine_provider.dart';

class SearchEnginePage extends StatelessWidget {
  const SearchEnginePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController textController = TextEditingController();
    final FocusNode focusNode = FocusNode();
    final localization = S.of(context);
    // Request focus when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    return Scaffold(
      appBar: AppBar(
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
        title:  Text(
          localization.searchCourses,
          style: TextStyle(fontSize: 20, color: isDarkMode ? Colors.white : Colors.black),
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
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10.0),
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
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search),
                      border: InputBorder.none,
                      hintText: 'ស្វែងរក៖ មេរៀន',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : !provider.searchAttempted
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search,
                                    size: 50, color: Colors.blue),
                                SizedBox(height: 20),
                                Text(
                                  'ចាប់ផ្តើមស្វែងរកដោយការសរសេរចូលទីនេះ',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : provider.courses.isEmpty
                            ? const Center(
                                child: Text(
                                  'រកមិនឃើញលទ្ធផល',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                itemCount: provider.courses.length,
                                itemBuilder: (context, index) {
                                  final course = provider.courses[index];
                                  return ListTile(
                                    leading: course.imageUrl.isNotEmpty
                                        ? Image.network(course.imageUrl)
                                        : const Icon(Icons.image,
                                            size: 50, color: Colors.grey),
                                    title: Text(course.title),
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
