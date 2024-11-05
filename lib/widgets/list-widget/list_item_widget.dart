import 'package:e_leaningapp/providers/lecture_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';

import '../../model/lecture_model.dart';
import '../../utils/time_utils.dart';

// ignore: must_be_immutable
class ListItem extends StatelessWidget {
  final Function(String) onDownloadPlayPausedPressed;
  final Function(String) onDelete;
  final DownloadTask? downloadTask;
  final Lecture lecture;
  final bool isWatched;
  final LectureProvider provider;
  void Function()? onTap;
  ListItem({
    Key? key,
    required this.lecture,
    required this.onDownloadPlayPausedPressed,
    required this.onDelete,
    this.downloadTask,
    required this.onTap,
    required this.isWatched,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(8.0),
        tileColor: provider.selectedLectureId == lecture.id
            ? Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade200
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(
          lecture.title,
          overflow: TextOverflow.ellipsis,
        ),
        leading: isWatched
            ? const Icon(Icons.check_box, color: Colors.green)
            : const Icon(Icons.check_box_outline_blank),
        subtitle: Row(
          children: [
            Image.asset(
              'assets/icons/tv-icon.png',
              width: 20,
              height: 20,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : Colors.grey.shade700,
            ),
            const SizedBox(
              width: 10,
            ),
            Text('${TimeUtils.formatDuration(lecture.videoDuration)} min'),
          ],
        ),
        trailing: downloadTask != null
            ? ValueListenableBuilder(
                valueListenable: downloadTask!.status,
                builder: (context, value, child) {
                  switch (downloadTask!.status.value) {
                    case DownloadStatus.downloading:
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: downloadTask!.progress.value,
                            color: Colors.amber,
                          ),
                          IconButton(
                            onPressed: () {
                              onDownloadPlayPausedPressed(lecture.videoUrl);
                            },
                            icon: const Icon(Icons.pause),
                          ),
                        ],
                      );
                    case DownloadStatus.paused:
                      return IconButton(
                        onPressed: () {
                          onDownloadPlayPausedPressed(lecture.videoUrl);
                        },
                        icon: const Icon(Icons.play_arrow),
                      );
                    case DownloadStatus.completed:
                      return IconButton(
                        onPressed: () {
                          onDelete(lecture.videoUrl);
                        },
                        icon: const Icon(Icons.delete),
                      );
                    case DownloadStatus.failed:
                    case DownloadStatus.canceled:
                      return IconButton(
                        onPressed: () {
                          onDownloadPlayPausedPressed(lecture.videoUrl);
                        },
                        icon: const Icon(Icons.download),
                      );
                    case DownloadStatus.queued:
                      return const CircularProgressIndicator(
                        color: Colors.amber,
                      );
                  }
                },
              )
            : IconButton(
                onPressed: () {
                  onDownloadPlayPausedPressed(lecture.videoUrl);
                },
                icon: const Icon(Icons.download),
              ),
      ),
    );
  }
}
