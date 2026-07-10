#!/bin/bash

# PROJECT: TỰ ĐỘNG HÓA BACKUP LOG HỆ THỐNG LINUX LÊN AWS S3
# TÊN: NGUYỄN VÕ NHẬT THIÊN - VỊ TRÍ: SYSTEM ENGINEER INTERN

# 1. Khai báo các biến
BACKUP_DIR="/var/log"
DEST_DIR="/home/thienaws/linux-backup-project"
BUCKET_NAME="thien-demo-s3-v12"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="system_logs_$TIMESTAMP.tar.gz"

echo "============================================="
echo "STDOUT: Bắt đầu tiến trình backup vào lúc: $(date)"

# 2. Tạo file nén .tar.gz từ thư mục log
# Lệnh tar -czf: c (create), z (gzip compression), f (file name)
echo "STDOUT: Đang tiến hành nén thư mục $BACKUP_DIR..."
sudo tar -czf $DEST_DIR/$BACKUP_NAME -C $BACKUP_DIR . 2>/dev/null

# Kiểm tra nén tar có chạy không (mã lỗi = 0)
if [ $? -eq 0 ]; then
	echo "STDOUT: Nén file thành công: $BACKUP_NAME"
else
	echo "STDERR: Có lỗi xảy ra trong quá trình nén file!"
	exit 1
fi

# 3. Đẩy file nén lên S3
echo "STDOUT: Đang upload file lên AWS S3 bucket: $BUCKET_NAME..."
aws s3 cp $DEST_DIR/$BACKUP_NAME s3://$BUCKET_NAME/

# Kiểm tra upload s3 có thành công không
if [ $? -eq 0 ]; then
	echo "STDOUT: Upload lên S3 thành công!"
	
	# 4. Dọn dẹp ổ cứng: Xóa file nén tạm thời trên EC2 để tiết kiệm dung lượng
	echo "STDOUT: Đang xóa file nén tạm thời trên ổ đĩa cục bộ..."
	sudo rm -f $DEST_DIR/$BACKUP_NAME
	echo "STDOUT: Tiến trình hoàn thành!"
	echo "================================================================"
else
	echo "STDERR: Upload lên S3 thất bại!"
	exit 1
fi
