import '../entities/vehicle.dart';

/// 车辆仓库抽象。
abstract class VehicleRepository {
  /// 监听全部车辆（按默认优先、创建时间排序）。
  Stream<List<Vehicle>> watchVehicles();

  Future<List<Vehicle>> getAll();

  Future<Vehicle> add(Vehicle vehicle);

  Future<void> update(Vehicle vehicle);

  Future<void> delete(String vehicleId);

  /// 设为默认车（其余取消默认）。
  Future<void> setDefault(String vehicleId);

  Future<Vehicle?> findByPlate(String plate);
}
