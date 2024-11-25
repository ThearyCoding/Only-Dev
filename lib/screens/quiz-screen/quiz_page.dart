import '../../export/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/quiz_provider.dart';
import '../../utils/show_dialog_infor_utils.dart';

class QuizPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final String categoryId;

  const QuizPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.categoryId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late QuizProvider quizProvider;
  User? user = FirebaseAuth.instance.currentUser;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    quizProvider = Provider.of<QuizProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      quizProvider.setcourseId = widget.courseId;
      quizProvider.settitle = widget.courseTitle;
      quizProvider.setcategoryId = widget.categoryId;
      quizProvider.fetchQuestions(widget.courseId);
    });

    quizProvider.addListener(_onProviderChange);
  }

  void _onProviderChange() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        quizProvider.currentQuestionIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    quizProvider.removeListener(_onProviderChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseTitle),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              bool? exit = await askComfirmation(
                context,
                quizProvider.cancelTimer,
                'Exit Quiz',
                'Are you sure you want to exit the quiz?',
              );
              if (exit == true) {
                // ignore: use_build_context_synchronously
                if (ModalRoute.of(context)?.isCurrent != true) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } else {
                  // ignore: use_build_context_synchronously
                  context.go(
                    RoutesPath.topicScreen,
                    extra: {
                      "categoryId": quizProvider.categoryId,
                      "title": quizProvider.title,
                      "courseId": quizProvider.courseId,
                    },
                  );
                }
                // ignore: use_build_context_synchronously
                // Navigator.pop(context);
              }
            }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            return quizProvider.questions.isEmpty
                ? const BuildQuizLoadingShimmer()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Remaining: ${quizProvider.time} seconds',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: (quizProvider.currentQuestionIndex + 1) /
                            quizProvider.questions.length,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: quizProvider.questions.length,
                          itemBuilder: (context, index) {
                            final question = quizProvider.questions[index];
                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question ${index + 1}:',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      question['question'],
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AnimationLimiter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: List.generate(
                                        question['options'].length,
                                        (optionIndex) {
                                          return AnimationConfiguration
                                              .staggeredList(
                                            position: optionIndex,
                                            duration: const Duration(
                                                milliseconds: 375),
                                            child: SlideAnimation(
                                              verticalOffset: 50.0,
                                              child: FadeInAnimation(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 8.0),
                                                  child: Material(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      onTap: () {
                                                        quizProvider
                                                                .selectedAnswer =
                                                            question['options']
                                                                [optionIndex];
                                                      },
                                                      splashColor: Colors.blue
                                                          .withOpacity(0.3),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                            color: quizProvider
                                                                        .selectedAnswer ==
                                                                    question[
                                                                            'options']
                                                                        [
                                                                        optionIndex]
                                                                ? Colors.blue
                                                                : Colors.grey
                                                                    .shade400,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          question['options']
                                                              [optionIndex],
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: quizProvider.currentQuestionIndex == 0
                                  ? null
                                  : () {
                                      quizProvider.goToPreviousQuestion();
                                    },
                              style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    quizProvider.currentQuestionIndex == 0
                                        ? Colors.white
                                        : Colors.white,
                                backgroundColor:
                                    quizProvider.currentQuestionIndex == 0
                                        ? Colors.grey.shade300
                                        : Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Previous'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: quizProvider.selectedAnswer.isEmpty
                                  ? null
                                  : () {
                                      quizProvider.goToNextQuestion();
                                    },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Next'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
