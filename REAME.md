# Dự Án Nhỏ: Tự Động Backup Log Từ Máy Ảo EC2 Lên AWS S3 bằng Shell Script

Dự án này em làm để tự động hóa việc lưu trữ log hệ thống từ thư mục `/var/log` của máy chủ Ubuntu lên AWS S3 Bucket. Qua bài Lab này, em muốn rèn luyện kỹ năng viết script Bash cơ bản, cách dùng AWS CLI và hiểu về phân quyền bảo mật IAM Role trên đám mây AWS.

---

## Mô Hình Hoạt Động Của Bài Lab

* **Server:** Máy ảo AWS EC2 chạy Ubuntu Server.
* **Nơi lưu file:** Amazon S3 Bucket (Đặt chế độ Private để bảo mật).
* **Cơ chế phân quyền:** Em sử dụng **AWS IAM Instance Profile (IAM Role)** gắn trực tiếp cho con EC2 để nó tự xin quyền đẩy file lên S3. Cách này giúp an toàn hơn, không bị lộ hay phải lưu file `credentials` (Access Key/Secret Key) ngay trên máy ảo.
* **Tự động hóa:** Dùng **Cronjob** của Linux để script tự chạy ngầm định kỳ.

---

## Các Điểm Bảo Mật Em Áp Dụng Trong Hệ Thống

1. **Dùng IAM Role:** Tránh hoàn toàn việc lộ tài khoản Root AWS khi share code lên GitHub.
2. **Quyền tối thiểu:** IAM Policy gán cho EC2 chỉ có quyền ghi (`s3:PutObject`) và xem bucket mục tiêu, không có quyền xóa hay can thiệp bucket khác.
3. **Bảo mật SSH cho EC2:** * Tắt tính năng đăng nhập bằng mật khẩu (chỉ cho dùng Key Pair).
   * Chặn tài khoản `root` đăng nhập trực tiếp qua SSH.
4. **Xóa file tạm:** File nén `.tar.gz` sau khi upload lên S3 thành công sẽ bị lệnh `rm` xóa ngay lập tức để tiết kiệm dung lượng ổ cứng cho máy ảo.

---

## Các Bước Cài Đặt Và Chạy Script

### 1. Tạo thư mục chứa dự án trên máy ảo EC2

mkdir -p ~/linux-backup-project
cd ~/linux-backup-project

### 2. Cấp quyền thực thi cho file script

chmod +x backup_to_s3.sh

### 3. Cài đặt Cronjob dđể script tự chạy vào 2 giờ sáng mỗi ngày

Mở trình quản lý Cronjob bằng lệnh: crontab -e


