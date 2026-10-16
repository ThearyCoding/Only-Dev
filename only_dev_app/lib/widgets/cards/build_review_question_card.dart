import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class ReviewQuestionCard extends StatelessWidget {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final int selectedAnswer;
  final bool isCorrect;
  final String explanation;

  const ReviewQuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyMedium!.color;
    final textColorLarge = Theme.of(context).textTheme.bodyLarge!.color;
    return Card(
      color: isCorrect
          ? isDarkMode
              ? Colors.grey[800] // Dark green for dark mode
              : const Color(0xFFEFFAF0) // Light green for light mode
          : isDarkMode
              ? Colors.grey[800] // Red for dark mode
              : const Color(0xFFFFEBEB), // Light red for light mode
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExpandableNotifier(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Question',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColorLarge),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    size: 17,
                    isCorrect ? Icons.check_circle : Icons.error,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCorrect ? 'Correct' : 'Incorrect',
                    style: TextStyle(
                      fontSize: 15,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  const Spacer(),
                  ExpandableButton(
                    child: ExpandableIcon(
                      theme: const ExpandableThemeData(
                        expandIcon: Icons.expand_more,
                        collapseIcon: Icons.expand_more,
                        iconColor: Colors.black,
                        iconSize: 28.0,
                        hasIcon: true,
                      ),
                    ),
                  ),
                ],
              ),
              Expandable(
                collapsed: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        question,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (int i = 0; i < options.length; i++) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: i == correctAnswer
                              ? const Color(0xFFE6F7E6)
                              : i == selectedAnswer && !isCorrect
                                  ? const Color(0xFFFFE6E6)
                                  : Colors.transparent,
                          border: Border.all(
                            color: i == correctAnswer
                                ? Colors.green
                                : i == selectedAnswer && !isCorrect
                                    ? Colors.red
                                    : const Color(0xFFE0E0E0),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (i == selectedAnswer && !isCorrect)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Your answer is incorrect',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            if (i == correctAnswer && isCorrect)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Your answer is correct',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            if (i == correctAnswer && !isCorrect)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Correct answer',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: i == correctAnswer
                                      ? const Icon(Icons.check_circle,
                                          color: Colors.green)
                                      : i == selectedAnswer && !isCorrect
                                          ? const Icon(Icons.cancel,
                                              color: Colors.red)
                                          : Radio(
                                              value: i,
                                              groupValue: selectedAnswer,
                                              onChanged: null,
                                            ),
                                ),
                                Expanded(
                                  child: Text(
                                    options[i],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: i == correctAnswer
                                          ? Colors.green
                                          : i == selectedAnswer && !isCorrect
                                              ? Colors.red
                                              : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (!isCorrect) ...[
                      const SizedBox(height: 16),
                      Container(
                        color: const Color(0xFFFFF4E6),
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Explanation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              explanation,
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
