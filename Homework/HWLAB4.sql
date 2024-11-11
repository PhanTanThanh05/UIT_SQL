USE HWLAB1
GO

-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.
SELECT TOP 3 WITH TIES CG.HoTen, COUNT(CGKN.MaKyNang) AS SoLuongKyNang
FROM dbo.ChuyenGia_KyNang AS CGKN
JOIN dbo.ChuyenGia AS CG ON CG.MaChuyenGia = CGKN.MaChuyenGia
GROUP BY CG.HoTen
ORDER BY SoLuongKyNang DESC


-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.
SELECT * 
FROM dbo.ChuyenGia AS CG1 
JOIN dbo.ChuyenGia AS CG2 ON CG1.ChuyenNganh = CG2.ChuyenNganh AND CG1.MaChuyenGia > CG2.MaChuyenGia
WHERE ABS(CG1.NamKinhNghiem - CG2.NamKinhNghiem) <= 2

-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.
SELECT TenCongTy, COUNT(DISTINCT DuAn.MaDuAn) AS SoLuongDuAn, SUM(ChuyenGia.NamKinhNghiem) AS 'So nam kinh nghiem'
FROM dbo.CongTy
JOIN dbo.DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
JOIN dbo.ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN dbo.ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY TenCongTy

-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.
--C1--
SELECT *
FROM dbo.ChuyenGia AS CG
WHERE EXISTS (
	SELECT *
	FROM dbo.ChuyenGia_KyNang AS CGKN1
	WHERE CGKN1.MaChuyenGia = CG.MaChuyenGia
	AND CapDo = 5
) 
AND NOT EXISTS (
	SELECT *
	FROM dbo.ChuyenGia_KyNang AS CGKN2
	WHERE CGKN2.MaChuyenGia = CG.MaChuyenGia
	AND CGKN2.CapDo < 3
)
--C2--
SELECT MaChuyenGia
FROM dbo.ChuyenGia_KyNang
GROUP BY MaChuyenGia
HAVING MAX(CAPDO) = 5
AND MIN(CAPDO) >= 3

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.
SELECT HoTen, COUNT(MADUAN) AS SoLuongDuAn
FROM dbo.ChuyenGia AS CG
LEFT JOIN dbo.ChuyenGia_DuAn AS CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY HoTen;


-- 81*. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.
WITH XEPHANGKYNANG AS (
SELECT MaChuyenGia, MaKyNang, CapDo,
RANK() OVER (PARTITION BY MaKyNang ORDER BY CapDo DESC) AS XEPHANG
FROM dbo.ChuyenGia_KyNang
)

SELECT MaChuyenGia, MaKyNang
FROM XEPHANGKYNANG
WHERE XEPHANG = 1

-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.
SELECT ChuyenNganh, COUNT(MaChuyenGia) AS SoLuongChuyenGia,
CAST(COUNT(MaChuyenGia) * 100.0 / (SELECT COUNT(ChuyenNganh) FROM dbo.ChuyenGia) AS DECIMAL(5,2)) AS TyLePhanTram
FROM dbo.ChuyenGia
GROUP BY ChuyenNganh


-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.
SELECT  TOP 1 WITH TIES K1.MaKyNang, K2.MaKyNang, COUNT(*) AS SoLanXuatHien
FROM dbo.ChuyenGia_KyNang AS K1
JOIN dbo.ChuyenGia_KyNang AS K2 ON  K1.MaChuyenGia = K2.MaChuyenGia AND K1.MaKyNang < K2.MaKyNang
GROUP BY K1.MaKyNang, K2.MaKyNang
ORDER BY SoLanXuatHien DESC

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.
SELECT TenCongTy,
AVG(DATEDIFF(DAY, NgayBatDau, NgayKetThuc)) AS SoNgayTrungBinh
FROM dbo.CongTy JOIN dbo.DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY TenCongTy;

-- 85*. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).
WITH COUNTSKILLS AS (
	SELECT MaKyNang, COUNT(MaKyNang) AS SoLuongKyNang
	FROM dbo.ChuyenGia_KyNang
	GROUP BY MaKyNang
	HAVING COUNT(MaKyNang) = 1
)

SELECT CG.MaChuyenGia, HoTen
FROM dbo.ChuyenGia AS CG
JOIN dbo.ChuyenGia_KyNang AS CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
WHERE CGKN.MaKyNang IN (
	SELECT MaKyNang
	FROM COUNTSKILLS
)

-- 86*. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.
SELECT CG.MaChuyenGia, HoTen, COUNT(DISTINCT CGDA.MaDuAn) AS SoLuongDuAn, SUM(CGKN.CapDo) AS TongCapDoKyNang,
DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT CGDA.MaDuAn) DESC, SUM(CGKN.CapDo) DESC) AS XepHang
FROM dbo.ChuyenGia AS CG
JOIN dbo.ChuyenGia_KyNang AS CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
JOIN dbo.ChuyenGia_DuAn AS CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY CG.MaChuyenGia, HoTen
ORDER BY XepHang 

-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT MaDuAn
FROM dbo.ChuyenGia_DuAn AS CGDA
JOIN dbo.ChuyenGia AS CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY MaDuAn
HAVING COUNT(DISTINCT CG.ChuyenNganh) = (
	SELECT COUNT(DISTINCT ChuyenNganh) AS SoLuongChuyenNganh
	FROM dbo.ChuyenGia
)

-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.
SELECT TenCongTy, DA.MaCongTy, COUNT(DA.MaDuAn) AS SoLuongDuAn,
CAST(COUNT(CASE WHEN TrangThai = N'Hoàn thành' THEN 1 END) * 100.00 / COUNT(DA.MaDuAn) AS DECIMAL(5,2)) AS TyLeHoanThanh
FROM dbo.CongTy AS CTY JOIN dbo.DuAn AS DA
ON CTY.MaCongTy = DA.MaCongTy
GROUP BY TenCongTy, DA.MaCongTy

-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
SELECT CG1.MaChuyenGia AS ChuyenGia1,
    CG2.MaChuyenGia AS ChuyenGia2,
    CG1.MaKyNang,
    CG1.CapDo AS CapDo_ChuyenGia1,
    CG2.CapDo AS CapDo_ChuyenGia2
FROM dbo.ChuyenGia_KyNang AS CG1 
JOIN dbo.ChuyenGia_KyNang AS CG2 ON CG1.MaKyNang = CG2.MaKyNang AND CG1.MaChuyenGia < CG2.MaChuyenGia --tạo các cặp chuyên gia khác nhau
WHERE (CG1.CapDo > CG2.CapDo AND CG1.CapDo >= 4 AND CG2.CapDo <= 3)
    OR
    (CG1.CapDo < CG2.CapDo AND CG1.CapDo <= 3 AND CG2.CapDo >= 4);