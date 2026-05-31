import 'package:equatable/equatable.dart';

enum ForceUpdateStatus {
  /// Initial state before the first check runs.
  unknown,

  /// The installed version is greater than or equal to the minimum.
  upToDate,

  /// The installed version is below the configured minimum and the app
  /// should block until the user updates.
  required,
}

class ForceUpdateState extends Equatable {
  const ForceUpdateState({
    this.status = ForceUpdateStatus.unknown,
    this.currentVersion = '',
    this.minimumVersion = '',
    this.storeUrl = '',
  });

  final ForceUpdateStatus status;
  final String currentVersion;
  final String minimumVersion;
  final String storeUrl;

  ForceUpdateState copyWith({
    ForceUpdateStatus? status,
    String? currentVersion,
    String? minimumVersion,
    String? storeUrl,
  }) {
    return ForceUpdateState(
      status: status ?? this.status,
      currentVersion: currentVersion ?? this.currentVersion,
      minimumVersion: minimumVersion ?? this.minimumVersion,
      storeUrl: storeUrl ?? this.storeUrl,
    );
  }

  @override
  List<Object?> get props => [status, currentVersion, minimumVersion, storeUrl];
}
