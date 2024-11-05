import 'dart:io';
import 'package:e_leaningapp/screens/post_list_screen.dart';
import 'package:e_leaningapp/service/firebase/firebase_api_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class PostEditorScreen extends StatefulWidget {
  const PostEditorScreen({super.key});

  @override
  PostEditorScreenState createState() => PostEditorScreenState();
}

class PostEditorScreenState extends State<PostEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<Map<String, dynamic>> _contentSections = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid uuid = const Uuid();

  void _addTextSection() {
    setState(() {
      _contentSections.add({
        'type': 'text',
        'controller': TextEditingController(),
      });
    });
  }

  Future<void> _addImageSection() async {
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    // if (image != null) {
    //   setState(() {
    //     _contentSections.add({
    //       'type': 'image',
    //       'filePath': image.path,
    //     });
    //   });
    // }
  }

  void _removeSection(int index) {
    setState(() {
      _contentSections.removeAt(index);
    });
  }

  Future<String> _uploadImage(String filePath) async {
    try {
      String fileId = uuid.v4();
      Reference storageRef = _storage.ref().child('post_images/$fileId');
      UploadTask uploadTask = storageRef.putFile(File(filePath));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<void> _savePost() async {
    if (_titleController.text.isEmpty || _contentSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Title and at least one content section are required!')),
      );
      return;
    }

    try {
      // Create a new document in Firestore
      DocumentReference postRef = _firestore.collection('posts').doc();
      // Get the auto-generated ID
      String id = postRef.id;
      String notificationId = const Uuid().v1();
      List<Map<String, dynamic>> contentList = [];
      String? contentPreview;

      for (var section in _contentSections) {
        if (section['type'] == 'text') {
          String textContent = section['controller'].text;
          contentList.add({
            'type': 'text',
            'content': textContent,
          });
          // Set content preview to the first text section
          contentPreview ??= textContent;
        } else if (section['type'] == 'image') {
          String imageUrl = await _uploadImage(section['filePath']);
          contentList.add({
            'type': 'image',
            'url': imageUrl,
          });
        }
      }

      // If no contentPreview is found, set a default one
      contentPreview ??= 'No content available';

      await postRef.set({
        'id': id,
        'title': _titleController.text,
        'contentPreview': contentPreview,
        'contentSections': contentList,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseApiNotifications()
          .markAsReadForUsersWithToken(notificationId, id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post saved successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Post'),
        centerTitle: true,
        actions: [
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
              ..._contentSections.map((section) {
                if (section['type'] == 'text') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: section['controller'],
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
                            onPressed: () => _removeSection(
                                _contentSections.indexOf(section)),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (section['type'] == 'image') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Image.file(File(section['filePath'])),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeSection(
                                _contentSections.indexOf(section)),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }).toList(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addTextSection,
                    icon: const Icon(Icons.text_fields),
                    label: const Text('Add Text'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addImageSection,
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
