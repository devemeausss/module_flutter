import 'package:flutter/material.dart';
import 'package:plugin_helper/index.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../configs/app_constrains.dart';
import '../../index.dart';
import '../../screens/auth/login.dart';
import '../../screens/auth/sign_up.dart';
import '../../screens/auth/verify.dart';
import '../../widgets/bottom_appbar_custom.dart';
import '../../widgets/button_custom.dart';
import '../../widgets/loading_custom.dart';
import '../../widgets/overlay_loading_custom.dart';
import '../../widgets/text_field_custom.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isValidEmail = false;
  late final AuthBloc _authBloc = BlocProvider.of<AuthBloc>(context);

  @override
  void initState() {
    super.initState();
  }

  _submit() {
    if (!_isValidEmail) {
      return;
    }
    _authBloc.add(AuthGetStarted(
      onSuccess: (String value) {
        switch (value) {
          case MyPluginAppConstraints.signUp:
            push(SignUp(
              email: _controller.text.trim(),
            ));
            break;
          case MyPluginAppConstraints.login:
            push(Login(
              email: _controller.text.trim(),
            ));
            break;
          case MyPluginAppConstraints.verify:
            push(Verify(
              isResend: true,
              email: _controller.text.trim(),
            ));
            break;
          default:
        }
      },
      body: {
        'email': _controller.text.trim(),
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return OverlayLoadingCustom(
      loadingWidget: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return LoadingCustom(
              isOverlay: true, isLoading: state.getStartedRequesting!);
        },
      ),
      child: Scaffold(
        bottomNavigationBar: BottomAppBarCustom(
          child: ButtonCustom(
            onPressed: () {
              _submit();
            },
            title: 'key_continue'.tr(),
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
                  controller: _controller,
                  focusNode: _focusNode,
                  validType: ValidType.email,
                  onValid: (bool val) {
                    _isValidEmail = val;
                  },
                  hintText: 'key_enter_an_email'.tr(),
                  onFieldSubmitted: (text) {
                    _submit();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
