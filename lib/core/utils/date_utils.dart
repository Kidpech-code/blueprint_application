/// Utility class สำหรับจัดการวันที่ เช่น format วันที่ให้เป็น string
class DateUtils {
  /// แปลง DateTime เป็น string ในรูปแบบ yyyy-MM-dd
  static String format(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
