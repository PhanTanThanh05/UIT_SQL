USE HWLAB1
GO

-- 8. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1.
SELECT TenKyNang, CapDo
FROM dbo.ChuyenGia 
JOIN dbo.ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN dbo.KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
WHERE ChuyenGia.MaChuyenGia = 1


-- 9. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2.
SELECT HoTen
FROM dbo.ChuyenGia JOIN DBO.ChuyenGia_DuAn
ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
WHERE MaDuAn = 2

-- 10. Hiển thị tên công ty và tên dự án của tất cả các dự án.
SELECT TenCongTy, TenDuAn 
FROM dbo.CongTy JOIN dbo.DuAn
ON CongTy.MaCongTy = DuAn.MaCongTy

-- 11. Đếm số lượng chuyên gia trong mỗi chuyên ngành.
SELECT ChuyenNganh, COUNT(*) AS 'So luong chuyen gia'
FROM dbo.ChuyenGia
GROUP BY ChuyenNganh

-- 12. Tìm chuyên gia có số năm kinh nghiệm cao nhất.
SELECT * FROM dbo.ChuyenGia
WHERE NamKinhNghiem = (
	SELECT MAX(NamKinhNghiem)
	FROM dbo.ChuyenGia
)

-- 13. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia.
SELECT ChuyenGia.HoTen, COUNT(MaDuAn) AS 'So luong du an tham gia'
FROM dbo.ChuyenGia JOIN dbo.ChuyenGia_DuAn
ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY HoTen

-- 14. Hiển thị tên công ty và số lượng dự án của mỗi công ty.
SELECT TenCongTy, COUNT(MaDuAn) AS 'So luong du an'
FROM dbo.CongTy JOIN dbo.DuAn
ON CongTy.MaCongTy = DuAn.MaCongTy
GROUP BY TenCongTy

-- 15. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất. 
SELECT TOP 1 TenKyNang, COUNT(ChuyenGia_KyNang.MaChuyenGia) As SoChuyenGiaSoHuu
FROM dbo.ChuyenGia JOIN dbo.ChuyenGia_KyNang
ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN dbo.KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
GROUP BY TenKyNang
ORDER BY SoChuyenGiaSoHuu DESC

-- 16. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên.
SELECT HoTen
FROM dbo.ChuyenGia JOIN dbo.ChuyenGia_KyNang
ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
JOIN dbo.KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
WHERE TenKyNang = 'Python' AND CapDo >= 4


-- 17. Tìm dự án có nhiều chuyên gia tham gia nhất.
SELECT TOP 1 TenDuAn, COUNT(ChuyenGia.MaChuyenGia) AS SoChuyenGiaThamGia
FROM dbo.ChuyenGia JOIN dbo.ChuyenGia_DuAn
ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
JOIN dbo.DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
GROUP BY TenDuAn
ORDER BY SoChuyenGiaThamGia DESC


-- 18. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia.
SELECT HOTEN, COUNT(ChuyenGia_KyNang.MaKyNang) AS 'So luong ky nang'
FROM dbo.ChuyenGia JOIN dbo.ChuyenGia_KyNang
ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
GROUP BY HoTen

-- 19. Tìm các cặp chuyên gia làm việc cùng dự án.
SELECT CG1.MaChuyenGia AS ChuyenGia1, CG2.MaChuyenGia AS ChuyenGia2, CG1.MaDuAn
FROM dbo.ChuyenGia_DuAn AS CG1 JOIN dbo.ChuyenGia_DuAn AS CG2
ON CG1.MaDuAn = CG2.MaDuAn AND CG1.MaChuyenGia < CG2.MaChuyenGia

-- 20. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ.
SELECT HoTen, COUNT(*) AS 'So luong ky nang cap do 5'
FROM dbo.ChuyenGia AS CG JOIN dbo.ChuyenGia_KyNang AS CGKN
ON CG.MaChuyenGia = CGKN.MaChuyenGia
WHERE CapDo = 5
GROUP BY HoTen

-- 21. Tìm các công ty không có dự án nào.
SELECT *
FROM dbo.CongTy
WHERE MaCongTy NOT IN (
	SELECT MaCongTy FROM dbo.DuAn
)

-- 22. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả chuyên gia không tham gia dự án nào.
SELECT HoTen, TenDuAn
FROM dbo.ChuyenGia 
LEFT JOIN dbo.ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
LEFT JOIN dbo.DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn

-- 23. Tìm các chuyên gia có ít nhất 3 kỹ năng.
SELECT HoTen
FROM dbo.ChuyenGia AS CG
JOIN dbo.ChuyenGia_KyNang AS CGKN
ON CG.MaChuyenGia = CGKN.MaChuyenGia
GROUP BY HoTen
HAVING COUNT(*) >= 3

-- 24. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó.
SELECT TenCongTy, SUM(ChuyenGia.NamKinhNghiem) AS 'So nam kinh nghiem'
FROM dbo.CongTy
JOIN dbo.DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
JOIN dbo.ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
JOIN dbo.ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY TenCongTy
-- 25. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python'.
SELECT * 
FROM dbo.ChuyenGia
JOIN dbo.ChuyenGia_KyNang 
ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE MaKyNang = (
	SELECT MaKyNang
	FROM dbo.KyNang
	WHERE TenKyNang = 'Java'
)
AND NOT EXISTS (
	SELECT *
	FROM dbo.ChuyenGia_KyNang AS CGKN
	WHERE 
		CGKN.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
		AND
		MaKyNang = (
		SELECT MaKyNang
		FROM dbo.KyNang
		WHERE TenKyNang = 'Python'
	)
)

-- 76. Tìm chuyên gia có số lượng kỹ năng nhiều nhất.
WITH SkillCounts AS (
	SELECT CG.MaChuyenGia, CG.HoTen, COUNT(CGKN.MaKyNang) AS SoLuongKyNang
	FROM dbo.ChuyenGia AS CG
	JOIN dbo.ChuyenGia_KyNang AS CGKN
	ON CG.MaChuyenGia = CGKN.MaChuyenGia
	GROUP BY CG.MaChuyenGia, CG.HoTen
),
MaxSkillCounts AS (
	SELECT MAX(SoLuongKyNang) AS SoLuongKNNhieuNhat
	FROM SkillCounts
)

SELECT MaChuyenGia, HoTen, SoLuongKyNang 
FROM SkillCounts
WHERE SoLuongKyNang = (
	SELECT SoLuongKNNhieuNhat
	FROM MaxSkillCounts
)

-- 77. Liệt kê các cặp chuyên gia có cùng chuyên ngành.
SELECT CG1.HoTen AS ChuyenGia1, CG2.HoTen AS ChuyenGia2
FROM dbo.ChuyenGia AS CG1 
JOIN dbo.ChuyenGia AS CG2
ON CG1.ChuyenNganh = CG2.ChuyenNganh AND CG1.MaChuyenGia < CG2.MaChuyenGia

-- 78. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất.
WITH TongKinhNghiem AS (
	SELECT TenCongTy, SUM(ChuyenGia.NamKinhNghiem) AS TongNamKinhNghiem
	FROM dbo.CongTy
	JOIN dbo.DuAn ON CongTy.MaCongTy = DuAn.MaCongTy
	JOIN dbo.ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
	JOIN dbo.ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
	GROUP BY TenCongTy
),
MaxTongNamKinhNghiem AS (
	SELECT MAX(TongNamKinhNghiem) AS TongNamKNCaoNhat
	FROM TongKinhNghiem
)

SELECT TenCongTy, TongNamKinhNghiem
FROM TongKinhNghiem
WHERE TongNamKinhNghiem = (
	SELECT TongNamKNCaoNhat
	FROM MaxTongNamKinhNghiem
)


-- 79. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia. -> ít nhất 1 chuyên gia không sở hữu
--C1
SELECT KN.TenKyNang
FROM dbo.KyNang AS KN
WHERE NOT EXISTS (
	SELECT * 
	FROM dbo.ChuyenGia AS CG
	WHERE NOT EXISTS (
		SELECT * 
		FROM dbo.ChuyenGia_KyNang AS CGKN
		WHERE CGKN.MaKyNang = KN.MaKyNang 
			AND CGKN.MaChuyenGia = CG.MaChuyenGia
	)
)
--C2
SELECT TenKyNang
FROM dbo.KyNang
WHERE MaKyNang IN (
	SELECT CGKN.MaKyNang
	FROM dbo.ChuyenGia_KyNang AS CGKN
	GROUP BY MaKyNang
	HAVING COUNT(CGKN.MaChuyenGia) = (
			SELECT COUNT(*)
			FROM dbo.ChuyenGia
		)
)