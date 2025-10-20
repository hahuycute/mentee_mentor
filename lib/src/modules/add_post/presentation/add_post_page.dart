import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/service/posts_service.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  bool _isPublic = true;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final _posts = PostsService();

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _posts.createPost(
        title: _title.text.trim(),
        content: _content.text.trim(),
        isPublic: _isPublic,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true); // Trả về true để reload danh sách bài viết
    } on ApiException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Đăng bài thất bại');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng bài mới')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Tiêu đề'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nhập tiêu đề'
                        : (v.length > 200 ? 'Tối đa 200 ký tự' : null),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _content,
                    decoration: const InputDecoration(labelText: 'Nội dung'),
                    minLines: 4,
                    maxLines: 8,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nhập nội dung'
                        : (v.length > 5000 ? 'Tối đa 5000 ký tự' : null),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _isPublic,
                    onChanged: (v) => setState(() => _isPublic = v),
                    title: const Text('Công khai'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('Đăng bài'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}