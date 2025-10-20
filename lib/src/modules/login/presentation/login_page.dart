import 'package:flutter/material.dart';
import 'package:mentee_mentor/src/common/api/api_exception.dart';
import 'package:mentee_mentor/src/common/service/auth_service.dart';
import 'package:mentee_mentor/src/modules/home/presentation/home_page.dart';
import 'package:mentee_mentor/src/modules/register/presentation/regisster_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  final _auth = AuthService();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  Future<void> _doLogin() async {
    if(!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try{
      await _auth.login(_email.text.trim(), _password.text);
      if(!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );

    }
    on ApiException catch (e){
      _showSnack(e.message);
    }
    catch(e){
      _showSnack('Unexpected error');
    }finally{
      if(mounted) setState(() => _loading = false);
    }
    
  }
  void _showSnack(String message){
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'),),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _email,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty) ? 'Nhập email': null,
              ),
              SizedBox(height: 12,),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Nhập mật khẩu': null,
              ),
              SizedBox(height: 24,),
              SizedBox( width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _doLogin, 
                  child: _loading ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2,color: Colors.white,),
                  ) : Text('Đăng nhập'),
                ),
              ),
              SizedBox(height: 12),
                TextButton(
                  onPressed: _loading ? null : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegissterPage()),
                    );
                  },
                  child: const Text('Chưa có tài khoản? Đăng ký'),
                ),
            ],
            ),
            
             ),
        ),
      ),
    );
  }
}