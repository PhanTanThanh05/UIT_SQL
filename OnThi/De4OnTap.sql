CREATE DATABASE DE4
GO

USE DE4
GO

CREATE TABLE KHACHHANG (
	MaKH char(5) primary key,
	HoTen varchar(30),
	DiaChi varchar(30),
	SoDT varchar(15),
	LoaiKH varchar(10),
);

CREATE TABLE BANG_DIA (
	MaBD char(5) primary key,
	TenBD varchar(25),
	TheLoai varchar(25),
);

CREATE TABLE PHIEU_THUE (
	MaPT char(5) primary key,
	MaKH char(5) foreign key references KHACHHANG(MaKH),
	NgayThue smalldatetime,
	NgayTra smalldatetime,
	SoLuongThue int,
);

CREATE TABLE CHITIET_PM (
	MaPT char(5) foreign key references PHIEU_THUE(MaPT),
	MaBD char(5) foreign key references BANG_DIA(MaBD),
	primary key (MaPT, MaBD),
);

--2.1--
ALTER TABLE BANG_DIA
ADD CONSTRAINT CHECK_THELOAI 
CHECK (TheLoai IN (N'ca nhạc', N'phim hành động', N'phim tình cảm', N'phim hoạt hình'));

--2.2--
CREATE TRIGGER TRG_INS_UPD_PT
ON dbo.PHIEU_THUE
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MaKH CHAR(5), @SoLuong INT, @LoaiKH VARCHAR(10)

	SELECT @MaKH = MaKH, @SoLuong = SoLuongThue
	FROM inserted

	SELECT @LoaiKH = LoaiKH
	FROM dbo.KHACHHANG
	WHERE MaKH = @MaKH

	IF (@LoaiKH <> 'VIP' AND @SoLuong > 5)
	BEGIN
		RAISERROR(N'Chỉ những khách hàng thuộc loại VIP mới được thuê với số lượng băng đĩa trên 5',16,1)
		ROLLBACK TRAN
	END
	ELSE 
	BEGIN
		PRINT 'THANH CONG'
	END
END
GO

CREATE TRIGGER TRG_UPD_KH
ON dbo.KHACHHANG
FOR UPDATE
AS
BEGIN
	DECLARE @MaKH CHAR(5), @SoLuong INT, @LoaiKH VARCHAR(10)

	SELECT @MaKH = MaKH, @LoaiKH = LoaiKH
	FROM inserted

	SELECT @SoLuong = SoLuongThue
	FROM dbo.PHIEU_THUE
	WHERE MaKH = @MaKH

	IF (@LoaiKH <> 'VIP' AND @SoLuong > 5)
	BEGIN
		RAISERROR(N'Chỉ những khách hàng thuộc loại VIP mới được thuê với số lượng băng đĩa trên 5',16,1)
		ROLLBACK TRAN
	END
	ELSE 
	BEGIN
		PRINT 'THANH CONG'
	END
END
GO

--3.1--
SELECT KH.MAKH, HoTen
FROM dbo.KHACHHANG AS KH
JOIN dbo.PHIEU_THUE AS PT ON PT.MaKH = KH.MaKH
JOIN dbo.CHITIET_PM AS CT ON CT.MAPT = PT.MAPT
JOIN dbo.BANG_DIA AS BD ON BD.MaBD = CT.MaBD
WHERE TheLoai = N'Tình cảm' AND SoLuongThue > 3

--3.2--
SELECT TOP 1 WITH TIES KH.MaKH, HoTen
FROM dbo.KHACHHANG AS KH
JOIN dbo.PHIEU_THUE AS PT ON KH.MaKH = PT.MaKH
WHERE LoaiKH = 'VIP'
GROUP BY KH.MaKH, HoTen
ORDER BY SUM(SoLuongThue) DESC

--3.3--
SELECT KH.MaKH, KH.HoTen
FROM dbo.KHACHHANG AS KH
JOIN dbo.PHIEU_THUE AS PT ON PT.MaKH = KH.MaKH
JOIN dbo.CHITIET_PM AS CT ON CT.MaPT = PT.MaPT
JOIN dbo.BANG_DIA AS BD1 ON BD1.MaBD = CT.MaBD
WHERE KH.MaKH IN (
    SELECT TOP 1 WITH TIES KH2.MaKH
    FROM dbo.KHACHHANG AS KH2
    JOIN dbo.PHIEU_THUE AS PT ON PT.MaKH = KH2.MaKH
    JOIN dbo.CHITIET_PM AS CT ON CT.MaPT = PT.MaPT
    JOIN dbo.BANG_DIA AS BD2 ON BD2.MaBD = CT.MaBD
    WHERE BD1.TheLoai = BD2.TheLoai
    GROUP BY KH2.MaKH
    ORDER BY COUNT(*) DESC
)
GROUP BY KH.MaKH, KH.HoTen;