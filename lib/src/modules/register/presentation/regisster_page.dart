import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/modules/home/presentation/home_page.dart';

class RegissterPage extends StatefulWidget {
  const RegissterPage({super.key});

  @override
  State<RegissterPage> createState() => _RegissterPageState();
}

class _RegissterPageState extends State<RegissterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  final _auth = AuthService();
  String _role = 'MENTEE';
  @override
  void dispose() {  
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.register(_email.text.trim(), _password.text, _role);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on ApiException catch (e) {
      _showSnack(e.message);
    } catch (e, st) {
      // Log chi tiết để debug
      debugPrint('Register failed: $e');
      debugPrint('Type: ${e.runtimeType}');
      debugPrintStack(stackTrace: st);
      // Hiện lỗi thật thay vì "Unexpected error"
      _showSnack(e.toString());
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
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || v.isEmpty) ? 'Nhập email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Mật khẩu (>= 6 ký tự)'),
                  obscureText: true,
                  validator: (v) => (v != null && v.length >= 6) ? null : 'Mật khẩu tối thiểu 6 ký tự',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: 'MENTEE', child: Text('Mentee')),
                    DropdownMenuItem(value: 'MENTOR', child: Text('Mentor')),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'MENTEE'),
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _doRegister,
                    child: _loading ? const CircularProgressIndicator() : const Text('Đăng ký'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}