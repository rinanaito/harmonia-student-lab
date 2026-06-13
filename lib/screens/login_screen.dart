import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isParentTab = true;
  bool isLoading = false;
  String? errorMsg;

  final _parentCtrl = TextEditingController();
  final _adminUserCtrl = TextEditingController();
  final _adminPassCtrl = TextEditingController();
  final _api = ApiService();

  @override
  void dispose() {
    _parentCtrl.dispose();
    _adminUserCtrl.dispose();
    _adminPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _parentLogin() async {
    final query = _parentCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() { isLoading = true; errorMsg = null; });
    try {
      final student = await _api.parentLogin(query);
      if (mounted) {
        context.read<AppState>().loginAsParent(student);
      }
    } catch (e) {
      setState(() => errorMsg = 'Student not found. Please check the name or ID.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _adminLogin() async {
    final u = _adminUserCtrl.text.trim();
    final p = _adminPassCtrl.text;
    if (u.isEmpty || p.isEmpty) return;
    setState(() { isLoading = true; errorMsg = null; });
    try {
      await _api.adminLogin(u, p);
      if (mounted) {
        context.read<AppState>().loginAsAdmin();
      }
    } catch (e) {
      setState(() => errorMsg = 'Invalid credentials.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navy, AppColors.navyLight, Color(0xFF2e4a7c)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 24,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 6,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.accent, AppColors.sage],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 32, 40, 40),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Harmonia',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontFamily: 'PlayfairDisplay',
                                color: AppColors.navy,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Language Lab — Student Media Gallery',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                            ),
                            const SizedBox(height: 28),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.gray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  _tabButton('👨‍👩‍👦 Parent', true),
                                  _tabButton('🔑 Admin', false),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (isParentTab) ...[
                              TextField(
                                controller: _parentCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Student Name or ID',
                                  hintText: 'e.g. Emma Johnson or S-1042',
                                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                                ),
                                onSubmitted: (_) => _parentLogin(),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _parentLogin,
                                  child: isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                                    : const Text('View My Child's Gallery →'),
                                ),
                              ),
                            ] else ...[
                              TextField(
                                controller: _adminUserCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'admin',
                                  prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _adminPassCtrl,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  hintText: '••••••••',
                                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted),
                                ),
                                onSubmitted: (_) => _adminLogin(),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _adminLogin,
                                  child: isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                                    : const Text('Access Admin Panel →'),
                                ),
                              ),
                            ],
                            if (errorMsg != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                errorMsg!,
                                style: const TextStyle(color: AppColors.error, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
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

  Widget _tabButton(String label, bool parent) {
    final active = isParentTab == parent;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() { isParentTab = parent; errorMsg = null; }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: active ? AppColors.navy : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
