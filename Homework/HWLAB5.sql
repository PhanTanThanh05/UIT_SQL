USE HWLAB1
GO

-- Câu hỏi và ví dụ về Triggers (101-110)

-- 101. Tạo một trigger để tự động cập nhật trường NgayCapNhat trong bảng ChuyenGia mỗi khi có sự thay đổi thông tin.
ALTER TABLE ChuyenGia
ADD NgayCapNhat smalldatetime


CREATE TRIGGER TRG_UPD_NGCN 
ON dbo.ChuyenGia
FOR UPDATE
AS 
BEGIN
	DECLARE @MACN INT

	SELECT @MACN = MaChuyenGia
	FROM inserted

	UPDATE dbo.ChuyenGia
	SET NgayCapNhat = GETDATE()
	WHERE MaChuyenGia = @MACN
END
GO

-- 102. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng DuAn.
CREATE TABLE LogDuAn (
	LogID INT IDENTITY(1, 1) PRIMARY KEY,
	HanhDong CHAR(30),
	MaDuAn INT,
    TenDuAn NVARCHAR(200),
    MaCongTy INT,
	LogTime smalldatetime,
)


CREATE TRIGGER TRG_INS_UPD_LOGDA
ON dbo.DuAn
FOR INSERT, UPDATE
AS 
BEGIN
	INSERT INTO LogDuAn(HanhDong, MaDuAn, TenDuAn, MaCongTy, LogTime)
	SELECT 'INSERT/UPDATE', MaDuAn, TenDuAn, MaCongTy, GETDATE()
	FROM inserted
END
GO

CREATE TRIGGER TRG_DEL_LOGDA
ON dbo.DuAn
FOR DELETE
AS 
BEGIN
	INSERT INTO LogDuAn(HanhDong, MaDuAn, TenDuAn, MaCongTy, LogTime)
	SELECT 'DELETE', MaDuAn, TenDuAn, MaCongTy, GETDATE()
	FROM deleted
END
GO

INSERT INTO DuAn(MaDuAn, TenDuAn, MaCongTy, NgayBatDau, NgayKetThuc, TrangThai)
VALUES (6, N'Phát triển ứng dụng di động cho nhà hàng', 1, '2023-01-01', '2023-06-30', N'Hoàn thành')



-- 103. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.
CREATE TRIGGER TRG_INS_UPD_CGDA
ON dbo.ChuyenGia_DuAn
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MaChuyenGia INT, @CountDA INT

	SELECT @MaChuyenGia = MaChuyenGia
	FROM inserted

	SELECT @CountDA = COUNT(MaDuAn) 
	FROM dbo.ChuyenGia_DuAn
	WHERE MaChuyenGia = @MaChuyenGia
	GROUP BY MaChuyenGia

	IF (@CountDA > 5)
	BEGIN
		RAISERROR('1 chuyên gia không thể tham gia vào quá 5 dự án cùng lúc', 16, 1)
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		PRINT 'THANH CONG'
	END
END
GO

-- 104. Tạo một trigger để tự động cập nhật số lượng nhân viên trong bảng CongTy mỗi khi có sự thay đổi trong bảng ChuyenGia.
ALTER TABLE ChuyenGia
ADD MaCongTy INT;

ALTER TABLE ChuyenGia
ADD CONSTRAINT FK_ChuyenGia_CongTy FOREIGN KEY (MaCongTy) REFERENCES CongTy(MaCongTy);

CREATE TRIGGER TRG_INS_CG
ON dbo.ChuyenGia
FOR INSERT
AS
BEGIN
	UPDATE dbo.CongTy
    SET SoNhanVien = SoNhanVien + sub.CountCG
    FROM (
        SELECT MaCongTy, COUNT(*) AS CountCG
        FROM inserted
        GROUP BY MaCongTy
    ) AS sub
    WHERE dbo.CongTy.MaCongTy = sub.MaCongTy;
END
GO

CREATE TRIGGER TRG_DEL_CG
ON dbo.ChuyenGia
FOR DELETE
AS
BEGIN
	UPDATE dbo.CongTy
    SET SoNhanVien = SoNhanVien - sub.CountCG
    FROM (
        SELECT MaCongTy, COUNT(*) AS CountCG
        FROM deleted
        GROUP BY MaCongTy
    ) AS sub
    WHERE dbo.CongTy.MaCongTy = sub.MaCongTy;
END
GO

-- 105. Tạo một trigger để ngăn chặn việc xóa các dự án đã hoàn thành.
CREATE TRIGGER TRG_DEL_DAHT
ON dbo.DuAn	
FOR DELETE
AS
BEGIN
	DECLARE @MaDuAn INT, @TT NVARCHAR(50)

	SELECT @MaDuAn
	FROM deleted

	SELECT @TT = TrangThai
	FROM dbo.DuAn
	WHERE MaDuAn = @MaDuAn

	IF (@TT = N'Hoàn thành')
	BEGIN
		RAISERROR('Không thể xóa dự án đã hoàn thành',16, 1)
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		PRINT 'XOA THANH CONG'
	END
END
GO


-- 106. Tạo một trigger để tự động cập nhật cấp độ kỹ năng của chuyên gia khi họ tham gia vào một dự án mới.


-- 107. Tạo một trigger để ghi log mỗi khi có sự thay đổi cấp độ kỹ năng của chuyên gia.
CREATE TABLE LogCapDoKyNang (
	LogID INT IDENTITY(1,1) PRIMARY KEY,
	MaChuyenGia INT NOT NULL,
	MaKyNang INT,
	CapDoCu INT,
	CapDoMoi INT,
	ThoiGianThayDoi smalldatetime,
);

CREATE TRIGGER TRG_UPD_CAPDO
ON dbo.ChuyenGia_KyNang
FOR UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM inserted I
		JOIN deleted D ON I.MaChuyenGia = D.MaChuyenGia
		WHERE I.CapDo <> D.CapDo AND I.MaKyNang = D.MaKyNang
	)
	BEGIN
		INSERT INTO LogCapDoKyNang(MaChuyenGia, MaKyNang, CapDoCu, CapDoMoi, ThoiGianThayDoi)
		SELECT D.MaChuyenGia, D.MaKyNang, D.CapDo, I.CapDo, GETDATE()
		FROM inserted I
		JOIN deleted D ON I.MaChuyenGia = D.MaChuyenGia
	END
END
GO

-- 108. Tạo một trigger để đảm bảo rằng ngày kết thúc của dự án luôn lớn hơn ngày bắt đầu.
ALTER TRIGGER TRG_INS_NgayKT
ON dbo.DuAn
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @NGBD smalldatetime, @NGKT smalldatetime

	SELECT @NGBD = NgayBatDau, @NGKT = NgayKetThuc
	FROM inserted

	IF (@NGBD > @NGKT)
	BEGIN
		RAISERROR('Ngày kết thúc của dự án luôn lớn hơn ngày bắt đầu', 16, 1)
		ROLLBACK TRAN
	END
	ELSE 
	BEGIN
		PRINT 'THANH CONG'
	END
END
GO

-- 109. Tạo một trigger để tự động xóa các bản ghi liên quan trong bảng ChuyenGia_KyNang khi một kỹ năng bị xóa.


-- 110. Tạo một trigger để đảm bảo rằng một công ty không thể có quá 10 dự án đang thực hiện cùng một lúc.
CREATE TRIGGER TRG_INS_UPD_CTYDA
ON dbo.DuAn
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MaCongTy INT, @Count INT

	SELECT @MaCongTy = MaCongTy 
	FROM inserted

	SELECT @Count = COUNT(MaDuAn)
	FROM dbo.DuAn
	WHERE TrangThai = N'Đang thực hiện'
		AND MaCongTy = @MaCongTy
	GROUP BY MaCongTy

	IF (@Count > 10)
	BEGIN
		RAISERROR('Một công ty không thể có quá 10 dự án đang thực hiện cùng một lúc.',16, 1)
		ROLLBACK TRAN
	END
END
GO

-- Câu hỏi và ví dụ về Triggers bổ sung (123-135)

-- 123. Tạo một trigger để tự động cập nhật lương của chuyên gia dựa trên cấp độ kỹ năng và số năm kinh nghiệm.


-- 124. Tạo một trigger để tự động gửi thông báo khi một dự án sắp đến hạn (còn 7 ngày).
-- Tạo bảng ThongBao nếu chưa có


-- 125. Tạo một trigger để ngăn chặn việc xóa hoặc cập nhật thông tin của chuyên gia đang tham gia dự án.


-- 126. Tạo một trigger để tự động cập nhật số lượng chuyên gia trong mỗi chuyên ngành.

-- Tạo bảng ThongKeChuyenNganh nếu chưa có

-- 127. Tạo một trigger để tự động tạo bản sao lưu của dự án khi nó được đánh dấu là hoàn thành.

-- Tạo bảng DuAnHoanThanh nếu chưa có


-- 128. Tạo một trigger để tự động cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.



-- 129. Tạo một trigger để tự động phân công chuyên gia vào dự án dựa trên kỹ năng và kinh nghiệm.


-- 130. Tạo một trigger để tự động cập nhật trạng thái "bận" của chuyên gia khi họ được phân công vào dự án mới.



-- 131. Tạo một trigger để ngăn chặn việc thêm kỹ năng trùng lặp cho một chuyên gia.



-- 132. Tạo một trigger để tự động tạo báo cáo tổng kết khi một dự án kết thúc.


-- 133. Tạo một trigger để tự động cập nhật thứ hạng của công ty dựa trên số lượng dự án hoàn thành và điểm đánh giá.



-- 133. (tiếp tục) Tạo một trigger để tự động cập nhật thứ hạng của công ty dựa trên số lượng dự án hoàn thành và điểm đánh giá.


-- 134. Tạo một trigger để tự động gửi thông báo khi một chuyên gia được thăng cấp (dựa trên số năm kinh nghiệm).


-- 135. Tạo một trigger để tự động cập nhật trạng thái "khẩn cấp" cho dự án khi thời gian còn lại ít hơn 10% tổng thời gian dự án.


-- 136. Tạo một trigger để tự động cập nhật số lượng dự án đang thực hiện của mỗi chuyên gia.


-- 137. Tạo một trigger để tự động tính toán và cập nhật tỷ lệ thành công của công ty dựa trên số dự án hoàn thành và tổng số dự án.

-- 138. Tạo một trigger để tự động ghi log mỗi khi có thay đổi trong bảng lương của chuyên gia.

-- 139. Tạo một trigger để tự động cập nhật số lượng chuyên gia cấp cao trong mỗi công ty.


-- 140. Tạo một trigger để tự động cập nhật trạng thái "cần bổ sung nhân lực" cho dự án khi số lượng chuyên gia tham gia ít hơn yêu cầu.


