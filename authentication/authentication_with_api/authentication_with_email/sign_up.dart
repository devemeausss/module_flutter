import 'package:flutter/material.dart';
import 'package:plugin_helper/index.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../configs/app_constrains.dart';
import '../../index.dart';
import '../../screens/auth/get_started.dart';
import '../../screens/auth/verify.dart';
import '../../widgets/bottom_appbar_custom.dart';
import '../../widgets/button_custom.dart';
import '../../widgets/loading_custom.dart';
import '../../widgets/overlay_loading_custom.dart';
import '../../widgets/text_field_custom.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key, this.email}) : super(key: key);
  final String? email;
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final TextEditingController _firstNameController = TextEditingController();
  final FocusNode _firstNameFocusNode = FocusNode();
  final TextEditingController _lastNameController = TextEditingController();
  final FocusNode _lastNameFocusNode = FocusNode();
  bool _isValidPassword = false,
      _isValidFirstName = false,
      _isValidEmail = false;
  late final AuthBloc _authBloc = BlocProvider.of<AuthBloc>(context);

  bool _enableButton = _isValidPassword && _isValidFirstName && _isValidEmail;

  _submit() {
    _authBloc.add(AuthGetStarted(
      onSuccess: (String value) {
        _authBloc.add(AuthSignUp(
          body: {
            'email': widget.email,
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'password': _passwordController.text.trim(),
          },
          onSuccess: () {
            replace(Verify(
              isResend: false,
              password: _passwordController.text,
              email: widget.email,
            ));
          },
        ));
      },
      body: {
        'email': _emailController.text.trim(),
      },
    ));
  }

  @override
  void initState() {
    _emailController.text = widget.email ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayLoadingCustom(
      loadingWidget: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return LoadingCustom(
              isOverlay: true, isLoading: state.signUpLoading!);
        },
      ),
      child: Scaffold(
        bottomNavigationBar: BottomAppBarCustom(
          child: ButtonCustom(
            enable: _enableButton,
            onPressed: () {
              _submit();
            },
            title: 'key_sign_up'.tr(),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: AppConstrains.paddingVertical,
                horizontal: AppConstrains.paddingHorizontal),
            child: Column(
              children: [
                TextFieldCustom(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  validType: ValidType.email,
                  validType: ValidType.notEmpty,
                  hintText: 'key_email'.tr(),
                  textInputAction: TextInputAction.next,
                  onValid: (bool val) {
                    setState(() {
                      _isValidEmail = val;
                    });
                  },
                ),
                10.h,
                TextFieldCustom(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  validType: ValidType.password,
                  hintText: 'key_password'.tr(),
                  onValid: (bool val) {
                    setState(() {
                      _isValidPassword = val;
                    });
                  },
                  textInputAction: TextInputAction.next,
                ),
                10.h,
                TextFieldCustom(
                  controller: _firstNameController,
                  focusNode: _firstNameFocusNode,
                  validType: ValidType.notEmpty,
                  hintText: 'key_first_name'.tr(),
                  onValid: (bool val) {
                    setState(() {
                      _isValidFirstName = val;
                    });
                  },
                  textInputAction: TextInputAction.next,
                ),
                10.h,
                TextFieldCustom(
                  controller: _lastNameController,
                  focusNode: _lastNameFocusNode,
                  hintText: 'key_last_name'.tr(),
                ),
                GestureDetector(
                    onTap: () {
                      replace(const GetStarted());
                    },
                    child: Text('key_use_another_account'.tr())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
