

import 'package:flutter/material.dart';

import '../../export/export.dart';

class CourseCardV1 extends StatelessWidget {
  final CourseModel course;
  final AdminModel admin;
  final int quizCount;
  final String userId;
  final bool isRegistered;
  const CourseCardV1(
      {super.key,
      required this.course,
      required this.admin,
      required this.quizCount,
      required this.userId,
      required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {

        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.green.withOpacity(.1))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: course.imageUrl,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: getResponsiveWidth(context, 110),
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    height: getResponsiveWidth(context, 110),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Container(
                    height: getResponsiveWidth(context, 110),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isDarkMode
                            ? [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ]
                            : [
                                Colors.grey.withOpacity(0.5),
                                Colors.transparent,
                              ],
                      ),
                    ),
                  ),
                  if (TimeUtils.isNew(course.timestamp, 4, TimeUnit.days))
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (course.registerCounts != null && course.registerCounts! > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Text(
                          '${course.registerCounts} students',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 8,
                    bottom: -15,
                    right: 8,
                    child: Row(
                      children: [
                        ClipOval(
                          child: SizedBox(
                            height: getResponsiveHeight(context, 70),
                            width: getResponsiveHeight(context, 70),
                            child: CachedNetworkImage(
                              imageUrl: admin.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.grey[300],
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey,
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            admin.name,
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(context, 20),
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 20.0, bottom: 10.0),
                child: Text(
                  course.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: getResponsiveFontSize(context, 18),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: [
                        const Icon(Icons.play_circle_outline, size: 16),
                        Text(
                          '0',
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 14),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.quiz, size: 16),
                        Text(
                          '$quizCount',
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    if (isRegistered)
                      Text(
                        "Continue Watching",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: getResponsiveFontSize(context, 14),
                        ),
                      )
                    else
                      course.price == 0 && course.discount == 0
                          ? Text(
                              "Free",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: getResponsiveFontSize(context, 14),
                              ),
                            )
                          : Row(
                              children: [
                                Text(
                                  '\$${course.discount}',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        getResponsiveFontSize(context, 14),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '\$${course.price}',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize:
                                        getResponsiveFontSize(context, 14),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: getResponsiveWidth(context, 32),
                                    height: getResponsiveHeight(context, 32),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.blue[200],
                                    ),
                                    child: const Icon(
                                      Icons.shopping_bag,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
