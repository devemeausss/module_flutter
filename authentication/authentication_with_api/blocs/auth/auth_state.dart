part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final bool getStartedRequesting;
  final bool loginLoading;
  final bool signUpLoading;
  final bool verifyCodeLoading;
  final bool resetPasswordLoading;
  final bool updateProfileLoading;
  final bool updatePasswordLoading;

  final GetStartedModel? getStartedModel;
  final ProfileModel? profileModel;

  factory AuthState.empty() {
    return const AuthState(
      getStartedModel: null,
      profileModel: null,
      getStartedRequesting: false,
      verifyCodeLoading: false,
      resetPasswordLoading: false,
      loginLoading: false,
      signUpLoading: false,
      updateProfileLoading: false,
      updatePasswordLoading: false,
    );
  }

  const AuthState({
    required this.getStartedRequesting,
    required this.verifyCodeLoading,
    required this.resetPasswordLoading,
    this.getStartedModel,
    this.profileModel,
    required this.loginLoading,
    required this.signUpLoading,
    required this.updateProfileLoading,
    required this.updatePasswordLoading,
  });

  AuthState copyWith({
    bool? getStartedRequesting,
    bool? verifyCodeLoading,
    bool? resetPasswordLoading,
    bool? loginLoading,
    bool? signUpLoading,
    bool? updatePasswordLoading,
    GetStartedModel? getStartedModel,
    ProfileModel? profileModel,
    bool? updateProfileLoading,
  }) {
    return AuthState(
      updateProfileLoading: updateProfileLoading ?? this.updateProfileLoading,
      getStartedRequesting: getStartedRequesting ?? this.getStartedRequesting,
      verifyCodeLoading: verifyCodeLoading ?? this.verifyCodeLoading,
      getStartedModel: getStartedModel ?? this.getStartedModel,
      resetPasswordLoading: resetPasswordLoading ?? this.resetPasswordLoading,
      profileModel: profileModel ?? this.profileModel,
      loginLoading: loginLoading ?? this.loginLoading,
      signUpLoading: signUpLoading ?? this.signUpLoading,
      updatePasswordLoading:
          updatePasswordLoading ?? this.updatePasswordLoading,
    );
  }

  @override
  List<Object?> get props => [
    updateProfileLoading,
    getStartedRequesting,
    getStartedModel,
    resetPasswordLoading,
    verifyCodeLoading,
    profileModel,
    loginLoading,
    signUpLoading,
    updatePasswordLoading,
  ];
}
