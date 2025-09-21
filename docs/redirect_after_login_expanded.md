การจัดการการกลับไปหน้าที่ผู้ใช้กำลังใช้งานหลังจากล็อกอิน (Redirect after login)

ภาพรวม

ในโปรเจกต์นี้ เราต้องการให้เมื่อ token หมดอายุ (เช่น backend ตอบกลับ 401 Unauthorized) ผู้ใช้จะถูกพาไปยังหน้าล็อกอิน และหลังจากล็อกอินสำเร็จ ให้ระบบพาผู้ใช้กลับไปยังหน้าเดิมที่กำลังใช้งาน (หรือหน้า fallback ที่เหมาะสม)

สิ่งที่เพิ่มเข้ามา

- `RouteHistory` — บริการจดจำ URL สุดท้ายที่ไม่ใช่หน้า auth/404
- `AuthInterceptor` — `Dio` interceptor ที่จับ 401 แล้วทำการ logout (ถ้ามี) และ redirect ไปที่ `/auth/login?redirect=<encoded>`
- `route_manager` / `AppRouter` helpers — วางจุดที่อัพเดท `RouteHistory` เมื่อเรียก navigation helper เช่น `go`, `push`, `replace`
- `resolveRedirect` — ฟังก์ชันช่วยสำหรับตรวจสอบและแปลง URL redirect ให้ปลอดภัยก่อนนำไปใช้หลังล็อกอิน
- การปรับปรุง `LoginView` — อ่านพารามิเตอร์ `redirect` จาก query parameters และใช้ `resolveRedirect` เพื่อกำหนดหน้าเป้าหมายหลังล็อกอิน
- Unit tests — ทดสอบ `resolveRedirect` ครอบคลุมกรณีปกติ, encoded redirect, การโจมตีแบบ open-redirect, และ fallback

ไฟล์สำคัญและคำอธิบาย

- `lib/core/route_history.dart`

  - บทบาท: เก็บ `last` URL ที่ไม่ใช่ prefixed routes ที่เป็น auth หรือ 404
  - วิธีใช้งาน: เรียก `RouteHistory.update(location)` ทุกครั้งก่อนเปลี่ยนหน้า (โค้ดตัวอย่างอยู่ใน `route_manager`)

- `lib/core/auth_interceptor.dart`

  - บทบาท: ดักจับ `401 Unauthorized` จาก `Dio` และสั่ง logout + redirect
  - พฤติกรรม: เมื่อ intercept พบ 401 ->
    1. เรียก `LogoutUseCase` (ถ้า DI ลงทะเบียนไว้) เพื่อเคลียร์สถานะ local token
    2. อ่าน `RouteHistory.last` เพื่อเตรียมค่า redirect
    3. ไปที่ `/auth/login?redirect=<encodedLast>` โดยใช้ `AppRouter.go()`
  - หมายเหตุ: มี flag ป้องกันการ loop เพื่อไม่ให้เกิด redirect ซ้ำๆ ถ้า login route เองทำ 401

    - ปรับปรุง (refresh+retry): Interceptor จะพยายามเรียก `AuthRepository.refreshToken(refreshToken)` และเมื่อสำเร็จจะ retry คำขอเดิมด้วย access token ใหม่ หากยังล้มเหลวจึงทำ logout+redirect

    ตัวอย่างย่อของการทำ refresh+retry (จากโค้ดจริง):

    ```dart
    // เมื่อได้ 401:
    final stored = await sl<AuthRepository>().getStoredToken();
    if (stored != null && stored.refreshToken.isNotEmpty) {
      final refreshResult = await sl<AuthRepository>().refreshToken(stored.refreshToken);
      if (refreshResult is Success) {
        final newToken = (refreshResult as Success).data as AuthToken;
        // retry original request with new token
        originalRequest.headers['Authorization'] = 'Bearer ${newToken.accessToken}';
        final response = await sl<Dio>().fetch(originalRequest);
        return handler.resolve(response);
      }
    }
    // ถ้า refresh ล้มเหลว: ทำ logout และ redirect ไป /auth/login?redirect=...
    ```

- `lib/core/redirect_resolver.dart`

  - ฟังก์ชัน `resolveRedirect` รับพารามิเตอร์ 3 ตัว: `widgetRedirect`, `lastFromHistory`, `currentUserId`
  - กฎตรวจสอบความปลอดภัย:

    - reject ถ้าเป็น full URL (มี `://`) — ป้องกัน open-redirect
    - ต้องขึ้นต้นด้วย `/` และไม่ได้ขึ้นต้นด้วย `/auth` หรือ `/404`
    - หากเป็น encoded string (เช่น `%2Fprofile%2F123`) จะ decode ก่อนตรวจ
    - ลำดับการเลือก: `widgetRedirect` (ถ้าปลอดภัย) -> `lastFromHistory` -> `/profile/$currentUserId` (ถ้ามี) -> `/`

      ตัวอย่างย่อของ `resolveRedirect`:

      ```dart
      String resolveRedirect({String? widgetRedirect, String? lastFromHistory, String? currentUserId}) {
        // decode widgetRedirect, validate, then fallback to history/profile/root
      }
      ```

- `lib/core/route_manager.dart` (หรือไฟล์ที่มี helper สำหรับ go_router)

  - ในทุกฟังก์ชัน navigation เช่น `go`, `push`, `replace` ให้เรียก `RouteHistory.update(location)` (หรือ location ที่จะไป) ก่อนเรียก `GoRouter`
  - เหตุผล: เพื่อให้ RouteHistory เก็บหน้าล่าสุดที่ผู้ใช้เห็นจริง (ไม่ใช่หน้า login/404)

- `lib/features/auth/presentation/views/login_view.dart`

  - อ่าน `redirect` query param และส่งต่อไปยัง `resolveRedirect` เมื่อล็อกอินสำเร็จ
  - อย่า `trust` ค่า redirect ก่อนตรวจสอบ (ใช้ `resolveRedirect` เสมอ)

    ตัวอย่างการใช้งานใน `LoginView` (ย่อ):

    ```dart
    if (authViewModel.isAuthenticated) {
      final redirect = resolveRedirect(
        widgetRedirect: widget.redirectTo,
        lastFromHistory: sl<RouteHistory>().last,
        currentUserId: authViewModel.currentUser?.id,
      );

      AppRouter.go(redirect);
    }
    ```

ตัวอย่างโค้ด (สรุป)

- ตัวอย่าง `resolveRedirect` (ย่อ):

- การทดสอบ

เขียน unit test สำหรับ `resolveRedirect` อย่างน้อย 5 กรณี:

- redirect ปกติ (`/features/detail/1`) -> ส่งกลับค่าตรงๆ
- redirect encoded (`%2Ffeatures%2Fdetail%2F1`) -> decode และส่งกลับ
- open-redirect attack (`https://evil.com`) -> reject และ fallback
- redirect เป็น `/auth/*` -> reject และ fallback
- fallback ไปยัง profile เมื่อไม่มีค่า history แต่มี `currentUserId`

คำแนะนำการดีบัก

- ถ้าไม่เห็นการ redirect เมื่อ token หมดอายุ:

  - ตรวจสอบว่า `AuthInterceptor` ถูกเพิ่มเป็น `interceptor` ให้ `Dio` instance ที่ใช้งานจริง
  - ตรวจสอบว่า `LogoutUseCase` ไม่ขวางการ redirect (เช่น ทำ navigation ระหว่างการ logout)
  - เปิด log ใน `AuthInterceptor` เพื่อตรวจสอบว่ามีการจับ 401 จริงหรือไม่

- ถ้ากึ่งๆ redirect แล้ววนซ้ำ:
  - ตรวจสอบ flag ป้องกัน loop ใน `AuthInterceptor`
  - ตรวจสอบว่า `RouteHistory` ไม่เก็บหน้า `/auth/login` เป็น last

การทดสอบเชิง integration / widget

- สร้าง widget test ที่ mock `Dio` ให้ตอบ 401 เมื่อเรียก API แล้วตรวจสอบว่าสุดท้าย widget เปลี่ยนไปยังหน้าล็อกอิน
- จากนั้น mock login สำเร็จและตรวจสอบว่า router กลับไปที่หน้า redirect ที่คาดหวัง

ขั้นตอนต่อไป (ถัดไป)

- เพิ่ม widget test e2e สำหรับ flow ทั้งหมด (mock network + DI)
- พิจารณาเพิ่ม token refresh + retry ก่อน logout (ถ้าระบบมี refresh token)

เอกสารนี้เขียนเมื่อ: 21 กันยายน 2568
