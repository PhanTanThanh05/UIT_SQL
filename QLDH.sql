CREATE DATABASE QLDH

CREATE TABLE KHOA (
	MAKHOA varchar(4) primary key,
	TENKHOA varchar(40),
	NGTLAP smalldatetime,
	TRGKHOA char(4) --REFERENCES GIAOVIEN(MAGV),
);

CREATE TABLE MONHOC (
	MAMH varchar(10) primary key,
	TENMH varchar(40),
	TCLT tinyint,
	TCTH tinyint,
	MAKHOA varchar(4) REFERENCES KHOA(MAKHOA),
);

CREATE TABLE DIEUKIEN (
	MAMH varchar(10) REFERENCES MONHOC(MAMH),
	MAMH_TRUOC varchar(10) REFERENCES MONHOC(MAMH),
	primary key(MAMH, MAMH_TRUOC),
);

CREATE TABLE GIAOVIEN (
	MAGV char(4) primary key,
	HOTEN varchar(40),
	HOCVI varchar(10),
	HOCHAM varchar(10),
	GIOITINH varchar(3),
	NGSINH smalldatetime,
	NGLV smalldatetime,
	HESO numeric(4,2),
	MUCLUONG money,
	MAKHOA varchar(4) REFERENCES KHOA(MAKHOA),
);

CREATE TABLE HOCVIEN (
	MAHV char(5) primary key,
	HO varchar(40),
	TEN varchar(40),
	NGSINH smalldatetime,
	GIOITINH varchar(3),
	NOISINH varchar(40),
	MALOP char(3), --references LOP(MALOP)
);

CREATE TABLE LOP (
	MALOP char(3) primary key,
	TENLOP varchar (40),
	TRGLOP char(5) REFERENCES HOCVIEN(MAHV),
	SISO tinyint,
	MAGVCN char(4) REFERENCES GIAOVIEN(MAGV),
);

CREATE TABLE GIANGDAY (
	MALOP char(3) REFERENCES LOP(MALOP),
	MAMH varchar(10) REFERENCES MONHOC(MAMH),
	primary key(MALOP, MAMH),
	MAGV char(4) REFERENCES GIAOVIEN(MAGV),
	HOCKY tinyint,
	NAM smallint,
	TUNGAY smalldatetime,
	DENNGAY smalldatetime,
);

CREATE TABLE KETQUATHI (
	MAHV char(5) REFERENCES HOCVIEN(MAHV),
	MAMH varchar(10) REFERENCES MONHOC(MAMH),
	primary key(MAHV, MAMH),
	LANTHI tinyint,
	NGTHI smalldatetime,
	DIEM numeric(4,2),
	KQUA varchar(10),
);

ALTER TABLE KHOA ADD
CONSTRAINT FK_KHOA_TRGKHOA FOREIGN KEY (TRGKHOA) REFERENCES GIAOVIEN(MAGV)

ALTER TABLE HOCVIEN ADD
CONSTRAINT FK_HOCVIEN_MALOP FOREIGN KEY (MALOP) REFERENCES LOP(MALOP)

ALTER TABLE HOCVIEN ADD GHICHU VARCHAR(50), DIEMTB NUMERIC(4,2), XEPLOAI VARCHAR(10)