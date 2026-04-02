import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_core/core/constants/key_translate.dart';

import '../bloc/auth_login_form/auth_login_form_bloc.dart';
import 'auth_text_field.dart';

class AuthLoginInput extends StatelessWidget {
  const AuthLoginInput({super.key});

  @override
  Widget build(BuildContext context) {
    final formBloc = context.read<AuthLoginFormBloc>();
    return Column(
      children: [
        AuthTextField<AuthLoginFormBloc>(
          label: inputEmailKey.tr(),
          onChanged: (val) {
            formBloc.add(LoginFormEmailChangedEvent(val));
          },
        ),
        AuthTextField<AuthLoginFormBloc>(
          label: inputPasswordKey.tr(),
          onChanged: (val) {
            formBloc.add(LoginFormPasswordChangedEvent(val));
          },
          isSecure: true,
        ),
      ],
    );
  }
}
