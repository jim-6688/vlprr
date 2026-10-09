/// 应用级失败类型（sealed，便于 UI 穷尽处理）。
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// 网络/数据源失败。
class SourceFailure extends Failure {
  const SourceFailure(super.message, {this.failedCityIds = const []});

  final List<String> failedCityIds;
}

/// 本地存储失败。
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// 授权被拒。
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {this.permission});

  final String? permission;
}

/// 输入校验失败。
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.field});

  final String? field;
}

/// 未知失败。
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
