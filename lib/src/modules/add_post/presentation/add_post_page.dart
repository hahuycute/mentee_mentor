import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/service/posts_service.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';

class AddPostPage extends StatefulWidget {
  final Map<String, dynamic>? post;
  const AddPostPage({super.key, this.post});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final _posts = PostsService();
  Map<String, dynamic>? _editingPost;

  @override
  void initState() {
    super.initState();
    _editingPost = widget.post;
    if (_editingPost != null) {
      _title.text = _editingPost!['title'] ?? '';
      _content.text = _editingPost!['content'] ?? '';
    }
  }

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
      if (_editingPost != null) {
        await _posts.updatePost(
          postId: _editingPost!['id'],
          title: _title.text.trim(),
          content: _content.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật bài viết thành công! 🎉')));
      } else {
        await _posts.createPost(
          title: _title.text.trim(),
          content: _content.text.trim(),
          isPublic: true,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng bài thành công! 🎉')));
      }
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      _showSnack(e.message);
    } catch (e) {
      _showSnack('Thất bại: $e');
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
      appBar: AppBar(
        title: Text(
          _editingPost != null ? 'Chỉnh sửa bài viết' : 'Đăng bài mới',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x4DE3F2FD),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chia sẻ điều gì đó...',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hãy viết gì đó thú vị để kết nối với cộng đồng!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _title,
                            decoration: InputDecoration(
                              labelText: 'Tiêu đề bài viết',
                              labelStyle: TextStyle(color: Colors.blue.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              prefixIcon: Icon(Icons.title, color: Colors.blue.shade400),
                            ),
                            style: const TextStyle(fontSize: 16),
                            validator:
                                (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Vui lòng nhập tiêu đề'
                                        : (v.length > 200 ? 'Tiêu đề tối đa 200 ký tự' : null),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextFormField(
                            controller: _content,
                            decoration: InputDecoration(
                              labelText: 'Nội dung bài viết',
                              labelStyle: TextStyle(color: Colors.blue.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              alignLabelWithHint: true,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 60),
                                child: Icon(Icons.edit_note, color: Colors.blue.shade400),
                              ),
                            ),
                            minLines: 4,
                            maxLines: 8,
                            style: const TextStyle(fontSize: 16),
                            validator:
                                (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Vui lòng nhập nội dung'
                                        : (v.length > 5000
                                            ? 'Nội dung tối đa 5000 ký tự'
                                            : null),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade600, Colors.blue.shade400],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: Text('Đăng bài',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
  }
}
