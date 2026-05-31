import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_starter/features/auth/data/auth_repository.dart';
import 'package:flutter_starter/features/auth/data/auth_status.dart';

class AuthCubit extends Cubit<AuthStatus> {
  AuthCubit({
    required AuthRepository authRepository,
    AuthStatus initialStatus = AuthStatus.unknown,
  }) : _authRepository = authRepository,
       super(initialStatus) {
    _subscription = _authRepository.status.listen(emit);
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<AuthStatus> _subscription;

  @override
  Future<void> close() {
    unawaited(_subscription.cancel());
    return super.close();
  }
}
