CREATE TABLE KHACHHANG
(
MAKH CHAR(4) primary key,
HOTEN varchar(40),
DCHI varchar(50),
SODT varchar(10),
NGSINH smalldatetime,
NGDK smalldatetime,
DOANHSO money,
);

CREATE TABLE NHANVIEN (
MANV CHAR(4) primary key,
HOTEN VARCHAR(40),
SODT VARCHAR(20),
NGVL smalldatetime,
);



CREATE TABLE SANPHAM(
MASP char(4) primary key,
TENSP varchar(40),
DVT varchar(20),
NUOCSX varchar(40),
GIA money,
);

CREATE TABLE HOADON ( 
SOHD int primary key,
NGHD smalldatetime,
MAKH char(4) REFERENCES KHACHHANG(MAKH),
MANV char(4) REFERENCES NHANVIEN(MANV),
TRIGIA money,
);

CREATE TABLE CTHD (
SOHD INT REFERENCES HOADON(SOHD),
MASP char(4) REFERENCES SANPHAM(MASP),
SL INT CHECK(SL >= 1),
PRIMARY KEY(SOHD, MASP),

);