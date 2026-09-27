import 'package:local_auth/local_auth.dart';
class SecurityService { final auth=LocalAuthentication(); Future<bool> biometric() async { try { return await auth.authenticate(localizedReason:'Unlock Work Time & Billing Manager'); } catch(_){return false;} } }
