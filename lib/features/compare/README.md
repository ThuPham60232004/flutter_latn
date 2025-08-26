# Compare Feature - Hướng dẫn sử dụng

## Tổng quan
Feature này cho phép người dùng tạo và quản lý các tiến trình so sánh ảnh, bao gồm:
- Tạo tiến trình mới với ảnh ban đầu
- Cập nhật tiến trình với ảnh mới để so sánh
- Xem kết quả so sánh với slider tương tác
- Xóa tiến trình không cần thiết

## API Endpoints

### 1. Tạo tiến trình mới
```
POST https://fastapi-service-748034725478.europe-west4.run.app/api/create-check-process
Body: 
- user_id: string
- image: file
```

### 2. Lấy danh sách tiến trình của user
```
GET https://fastapi-service-748034725478.europe-west4.run.app/api/user-check-process/{user_id}
```

### 3. Cập nhật tiến trình (so sánh ảnh)
```
POST https://fastapi-service-748034725478.europe-west4.run.app/api/track-check-process/{process_id}
Body:
- user_id: string
- image: file
```

### 4. Xóa tiến trình
```
DELETE https://fastapi-service-748034725478.europe-west4.run.app/api/delete-check-process/{process_id}
```

## Tính năng

### Mock Data Mode
- Khi bật toggle "Mock" trong AppBar
- Sử dụng dữ liệu giả để test giao diện
- Không gọi API thực
- Hữu ích cho development và testing

### Real API Mode
- Khi bật toggle "API" trong AppBar
- Gọi các API thực từ server
- Xử lý lỗi và loading states
- Dữ liệu thực từ database

### Giao diện kết quả so sánh
- Hiển thị ảnh "trước" và "sau" cạnh nhau
- Slider tương tác để so sánh
- Nút đóng để ẩn kết quả
- Responsive design

## Cách sử dụng

1. **Chuyển đổi giữa Mock/API**: Sử dụng toggle switch trong AppBar
2. **Tạo tiến trình**: Click FAB để chọn ảnh từ gallery
3. **Cập nhật tiến trình**: Click nút edit trên process card
4. **Xem kết quả**: Sau khi cập nhật, kết quả so sánh sẽ hiển thị
5. **Xóa tiến trình**: Click nút delete và xác nhận
6. **Làm mới dữ liệu**: Click nút refresh trong AppBar

## Error Handling
- Hiển thị thông báo lỗi rõ ràng
- Loading states cho tất cả operations
- Fallback UI khi không có dữ liệu
- Retry mechanism cho các lỗi network

## Dependencies
- `http`: Gọi API
- `image_picker`: Chọn ảnh từ gallery
- `shared_preferences`: Lưu user ID
- `flutter`: UI framework
