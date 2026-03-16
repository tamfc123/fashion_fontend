# 🌟 Fashion E-Commerce App

Một ứng dụng thương mại điện tử thời trang hiện đại được xây dựng với **Flutter** theo chuẩn **Clean Architecture (FCAEP)**. Dự án tập trung vào tính thẩm mỹ cao, hiệu năng mượt mà và cấu trúc code chuẩn công nghiệp.

---

## 🚀 Tính Năng Nổi Bật

### 🛒 Trải Nghiệm Mua Sắm
- **Trang chủ & Khám phá:** Giao diện tối giản, hiển thị sản phẩm theo danh mục và bộ sưu tập.
- **Chi tiết sản phẩm:** Carousel hình ảnh mượt mà, chọn biến thể (Size/Color) với Bottom Sheet hiện đại.
- **Giỏ hàng thông minh:** Cập nhật số lượng thời gian thực, huy hiệu (Badge) thông báo trực quan.
- **Yêu thích (Wishlist):** Lưu sản phẩm yêu thích với trạng thái đồng bộ toàn ứng dụng.

### 💳 Thanh Toán & Đơn Hàng
- **Cổng thanh toán Mock:** Giả lập quy trình thanh toán VNPay cực kỳ chi tiết (Success/Cancel flows).
- **Địa chỉ giao hàng:** Quản lý danh sách địa chỉ nhận hàng linh hoạt.
- **Lịch sử đơn hàng:** Theo dõi trạng thái đơn hàng (PAID, PENDING, FAILED) với giao diện timeline.

### 🔐 Bảo Mật & Tài Khoản
- **Xác thực:** Đăng ký, đăng nhập bảo mật với JWT và SharedPreferences.
- **Quyền Quản trị (Admin):** Giao diện riêng cho Admin để thêm sản phẩm mới nhanh chóng.

---

## 🛠 Tech Stack

- **Framework:** Flutter
- **State Management:** BLoC (Business Logic Component)
- **Architecture:** Clean Architecture (Presentation → Domain → Data)
- **API Communication:** GraphQL (`graphql_flutter`)
- **Dependency Injection:** GetIt
- **Local Storage:** Shared Preferences & Flutter Secure Storage

---

## 📁 Cấu Trúc Thư Mục (FCAEP Standard)

```txt
lib/
 ├── core/              # Thành phần chung (Error, Network, Utils)
 ├── features/          # Các tính năng (Auth, Product, Cart, Order, Wishlist)
 │    ├── data/         # Models, DataSources, RepositoriesImpl
 │    ├── domain/       # Entities, Repositories (Abstract), UseCases
 │    └── presentation/ # BLoC, Pages, Widgets
 └── injection_container.dart # Cài đặt Dependency Injection
```

---

## 🔧 Cài Đặt

```bash
flutter pub get
flutter run
```

