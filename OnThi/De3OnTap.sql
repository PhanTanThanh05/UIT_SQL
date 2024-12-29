CREATE DATABASE DE3
GO

USE DE3
GO

CREATE TABLE DOCGIA (
	MaDG char(5) primary key,
	HoTen varchar(30),
	NgaySinh smalldatetime,
	DiaChi varchar(30),
	SoDT varchar(15),
);

CREATE TABLE SACH (
	MaSach char(5) primary key,
	TenSach varchar(25),
	TheLoai varchar(25),
	NhaXuatBan varchar(30),
);

CREATE TABLE PHIEUTHUE (
	MaPT char(5) primary key,
	MaDG char(5) foreign key references DOCGIA(MaDG),
	NgayThue smalldatetime,
	NgayTra smalldatetime,
	SoSachThue int,
);

CREATE TABLE CHITIET_PT (
	MaPT char(5) foreign key references PHIEUTHUE(MaPT),
	MaSach char(5)foreign key references SACH(MaSach),
	primary key (MaPT, MaSach),
);

--2.1--
ALTER TABLE PHIEUTHUE
ADD CONSTRAINT CHECK_NGTHUE 
CHECK (NgayTra - NgayThue <= 10)

--2.2--
CREATE TRIGGER TRG_INS_UPD_DEL_PTHUE
ON dbo.CHITIET_PT
FOR INSERT, UPDATE, DELETE
AS 
BEGIN
	UPDATE PHIEUTHUE
	SET SoSachThue = (
		SELECT COUNT(*)
		FROM CHITIET_PT
		WHERE PHIEUTHUE.MaPT = CHITIET_PT.MAPT
	)
	WHERE PHIEUTHUE.MaPT IN (
		SELECT DISTINCT MaPT 
		FROM inserted
		UNION
		SELECT DISTINCT MaPT
		FROM deleted
	)
END;
GO

--3.1--
SELECT *
FROM dbo.DOCGIA AS DG 
JOIN dbo.PHIEUTHUE AS PT ON PT.MaDG = DG.MaDG
JOIN dbo.CHITIET_PT AS CT ON CT.MaPT = PT.MaPT
JOIN dbo.SACH AS S ON S.MaSach = CT.MaSach
WHERE TheLoai = N'Tin hoc' AND YEAR(NgayThue) = 2007

--3.2--
SELECT TOP 1 WITH TIES DG.MaDG, HoTen
FROM dbo.DOCGIA AS DG 
JOIN dbo.PHIEUTHUE AS PT ON PT.MaDG = DG.MaDG
JOIN dbo.CHITIET_PT AS CT ON CT.MaPT = PT.MaPT
JOIN dbo.SACH AS S ON S.MaSach = CT.MaSach
GROUP BY DG.MaDG, HoTen
ORDER BY COUNT(DISTINCT TheLoai) DESC

--3.3--
SELECT TheLoai, TenSach
FROM dbo.SACH AS S1
WHERE S1.MaSach IN (
	SELECT TOP 1 WITH TIES S2.MaSach
	FROM dbo.SACH AS S2
	JOIN dbo.CHITIET_PT AS CT ON CT.MaSach = S2.MaSach
	JOIN dbo.PHIEUTHUE AS PT ON PT.MaPT = CT.MaPT
	WHERE S2.TheLoai = S1.TheLoai
	GROUP BY S2.MaSach
	ORDER BY COUNT(PT.MAPT) DESC
)