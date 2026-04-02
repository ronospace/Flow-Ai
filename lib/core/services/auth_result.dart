
class AuthResult {
  final bool isSuccess;
  final String? error;

  AuthResult._({required this.isSuccess, this.error});
  factory AuthResult.success({dynamic user}) => AuthResult._(isSuccess:true);
  factory AuthResult.failure(String error) => AuthResult._(isSuccess:false, error:error);
}
