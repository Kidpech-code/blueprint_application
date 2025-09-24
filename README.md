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
