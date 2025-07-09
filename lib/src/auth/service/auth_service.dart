abstract class AuthService {
  void register({required String email, required String password});
  void login({required String email, required String password});
  void logout();
}