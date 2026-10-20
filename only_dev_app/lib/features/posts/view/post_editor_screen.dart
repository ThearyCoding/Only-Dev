import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:only_dev_app/core/providers/app_providers.dart';
import 'package:only_dev_app/features/posts/view/post_list_screen.dart';
import 'package:only_dev_app/utils/app_toast_utils.dart';

class PostEditorScreen extends ConsumerStatefulWidget {
  const PostEditorScreen({super.key});

  @override
  ConsumerState<PostEditorScreen> createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends ConsumerState<PostEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final Map<String, TextEditingController> _textControllers = {};
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
    super.dispose();
  }

  TextEditingController _getControllerForSection(String sectionId) {
    return _textControllers.putIfAbsent(
      sectionId,
      () => TextEditingController(),
    );
  }

  void _addTextSection() {
    ref.read(postEditorProvider.notifier).addTextSection();
  }

  Future<void> _addImageSection() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        ref.read(postEditorProvider.notifier).addImageSection(image.path);
      }
    } catch (e) {
      AppToastUtils.error('Failed to pick image: $e');
    }
  }

  void _removeSection(String sectionId) {
    _textControllers.remove(sectionId)?.dispose();
    ref.read(postEditorProvider.notifier).removeSection(sectionId);
  }

  Future<void> _savePost() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      AppToastUtils.warning('Title is required!');
      return;
    }

    final editorState = ref.read(postEditorProvider);
    if (editorState.sections.isEmpty) {
      AppToastUtils.warning('At least one content section is required!');
      return;
    }

    // Collect all text from controllers
    final Map<String, String> textContents = {};
    for (var section in editorState.sections) {
      if (section.type == 'text') {
        textContents[section.id] = _textControllers[section.id]?.text ?? '';
      }
    }

    try {
      await ref.read(postEditorProvider.notifier).savePost(
            title: title,
            textContents: textContents,
          );
      if (!mounted) return;
      AppToastUtils.success('Post saved successfully!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PostListScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      AppToastUtils.error('Failed to save post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(postEditorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Post'),
        centerTitle: true,
        actions: [
          if (editorState.isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _savePost,
            ),
          IconButton(
            icon: const Icon(Icons.newspaper),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                return const PostListScreen();
              }));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ...editorState.sections.map((section) {
                if (section.type == 'text') {
                  final controller = _getControllerForSection(section.id);
                  return Padding(
                    key: ValueKey(section.id),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: controller,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeSection(section.id),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (section.type == 'image') {
                  return Padding(
                    key: ValueKey(section.id),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Image.file(File(section.content)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeSection(section.id),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: editorState.isSubmitting ? null : _addTextSection,
                    icon: const Icon(Icons.text_fields),
                    label: const Text('Add Text'),
                  ),
                  ElevatedButton.icon(
                    onPressed: editorState.isSubmitting ? null : _addImageSection,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Image'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
