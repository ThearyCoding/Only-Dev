import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:only_dev_app/core/app_style.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/routes/app_routes.dart';
import 'package:only_dev_app/utils/show_dialog_infor_utils.dart';
import 'package:only_dev_app/widgets/loadings-widget/build_quiz_loading_shimmer.dart';

class QuizPage extends ConsumerStatefulWidget {
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
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  User? user = FirebaseAuth.instance.currentUser;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = ref.read(quizNotifierProvider);
      quizProvider.setcourseId = widget.courseId;
      quizProvider.settitle = widget.courseTitle;
      quizProvider.setcategoryId = widget.categoryId;
      quizProvider.fetchQuestions(widget.courseId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = ref.watch(quizNotifierProvider);

    ref.listen(quizNotifierProvider, (previous, next) {
      if (previous?.currentQuestionIndex != next.currentQuestionIndex &&
          _pageController.hasClients) {
        _pageController.animateToPage(
          next.currentQuestionIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

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
            if (exit == true && context.mounted) {
              if (ModalRoute.of(context)?.isCurrent != true) {
                Navigator.pop(context);
              } else {
                context.go(
                  RoutesPath.topicScreen,
                  extra: {
                    "categoryId": quizProvider.categoryId,
                    "title": quizProvider.title,
                    "courseId": quizProvider.courseId,
                  },
                );
              }
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: quizProvider.questions.isEmpty
            ? const BuildQuizLoadingShimmer()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time Remaining: ${quizProvider.time}s',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: quizProvider.time <= 5
                              ? AppStyle.error
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        'Question ${quizProvider.currentQuestionIndex + 1} of ${quizProvider.questions.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (quizProvider.currentQuestionIndex + 1) /
                          quizProvider.questions.length,
                      color: AppStyle.primaryColor,
                      backgroundColor: Colors.grey.shade300,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: quizProvider.questions.length,
                      itemBuilder: (context, index) {
                        final question = quizProvider.questions[index];
                        final questionText = (question['question'] ??
                                question['prompt'] ??
                                '')
                            .toString();
                        final options = List<String>.from(
                            (question['options'] as List?) ?? []);

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppStyle.darkSurface
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  questionText,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              AnimationLimiter(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: List.generate(
                                    options.length,
                                    (optionIndex) {
                                      final option = options[optionIndex];
                                      final isSelected =
                                          quizProvider.selectedAnswer == option;

                                      return AnimationConfiguration
                                          .staggeredList(
                                        position: optionIndex,
                                        duration: const Duration(
                                            milliseconds: 300),
                                        child: SlideAnimation(
                                          verticalOffset: 30.0,
                                          child: FadeInAnimation(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6.0),
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12),
                                                  onTap: quizProvider
                                                          .isSubmitting
                                                      ? null
                                                      : () {
                                                          quizProvider
                                                                  .selectedAnswer =
                                                              option;
                                                        },
                                                  splashColor: AppStyle
                                                      .primaryColor
                                                      .withOpacity(0.15),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                      color: isSelected
                                                          ? AppStyle.primaryColor
                                                              .withOpacity(
                                                                  0.08)
                                                          : Colors
                                                              .transparent,
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? AppStyle
                                                                .primaryColor
                                                            : Colors
                                                                .grey.shade400,
                                                        width:
                                                            isSelected ? 2 : 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 24,
                                                          height: 24,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: isSelected
                                                                  ? AppStyle
                                                                      .primaryColor
                                                                  : Colors.grey,
                                                              width: 2,
                                                            ),
                                                            color: isSelected
                                                                ? AppStyle
                                                                    .primaryColor
                                                                : Colors
                                                                    .transparent,
                                                          ),
                                                          child: isSelected
                                                              ? const Icon(
                                                                  Icons.check,
                                                                  size: 16,
                                                                  color: Colors
                                                                      .white,
                                                                )
                                                              : null,
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            option,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  isSelected
                                                                      ? FontWeight
                                                                          .w600
                                                                      : FontWeight
                                                                          .normal,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: (quizProvider.currentQuestionIndex == 0 ||
                                  quizProvider.isSubmitting)
                              ? null
                              : () {
                                  quizProvider.goToPreviousQuestion();
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
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
                          onPressed: (quizProvider.selectedAnswer.isEmpty ||
                                  quizProvider.isSubmitting)
                              ? null
                              : () {
                                  quizProvider.goToNextQuestion();
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppStyle.primaryColor,
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.grey.shade600,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: quizProvider.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  quizProvider.currentQuestionIndex ==
                                          quizProvider.questions.length - 1
                                      ? 'Submit Quiz'
                                      : 'Next',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
