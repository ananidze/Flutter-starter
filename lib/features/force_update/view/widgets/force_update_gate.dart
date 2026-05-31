import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/features/force_update/cubit/force_update_cubit.dart';
import 'package:flutter_starter/features/force_update/cubit/force_update_state.dart';
import 'package:flutter_starter/features/force_update/view/force_update_page.dart';

/// Wraps [child] and replaces it with [ForceUpdatePage] whenever the
/// configured minimum version is above the installed version.
class ForceUpdateGate extends StatelessWidget {
  const ForceUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final status = context.select<ForceUpdateCubit, ForceUpdateStatus>(
      (c) => c.state.status,
    );
    return status == ForceUpdateStatus.required
        ? const ForceUpdatePage()
        : child;
  }
}
