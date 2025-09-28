# Blueprint Application Clean Architecture

---

## Project Structure

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

- **domain**: Business logic (entities, repositories, usecases)
- **data**: Data sources (API, local, models, repository implementation)
- **presentation**: UI, state management (Riverpod/Bloc)
- **di**: Dependency injection (Riverpod provider, GetIt)
- **core**: Shared utilities, error, etc.

---

## How to Add a New Domain (e.g. Product)

1. Create Entity: `lib/domain/entities/product.dart`
2. Create Repository Interface: `lib/domain/repositories/product_repository.dart`
3. Create Usecase: `lib/domain/usecases/get_product.dart`
4. Create Model: `lib/data/models/product_model.dart`
5. Create DataSource: `lib/data/datasources/product_remote_data_source.dart`
6. Create Repository Implementation: `lib/data/repositories/product_repository_impl.dart`
7. Register Providers in DI: `lib/di/injection.dart`
8. Add Presentation Layer: bloc, page, widget

---

## Example: Adding a New Domain (Order)

### File Structure for Order Domain

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
    injection.dart (add providers for Order)
```

### Example Code for Order Domain

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

#### 7. Providers in DI

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

You can copy the pattern from the example or user domain.

---

## Example: Using Hive and Dio in Repository/DataSource

- See `example_repository_impl.dart` and `example_remote_data_source.dart`
- Repository: Read/write cache with Hive before/after remote call
- DataSource: Use Dio to fetch data from API

---

## Notes

- Don't forget to register Hive adapters if using custom objects
- Providers using async (e.g. hiveBoxProvider) must handle loading/error state
- You can extend this pattern for any new domain

---

## Suggestion

- Use Riverpod/Provider for DI and state management
- Use go_router for navigation
- Use dio for network and hive for local cache

---

## License

MIT

---

## Deep Dive: File/Folder Purpose & Relationships

---

## Example: lib/core Structure, Usage, and Benefits

### 1. error/

**Purpose:**
สำหรับจัดการข้อผิดพลาด (error handling) เช่น custom exceptions, failure class, network error ฯลฯ

**Example:**

```dart
// lib/core/error/failure.dart
class Failure {
  final String message;
  Failure(this.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}
```

**How to use:**

```dart
import 'package:blueprint_application/core/error/failure.dart';

Future<void> fetchData() async {
  try {
    // ...
  } catch (e) {
    throw NetworkFailure('No Internet');
  }
}
```

---

### 2. usecases/

**Purpose:**
รวม base class สำหรับ usecase เพื่อให้ทุก usecase ใน domain layer สืบทอดและใช้งานได้อย่างเป็นมาตรฐาน

**Example:**

```dart
// lib/core/usecases/usecase.dart
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}
```

**How to use:**

```dart
import 'package:blueprint_application/core/usecases/usecase.dart';

class GetUser implements UseCase<User, String> {
  @override
  Future<User> call(String id) async {
    // ...
  }
}
```

---

### 3. utils/

**Purpose:**
ฟังก์ชันหรือคลาสช่วยเหลือทั่วไปที่ใช้ซ้ำได้ในหลายๆ ส่วนของแอป เช่น date formatter, validators, converters

**Example:**

```dart
// lib/core/utils/date_utils.dart
class DateUtils {
  static String format(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

**How to use:**

```dart
import 'package:blueprint_application/core/utils/date_utils.dart';

final formatted = DateUtils.format(DateTime.now());
```

---

### Summary

- ทุกไฟล์ใน core/ ควรเป็น generic, reusable, ไม่ขึ้นกับ domain/business logic โดยตรง
- สามารถนำไปใช้ได้ทุก layer ของแอป

---

---

## Example: lib/core (error, usecases, utils)

### โครงสร้างไฟล์

```
lib/core/
  error/
    failure.dart
    exception.dart
  usecases/
    usecase.dart
  utils/
    network_info.dart
    constants.dart
```

### อธิบายแต่ละไฟล์/โฟลเดอร์

- **error/**
  - `failure.dart`: กำหนด Failure (abstract) และ subclass เช่น ServerFailure, CacheFailure สำหรับสื่อสารข้อผิดพลาดข้ามเลเยอร์
  - `exception.dart`: custom Exception เช่น ServerException, CacheException สำหรับโยนข้อผิดพลาดจาก data layer
- **usecases/**
  - `usecase.dart`: abstract class `UseCase<Type, Params>` ให้ทุก usecase ใน domain layer สืบทอด
- **utils/**
  - `network_info.dart`: Utility สำหรับเช็ค network (เช่น เชื่อมต่ออินเทอร์เน็ตหรือไม่)
  - `constants.dart`: กำหนดค่าคงที่ที่ใช้ซ้ำ เช่น baseUrl, timeout

### ตัวอย่างโค้ด

#### error/failure.dart

```dart
abstract class Failure {
  final String? message;
  Failure([this.message]);
}

class ServerFailure extends Failure {
  ServerFailure([String? message]) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure([String? message]) : super(message);
}
```

#### error/exception.dart

```dart
class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);
}

class CacheException implements Exception {
  final String? message;
  CacheException([this.message]);
}
```

#### usecases/usecase.dart

```dart
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}
```

#### utils/network_info.dart

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

#### utils/constants.dart

```dart
const String baseUrl = 'https://api.example.com/';
const int timeout = 5000;
```

### ประโยชน์

- **error/**: แยกข้อผิดพลาดและ exception ให้จัดการได้ง่ายและเป็นระบบ
- **usecases/**: ทำให้ usecase ทุกตัวมีรูปแบบเดียวกัน รองรับการทดสอบและขยายระบบ
- **utils/**: รวม utility ที่ใช้ซ้ำ เช่น network, constants ลดการเขียนโค้ดซ้ำ

### วิธีเรียกใช้

#### ตัวอย่างการใช้ Failure ใน repository

```dart
import '../../core/error/failure.dart';

Future<Either<Failure, User>> getUser(String id) async {
  try {
    // ... fetch user
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}
```

#### ตัวอย่างการใช้ UseCase

```dart
import '../../core/usecases/usecase.dart';

class GetUser extends UseCase<User, String> {
  // ... implement call
}
```

#### ตัวอย่างการใช้ NetworkInfo

```dart
import '../../core/utils/network_info.dart';

final networkInfo = NetworkInfoImpl(Connectivity());
final connected = await networkInfo.isConnected;
```

### สรุป

- `lib/core` คือศูนย์กลางของโค้ดที่ใช้ซ้ำและเป็นมาตรฐานกลางของแอป
- ทุกเลเยอร์สามารถ import มาใช้ได้
- ช่วยให้โค้ดสะอาด ขยายง่าย และทดสอบง่าย

### Clean Architecture Diagram

```mermaid
flowchart TD
  UI["Presentation Layer\n(pages, widgets, bloc)"]
  UseCase["Domain Layer\n(usecases)"]
  Entity["Domain Layer\n(entities)"]
  RepoInterface["Domain Layer\n(repositories)"]
  RepoImpl["Data Layer\n(repositories impl)"]
  DataSource["Data Layer\n(datasources)"]
  Model["Data Layer\n(models)"]
  API["External: API (Dio)"]
  Hive["External: Hive (Cache)"]
  DI["DI (Provider)"]

  UI -->|calls| UseCase
  UseCase -->|calls| RepoInterface
  RepoInterface <..> RepoImpl
  RepoImpl -->|calls| DataSource
  RepoImpl -->|uses| Model
  DataSource -->|fetches| API
  RepoImpl -->|caches| Hive
  DataSource -->|returns| Model
  Model <..> Entity
  DI -.-> UI
  DI -.-> UseCase
  DI -.-> RepoImpl
  DI -.-> DataSource
```

---

### Folder/File Explanations

- **lib/core/**

  - `error/`: ข้อผิดพลาด, failure, exception handling
  - `usecases/`: base class สำหรับ usecase (เช่น `UseCase<T, Params>`)
  - `utils/`: ฟังก์ชัน/utility ที่ใช้ซ้ำได้

- **lib/domain/**

  - `entities/`: โครงสร้างข้อมูลหลัก (business object) ที่ไม่ขึ้นกับ framework
  - `repositories/`: interface ของ repository (กำหนด method ที่ต้องมี)
  - `usecases/`: ธุรกิจหลัก (เรียกผ่าน repository interface)

- **lib/data/**

  - `datasources/`: ติดต่อ API (Dio), local (Hive) หรือแหล่งข้อมูลอื่น ๆ
  - `models/`: Data model สำหรับ mapping JSON <-> Entity
  - `repositories/`: implements repository interface (domain) เชื่อมโยง datasource กับ domain

- **lib/presentation/**

  - `bloc/`: state management (Riverpod/StateNotifier/Bloc)
  - `pages/`: UI หลักแต่ละหน้า (เช่น HomePage, UserPage)
  - `widgets/`: UI ย่อยที่นำกลับมาใช้ซ้ำได้

- **lib/di/**

  - `injection.dart`: กำหนด provider สำหรับ dependency injection (Riverpod/Provider)

- **lib/main.dart**
  - จุดเริ่มต้นของแอป, กำหนด ProviderScope, go_router, theme, initial route

---

### Data Flow Example

1. User กดปุ่มใน `example_page.dart`
2. เรียก method ใน `example_notifier.dart`
3. Notifier เรียก `GetExample` usecase
4. Usecase เรียก `ExampleRepository` (interface)
5. `ExampleRepositoryImpl` (data layer) implements interface และเรียก `ExampleRemoteDataSource`
6. DataSource ใช้ dio ดึงข้อมูลจาก API, hive cache ข้อมูล
7. ข้อมูลถูกแปลงเป็น `ExampleModel` แล้ว map เป็น `ExampleEntity`
8. ข้อมูลถูกส่งกลับไปยัง notifier และแสดงผลใน page

---
