# Blueprint Application - เทมเพลต Flutter สถาปัตยกรรม MVVM+DDD

## 📘 คู่มือเรียนรู้สถาปัตยกรรมแบบเจาะลึก

### 🎯 วัตถุประสงค์ของเอกสารนี้

เอกสารนี้จัดทำขึ้นเพื่อเป็นคู่มือการเรียนรู้ที่ครบถ้วนสำหรับนักพัฒนาทุกระดับ ตั้งแต่ผู้เริ่มต้นจนถึงผู้เชี่ยวชาญ เพื่อทำความเข้าใจสถาปัตยกรรม **MVVM (Model-View-ViewModel)** ร่วมกับ **Domain-Driven Design (DDD)** ในลักษณะที่ลึกซึ้งและปฏิบัติได้จริง

**สิ่งที่คุณจะได้เรียนรู้:**

- 🏗️ หลักการและแนวคิดเบื้องหลังสถาปัตยกรรม Clean Architecture
- 🔄 ความสัมพันธ์และการไหลของข้อมูลระหว่างชั้นต่างๆ
- 📁 บทบาทและหน้าที่ของแต่ละไฟล์ในระบบ
- 🎯 วิธีการประยุกต์ใช้ในโปรเจกต์จริง
- 🧪 กลยุทธ์การทดสอบที่ครอบคลุมและมีประสิทธิภาพ

## ❓ ทำไมต้องใช้สถาปัตยกรรมนี้?

### 🔍 ปัญหาของการพัฒนาแบบดั้งเดิม

ในการพัฒนาแอปพลิเคชันแบบดั้งเดิม เรามักพบปัญหาเหล่านี้:

```dart
// ❌ ตัวอย่างโค้ดที่มีปัญหา - ทุกอย่างอยู่ใน Widget เดียว
class BadLoginScreen extends StatefulWidget {
  @override
  _BadLoginScreenState createState() => _BadLoginScreenState();
}

class _BadLoginScreenState extends State<BadLoginScreen> {
  final _dio = Dio(); // HTTP client ติดแน่นกับ UI
  final _prefs = SharedPreferences.getInstance(); // Storage ติดแน่นกับ UI

  Future<void> login(String email, String password) async {
    // ✗ Business logic ปะปนกับ UI logic
    // ✗ ทดสอบยาก เพราะทุกอย่างติดกัน
    // ✗ ใช้ซ้ำไม่ได้ เพราะผูกติดกับ Widget นี้
    // ✗ แก้ไขยาก เมื่อโปรเจกต์ใหญ่ขึ้น
  }
}
```

### ✅ วิธีแก้ไขด้วยสถาปัตยกรรม MVVM+DDD

```dart
// ✅ แก้ไขด้วยการแยกความรับผิดชอบ
class GoodLoginScreen extends StatefulWidget {
  @override
  _GoodLoginScreenState createState() => _GoodLoginScreenState();
}

class _GoodLoginScreenState extends State<GoodLoginScreen> {
  late final AuthViewModel _viewModel; // เชื่อมต่อกับ Business Logic เท่านั้น

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance<AuthViewModel>(); // Dependency Injection
  }

  // ✓ UI มีหน้าที่แค่แสดงผลและรับ input
  // ✓ Business logic อยู่ใน ViewModel
  // ✓ Data access อยู่ใน Repository
  // ✓ ทดสอบได้ง่าย เพราะแต่ละชิ้นแยกจากกัน
  // ✓ ใช้ซ้ำได้ ใน UI อื่นๆ
  // ✓ แก้ไขง่าย เพราะมีโครงสร้างชัดเจน
}
```

## 🏗️ สถาปัตยกรรมและหลักการ

### 🧠 แนวคิดหลัก: Separation of Concerns

หลักการสำคัญที่สุดคือ **"แยกความรับผิดชอบ"** - แต่ละส่วนของโค้ดควรมีหน้าที่เฉพาะ และไม่ควรรู้จักรายละเอียดของส่วนอื่น

```
🎯 หลักการ Dependency Rule:
Domain ← Application ← Data
   ↑                   ↑
   └─── Presentation ──┘

การไหลของ Dependency:
- ชั้นใน (Domain) ไม่รู้จักชั้นนอก
- ชั้นนอกสามารถพึ่งพาชั้นในได้
- การเปลี่ยนแปลงชั้นนอกไม่กระทบชั้นใน
```

### 🎨 ภาพรวมสถาปัตยกรรม 4 ชั้น

```
┌─────────────────────────────────────────────────────────────┐
│                    📱 PRESENTATION LAYER                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │   Views     │ │ ViewModels  │ │   Routes    │           │
│  │ (UI Widgets)│ │(State Mgmt) │ │(Navigation) │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────┬───────────────────────────────────────┘
                      │ ViewModel เรียกใช้ Use Cases
┌─────────────────────┴───────────────────────────────────────┐
│                   🎯 APPLICATION LAYER                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │ Use Cases   │ │ Use Cases   │ │ Use Cases   │           │
│  │  (Login)    │ │ (Register)  │ │ (Logout)    │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────┬───────────────────────────────────────┘
                      │ Use Cases เรียกใช้ Repository Interface
┌─────────────────────┴───────────────────────────────────────┐
│                     🏛️ DOMAIN LAYER                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │  Entities   │ │Value Objects│ │Repository   │           │
│  │   (User)    │ │(Email,Pass) │ │ Interfaces  │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────┬───────────────────────────────────────┘
                      │ Repository Implementation
┌─────────────────────┴───────────────────────────────────────┐
│                     💾 DATA LAYER                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │ Repository  │ │Remote Data  │ │Local Data   │           │
│  │    Impl     │ │   Source    │ │   Source    │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────────────────────────────────────────────┘
           │                    │                    │
    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
    │  Database   │    │  REST API   │    │   Cache     │
    │  (SQLite)   │    │   (HTTP)    │    │(SharedPref) │
    └─────────────┘    └─────────────┘    └─────────────┘
```

### 🔄 การไหลของข้อมูลและการควบคุม

#### 🚀 User Action Flow (การไหลจาก UI ลงไปยัง Data)

```
1. User กด Login Button
   ↓
2. LoginView เรียก viewModel.login()
   ↓
3. AuthViewModel เรียก loginUseCase.call()
   ↓
4. LoginUseCase เรียก authRepository.login()
   ↓
5. AuthRepositoryImpl เรียก remoteDataSource.login()
   ↓
6. AuthRemoteDataSource ส่ง HTTP request ไป API
```

#### 🔙 Data Response Flow (การไหลจาก Data กลับขึ้นมายัง UI)

```
1. API ส่ง response กลับมา
   ↓
2. AuthRemoteDataSource แปลง JSON เป็น Model
   ↓
3. AuthRepositoryImpl แปลง Model เป็น Entity
   ↓
4. LoginUseCase ได้รับ Result<AuthToken>
   ↓
5. AuthViewModel อัปเดต state และ notifyListeners()
   ↓
6. LoginView rebuild ตาม state ใหม่
```

### 🧩 หลักการ Dependency Injection

```dart
// 🎯 ปัญหาที่ Dependency Injection แก้ไข

// ❌ ปัญหา: Hard Dependency
class BadAuthViewModel {
  // ผูกติดแน่นกับ implementation เฉพาะ
  final AuthRepositoryImpl repository = AuthRepositoryImpl();
  // ❌ ทดสอบยาก - ไม่สามารถ mock ได้
  // ❌ เปลี่ยน implementation ยาก
  // ❌ การต้อง new object ทุกครั้งที่ใช้
}

// ✅ แก้ไข: Dependency Injection
class GoodAuthViewModel {
  final AuthRepository repository; // ใช้ interface แทน implementation

  // รับ dependency จากภายนอก (Injection)
  GoodAuthViewModel({required this.repository});

  // ✓ ทดสอบง่าย - ส่ง mock repository เข้ามาได้
  // ✓ เปลี่ยน implementation ได้ตอน runtime
  // ✓ Object lifecycle จัดการโดย DI container
}
```

## 📂 โครงสร้างไฟล์และความสัมพันธ์แบบเจาะลึก

### 🌍 โครงสร้างระดับโลก (Global Structure)

```
lib/
├── 🚀 main.dart                    # จุดเริ่มต้นของแอปพลิเคชัน
├── 📱 app.dart                     # Widget หลักและการตั้งค่าแอป
├── ⚙️ config.dart                  # การตั้งค่า environment และ API
├── 🎨 constants.dart               # ค่าคงที่ UI และ design system
├── core/                           # โครงสร้างพื้นฐานที่ใช้ร่วมกัน
│   ├── 🔧 dependency_injection.dart # DI container และการจัดการ dependencies
│   ├── ❌ error_handling.dart      # Result pattern และการจัดการข้อผิดพลาด
│   ├── 🛣️ route_manager.dart       # การจัดการเส้นทางและ navigation
│   └── 🛠️ utils.dart               # helper functions และ utilities
└── features/                       # ฟีเจอร์โมดูลาร์ (แยกตาม business domain)
    ├── auth/                       # ระบบการพิสูจน์ตัวตน
    ├── profile/                    # จัดการโปรไฟล์ผู้ใช้
    ├── blog/                       # ระบบเนื้อหาและบทความ
    └── common/                     # UI components ที่ใช้ร่วมกัน
```

### 🚀 จุดเริ่มต้น: `main.dart`

**หน้าที่และความสำคัญ:**

```dart
void main() async {
  // 1. 🔧 Initialize Flutter Framework
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 🔌 Setup Dependency Injection
  await initializeDependencies();

  // 3. 🚀 Start Application
  runApp(const MyApp());
}
```

**ทำไมต้องทำแบบนี้:**

- **`WidgetsFlutterBinding.ensureInitialized()`**: ให้แน่ใจว่า Flutter framework พร้อมก่อนที่จะทำอะไรอื่น
- **`await initializeDependencies()`**: ตั้งค่าทุก dependencies ก่อนที่แอปจะเริ่ม เพื่อให้ทุก Widget สามารถใช้ services ต่างๆ ได้
- **`runApp()`**: เริ่มต้นแอป Flutter

**ความสัมพันธ์กับไฟล์อื่น:**

```
main.dart
    ├── → core/dependency_injection.dart (ตั้งค่า services)
    └── → app.dart (เริ่มต้น UI tree)
```

### 🔧 Dependency Injection: `core/dependency_injection.dart`

**บทบาทหลัก: "Service Locator และ Factory"**

```dart
final sl = GetIt.instance; // Service Locator singleton

Future<void> initializeDependencies() async {
  // 1. 🗂️ External Dependencies (สิ่งที่มาจากภายนอก)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // 2. 🌐 HTTP Client Setup
  sl.registerLazySingleton(() => Dio()..options = BaseOptions(...));

  // 3. 🔐 Feature Dependencies (แยกตาม feature)
  _initAuthFeature();
  _initProfileFeature();
  _initBlogFeature();
}
```

**การจัดการ Object Lifecycle:**

- **`registerLazySingleton`**: สร้าง object ครั้งเดียว เมื่อถูกเรียกใช้ครั้งแรก (เหมาะกับ Repository, DataSource)
- **`registerFactory`**: สร้าง object ใหม่ทุกครั้งที่ถูกเรียก (เหมาะกับ ViewModel ที่ผูกกับ Widget)

**ตัวอย่างการลงทะเบียน Auth Feature:**

```dart
void _initAuthFeature() {
  // 📡 Data Sources (การเข้าถึงข้อมูล)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()) // ส่ง Dio เข้าไป
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()) // ส่ง SharedPreferences เข้าไป
  );

  // 📚 Repository (ประสานงานระหว่าง DataSources)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(), // DI จะหา AuthRemoteDataSource ให้อัตโนมัติ
      localDataSource: sl()   // DI จะหา AuthLocalDataSource ให้อัตโนมัติ
    )
  );

  // 🎯 Use Cases (Business Logic)
  sl.registerLazySingleton(() => LoginUseCase(sl())); // ส่ง Repository เข้าไป

  // 🎭 ViewModels (UI State Management)
  sl.registerFactory(() => AuthViewModel(
    loginUseCase: sl(),    // DI จะหา LoginUseCase ให้
    registerUseCase: sl(), // DI จะหา RegisterUseCase ให้
    // ... Use Cases อื่นๆ
  ));
}
```

**ข้อดีของการออกแบบแบบนี้:**

1. **🔄 Loose Coupling**: ไฟล์ต่างๆ ไม่ต้องรู้จักกันโดยตรง
2. **🧪 Testability**: สามารถ inject mock objects สำหรับการทดสอบ
3. **🔧 Maintainability**: เปลี่ยน implementation ได้ง่าย เพียงแก้ที่จุดเดียว
4. **🎯 Single Responsibility**: แต่ละ class มีหน้าที่เฉพาะ

## 🔍 การวิเคราะห์ฟีเจอร์แบบเจาะลึก: Authentication

## 🔁 การย้อนกลับหลังล็อกอิน (Redirect after login)

เมื่อแอปต้องการให้ผู้ใช้ล็อกอิน (เช่น token หมดอายุ) เราต้องการให้ผู้ใช้กลับไปยังหน้าที่กำลังดูหลังจากล็อกอินสำเร็จ

กลไกภายในโปรเจกต์นี้:

- การเรียก redirect: นำทางไปที่หน้า login พร้อม query param `redirect` ตัวอย่าง:

  AppRouter.go('/auth/login?redirect=${Uri.encodeComponent(currentLocation)}');

- หากไม่มี `redirect` param ระบบจะใช้ `RouteHistory` ซึ่งบันทึกหน้าล่าสุด (ที่ไม่ใช่หน้าของ /auth) โดย `AppRouter.go/push/replace` จะอัปเดตค่านี้

- ลำดับการเลือกเป้าหมายหลังล็อกอิน:
  1. `widget.redirectTo` (ถ้ามี, จะ decode และ validate)
  2. `RouteHistory.last` (ถ้ามีและถูกต้อง)
  3. `/profile/<userId>` ถ้ามีข้อมูลผู้ใช้
  4. `/` เป็น fallback สุดท้าย

ความปลอดภัย:

- ปฏิเสธ redirect ที่เป็น full URL (มี `://`) เพื่อป้องกัน open redirect
- ต้องเป็น path ภายในที่ขึ้นต้นด้วย `/`
- ปฏิเสธ path ที่เริ่มด้วย `/auth` เพื่อป้องกัน loop

Integration:

- `AuthInterceptor` จะจับ 401 และ redirect ไป `/auth/login?redirect=<encoded-last>`
- `LoginView` รับ `redirectTo` เป็น parameter และใช้ resolver ในการเลือกเป้าหมายปลอดภัยหลังล็อกอิน

ดู `docs/redirect_after_login.md` สำหรับคำอธิบายและตัวอย่างเพิ่มเติม

### 🔐 ภาพรวมของ Auth Feature

Authentication เป็นฟีเจอร์ที่แสดงให้เห็นการใช้งานสถาปัตยกรรม MVVM+DDD อย่างครบถ้วน เพราะมีความซับซ้อนของ business logic, data persistence, และ UI interaction

```
🔐 Auth Feature Architecture Map:

📱 UI Layer (presentation/)
   ├── 🖼️ views/login_view.dart           # หน้าจอ login
   ├── 🖼️ views/register_view.dart        # หน้าจอ register
   ├── 🎛️ viewmodels/auth_viewmodel.dart   # state management
   └── 🛣️ routes/auth_routes.dart          # navigation

🎯 Business Layer (application/)
   └── usecases/
       ├── 🔑 login_usecase.dart           # login business logic
       ├── 📝 register_usecase.dart        # register business logic
       ├── 🚪 logout_usecase.dart          # logout business logic
       └── 👤 get_current_user_usecase.dart # user info retrieval

🏛️ Domain Layer (domain/)
   ├── entities/
   │   ├── 👤 User                         # ข้อมูลผู้ใช้พื้นฐาน
   │   └── 🎫 AuthToken                    # token และ expiration
   ├── value_objects/
   │   ├── 📧 Email                        # email validation
   │   ├── 🔒 Password                     # password rules
   │   └── 📛 Name                         # name validation
   └── repositories/
       └── 🔌 AuthRepository               # interface เท่านั้น

💾 Data Layer (data/)
   ├── models/
   │   ├── 📄 UserModel                    # API response mapping
   │   └── 📄 AuthTokenModel               # token response mapping
   ├── datasources/
   │   ├── 🌐 AuthRemoteDataSource         # API integration
   │   └── 💿 AuthLocalDataSource          # local storage
   └── repositories/
       └── 🔧 AuthRepositoryImpl           # business logic coordinator
```

### 🏛️ Domain Layer: หัวใจของ Business Logic

#### 📦 Entities: ข้อมูลหลักของธุรกิจ

**`domain/entities/auth_entities.dart`**

```dart
// 👤 User Entity - แทนผู้ใช้ในระบบ
class User extends Equatable {
  final String id;              // 🆔 unique identifier
  final String email;           // 📧 email address (business requirement)
  final String name;            // 📛 display name
  final String? profileImage;   // 🖼️ optional profile picture
  final DateTime createdAt;     // 📅 account creation date
  final DateTime? lastLoginAt;  // ⏰ last activity tracking

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    required this.createdAt,
    this.lastLoginAt,
  });

  // 🔄 Business Methods
  bool get isNewUser => lastLoginAt == null;
  bool get hasProfileImage => profileImage != null;

  // 📋 Data Integrity (Equatable)
  @override
  List<Object?> get props => [id, email, name, profileImage, createdAt, lastLoginAt];
}
```

**ทำไม User เป็น Entity:**

- **🆔 Identity**: มี unique ID เป็นตัวระบุ
- **🔄 Mutable**: สามารถเปลี่ยนแปลงได้ (name, profileImage, lastLoginAt)
- **📋 Business Rules**: มี business methods (isNewUser, hasProfileImage)
- **⚖️ Equality**: ใช้ Equatable เพื่อเปรียบเทียบตาม properties

```dart
// 🎫 AuthToken Entity - จัดการ authentication state
class AuthToken extends Equatable {
  final String accessToken;     // 🔑 JWT token for API access
  final String refreshToken;    // 🔄 token for refreshing access
  final DateTime expiresAt;     // ⏰ expiration timestamp

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  // 🔄 Business Logic Methods
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());
  bool get needsRefresh => timeUntilExpiry.inMinutes < 5; // refresh 5 min before expire

  @override
  List<Object> get props => [accessToken, refreshToken, expiresAt];
}
```

**ทำไม AuthToken เป็น Entity:**

- **📅 Time-based Logic**: มี business rules เกี่ยวกับเวลา
- **🔄 Stateful**: สถานะเปลี่ยนแปลงตามเวลา
- **🎯 Critical Business Object**: สำคัญต่อการทำงานของระบบ

### 📱 แอปพลิเคชันหลัก: `app.dart`

**หน้าที่: "Central App Configuration Hub"**

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // 🎨 Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // 🛣️ Routing Configuration
      routerConfig: AppRouter.router,

      // 🌍 Localization
      locale: const Locale('th', 'TH'),

      // 📱 App Metadata
      title: 'Blueprint Application',
    );
  }
}
```

**ความสัมพันธ์และการไหลของข้อมูล:**

```
app.dart
    ├── → constants.dart (AppTheme, colors, styles)
    ├── → core/route_manager.dart (AppRouter configuration)
    └── → features/*/presentation/routes/ (feature-specific routes)
```

**ประโยชน์ของการแยกไฟล์นี้:**

- **🎨 Centralized Theming**: จัดการธีมทั้งหมดที่จุดเดียว
- **🛣️ Global Navigation**: กำหนดกฎการนำทางในระดับแอป
- **🌍 Internationalization**: ตั้งค่าภาษาและ locale
- **⚙️ App-wide Settings**: การตั้งค่าที่ส่งผลต่อทั้งแอป

### ⚙️ การตั้งค่าและสภาพแวดล้อม: `config.dart`

**หน้าที่: "Environment และ Configuration Management"**

```dart
class AppConfig {
  // 🌍 Environment Management
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development'
  );

  // 🔗 API Configuration
  static String get apiBaseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.myapp.com';
      case 'staging':
        return 'https://staging-api.myapp.com';
      default:
        return 'https://dev-api.myapp.com';
    }
  }

  // ⏱️ Timeout Settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 🔐 Security Settings
  static const bool enableLogging = !bool.fromEnvironment('PRODUCTION');
}
```

**การใช้งานในไฟล์อื่น:**

```dart
// ใน dependency_injection.dart
sl.registerLazySingleton(() => Dio()
  ..options = BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,           // ใช้ config
    connectTimeout: AppConfig.connectTimeout, // ใช้ config
    receiveTimeout: AppConfig.receiveTimeout, // ใช้ config
  )
);
```

**ประโยชน์:**

- **🔄 Environment Switching**: เปลี่ยน environment ได้ง่าย
- **🔒 Security**: ไม่ hardcode sensitive data
- **⚡ Performance Tuning**: ปรับ timeout ตาม environment
- **🐛 Debug Control**: เปิด/ปิด logging ตาม environment

### 🎨 ระบบออกแบบ: `constants.dart`

**หน้าที่: "Design System และ UI Standards"**

```dart
class AppColors {
  // 🎨 Primary Color Palette
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF03DAC6);

  // 🌓 Dark/Light Theme Support
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);

  // ⚠️ Semantic Colors
  static const Color error = Color(0xFFB00020);
  static const Color warning = Color(0xFFFF9800);
  static const Color success = Color(0xFF4CAF50);
}

class AppSpacing {
  // 📏 Consistent Spacing System
  static const double xs = 4.0;   // Extra small
  static const double sm = 8.0;   // Small
  static const double md = 16.0;  // Medium (base unit)
  static const double lg = 24.0;  // Large
  static const double xl = 32.0;  // Extra large
  static const double xxl = 48.0; // Extra extra large
}

class AppTextStyles {
  // 📝 Typography System
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
  );
}

class AppDimensions {
  // 📱 Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // 🔲 Component Dimensions
  static const double buttonHeight = 48.0;
  static const double inputFieldHeight = 56.0;
  static const double appBarHeight = 56.0;
}
```

**การใช้งานในโปรเจกต์:**

```dart
// ใน UI Components
Container(
  padding: EdgeInsets.all(AppSpacing.md), // ใช้ spacing system
  decoration: BoxDecoration(
    color: AppColors.primary,              // ใช้ color system
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    'Hello World',
    style: AppTextStyles.headline1,        // ใช้ typography system
  ),
)
```

**ข้อดีของ Design System:**

- **🎨 Consistency**: UI ดูสอดคล้องกันทั่วทั้งแอป
- **⚡ Development Speed**: ไม่ต้องคิดค่า design ใหม่ทุกครั้ง
- **🔧 Maintainability**: เปลี่ยนธีมได้ที่จุดเดียว
- **♿ Accessibility**: มาตรฐาน contrast และ spacing

## 🏗️ โครงสร้างฟีเจอร์แบบโมดูลาร์

### 📁 โครงสร้างมาตรฐานของทุกฟีเจอร์

```
features/[feature_name]/
├── 🏛️ domain/                     # 🧠 ชั้นตรรกะทางธุรกิจ (Business Logic)
│   ├── entities/                  # 📦 Core Business Objects
│   ├── value_objects/            # 💎 Domain Value Objects
│   └── repositories/             # 🔌 Repository Interfaces
├── 💾 data/                       # 📡 ชั้นการเข้าถึงข้อมูล (Data Access)
│   ├── models/                   # 📋 Data Transfer Objects (DTOs)
│   ├── datasources/              # 🌐 Data Sources (API, Database, Cache)
│   └── repositories/             # 🔧 Repository Implementations
├── 🎯 application/                # 📋 ชั้น Use Cases (Application Logic)
│   └── usecases/                 # 🎯 Business Use Cases
└── 🎭 presentation/               # 🖥️ ชั้น UI (User Interface)
    ├── viewmodels/               # 🎛️ State Management
    ├── views/                    # 🎨 UI Screens/Widgets
    └── routes/                   # 🛣️ Feature Navigation
```

### 🔄 การไหลของข้อมูลในแต่ละชั้น

#### 📱 จาก UI ลงไป Data (User Action)

```
1. 👆 User กดปุ่ม "Login"
   ↓
2. 🎨 LoginView.onLoginPressed()
   ↓
3. 🎛️ AuthViewModel.login(email, password)
   ↓
4. 🎯 LoginUseCase.call(email, password)
   ↓
5. 🔌 AuthRepository.login(email, password) [Interface]
   ↓
6. 🔧 AuthRepositoryImpl.login() [Implementation]
   ↓
7. 🌐 AuthRemoteDataSource.login() [API Call]
   ↓
8. 📡 HTTP POST /api/auth/login
```

#### 📤 จาก Data กลับขึ้น UI (Data Response)

```
1. 📡 API Response: { "token": "...", "user": {...} }
   ↓
2. 📋 AuthRemoteDataSource แปลง JSON → AuthTokenModel
   ↓
3. 🔧 AuthRepositoryImpl แปลง Model → AuthToken Entity
   ↓
4. 🎯 LoginUseCase ห่อผลลัพธ์ด้วย Result<AuthToken>
   ↓
5. 🎛️ AuthViewModel รับ Result และอัปเดต state
   ↓
6. 🎨 LoginView rebuild UI ตาม state ใหม่
   ↓
7. 👀 User เห็นผลลัพธ์ (success/error)
```

**🔑 หลักการสำคัญ: Dependency Rule**

- **🏛️ Domain Layer**: ไม่พึ่งพาใครเลย (แยกตัวสมบูรณ์)
- **🎯 Application Layer**: พึ่งพาแค่ Domain เท่านั้น
- **💾 Data Layer**: พึ่งพา Domain (implement interfaces)
- **🎭 Presentation Layer**: พึ่งพา Application และ Domain

## 📂 โครงสร้างไฟล์โดยละเอียด

### 🔧 โครงสร้างโปรเจกต์

#### ✅ การใช้งาน Clean Architecture

**`main.dart`** - จุดเริ่มต้นแอปพลิเคชัน

```dart
// จุดเริ่มต้นของแอปพลิเคชัน
// - ตั้งค่า dependency injection
// - เริ่มต้นแอปพลิเคชัน
// - การตั้งค่า error handling ระดับโลก
```

**`app.dart`** - Widget แอปพลิเคชันหลัก

```dart
// - การตั้งค่าธีมและ Material Design 3
// - การกำหนดค่าการเส้นทางด้วย go_router
// - การตั้งค่า locale และ internationalization
// - การจัดการสถานะระดับแอปพลิเคชัน
```

**`config.dart`** - การตั้งค่าและ environment

```dart
// - ตัวแปร environment (DEV/STAGING/PROD)
// - API endpoints และ base URLs
// - การตั้งค่าฐานข้อมูล
// - ค่าคงที่การตั้งค่าแอปพลิเคชัน
```

**`constants.dart`** - ค่าคงที่ UI และ design tokens

```dart
// - Color schemes และ palettes
// - Typography scales และ text styles
// - Spacing และ dimension constants
// - Animation durations และ curves
// - Icon paths และ asset management
```

### 🏛️ Core Infrastructure (`core/`)

#### `dependency_injection.dart`

```dart
// Service Locator pattern ด้วย GetIt
// - การลงทะเบียน dependencies ทั้งหมด
// - Factory และ Singleton registrations
// - การตั้งค่า testing dependencies
// - การจัดการ lifecycle ของ dependencies
```

#### `error_handling.dart`

```dart
// Result type pattern สำหรับการจัดการข้อผิดพลาด
// - Success/Failure wrapper types
// - Exception mapping และ error codes
// - User-friendly error messages
// - Logging และ analytics integration
```

#### `route_manager.dart`

```dart
// การจัดการเส้นทางระดับโลก
// - Route definitions และ path patterns
// - Navigation guards และ middleware
// - Deeplink handling
// - Transition animations
```

#### `utils.dart`

```dart
// เครื่องมือที่ใช้ร่วมกัน
// - Date/time formatting utilities
// - String manipulation helpers
// - Validation functions
// - Extension methods
```

## 🔍 โครงสร้างฟีเจอร์โดยละเอียด

### 🔐 ฟีเจอร์การพิสูจน์ตัวตน (`features/auth/`)

#### **Domain Layer** (`domain/`)

**`entities/auth_entities.dart`**

```dart
// Core business objects
class User {
  // - ข้อมูลผู้ใช้พื้นฐาน (id, email, name)
  // - Business rules และ invariants
  // - Domain behaviors (isActive, hasPermission)
}

class AuthToken {
  // - JWT token management
  // - Expiration handling
  // - Refresh token logic
}
```

**`value_objects/auth_value_objects.dart`**

```dart
// Domain value objects ที่มีการ validation
class Email {
  // - Email format validation
  // - Unicode support
  // - Whitespace handling
}

class Password {
  // - Strength validation (8+ characters)
  // - Character type requirements
  // - Security rules
}

class Name {
  // - Unicode character support
  // - International name formats
  // - Length validation
}
```

**`repositories/auth_repository.dart`**

```dart
// Repository interface - ไม่มี implementation
abstract class AuthRepository {
  // - login(), register(), logout()
  // - getCurrentUser(), refreshToken()
  // - Token storage management
  // - Password reset functionality
}
```

#### **Data Layer** (`data/`)

**`models/auth_models.dart`**

```dart
// Data Transfer Objects (DTOs)
@JsonSerializable()
class UserModel {
  // - JSON serialization/deserialization
  // - API response mapping
  // - toEntity() conversion methods
}

@JsonSerializable()
class AuthTokenModel {
  // - Token response from API
  // - Automatic expiration parsing
  // - Refresh token handling
}
```

**`datasources/auth_remote_datasource.dart`**

```dart
// API integration
class AuthRemoteDataSource {
  // - HTTP client setup (Dio)
  // - API endpoints (login, register, etc.)
  // - Request/response interceptors
  // - Error handling และ retry logic
}
```

**`datasources/auth_local_datasource.dart`**

```dart
// Local storage management
class AuthLocalDataSource {
  // - SharedPreferences integration
  // - Secure token storage
  // - Cache management
  // - Offline data handling
}
```

**`repositories/auth_repository_impl.dart`**

```dart
// Repository implementation
class AuthRepositoryImpl implements AuthRepository {
  // - Combines remote และ local data sources
  // - Business logic orchestration
  // - Error mapping และ handling
  // - Cache strategies
}
```

#### **Application Layer** (`application/`)

**`usecases/login_usecase.dart`**

```dart
// Business use cases
class LoginUseCase {
  // - Input validation
  // - Repository orchestration
  // - Business rules enforcement
  // - Return Result<AuthToken>
}
```

**`usecases/register_usecase.dart`**

```dart
class RegisterUseCase {
  // - User registration flow
  // - Email verification
  // - Password policy enforcement
  // - Return Result<AuthToken>
}
```

#### **Presentation Layer** (`presentation/`)

**`viewmodels/auth_viewmodel.dart`**

```dart
// State management และ UI logic
class AuthViewModel extends ChangeNotifier {
  // - Loading states management
  // - Error handling และ user feedback
  // - Form validation
  // - Navigation triggers
  // - Reactive state updates
}
```

**`views/login_view.dart`**

```dart
// Login UI screen
class LoginView extends StatefulWidget {
  // - Form widgets และ validation
  // - Material Design components
  // - Responsive layout
  // - Loading indicators
  // - Error state handling
}
```

**`views/register_view.dart`**

```dart
// Registration UI screen
class RegisterView extends StatefulWidget {
  // - Multi-step registration form
  // - Real-time validation feedback
  // - Password strength indicator
  // - Terms และ conditions
}
```

**`routes/auth_routes.dart`**

```dart
// Feature-specific routing
class AuthRoutes {
  // - Route definitions (/login, /register)
  // - Route guards (authentication checks)
  // - Navigation helpers
  // - Deeplink support
}
```

### 📝 ฟีเจอร์บล็อก (`features/blog/`)

#### **Domain Layer** (`domain/`)

**`entities/blog_entities.dart`**

```dart
class BlogPost {
  // - Post metadata (title, content, author)
  // - Publishing workflow
  // - SEO และ metadata
  // - Comment system integration
}

class BlogCategory {
  // - Category hierarchy
  // - Post associations
  // - SEO optimizations
}
```

#### **Data Layer** (`data/`)

**`models/blog_models.dart`**

```dart
@JsonSerializable()
class BlogPostModel {
  // - API response mapping
  // - Rich content parsing
  // - Media attachment handling
  // - toEntity() conversions
}
```

**`datasources/blog_remote_datasource.dart`**

```dart
class BlogRemoteDataSource {
  // - REST API integration
  // - Pagination support
  // - Search และ filtering
  // - Content management
}
```

#### **Application Layer** (`application/`)

**`usecases/get_blog_posts_usecase.dart`**

```dart
class GetBlogPostsUseCase {
  // - Pagination logic
  // - Filtering และ sorting
  // - Cache strategies
  // - Performance optimization
}
```

#### **Presentation Layer** (`presentation/`)

**`viewmodels/blog_viewmodel.dart`**

```dart
class BlogViewModel extends ChangeNotifier {
  // - Infinite scrolling management
  // - Search state handling
  // - Favorite/bookmark functionality
  // - Share integration
}
```

**`views/blog_list_view.dart`**

```dart
class BlogListView extends StatefulWidget {
  // - Infinite scroll ListView
  // - Pull-to-refresh
  // - Search และ filter UI
  // - Card-based post layout
}
```

**`views/blog_detail_view.dart`**

```dart
class BlogDetailView extends StatefulWidget {
  // - Rich content rendering
  // - Social sharing
  // - Comment system
  // - Related posts
}
```

### 👤 ฟีเจอร์โปรไฟล์ (`features/profile/`)

#### **Domain Layer** (`domain/`)

**`entities/profile_entities.dart`**

```dart
class UserProfile {
  // - Extended user information
  // - Avatar และ media management
  // - Privacy settings
  // - Activity tracking
}
```

#### **Presentation Layer** (`presentation/`)

**`views/profile_view.dart`**

```dart
class ProfileView extends StatefulWidget {
  // - Tabbed interface (Posts, Settings, Stats)
  // - Avatar upload functionality
  // - Settings management
  // - Activity timeline
}
```

### 🔄 ส่วนที่ใช้ร่วมกัน (`features/common/`)

#### **`presentation/widgets/common_widgets.dart`**

```dart
// Reusable UI components
class LoadingWidget extends StatelessWidget {
  // - Consistent loading indicators
  // - Shimmer effects
  // - Skeleton screens
}

class ErrorWidget extends StatelessWidget {
  // - Standardized error displays
  // - Retry functionality
  // - User-friendly messaging
}

class CustomButton extends StatelessWidget {
  // - Themed button variations
  // - Loading states
  // - Accessibility features
}
```

#### **`presentation/widgets/responsive_layout.dart`**

```dart
// Responsive design utilities
class ResponsiveBuilder extends StatelessWidget {
  // - Breakpoint management
  // - Mobile/tablet/desktop layouts
  // - Orientation handling
}
```

## 📚 เอกสารเสริมสำหรับการเรียนรู้เชิงลึก

### 🔍 เอกสารแนะนำ

- **📘 README.th.md** (ไฟล์นี้) - ภาพรวมและการเริ่มต้นใช้งาน
- **🏗️ ARCHITECTURE_DEEP_DIVE.th.md** - การเจาะลึกสถาปัตยกรรมแบบละเอียด
- **🧪 TESTING_GUIDE.md** - คู่มือการทดสอบครบถ้วน (161/161 tests ผ่าน 100%)

### 🎯 แนะนำสำหรับกลุ่มผู้ใช้

#### 👶 **สำหรับผู้เริ่มต้น**

1. อ่าน **README.th.md** (ไฟล์นี้) เพื่อทำความเข้าใจภาพรวม
2. ศึกษา **ARCHITECTURE_DEEP_DIVE.th.md** เพื่อเข้าใจรายละเอียดการใช้งาน
3. ทดลองรันโปรเจกต์และดูโครงสร้างไฟล์
4. ลองแก้ไขโค้ดเล็กๆ น้อยๆ เพื่อทำความเข้าใจ

#### 🧑‍💻 **สำหรับนักพัฒนาระดับกลาง**

1. ศึกษาการ implement patterns ต่างๆ ใน **ARCHITECTURE_DEEP_DIVE.th.md**
2. ดู **TESTING_GUIDE.md** เพื่อเรียนรู้การเขียน tests
3. ลองเพิ่ม feature ใหม่ตามตัวอย่างที่ให้
4. ประยุกต์ใช้ใน project จริง

#### 🏆 **สำหรับผู้เชี่ยวชาญ**

1. วิเคราะห์การออกแบบ architecture และ design decisions
2. ใช้เป็น reference สำหรับ team training
3. ปรับแต่งให้เหมาะกับ business requirements เฉพาะ
4. Contribute กลับไปยัง community

### 💡 การเรียนรู้แบบก้าวหน้า

#### 📊 ระดับพื้นฐาน (Foundation)

- ✅ ทำความเข้าใจ **Clean Architecture** และ **MVVM Pattern**
- ✅ เรียนรู้ **Value Objects** และ **Entities**
- ✅ ทำความรู้จักกับ **Dependency Injection**

#### 🎯 ระดับกลาง (Intermediate)

- ✅ เข้าใจ **Use Cases** และ **Repository Pattern**
- ✅ เรียนรู้ **Result Pattern** สำหรับ error handling
- ✅ ทำความเข้าใจ **State Management** ด้วย ViewModel

#### 🚀 ระดับสูง (Advanced)

- ✅ การออกแบบ **Testing Strategy** ที่ครอบคลุม
- ✅ **Performance Optimization** และ **Memory Management**
- ✅ **CI/CD Integration** และ **Code Quality**

## 🚀 ฟีเจอร์ที่สมบูรณ์

### ✅ โมดูลฟีเจอร์ที่พร้อมใช้งาน

- **🔐 ระบบการพิสูจน์ตัวตน**: เข้าสู่ระบบ สมัครสมาชิก ออกจากระบบ การจัดการโทเค็น
- **👤 การจัดการโปรไฟล์ผู้ใช้**: ดูโปรไฟล์ แก้ไข สถิติ อินเทอร์เฟสแท็บ
- **📝 ระบบบล็อก**: รายการโพสต์ มุมมองรายละเอียด การกำหนดเส้นทางตามวันที่ที่ซับซ้อน
- **🔄 คอมโพเนนต์ที่ใช้ร่วมกัน**: วิดเจ็ตโหลด มุมมองข้อผิดพลาด องค์ประกอบ UI ทั่วไป

### 🛤️ การกำหนดเส้นทางขั้นสูง

- **🔗 Deeplinks ที่ซับซ้อน**: `/blog/2024/01/15/my-blog-post`
- **❓ Query Parameters**: โหมดตัวอย่าง การแบ่งหน้า การกรอง
- **🎫 การจองอีเวนต์**: `/event/123/booking?step=payment&coupon=SAVE20`
- **📱 การนำทางที่ซ้อนกัน**: การนำทางโปรไฟล์แบบแท็บ

### 🎨 ฟีเจอร์ UI/UX

- **🎨 Material Design 3**: UI ทันสมัยพร้อมธีมแบบไดนามิก
- **🌓 รองรับโหมดมืด**: การเปลี่ยนธีมตามระบบ
- **📱 การออกแบบที่ตอบสนอง**: เลย์เอาท์ที่ปรับได้สำหรับขนาดหน้าจอต่างๆ
- **⏳ สถานะการโหลด**: การจัดการการโหลดและข้อผิดพลาดอย่างครอบคลุม
- **♾️ การเลื่อนแบบไม่สิ้นสุด**: มุมมองรายการที่ปรับปรุงประสิทธิภาพ

## 🚀 การเริ่มต้นใช้งาน

### 1. โคลนและตั้งค่า

```bash
git clone <repository>
cd blueprint_application
flutter pub get
```

### 2. สร้างโค้ด

```bash
flutter packages pub run build_runner build
```

### 3. รันแอปพลิเคชัน

```bash
flutter run
```

### 4. รันการทดสอบ

```bash
# รันทดสอบทั้งหมด
flutter test

# รันทดสอบเฉพาะชั้น
flutter test test/features/auth/domain/
flutter test test/features/auth/presentation/
```

## 💡 ตัวอย่างการใช้งาน

### การเพิ่มฟีเจอร์ใหม่

1. **สร้างโครงสร้างฟีเจอร์**

```bash
mkdir -p lib/features/[ชื่อฟีเจอร์]/{domain,data,application,presentation}/{entities,repositories,models,datasources,usecases,viewmodels,views,routes}
```

2. **กำหนด Domain Layer**

```dart
// Domain Entity
class Product {
  final String id;
  final String name;
  final Price price;

  const Product({
    required this.id,
    required this.name,
    required this.price,
  });
}

// Value Object
class Price {
  final double value;
  final String currency;

  const Price({required this.value, required this.currency});

  bool get isValid => value > 0;
}
```

3. **ใช้งาน Repository Interface**

```dart
abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts();
  Future<Result<Product>> getProduct(String id);
  Future<Result<void>> createProduct(Product product);
}
```

4. **สร้าง Use Cases**

```dart
class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Result<List<Product>>> call() async {
    return await repository.getProducts();
  }
}
```

5. **สร้าง ViewModel**

```dart
class ProductViewModel extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;

  ProductViewModel({required this.getProductsUseCase});

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getProductsUseCase();

    result.when(
      success: (products) {
        _products = products;
        _isLoading = false;
        notifyListeners();
      },
      failure: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
```

### ตัวอย่างการกำหนดเส้นทางที่ซับซ้อน

```dart
// นำทางไปยังโพสต์บล็อกด้วย URL ที่ใช้วันที่
AppRouter.goToBlogPost(
  year: '2024',
  month: '01',
  day: '15',
  slug: 'flutter-architecture-guide',
  preview: true,
);

// นำทางไปยังการจองอีเวนต์ด้วย query parameters
AppRouter.goToEventBooking(
  'event-123',
  step: 'payment',
  coupon: 'SAVE20',
);

// นำทางไปยังโปรไฟล์ผู้ใช้ด้วยแท็บเฉพาะ
AppRouter.goToProfile('user-456', tab: 'posts');
```

## 🔒 คุณสมบัติด้านความปลอดภัย

### การพิสูจน์ตัวตน

- **การจัดการ JWT token** ด้วยการรีเฟรชอัตโนมัติ
- **การจัดเก็บข้อมูลท้องถิ่นที่ปลอดภัย** สำหรับข้อมูลสำคัญ
- **การล้างข้อมูลเมื่อออกจากระบบ** เพื่อล้างข้อมูลการยืนยันตัวตนทั้งหมด
- **การจัดการการหมดอายุของโทเค็น**

### การป้องกันข้อมูล

- **การตรวจสอบอินพุต** ด้วย value objects
- **การป้องกัน XSS** ในเนื้อหาที่ผู้ใช้สร้าง
- **การป้องกัน API key** (ไม่ hardcode)

## 📈 การปรับปรุงประสิทธิภาพ

### การจัดการสถานะ

- **รูปแบบ Provider** สำหรับการอัปเดตสถานะแบบ reactive
- **การลงทะเบียนแบบ Factory** สำหรับ ViewModels เพื่อป้องกัน memory leaks
- **Lazy loading** สำหรับ dependencies ที่ใช้ทรัพยากรมาก

### ประสิทธิภาพ UI

- **การเลื่อนแบบไม่สิ้นสุด** ด้วยการแบ่งหน้า
- **การแคชรูปภาพ** สำหรับโปรไฟล์และรูปภาพบล็อก
- **การค้นหาแบบ debounced** เพื่อลดการเรียก API
- **การปรับปรุง list views** ด้วย builders

## 🏆 ประโยชน์

### สำหรับทีมพัฒนา

- **ขอบเขตโมดูลที่ชัดเจน** สำหรับการพัฒนาแบบขนาน
- **รูปแบบที่สอดคล้อง** ในทุกฟีเจอร์
- **การเรียนรู้ที่ง่าย** ด้วยโครงสร้างที่มีเอกสาร
- **สถาปัตยกรรมที่ขยายได้** สำหรับแอปพลิเคชันที่เติบโต
- **ความครอบคลุมการทดสอบ 100%** ด้วยตัวอย่างที่ครอบคลุม
- **รูปแบบที่พร้อมใช้ในการผลิต** ด้วยกลยุทธ์การทดสอบที่ได้รับการพิสูจน์

### สำหรับธุรกิจ

- **การส่งมอบฟีเจอร์ที่เร็วขึ้น** ด้วยคอมโพเนนต์ที่นำมาใช้ใหม่ได้
- **ต้นทุนการบำรุงรักษาที่ลดลง** ด้วยสถาปัตยกรรมที่สะอาด
- **คุณภาพที่ดีขึ้น** ด้วยการจัดการข้อผิดพลาดที่ครอบคลุม
- **อนาคตที่มั่นคง** ด้วยรูปแบบ Flutter ที่ทันสมัย
- **ลดข้อผิดพลาด** ด้วยความครอบคลุมการทดสอบ unit ที่กว้างขวาง
- **CI/CD ที่เชื่อถือได้** ด้วยชุดทดสอบที่มั่นคง

## 📚 แหล่งเรียนรู้

### รูปแบบสถาปัตยกรรม

- [Clean Architecture โดย Robert Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [MVVM ใน Flutter](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple)

### แนวทางปฏิบัติที่ดีของ Flutter

- [แนวทางปฏิบัติที่ดีด้านประสิทธิภาพของ Flutter](https://flutter.dev/docs/perf/rendering/best-practices)
- [สถาปัตยกรรมแอป Flutter](https://flutter.dev/docs/development/data-and-backend/architecting-app)

---

## 📄 ใบอนุญาต

เทมเพลตนี้ให้บริการตามสภาพที่เป็นอยู่สำหรับการใช้งานทางการศึกษาและเชิงพาณิชย์ รู้สึกอิสระที่จะแก้ไขและแจกจ่ายตามความต้องการของคุณ

---

**ขอให้มีความสุขกับการเขียนโค้ด! 🚀**

_เทมเพลตนี้แสดงให้เห็นถึงแนวทางปฏิบัติการพัฒนา Flutter ระดับองค์กรโดยเน้นการบำรุงรักษา ความสามารถในการขยาย และการทำงานร่วมกันของทีม ตอนนี้มีฟีเจอร์ **ความครอบคลุมการทดสอบ 100%** ด้วยตัวอย่างการทดสอบ unit ที่ครอบคลุมสำหรับทุกชั้นสถาปัตยกรรม_

---

## 🔗 ลิงก์เอกสารที่เกี่ยวข้อง

- 📘 **README.th.md** - เอกสารหลัก (ไฟล์นี้)
- 🏗️ **ARCHITECTURE_DEEP_DIVE.th.md** - การเจาะลึกสถาปัตยกรรมแบบละเอียด
- 🧪 **TESTING_GUIDE.md** - คู่มือการทดสอบ (161/161 tests ผ่าน 100%)
- 📄 **README.md** - English documentation
