/// Abstract base class สำหรับ usecase ทุกตัวใน domain layer
/// ช่วยให้ทุก usecase มี interface ที่เหมือนกัน (call method)
///
/// ตัวอย่าง:
/// ```dart
/// class GetUser implements UseCase<User, String> {
///   Future<User> call(String id) async { ... }
/// }
/// ```
abstract class UseCase<Type, Params> {
  /// เรียกใช้งาน usecase
  Future<Type> call(Params params);
}
