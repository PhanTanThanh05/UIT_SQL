CREATE DATABASE QuanLyHocVu
GO

USE QuanLyHocVu
GO
--I--
CREATE TABLE LOP
(
MALOP CHAR(3) PRIMARY KEY,
TENLOP VARCHAR(40),
TRGLOP CHAR(5),--FOREIGN KEY REFERENCES HOCVIEN(MAHV)
SISO TINYINT,
MAGVCN CHAR(4),
)
CREATE TABLE MONHOC
(
MAMH VARCHAR(10) PRIMARY KEY,
TENMH VARCHAR(40),
TCLT TINYINT,
TCTH TINYINT,
MAKHOA VARCHAR(4),--FOREIGN KEY REFERENCES KHOA(MAKHOA)
)
CREATE TABLE HOCVIEN
(
MAHV CHAR(5) PRIMARY KEY,
HO VARCHAR(40),
TEN VARCHAR(10),
NGSINH SMALLDATETIME,
GIOITINH VARCHAR(3),
NOISINH VARCHAR(40),
MALOP CHAR(3)
)
CREATE TABLE KHOA
(
MAKHOA VARCHAR(4) PRIMARY KEY,
TENKHOA VARCHAR(40),
NGTLAP SMALLDATETIME,
TRGKHOA CHAR(4), --FOREIGN KEY REFERENCES GIAOVIEN(MAGV)
)
CREATE TABLE DIEUKIEN
(
MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
MAMH_TRUOC VARCHAR(10),
CONSTRAINT DK_MH PRIMARY KEY(MAMH,MAMH_TRUOC)
)
CREATE TABLE GIAOVIEN
(
MAGV CHAR(4) PRIMARY KEY,
HOTEN VARCHAR(40),
HOCVI VARCHAR(10),
HOCHAM VARCHAR(10),
GIOITINH VARCHAR(3),
NGSINH SMALLDATETIME,
NGVL SMALLDATETIME,
HESO NUMERIC(4,2),
MUCLUONG MONEY,
MAKHOA VARCHAR(4)
)
CREATE TABLE GIANGDAY
(
MALOP CHAR(3) FOREIGN KEY REFERENCES LOP(MALOP),
MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
MAGV CHAR(4) FOREIGN KEY REFERENCES GIAOVIEN(MAGV),
HOCKY TINYINT,
NAM SMALLINT,
TUNGAY SMALLDATETIME,
DENNGAY SMALLDATETIME,
CONSTRAINT KQGIANGDAY PRIMARY KEY(MALOP,MAMH)
)
CREATE TABLE KETQUATHI
(
MAHV CHAR(5) FOREIGN KEY REFERENCES HOCVIEN(MAHV),
MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
LANTHI TINYINT,
NGTHI SMALLDATETIME,
DIEM NUMERIC(4,2),
KQUA VARCHAR(10),
CONSTRAINT KQT PRIMARY KEY(MAHV,MAMH,LANTHI)
)

ALTER TABLE LOP ADD	CONSTRAINT FK_MAGVCN FOREIGN KEY (MAGVCN) REFERENCES GIAOVIEN(MAGV)
ALTER TABLE GIAOVIEN ADD CONSTRAINT FK_MAKHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA)
ALTER TABLE DIEUKIEN ADD CONSTRAINT FK_MAMH_TRUOC FOREIGN KEY (MAMH_TRUOC) REFERENCES MONHOC(MAMH)

ALTER TABLE HOCVIEN ADD GHICHU VARCHAR(50), DIEMTB NUMERIC(4,2), XEPLOAI VARCHAR(10)

--3--
ALTER TABLE HOCVIEN ADD CONSTRAINT CHECK_GT CHECK(GIOITINH IN('Nam', 'Nu'))
ALTER TABLE GIAOVIEN ADD CONSTRAINT GHECK_GTGV CHECK(GIOITINH IN('Nam','Nu'))

--4--
ALTER TABLE KETQUATHI ADD CONSTRAINT CHECK_DIEM 
CHECK((DIEM BETWEEN 0 AND 10) AND (DIEM = ROUND(DIEM, 2)))

--5--
ALTER TABLE KETQUATHI ADD CONSTRAINT CHECK_KQ 
CHECK(
	(KQUA = 'Dat' AND DIEM BETWEEN 5 AND 10) OR (KQUA = 'Khong dat' AND DIEM < 5)
)	


--6--
ALTER TABLE KETQUATHI ADD CONSTRAINT CHECK_LANTHI 
CHECK(LANTHI <= 3)

--7--
ALTER TABLE GIANGDAY ADD CONSTRAINT CHECK_HK
CHECK(HOCKY BETWEEN 1 AND 3)

--8--
ALTER TABLE GIAOVIEN ADD CONSTRAINT CHECK_HV
CHECK(HOCVI IN('CN', 'KS', 'Ths', 'TS', 'PTS'))

--9--
CREATE TRIGGER TRG_INS_UPD_LopTruong
ON dbo.LOP
FOR INSERT, UPDATE
AS
BEGIN
	IF NOT EXISTS (
		SELECT *
		FROM inserted AS L 
		JOIN dbo.HOCVIEN AS HV ON L.TRGLOP = HV.MAHV AND L.MAGVCN = HV.MALOP
	)
		BEGIN 
			PRINT N'Lớp trường phải là học viên của lớp đó'
			ROLLBACK TRAN
		END
END
GO


--10--
CREATE TRIGGER TRG_INS_UPD_TruongKhoa
ON dbo.KHOA
FOR INSERT, UPDATE
AS 
BEGIN
	IF NOT EXISTS (
		SELECT *
		FROM inserted AS K
		JOIN dbo.GIAOVIEN AS GV
		ON K.TRGKHOA = GV.MAGV AND K.MAKHOA = GV.MAKHOA
		WHERE HOCVI IN('TS', 'PTS')
	)
		BEGIN
			PRINT N'Trưởng khoa phải là TS hoặc PTS'
			ROLLBACK TRAN
		END
END
GO

--Nhập dữ liệu--
SET DATEFORMAT DMY

INSERT INTO LOP VALUES('K11','Lop 1 khoa 1','K1108',11,'GV07')
INSERT INTO LOP VALUES('K12','Lop 2 khoa 1','K1205',12,'GV09')
INSERT INTO LOP VALUES('K13','Lop 3 khoa 1','K1305',12,'GV14')

-- NHAP DU LIEU KHOA --
INSERT INTO KHOA VALUES('KHMT','Khoa hoc may tinh','7/6/2005','GV01')
INSERT INTO KHOA VALUES('HTTT','He thong thong tin','7/6/2005','GV02')
INSERT INTO KHOA VALUES('CNPM','Cong nghe phan mem','7/6/2005','GV04')
INSERT INTO KHOA VALUES('MTT','Mang va truyen thong','20/10/2005','GV03')
INSERT INTO KHOA VALUES('KTMT','Ky thuat may tinh','20/12/2005',Null)

-- NHAP DU LIEU GIAOVIEN --
INSERT INTO GIAOVIEN VALUES('GV01','Ho Thanh Son','PTS','GS','Nam','2/5/1950','11/1/2004',5,2250000,'KHMT')
INSERT INTO GIAOVIEN VALUES('GV02','Tran Tam Thanh','TS','PGS','Nam','17/12/1965','20/4/2004',4.5,2025000,'HTTT')
INSERT INTO GIAOVIEN VALUES('GV03','Do Nghiem Phung','TS','GS','Nu','1/8/1950','23/9/2004',4,1800000,'CNPM')
INSERT INTO GIAOVIEN VALUES('GV04','Tran Nam Son','TS','PGS','Nam','22/2/1961','12/1/2005',4.5,2025000,'KTMT')
INSERT INTO GIAOVIEN VALUES('GV05','Mai Thanh Danh','ThS','GV','Nam','12/3/1958','12/1/2005',3,1350000,'HTTT')
INSERT INTO GIAOVIEN VALUES('GV06','Tran Doan Hung','TS','GV','Nam','11/3/1953','12/1/2005',4.5,2025000,'KHMT')
INSERT INTO GIAOVIEN VALUES('GV07','Nguyen Minh Tien','ThS','GV','Nam','23/11/1971','1/3/2005',4,1800000,'KHMT')
INSERT INTO GIAOVIEN VALUES('GV08','Le Thi Tran','KS',Null,'Nu','26/3/1974','1/3/2005',1.69,760500,'KHMT')
INSERT INTO GIAOVIEN VALUES('GV09','Nguyen To Lan','ThS','GV','Nu','31/12/1966','1/3/2005',4,1800000,'HTTT')
INSERT INTO GIAOVIEN VALUES('GV10','Le Tran Anh Loan','KS',Null,'Nu','17/7/1972','1/3/2005',1.86,837000,'CNPM')
INSERT INTO GIAOVIEN VALUES('GV11','Ho Thanh Tung','CN','GV','Nam','12/1/1980','15/5/2005',2.67,1201500,'MTT')
INSERT INTO GIAOVIEN VALUES('GV12','Tran Van Anh','CN',Null,'Nu','29/3/1981','15/5/2005',1.69,760500,'CNPM')
INSERT INTO GIAOVIEN VALUES('GV13','Nguyen Linh Dan','CN',Null,'Nu','23/5/1980','15/5/2005',1.69,760500,'KTMT')
INSERT INTO GIAOVIEN VALUES('GV14','Truong Minh Chau','ThS','GV','Nu','30/11/1976','15/5/2005',3,1350000,'MTT')
INSERT INTO GIAOVIEN VALUES('GV15','Le Ha Thanh','ThS','GV','Nam','4/5/1978','15/5/2005',3,1350000,'KHMT')

-- NHAP DU LIEU MONHOC --
INSERT INTO MONHOC VALUES('THDC','Tin hoc dai cuong',4,1,'KHMT')
INSERT INTO MONHOC VALUES('CTRR','Cau truc roi rac',5,0,'KHMT')
INSERT INTO MONHOC VALUES('CSDL','Co so du lieu',3,1,'HTTT')
INSERT INTO MONHOC VALUES('CTDLGT','Cau truc du lieu va giai thuat',3,1,'KHMT')
INSERT INTO MONHOC VALUES('PTTKTT','Phan tich thiet ke thuat toan',3,0,'KHMT')
INSERT INTO MONHOC VALUES('DHMT','Do hoa may tinh',3,1,'KHMT')
INSERT INTO MONHOC VALUES('KTMT','Kien truc may tinh',3,0,'KTMT')
INSERT INTO MONHOC VALUES('TKCSDL','Thiet ke co so du lieu',3,1,'HTTT')
INSERT INTO MONHOC VALUES('PTTKHTTT','Phan tich thiet ke he thong thong tin',4,1,'HTTT')
INSERT INTO MONHOC VALUES('HDH','He dieu hanh',4,0,'KTMT')
INSERT INTO MONHOC VALUES('NMCNPM','Nhap mon cong nghe phan mem',3,0,'CNPM')
INSERT INTO MONHOC VALUES('LTCFW','Lap trinh C for win',3,1,'CNPM')
INSERT INTO MONHOC VALUES('LTHDT','Lap trinh huong doi tuong',3,1,'CNPM')

-- NHAP DU LIEU GIANGDAY --
INSERT INTO GIANGDAY VALUES ('K11','THDC','GV07',1,2006,'2/1/2006','12/5/2006')
INSERT INTO GIANGDAY VALUES ('K12','THDC','GV06',1,2006,'2/1/2006','12/5/2006')
INSERT INTO GIANGDAY VALUES ('K13','THDC','GV15',1,2006,'2/1/2006','12/5/2006')
INSERT INTO GIANGDAY VALUES ('K11','CTRR','GV02',1,2006,'9/1/2006','17/5/2006')
INSERT INTO GIANGDAY VALUES ('K12','CTRR','GV02',1,2006,'9/1/2006','17/5/2006')
INSERT INTO GIANGDAY VALUES ('K13','CTRR','GV08',1,2006,'9/1/2006','17/5/2006')
INSERT INTO GIANGDAY VALUES ('K11','CSDL','GV05',2,2006,'1/6/2006','15/7/2006')
INSERT INTO GIANGDAY VALUES ('K12','CSDL','GV09',2,2006,'1/6/2006','15/7/2006')
INSERT INTO GIANGDAY VALUES ('K13','CTDLGT','GV15',2,2006,'1/6/2006','15/7/2006')
INSERT INTO GIANGDAY VALUES ('K13','CSDL','GV05',3,2006,'1/8/2006','15/12/2006')
INSERT INTO GIANGDAY VALUES ('K13','DHMT','GV07',3,2006,'1/8/2006','15/12/2006')
INSERT INTO GIANGDAY VALUES ('K11','CTDLGT','GV15',3,2006,'1/8/2006','15/12/2006')
INSERT INTO GIANGDAY VALUES ('K12','CTDLGT','GV15',3,2006,'1/8/2006','15/12/2006')
INSERT INTO GIANGDAY VALUES ('K11','HDH','GV04',1,2007,'2/1/2007','18/2/2007')
INSERT INTO GIANGDAY VALUES ('K12','HDH','GV04',1,2007,'2/1/2007','20/3/2007')
INSERT INTO GIANGDAY VALUES ('K11','DHMT','GV07',1,2007,'18/2/2007','20/3/2007')

-- NHAP DU LIEU DIEUKIEN --
INSERT INTO DIEUKIEN VALUES ('CSDL','CTRR')
INSERT INTO DIEUKIEN VALUES ('CSDL','CTDLGT')
INSERT INTO DIEUKIEN VALUES ('CTDLGT','THDC')
INSERT INTO DIEUKIEN VALUES ('PTTKTT','THDC')
INSERT INTO DIEUKIEN VALUES ('PTTKTT','CTDLGT')
INSERT INTO DIEUKIEN VALUES ('DHMT','THDC')
INSERT INTO DIEUKIEN VALUES ('LTHDT','THDC')
INSERT INTO DIEUKIEN VALUES ('PTTKHTTT','CSDL')

-- NHAP DU LIEU KETQUATHI --
INSERT INTO KETQUATHI VALUES ('K1101','CSDL',1,'20/7/2006',10,'Dat')
INSERT INTO KETQUATHI VALUES ('K1101','CTDLGT',1,'28/12/2006',9,'Dat')
INSERT INTO KETQUATHI VALUES ('K1101','THDC',1,'20/5/2006',9,'Dat')
INSERT INTO KETQUATHI VALUES ('K1101','CTRR',1,'13/5/2006',9.5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1102','CSDL',1,'20/7/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1102','CSDL',2,'27/7/2006',4.25,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1102','CSDL',3,'10/8/2006',4.5,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1102','CTDLGT',1,'28/12/2006',4.5,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1102','CTDLGT',2,'5/1/2007',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1102','CTDLGT',3,'15/1/2007',6,'Dat')
INSERT INTO KETQUATHI VALUES ('K1102','THDC',1,'20/5/2006',5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1102','CTRR',1,'13/5/2006',7,'Dat')
INSERT INTO KETQUATHI VALUES ('K1103','CSDL',1,'20/7/2006',3.5,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1103','CSDL',2,'27/7/2006',8.25,'Dat')
INSERT INTO KETQUATHI VALUES ('K1103','CTDLGT',1,'28/12/2006',7,'Dat')
INSERT INTO KETQUATHI VALUES ('K1103','THDC',1,'20/5/2006',8,'Dat')
INSERT INTO KETQUATHI VALUES ('K1103','CTRR',1,'13/5/2006',6.5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1104','CSDL',1,'20/7/2006',3.75,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1104','CTDLGT',1,'28/12/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1104','THDC',1,'20/5/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1104','CTRR',1,'13/5/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1104','CTRR',2,'20/5/2006',3.5,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1104','CTRR',3,'30/6/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1201','CSDL',1,'20/7/2006',6,'Dat')
INSERT INTO KETQUATHI VALUES ('K1201','CTDLGT',1,'28/12/2006',5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1201','THDC',1,'20/5/2006',8.5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1201','CTRR',1,'13/5/2006',9,'Dat')
INSERT INTO KETQUATHI VALUES ('K1202','CSDL',1,'20/7/2006',8,'Dat')
INSERT INTO KETQUATHI VALUES ('K1202','CTDLGT',1,'28/12/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1202','CTDLGT',2,'5/1/2007',5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1202','THDC',1,'20/5/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1202','THDC',2,'27/5/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1202','CTRR',1,'13/5/2006',3,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1202','CTRR',2,'20/5/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1202','CTRR',3,'30/6/2006',6.25,'Dat')
INSERT INTO KETQUATHI VALUES ('K1203','CSDL',1,'20/7/2006',9.25,'Dat')
INSERT INTO KETQUATHI VALUES ('K1203','CTDLGT',1,'28/12/2006',9.5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1203','THDC',1,'20/5/2006',10,'Dat')
INSERT INTO KETQUATHI VALUES ('K1203','CTRR',1,'13/5/2006',10,'Dat')
INSERT INTO KETQUATHI VALUES ('K1204','CSDL',1,'20/7/2006',8.5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1204','CTDLGT',1,'28/12/2006',6.75,'Dat')
INSERT INTO KETQUATHI VALUES ('K1204','THDC',1,'20/5/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1204','CTRR',1,'13/5/2006',6,'Dat')
INSERT INTO KETQUATHI VALUES ('K1301','CSDL',1,'20/12/2006',4.25,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1301','CTDLGT',1,'25/7/2006',8,'Dat')
INSERT INTO KETQUATHI VALUES ('K1301','THDC',1,'20/5/2006',7.75,'Dat')
INSERT INTO KETQUATHI VALUES ('K1301','CTRR',1,'13/5/2006',8,'Dat')
INSERT INTO KETQUATHI VALUES ('K1302','CSDL',1,'20/12/2006',6.75,'Dat')
INSERT INTO KETQUATHI VALUES ('K1302','CTDLGT',1,'25/7/2006',5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1302','THDC',1,'20/5/2006',8,'Dat')
INSERT INTO KETQUATHI VALUES ('K1302','CTRR',1,'13/5/2006',8.5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1303','CSDL',1,'20/12/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1303','CTDLGT',1,'25/7/2006',4.5,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1303','CTDLGT',2,'7/8/2006',4,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1303','CTDLGT',3,'15/8/2006',4.25,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1303','THDC',1,'20/5/2006',4.5,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1303','CTRR',1,'13/5/2006',3.25,'Khong Dat')
INSERT INTO KETQUATHI VALUES ('K1303','CTRR',2,'20/5/2006',5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1304','CSDL',1,'20/12/2006',7.75,'Dat')
INSERT INTO KETQUATHI VALUES ('K1304','CTDLGT',1,'25/7/2006',9.75,'Dat')
INSERT INTO KETQUATHI VALUES ('K1304','THDC',1,'20/5/2006',5.5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1304','CTRR',1,'13/5/2006',5,'Dat')
INSERT INTO KETQUATHI VALUES ('K1305','CSDL',1,'20/12/2006',9.25,'Dat')
INSERT INTO KETQUATHI VALUES ('K1305','CTDLGT',1,'25/7/2006',10,'Dat')
INSERT INTO KETQUATHI VALUES ('K1305','THDC',1,'20/5/2006',8,'Dat')
INSERT INTO KETQUATHI VALUES ('K1305','CTRR',1,'13/5/2006',10,'Dat')


INSERT INTO HOCVIEN VALUES('K1101','Nguyen Van','A','27/1/1986','Nam','TpHCM','K11')
INSERT INTO HOCVIEN VALUES('K1102','Tran Ngoc','Han','14/3/1986','Nu','Kien Giang','K11')
INSERT INTO HOCVIEN VALUES('K1103','Ha Duy','Lap','18/4/1986','Nam','Nghe An','K11')
INSERT INTO HOCVIEN VALUES('K1104','Tran Ngoc','Linh','30/3/1986','Nu','Tay Ninh','K11')
INSERT INTO HOCVIEN VALUES('K1105','Tran Minh','Long','27/2/1986','Nam','TpHCM','K11')
INSERT INTO HOCVIEN VALUES('K1106','Le Nhat','Minh','24/1/1986','Nam','TpHCM','K11')
INSERT INTO HOCVIEN VALUES('K1107','Nguyen Nhu','Nhut','27/1/1986','Nam','Ha Noi','K11')
INSERT INTO HOCVIEN VALUES('K1108','Nguyen Manh','Tam','27/2/1986','Nam','Kien Giang','K11')
INSERT INTO HOCVIEN VALUES('K1109','Phan Thi Thanh','Tam','27/1/1986','Nu','Vinh Long','K11')
INSERT INTO HOCVIEN VALUES('K1110','Le Hoai','Thuong','5/2/1986','Nu','Can Tho','K11')
INSERT INTO HOCVIEN VALUES('K1111','Le Ha','Vinh','25/12/1986','Nam','Vinh Long','K11')
INSERT INTO HOCVIEN VALUES('K1201','Nguyen Van','B','11/2/1986','Nam','TpHCM','K12')
INSERT INTO HOCVIEN VALUES('K1202','Nguyen Thi Kim','Duyen','18/1/1986','Nu','TpHCM','K12')
INSERT INTO HOCVIEN VALUES('K1203','Tran Thi Kim','Duyen','17/9/1986','Nu','TpHCM','K12')
INSERT INTO HOCVIEN VALUES('K1204','Truong My','Hanh','19/5/1986','Nu','Dong Nai','K12')
INSERT INTO HOCVIEN VALUES('K1205','Nguyen Thanh','Nam','17/4/1986','Nam','TpHCM','K12')
INSERT INTO HOCVIEN VALUES('K1206','Nguyen Thi Truc','Thanh','4/3/1986','Nu','Kien Giang','K12')
INSERT INTO HOCVIEN VALUES ('K1207','Tran Thi Bich','Thuy','8/2/1986','Nu','Nghe An','K12')
INSERT INTO HOCVIEN VALUES ('K1208','Huynh Thi Kim','Trieu','8/4/1986 ','Nu ','Tay Ninh ','K12')
INSERT INTO HOCVIEN VALUES ('K1209','Pham Thanh','Trieu','23/2/1986','Nam','TpHCM','K12')
INSERT INTO HOCVIEN VALUES ('K1210','Ngo Thanh','Tuan','14/2/1986','Nam ','TpHCM','K12')
INSERT INTO HOCVIEN VALUES ('K1211','Do Thi','Xuan','9/3/1986','Nu','Ha Noi','K12')
INSERT INTO HOCVIEN VALUES ('K1212','Le Thi Phi',' Yen','12/3/1986','Nu',' TpHCM','K12')
INSERT INTO HOCVIEN VALUES ('K1301','Nguyen Thi Kim','Cuc','9/6/1986','Nu','Kien Giang','K13')
INSERT INTO HOCVIEN VALUES ('K1302','Truong Thi My','Hien','18/3/1986','Nu','Nghe An','K13')
INSERT INTO HOCVIEN VALUES ('K1303','Le Duc','Hien','21/3/1986','Nam','Tay Ninh','K13')
INSERT INTO HOCVIEN VALUES ('K1304','Le Quang','Hien','18/4/1986','Nam','TpHCM','K13')
INSERT INTO HOCVIEN VALUES ('K1305','Le Thi','Huong','27/3/1986','Nu','TpHCM','K13')
INSERT INTO HOCVIEN VALUES ('K1306','Nguyen Thai','Huu','30/3/1986','Nam','Ha Noi','K13')
INSERT INTO HOCVIEN VALUES ('K1307','Tran Minh','Man','28/5/1986 ','Nam ','TpHCM','K13')
INSERT INTO HOCVIEN VALUES ('K1308','Nguyen Hieu','Nghia','8/4/1986 ','Nam','Kien Giang','K13')
INSERT INTO HOCVIEN VALUES ('K1309','Nguyen Trung','Nghia','18/1/1987','Nam','Nghe An','K13')
INSERT INTO HOCVIEN VALUES ('K1310','Tran Thi Hong','Tham','22/4/1986','Nu','Tay Ninh','K13')
INSERT INTO HOCVIEN VALUES ('K1311','Tran Minh','Thuc','4/4/1986','Nam','TpHCM','K13')
INSERT INTO HOCVIEN VALUES ('K1312','Nguyen Thi Kim','Yen','7/9/1986','Nu','TpHCM','K13')


--11-- Học viên ít nhất 18 tuổi
ALTER TABLE HOCVIEN
ADD CONSTRAINT CHECK_TUOI CHECK(YEAR(GETDATE()) - YEAR(NGSINH) >= 18)

--12-- Giảng dạy mà ngày bắt đầu < ngày kết thúc
ALTER TABLE GIANGDAY
ADD CONSTRAINT CHECK_NGAY CHECK(TUNGAY < DENNGAY)

--13-- Giáo viên khi vào làm ít nhất 22 tuổi
ALTER TABLE GIAOVIEN
ADD CONSTRAINT CHECK_TUOIVL CHECK(YEAR(NGVL) - YEAR(NGSINH) >= 22)

--14-- Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không quá 3.
ALTER TABLE MONHOC 
ADD CONSTRAINT CHECK_TC CHECK(ABS(TCLT-TCTH) <= 3)

--15-- Học viên chỉ được thi một môn học nào đó khi lớp của học viên đã học xong môn học này.
CREATE TRIGGER TRG_INS_UPD_HVTHI
ON dbo.KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (
		SELECT *
		FROM inserted AS KQ
		JOIN dbo.GIANGDAY AS GD ON KQ.MAMH = GD.MAMH
		WHERE DENNGAY > NGTHI
	)
		BEGIN 
			PRINT N'Học viên chỉ được thi môn này khi học xong môn học'
			ROLLBACK TRAN
		END
END
GO

--16--
CREATE TRIGGER TRG_INS_UPD_MHMoiKy
ON dbo.GIANGDAY
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @SoLuongMH INT, @MaLop CHAR(10), @HocKy INT, @Nam INT, @SoMH_HT INT

	SELECT @SoLuongMH = COUNT(MAMH), @MaLop = MALOP, @HocKy = HOCKY, @Nam = NAM
	FROM inserted
	GROUP BY MALOP, HOCKY, NAM

	SELECT @SoMH_HT = COUNT(MAMH)
	FROM dbo.GIANGDAY
	WHERE MALOP = @MaLop AND HOCKY = @HocKy AND NAM = @Nam
	GROUP BY MALOP, HOCKY, NAM

	IF (@SoLuongMH + @SoMH_HT > 3)
	BEGIN
		PRINT N'Số lượng môn học mỗi kỳ phải nhở hơn 3'
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		PRINT N'THANH CONG'
	END
END
GO

--17--
CREATE TRIGGER TRG_INS_UPD_SISO
ON dbo.LOP
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @SiSo INT, @SLHV INT, @MaLop CHAR(10), @TONGSL INT
	--lay ra ma lop tu inserted
	SELECT @MaLop = MALOP
	FROM inserted
	--lay ra si so cua lop do
	SELECT @SiSo = SISO
	FROM dbo.LOP 
	WHERE @MaLop = MALOP
	--DEM SLHV
	SELECT @SLHV = COUNT(MAHV)
	FROM dbo.HOCVIEN
	WHERE MALOP = @MaLop
	GROUP BY MALOP

	IF (@SiSo <> @SLHV)
	BEGIN
		PRINT N'Loi! So luong hoc vien phai bang si so'
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		PRINT N'THEM THANH CONG'
	END
END
GO

--18--
CREATE TRIGGER TRG_INS_UPD_DK
ON dbo.DIEUKIEN
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MaMH CHAR (10), @MaMH_Truoc CHAR(10)

	SELECT @MaMH = MAMH, @MaMH_Truoc = MAMH_TRUOC
	FROM inserted

	IF EXISTS (
		SELECT *
		FROM dbo.DIEUKIEN
		WHERE (MAMH = @MaMH AND MAMH_TRUOC = @MaMH_Truoc)
			OR 
				(MAMH = @MaMH_Truoc AND MAMH_TRUOC = @MaMH)
			)
	BEGIN
		PRINT N'LOI! SAI DIEU KIEN'
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		PRINT N'THANH CONG'
	END
END
GO

--19--
CREATE TRIGGER TRG_INS_UPD_GV
ON dbo.GIAOVIEN
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @HocVi CHAR(10), @HocHam CHAR(10), @HeSo NUMERIC(4,2), @ML MONEY, @MLHT MONEY

	SELECT @HocVi = HOCVI, @HocHam = HOCHAM, @HeSo = HESO, @ML = MUCLUONG
	FROM inserted
	
	SELECT @MLHT = MUCLUONG
	FROM dbo.GIAOVIEN
	WHERE HOCVI = @HocVi AND  HOCHAM = @HocHam AND HESO = @HeSo

	IF (@MLHT <> @ML)
	BEGIN
		PRINT N'LOI! GV CO CUNG HOC HAM, HOC VI, HE SO LUONG THI MUC LUONG BANG NHAU'
		ROLLBACK TRAN
	END
	ELSE 
	BEGIN
		PRINT N'THANH CONG'
	END
END
GO

--20--
CREATE TRIGGER TRG_INS_UPD_LT
ON dbo.KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MaHV CHAR(10), @LanThi INT, @DT NUMERIC(4,2), @MaMH CHAR (10)

	SELECT @MaHV = MAHV, @MaMH = MAMH, @LanThi = LANTHI 
	FROM inserted
	--Lay diem cua lan thi truoc do
	SELECT @DT = DIEM 
	FROM dbo.KETQUATHI
	WHERE MAHV = @MaHV AND MAMH = @MaMH AND LANTHI = @LanThi - 1

	IF (@LanThi > 1 AND @DT > 5)
	BEGIN 
		PRINT N'LOI! DIEM THI < 5'
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		PRINT N'THANH CONG'
	END
END
GO

--21--
CREATE TRIGGER TRG_INS_UPD_NGTHI
ON dbo.KETQUATHI
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @MaHV CHAR(10), @MaMH CHAR(10), @NGTHI_TRC smalldatetime, @NGTHI_SAU smalldatetime, @LT INT

	SELECT @MaHV = MAHV, @MaMH = MAMH, @LT = LANTHI, @NGTHI_SAU = NGTHI
	FROM inserted

	SELECT @NGTHI_TRC = NGTHI
	FROM dbo.KETQUATHI
	WHERE MAHV = @MaHV AND MAMH = @MaMH AND LANTHI = @LT - 1

	IF (@NGTHI_SAU < @NGTHI_TRC)
	BEGIN
		PRINT N'LOI! NGAY THI SAU > NGAY THI TRUOC'
		ROLLBACK TRAN
	END
	ELSE
	BEGIN
		PRINT N'THANH CONG'
	END
END
GO

--22--



--II--
--1--
UPDATE GIAOVIEN
SET HESO = HESO * 1.2
WHERE MAGV IN(
	SELECT TRGKHOA
	FROM dbo.KHOA
)

--2--
UPDATE HOCVIEN
SET DIEMTB = (
	SELECT AVG(DIEM)
	FROM dbo.KETQUATHI
	WHERE LANTHI = (
			SELECT MAX(LANTHI)
			FROM dbo.KETQUATHI
			GROUP BY MAHV
			HAVING HOCVIEN.MAHV = KETQUATHI.MAHV
		)
	GROUP BY MAHV
	HAVING HOCVIEN.MAHV = KETQUATHI.MAHV
)


--3--
UPDATE HOCVIEN
SET GHICHU = 'Cam thi'
WHERE MAHV IN (
	SELECT KETQUATHI.MAHV
	FROM dbo.KETQUATHI
	WHERE LANTHI = 3 AND DIEM < 5
)

--4--
UPDATE dbo.HOCVIEN
SET XEPLOAI = (
	CASE 
		WHEN DIEMTB >= 9 THEN 'XS'
		WHEN DIEMTB >=8 AND DIEMTB < 9 THEN 'G'
		WHEN DIEMTB >= 6.5 AND DIEMTB < 8 THEN 'K'
		WHEN DIEMTB >= 5 AND DIEMTB < 6.5 THEN 'TB'
		WHEN DIEMTB < 5 THEN 'Y'
	END
)

	

--III--
--1--
SELECT MAHV, HO, TEN, NGSINH, HOCVIEN.MALOP
FROM dbo.HOCVIEN, dbo.LOP
WHERE HOCVIEN.MAHV = LOP.TRGLOP

--2--
SELECT HOCVIEN.MAHV, HO, TEN, LANTHI, DIEM
FROM dbo.HOCVIEN, dbo.KETQUATHI
WHERE 
	HOCVIEN.MAHV = KETQUATHI.MAHV
	AND KETQUATHI.MAMH = 'CTRR'
	AND
	HOCVIEN.MALOP = 'K12'
ORDER BY TEN, HO

--3--
SELECT HOCVIEN.MAHV, HO, TEN, KETQUATHI.MAMH
FROM dbo.HOCVIEN 
JOIN dbo.KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
WHERE 
	KETQUATHI.LANTHI = 1
	AND
	KETQUATHI.KQUA = 'Dat'

--4--
SELECT HOCVIEN.MAHV, HO, TEN
FROM dbo.HOCVIEN 
JOIN dbo.KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
WHERE 
	HOCVIEN.MALOP = 'K11'
	AND 
	KETQUATHI.MAMH = 'CTRR'
	AND
	KETQUATHI.KQUA = 'Khong Dat'
	AND
	KETQUATHI.LANTHI = 1

--5--
SELECT HOCVIEN.MAHV, HO, TEN
FROM dbo.HOCVIEN 
JOIN dbo.KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
WHERE 
	HOCVIEN.MALOP LIKE 'K%'
	AND 
	KETQUATHI.MAMH = 'CTRR'
	AND
	KETQUATHI.KQUA = 'Khong Dat'
GROUP BY HOCVIEN.MAHV, HO, TEN

--6--
SELECT DISTINCT TENMH
FROM dbo.MONHOC JOIN dbo.GIANGDAY
ON MONHOC.MAMH = GIANGDAY.MAMH
JOIN dbo.GIAOVIEN 
ON GIANGDAY.MAGV = GIAOVIEN.MAGV
WHERE 
	HOTEN = 'Tran Tam Thanh'
	AND
	HOCKY = 1 AND NAM = 2006

--7--
SELECT DISTINCT MONHOC.MAKHOA, MONHOC.TENMH
FROM dbo.MONHOC 
JOIN dbo.GIANGDAY ON MONHOC.MAMH = GIANGDAY.MAMH
JOIN dbo.LOP ON GIANGDAY.MAGV = LOP.MAGVCN
WHERE 
	LOP.MALOP = 'K11'
	AND
	HOCKY = 1 AND NAM = 2006
	
--8--
SELECT HO + ' ' + TEN AS HOTEN FROM HOCVIEN
WHERE MAHV IN (
	SELECT TRGLOP FROM LOP 
	WHERE MALOP IN (
		SELECT DISTINCT MALOP FROM GIANGDAY 
		WHERE MAGV IN (
			SELECT MAGV FROM GIAOVIEN WHERE HOTEN = 'Nguyen To Lan'
		) AND MAMH IN (
			SELECT MAMH FROM MONHOC WHERE TENMH = 'Co So Du Lieu'
		)
	)
)
	
--9--
SELECT MONHOCTRUOC.MAMH, MONHOCTRUOC.TENMH
FROM dbo.MONHOC 
JOIN dbo.DIEUKIEN ON MONHOC.MAMH = DIEUKIEN.MAMH
JOIN dbo.MONHOC AS MONHOCTRUOC ON MONHOCTRUOC.MAMH = DIEUKIEN.MAMH_TRUOC
WHERE MONHOC.MAMH = 'CSDL'

--10--
SELECT MONHOC.MAMH, MONHOC.TENMH
FROM dbo.MONHOC 
JOIN dbo.DIEUKIEN ON MONHOC.MAMH = DIEUKIEN.MAMH
JOIN dbo.MONHOC AS MONHOCTRUOC ON MONHOCTRUOC.MAMH = DIEUKIEN.MAMH_TRUOC
WHERE MONHOCTRUOC.TENMH = 'Cau truc roi rac'

--11--
SELECT GV.HOTEN
FROM dbo.GIAOVIEN AS GV
JOIN dbo.GIANGDAY AS GD ON GV.MAGV = GD.MAGV
WHERE 
	MALOP = 'K11'
	AND
	HOCKY = 1 AND NAM = 2006
INTERSECT (
	SELECT GV.HOTEN
	FROM dbo.GIAOVIEN AS GV
	JOIN dbo.GIANGDAY AS GD ON GV.MAGV = GD.MAGV
	WHERE 
		MALOP = 'K12'
		AND
		HOCKY = 1 AND NAM = 2006
)

--12--
SELECT HOCVIEN.MAHV, HO, TEN
FROM dbo.HOCVIEN JOIN dbo.KETQUATHI
ON HOCVIEN.MAHV = KETQUATHI.MAHV
WHERE 
	KQUA = 'Khong dat' AND MAMH = 'CSDL' AND LANTHI = 1
	AND NOT EXISTS (
		SELECT *
		FROM dbo.KETQUATHI
		WHERE LANTHI > 1 AND KETQUATHI.MAHV = HOCVIEN.MAHV
	)

--13--
SELECT GIAOVIEN.MAGV, HOTEN
FROM dbo.GIAOVIEN 
EXCEPT (
	SELECT GD.MAGV, HOTEN
	FROM dbo.GIAOVIEN AS GV JOIN dbo.GIANGDAY AS GD
	ON GV.MAGV = GD.MAGV
)

--14--
SELECT GIAOVIEN.MAGV, HOTEN
FROM dbo.GIAOVIEN
WHERE NOT EXISTS (
	SELECT *
	FROM dbo.MONHOC
	WHERE MONHOC.MAKHOA = GIAOVIEN.MAKHOA
		AND NOT EXISTS (
			SELECT * 
			FROM dbo.GIANGDAY
			WHERE 
				GIANGDAY.MAGV = GIAOVIEN.MAGV
				AND
				GIANGDAY.MAMH = MONHOC.MAMH
		)
)

--15--
SELECT HO, TEN 
FROM dbo.HOCVIEN
JOIN dbo.KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
WHERE MALOP = 'K11' 
AND (
	(LANTHI = 2 AND MAMH = 'CTRR' AND DIEM = 5)
	OR
	(LANTHI > 3 AND KQUA = 'Khong dat')
)

--16--
SELECT HOTEN
FROM dbo.GIAOVIEN AS GV JOIN dbo.GIANGDAY AS GD
ON GV.MAGV = GD.MAGV
WHERE MAMH = 'CTRR'
GROUP BY GV.HOTEN, HOCKY
HAVING COUNT(MALOP) >= 2

--17--
SELECT HO, TEN, KQ.DIEM 
FROM dbo.HOCVIEN AS HV JOIN dbo.KETQUATHI KQ 
ON HV.MAHV = KQ.MAHV
WHERE MAMH = 'CSDL'
AND LANTHI = (
	SELECT MAX(LANTHI)
	FROM dbo.KETQUATHI
	WHERE MAMH = 'CSDL' 
		AND
		KETQUATHI.MAHV = HV.MAHV
		GROUP BY MAHV
)

--18--
SELECT HO, TEN, DIEM AS 'Diem cao nhat'
FROM dbo.HOCVIEN AS HV 
JOIN dbo.KETQUATHI AS KQ ON HV.MAHV = KQ.MAHV
JOIN dbo.MONHOC AS MH ON MH.MAMH = KQ.MAMH
WHERE TENMH = 'Co so du lieu'
AND DIEM = (
	SELECT MAX(DIEM)
	FROM dbo.KETQUATHI, dbo.MONHOC
	WHERE KETQUATHI.MAHV = HV.MAHV AND TENMH = 'Co so du lieu'
	GROUP BY MAHV
)

--19--
SELECT MAKHOA,TENKHOA
FROM dbo.KHOA
WHERE NGTLAP = (
	SELECT MIN(NGTLAP)
	FROM dbo.KHOA
)

--20--
SELECT COUNT(MAGV) SOGV
FROM dbo.GIAOVIEN
WHERE HOCHAM IN('GS', 'PGS')

--21--
SELECT COUNT(MAGV) SOGIAOVIEN
FROM dbo.GIAOVIEN
WHERE HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS')

--22--
SELECT MAMH, KQUA, COUNT(MAMH) AS SL
FROM dbo.KETQUATHI
GROUP BY MAMH, KQUA

--23--
SELECT GV.MAGV, HOTEN
FROM dbo.GIAOVIEN GV
JOIN dbo.LOP AS L ON GV.MAGV = L.MAGVCN
WHERE EXISTS(
	SELECT *
	FROM dbo.GIANGDAY AS GD
	WHERE GD.MAGV = GV.MAGV
		AND GD.MALOP = L.MALOP
)

--24--
SELECT HO, TEN
FROM dbo.HOCVIEN AS HV
JOIN dbo.LOP AS L ON HV.MAHV = L.TRGLOP
WHERE SISO = (
	SELECT MAX(LOP.SISO)
	FROM dbo.LOP
)

--C2--
SELECT HO+TEN AS HOTEN
FROM dbo.HOCVIEN
WHERE MAHV IN (
	SELECT TRGLOP
	FROM dbo.LOP
	WHERE SISO IN (
		SELECT TOP 1 SISO
		FROM dbo.LOP 
		ORDER BY SISO DESC
	)
)

--25--
SELECT HO, TEN 
FROM dbo.HOCVIEN AS HV
JOIN dbo.LOP AS L ON HV.MAHV = L.TRGLOP
JOIN dbo.KETQUATHI AS KQ ON KQ.MAHV = L.TRGLOP
WHERE KQUA = 'Khong Dat'
	AND LANTHI = (
		SELECT MAX(LANTHI)
		FROM dbo.KETQUATHI
		WHERE KETQUATHI.MAHV = KQ.MAHV
			AND KETQUATHI.MAMH = KQ.MAMH
		GROUP BY KETQUATHI.MAMH
	)
GROUP BY HO, TEN
HAVING COUNT(HV.MAHV) > 3

--26--
SELECT TOP 1 WITH TIES HV.MAHV, HO+ ' '+TEN AS HOTEN 
FROM dbo.HOCVIEN AS HV
JOIN dbo.KETQUATHI AS KQ ON HV.MAHV = KQ.MAHV
WHERE DIEM IN('9', ' 10')
GROUP BY HV.MAHV, HO, TEN
ORDER BY COUNT(KQ.MAMH) DESC

--27--
WITH XEPHANGHOCVIEN AS(
	SELECT MALOP, HV.MAHV, HO+' '+ TEN AS HOTEN,
	RANK() OVER (PARTITION BY MALOP ORDER BY COUNT(KQ.MAMH) DESC) AS XEPHANG
	FROM dbo.HOCVIEN AS HV
	JOIN dbo.KETQUATHI AS KQ ON HV.MAHV = KQ.MAHV
	WHERE DIEM >= 9
	GROUP BY MALOP, HV.MAHV, HO, TEN
)
SELECT MALOP, MAHV, HOTEN
FROM XEPHANGHOCVIEN
WHERE XEPHANGHOCVIEN.XEPHANG = 1

--28--
SELECT HOCKY, MAGV, COUNT(DISTINCT MAMH) AS SOMONHOCGD, COUNT(MALOP) AS SOLOPGD
FROM dbo.GIANGDAY
GROUP BY HOCKY, MAGV
ORDER BY HOCKY ASC

--29--
WITH XEPHANGGV AS (
	SELECT HOCKY, NAM, MAGV,
	RANK() OVER (PARTITION BY HOCKY, NAM ORDER BY COUNT(MAMH) ASC) AS XEPHANG
	FROM dbo.GIANGDAY
	GROUP BY HOCKY, NAM, MAGV
)
SELECT HOCKY, NAM, MAGV
FROM XEPHANGGV 
WHERE XEPHANG = 1
ORDER BY HOCKY, NAM

--30--
SELECT TOP 1 WITH TIES KQ.MAMH, TENMH
FROM dbo.MONHOC AS MH
JOIN dbo.KETQUATHI AS KQ ON MH.MAMH = KQ.MAMH
WHERE KQUA = 'Khong Dat' AND LANTHI = 1
GROUP BY KQ.MAMH, TENMH
ORDER BY COUNT(KQ.MAMH) DESC

--31--
SELECT HV.MAHV, HO+' '+TEN AS HOTEN
FROM dbo.HOCVIEN AS HV
WHERE NOT EXISTS (
	SELECT *
	FROM dbo.KETQUATHI AS KQ
	WHERE KQ.MAHV = HV.MAHV
		AND KQ.KQUA = 'Dat'
		AND KQ.LANTHI = 1
)

--32--
SELECT HV.MAHV, HO+' '+TEN AS HOTEN
FROM dbo.HOCVIEN AS HV
WHERE NOT EXISTS (
	SELECT *
	FROM dbo.KETQUATHI AS KQ
	WHERE KQ.MAHV = HV.MAHV
		AND KQ.KQUA = 'Dat'
		AND KQ.LANTHI = (
			SELECT MAX(LANTHI)
			FROM dbo.KETQUATHI
			WHERE KETQUATHI.MAHV = KQ.MAHV
			GROUP BY MAHV
		)
)

--33--
SELECT HV.MAHV, HO+' '+TEN AS HOTEN
FROM dbo.HOCVIEN AS HV
WHERE NOT EXISTS (
	SELECT *
	FROM dbo.MONHOC AS MH
	WHERE NOT EXISTS (
		SELECT *
		FROM dbo.KETQUATHI AS KQ
		WHERE KQ.MAHV = HV.MAHV
			AND MH.MAMH = KQ.MAMH
			AND KQ.KQUA = 'Dat'
			AND LANTHI = 1
	)
)

--34--
SELECT HV.MAHV, HO+' '+TEN AS HOTEN
FROM dbo.HOCVIEN AS HV
WHERE NOT EXISTS (
	SELECT *
	FROM dbo.MONHOC AS MH
	WHERE NOT EXISTS (
		SELECT *
		FROM dbo.KETQUATHI AS KQ
		WHERE KQ.MAHV = HV.MAHV
			AND MH.MAMH = KQ.MAMH
			AND KQ.KQUA = 'Dat'
			AND KQ.LANTHI = (
				SELECT MAX(LANTHI)
				FROM dbo.KETQUATHI
				WHERE KETQUATHI.MAHV = KQ.MAHV
				GROUP BY MAHV
			)
	)
)

--35--
WITH XEPHANGHOCVIEN AS( 
	SELECT KQ.MAMH, HV.MAHV, HO+' '+TEN AS HOTEN,
	RANK() OVER (PARTITION BY MAMH ORDER BY MAX(DIEM) DESC) AS XEPHANG
	FROM dbo.HOCVIEN AS HV
	JOIN dbo.KETQUATHI AS KQ ON HV.MAHV = KQ.MAHV
	WHERE KQ.LANTHI = (
		SELECT MAX(LANTHI)
		FROM dbo.KETQUATHI 
		WHERE KETQUATHI.MAHV = KQ.MAHV
	)
	GROUP BY KQ.MAMH, HV.MAHV, HO, TEN
)
SELECT MAMH, MAHV, HOTEN
FROM XEPHANGHOCVIEN
WHERE XEPHANG = 1
