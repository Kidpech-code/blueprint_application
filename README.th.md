# อธิบายโครงสร้างและความสัมพันธ์ของแต่ละไฟล์/โฟลเดอร์

### core/

- **error/**: จัดการ error handling กลาง เช่น exception, failure class
- **usecases/**: usecase ที่ใช้ซ้ำได้หลาย domain หรือ generic usecase
- **utils/**: ฟังก์ชันหรือคลาสช่วยเหลือที่ใช้ซ้ำได้ทั้งโปรเจกต์ เช่น date, string, validation

### domain/

- **entities/**: โครงสร้างข้อมูลหลัก (Model หลักของ business logic) เช่น User, Product, Order
- **repositories/**: interface ของ repository (abstract class) กำหนด method ที่ต้องมีสำหรับ data access ของแต่ละ domain (ไม่ผูกกับ data source ใด ๆ)
- **usecases/**: กำหนด business logic ที่ใช้กับ entity/repository เช่น GetUser, GetProduct, LoginUser

### data/

- **models/**: data model ที่ใช้ mapping กับ API หรือ local storage (extends entity) เช่น UserModel extends User
- **datasources/**: จัดการการดึง/บันทึกข้อมูลจากแหล่งต่าง ๆ เช่น API, Database, Local storage (เช่น UserRemoteDataSource, UserLocalDataSource)
- **repositories/**: implement repository interface จาก domain โดยเชื่อมโยงกับ datasource และ model (เช่น UserRepositoryImpl implements UserRepository)

### presentation/

- **bloc/**: state management (เช่น Riverpod AsyncNotifier, Bloc, Cubit) สำหรับควบคุม state ของ UI
- **pages/**: หน้าจอ UI หลักแต่ละหน้า (Widget หลัก) เช่น UserPage, ProductPage
- **widgets/**: widget ย่อยที่ใช้ซ้ำในแต่ละหน้า เช่น UserCard, ProductTile

### di/

- **injection.dart**: รวม provider หรือ DI setup สำหรับเชื่อมโยง repository, datasource, usecase, dio, hive ฯลฯ ให้กับ presentation layer

### main.dart

- จุดเริ่มต้นของแอป กำหนด ProviderScope, MaterialApp, go_router, theme, home page

---

## ความสัมพันธ์ของแต่ละไฟล์/โฟลเดอร์

1. **presentation** เรียกใช้ usecase ผ่าน provider ที่ประกาศใน di/injection.dart
2. usecase จะเรียก repository interface (domain)
3. repository implementation (data) จะ implement interface จาก domain และเชื่อมโยงกับ datasource/model
4. datasource จะดึงข้อมูลจาก API/local แล้ว map เป็น model และ entity
5. entity คือข้อมูลหลักที่ไหลกลับไปยัง presentation layer
6. core ใช้สำหรับ logic หรือ utility ที่ใช้ร่วมกันหลาย domain
7. di/injection.dart ทำหน้าที่เชื่อมโยงทุกชั้น (dependency graph)

**สรุป:**

presentation → usecase → repository (domain) → repository impl (data) → datasource/model → entity → presentation

---

# Blueprint Application Clean Architecture (ภาษาไทย)

---

## โครงสร้างโปรเจกต์ (Project Structure)

```
lib/
  core/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    bloc/
    pages/
    widgets/
  di/
  main.dart
```

- **domain**: กำหนด business logic (entities, repositories, usecases)
- **data**: จัดการ data source (API, local, models, repository implementation)
- **presentation**: UI, state management (Riverpod/Bloc)
- **di**: Dependency injection (Riverpod provider, GetIt)
- **core**: ส่วนกลางที่ใช้ร่วมกัน เช่น error, utils

---

## ขั้นตอนการเพิ่ม Domain ใหม่ (เช่น Product)

1. สร้าง Entity: `lib/domain/entities/product.dart`
2. สร้าง Repository Interface: `lib/domain/repositories/product_repository.dart`
3. สร้าง Usecase: `lib/domain/usecases/get_product.dart`
4. สร้าง Model: `lib/data/models/product_model.dart`
5. สร้าง DataSource: `lib/data/datasources/product_remote_data_source.dart`
6. สร้าง Repository Implementation: `lib/data/repositories/product_repository_impl.dart`
7. สร้าง Provider ใน DI: `lib/di/injection.dart`
8. Presentation Layer: bloc, page, widget

---

## ตัวอย่าง: การเพิ่ม Domain ใหม่ (Order)

### โครงสร้างไฟล์เมื่อเพิ่ม Order Domain

```
lib/
  domain/
    entities/
      order.dart
    repositories/
      order_repository.dart
    usecases/
      get_order.dart
  data/
    models/
      order_model.dart
    datasources/
      order_remote_data_source.dart
    repositories/
      order_repository_impl.dart
  presentation/
    bloc/
      order_notifier.dart
    pages/
      order_page.dart
    widgets/
      order_card.dart
  di/
    injection.dart (เพิ่ม provider สำหรับ Order)
```

### ตัวอย่างโค้ด Order Domain

#### 1. Entity

`lib/domain/entities/order.dart`

```dart
class Order {
  final String id;
  final double total;
  Order({required this.id, required this.total});
}
```

#### 2. Repository Interface

`lib/domain/repositories/order_repository.dart`

```dart
import '../entities/order.dart';
abstract class OrderRepository {
  Future<Order> getOrder(String id);
}
```

#### 3. Usecase

`lib/domain/usecases/get_order.dart`

```dart
import '../entities/order.dart';
import '../repositories/order_repository.dart';
class GetOrder {
  final OrderRepository repository;
  GetOrder(this.repository);
  Future<Order> call(String id) => repository.getOrder(id);
}
```

#### 4. Model

`lib/data/models/order_model.dart`

```dart
import '../../domain/entities/order.dart';
class OrderModel extends Order {
  OrderModel({required super.id, required super.total});
  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      OrderModel(id: json['id'], total: (json['total'] as num).toDouble());
  Map<String, dynamic> toJson() => {'id': id, 'total': total};
}
```

#### 5. DataSource

`lib/data/datasources/order_remote_data_source.dart`

```dart
import 'package:dio/dio.dart';
import '../models/order_model.dart';
abstract class OrderRemoteDataSource {
  Future<OrderModel> fetchOrder(String id);
}
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;
  OrderRemoteDataSourceImpl(this.dio);
  @override
  Future<OrderModel> fetchOrder(String id) async {
    // final response = await dio.get('https://api.example.com/order/$id');
    // return OrderModel.fromJson(response.data);
    return OrderModel(id: id, total: 999.99);
  }
}
```

#### 6. Repository Implementation

`lib/data/repositories/order_repository_impl.dart`

```dart
import 'package:hive/hive.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final Box? cacheBox;
  OrderRepositoryImpl(this.remoteDataSource, [this.cacheBox]);
  @override
  Future<Order> getOrder(String id) async {
    if (cacheBox != null && cacheBox!.containsKey(id)) {
      final cached = cacheBox!.get(id) as Map?;
      if (cached != null) {
        return Order(id: cached['id'], total: cached['total']);
      }
    }
    final result = await remoteDataSource.fetchOrder(id);
    if (cacheBox != null) {
      await cacheBox!.put(id, result.toJson());
    }
    return result;
  }
}
```

#### 7. Provider ใน DI

`lib/di/injection.dart`

```dart
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return OrderRemoteDataSourceImpl(dio);
});
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final ds = ref.watch(orderRemoteDataSourceProvider);
  final box = ref.watch(hiveBoxProvider).maybeWhen(data: (b) => b, orElse: () => null);
  return OrderRepositoryImpl(ds, box);
});
final getOrderUseCaseProvider = Provider<GetOrder>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return GetOrder(repo);
});
```

#### 8. Presentation Layer

- `lib/presentation/bloc/order_notifier.dart` (AsyncNotifier)
- `lib/presentation/pages/order_page.dart` (ConsumerWidget)
- `lib/presentation/widgets/order_card.dart` (StatelessWidget)

สามารถลอกแบบจากตัวอย่างใน example หรือ user ได้เลย

---

## ข้อควรระวัง

- อย่าลืม register adapter ของ Hive หากใช้ custom object
- Provider ที่ใช้ async (เช่น hiveBoxProvider) ต้อง handle loading/error state
- สามารถขยาย pattern นี้กับ domain อื่น ๆ ได้ทันที

---

## License

MIT
