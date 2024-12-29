-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger
USE HWLAB1
GO
-- Cơ bản:
--1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.
SELECT *
FROM CHUYENGIA

--2. Hiển thị tên và email của các chuyên gia nữ.
SELECT HoTen, Email
FROM dbo.ChuyenGia
WHERE GioiTinh = N'Nữ'

--3. Liệt kê các công ty có trên 100 nhân viên.
SELECT *
FROM dbo.CongTy
WHERE SoNhanVien > 100

--4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.
SELECT TenDuAn, NgayBatDau
FROM dbo.DuAn
WHERE YEAR(NgayBatDau) = 2023

-- Trung cấp:
--6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.
SELECT HoTen, COUNT(MaDuAn) AS SoLuongDuAn
FROM dbo.ChuyenGia AS CG
JOIN dbo.ChuyenGia_DuAn AS CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY HoTen

--7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.
SELECT DISTINCT MaDuAn
FROM dbo.ChuyenGia_DuAn AS CGDA
JOIN dbo.ChuyenGia_KyNang AS CGKN ON CGDA.MaChuyenGia = CGKN.MaChuyenGia
JOIN dbo.KyNang AS KN ON KN.MaKyNang = CGKN.MaKyNang
WHERE TenKyNang = 'Python' AND CapDo >= 4

--8. Hiển thị tên công ty và số lượng dự án đang thực hiện.
SELECT TenCongTy, COUNT(*) AS SoLuongDuAn
FROM dbo.CongTy AS CT 
JOIN dbo.DuAn AS DA ON CT.MaCongTy = DA.MaCongTy
GROUP BY TenCongTy;

--9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.
WITH RANKCHUYENGIA AS(
	SELECT MaChuyenGia, HoTen, ChuyenNganh, NamKinhNghiem,
	DENSE_RANK() OVER (PARTITION BY ChuyenNganh ORDER BY NamKinhNghiem DESC) AS XEPHANG
	FROM dbo.ChuyenGia
)

SELECT *
FROM RANKCHUYENGIA
WHERE XEPHANG = 1

--10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.
SELECT CG1.MaChuyenGia, CG2.MaChuyenGia, CG1.MaDuAn
FROM dbo.ChuyenGia_DuAn AS CG1 
JOIN dbo.ChuyenGia_DuAn AS CG2 
ON CG1.MaDuAn = CG2.MaDuAn AND CG1.MaChuyenGia > CG2.MaChuyenGia

-- Nâng cao:
--11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.


--12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).


--13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.


--14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).


--15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.


-- Trigger:
--16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.


--17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.


--18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.


--19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.


--20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.
