/// Failure base class สำหรับจัดการข้อผิดพลาดในแอป
/// ใช้เป็นแม่แบบสำหรับ error ที่เกิดขึ้นในแต่ละ usecase/data source
class Failure {
  /// ข้อความอธิบาย error
  final String message;
  Failure(this.message);
}

/// ตัวอย่าง custom failure สำหรับ network error
class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}
