import 'package:e_leaningapp/providers/lecture_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../../model/lecture_model.dart';
import '../../utils/time_utils.dart';

class ListItem extends StatefulWidget {
  final Function(String) onDownloadPlayPausedPressed;
  final Function(String) onDelete;
  final DownloadTask? downloadTask;
  final Lecture lecture;
  final bool isWatched;
  final LectureProvider provider;
  final void Function()? onTap;
  const ListItem({
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
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  double _downloadProgress = 0.0;
  var savedDir = "";
  @override
  void initState() {
    super.initState();
    getApplicationSupportDirectory().then((value) => savedDir = value.path);
    if (widget.downloadTask != null) {
      _downloadProgress = widget.downloadTask!.progress.value;

      // Add listeners to download status and progress changes
      widget.downloadTask!.status.addListener(_onDownloadStatusChanged);
      widget.downloadTask!.progress.addListener(_onDownloadProgressChanged);
    }
  }

  @override
  void dispose() {
    if (widget.downloadTask != null) {
      widget.downloadTask!.status.removeListener(_onDownloadStatusChanged);
      widget.downloadTask!.progress.removeListener(_onDownloadProgressChanged);
    }
    super.dispose();
  }

  void _onDownloadStatusChanged() {
    setState(() {});
  }

  void _onDownloadProgressChanged() {
    setState(() {
      _downloadProgress = widget.downloadTask!.progress.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: widget.onTap,
        contentPadding: const EdgeInsets.all(8.0),
        tileColor: widget.provider.selectedLectureId == widget.lecture.id
            ? Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade200
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(
          widget.lecture.title,
          overflow: TextOverflow.ellipsis,
        ),
        leading: widget.isWatched
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
            Text(
                '${TimeUtils.formatDuration(widget.lecture.videoDuration)} min'),
          ],
        ),
        trailing: widget.downloadTask != null
            ? ValueListenableBuilder(
                valueListenable: widget.downloadTask!.status,
                builder: (context, value, child) {
                  switch (widget.downloadTask!.status.value) {
                    case DownloadStatus.downloading:
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _downloadProgress,
                            color: Colors.amber,
                          ),
                          IconButton(
                            onPressed: () {
                              widget.onDownloadPlayPausedPressed(
                                  widget.lecture.videoUrl);
                            },
                            icon: const Icon(Icons.pause),
                          ),
                        ],
                      );
                    case DownloadStatus.paused:
                      return IconButton(
                        onPressed: () {
                          widget.onDownloadPlayPausedPressed(
                              widget.lecture.videoUrl);
                        },
                        icon: const Icon(Icons.play_arrow),
                      );
                    case DownloadStatus.completed:
                      return IconButton(
                        onPressed: () {
                          widget.onDelete(widget.lecture.videoUrl);
                        },
                        icon: const Icon(Icons.delete),
                      );
                    case DownloadStatus.failed:
                    case DownloadStatus.canceled:
                      return IconButton(
                        onPressed: () {
                          widget.onDownloadPlayPausedPressed(
                              widget.lecture.videoUrl);
                          setState(() {});
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
                  widget.onDownloadPlayPausedPressed(widget.lecture.videoUrl);
                  setState(() {});
                },
                icon: const Icon(Icons.download),
              ),
      ),
    );
  }
}
