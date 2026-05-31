import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/auth/cubit/email_link/email_link_cubit.dart';
import 'package:flutter_starter/features/auth/cubit/email_link/email_link_state.dart';
import 'package:flutter_starter/features/auth/data/auth_repository.dart';
import 'package:flutter_starter/features/auth/view/widgets/widgets.dart';
import 'package:form_inputs/form_inputs.dart';

/// Reached when a `/auth/email-link?email=…&link=…` deep-link is opened
/// while unauthenticated.
///
/// All verification logic lives in [EmailLinkCubit]; the page only binds
/// to its state and renders the right visual.
class EmailLinkSignInPage extends StatelessWidget {
  const EmailLinkSignInPage({
    required this.email,
    required this.link,
    super.key,
  });

  final String email;
  final String link;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmailLinkCubit>(
      create: (context) {
        final cubit = EmailLinkCubit(
          authRepository: context.read<AuthRepository>(),
        );
        unawaited(cubit.verify(email: email, link: link));
        return cubit;
      },
      child: const _EmailLinkView(),
    );
  }
}

class _EmailLinkView extends StatelessWidget {
  const _EmailLinkView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<EmailLinkCubit, EmailLinkState>(
            builder: (context, state) {
              if (state.status.isFailure) {
                return EmailLinkErrorView(message: state.errorMessage);
              }
              // initial / inProgress / success → busy. Success is transient
              // — the router redirect carries us home as soon as auth flips.
              return const EmailLinkBusyView();
            },
          ),
        ),
      ),
    );
  }
}
