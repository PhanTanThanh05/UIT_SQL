USE HWLAB1
GO
--51--
SELECT * FROM dbo.ChuyenGia --Hiển thị thông tin bảng Chuyên Gia

--52--
SELECT HoTen, Email FROM dbo.ChuyenGia --Liệt kê họ tên và email của tất cả chuyên gia


--53--
SELECT TenCongTy, SoNhanVien FROM dbo.CongTy --Hiển thị tên công ty và số nhân viên

--54--
SELECT TenDuAn FROM dbo.DuAn
WHERE TrangThai = N'Đang thực hiện' --Liệt kê tên dự án đang trong trạng thái "Đang thực hiện"

--55--
SELECT TenKyNang, LoaiKyNang FROM dbo.KyNang --Hiển thị tên, loại của tất cả kĩ năng

--56--
SELECT HoTen, ChuyenNganh FROM dbo.ChuyenGia --Liệt kê họ tên, chuyên ngành các chuyên gia nam
WHERE GioiTinh = N'Nam'

--57--
SELECT TenCongTy, LinhVuc FROM dbo.CongTy --Tên công ty và lĩnh vực của công ty có trên 150 nhân viên
WHERE SoNhanVien > 150

--58--
SELECT TenDuAn FROM dbo.DuAn --Các dự án bắt đầu trong năm 2023
WHERE YEAR(NgayBatDau) = 2023

--59--
SELECT TenKyNang FROM dbo.KyNang --Tên kĩ năng thuộc loại 'Công Cụ'
WHERE LoaiKyNang = N'Công cụ'

--60--
SELECT HoTen, NamKinhNghiem FROM dbo.ChuyenGia --Họ tên, Năm kinh nghiệm của chuyên gia có trên 5 năm kinh nghiệm
WHERE NamKinhNghiem > 5

--61--
SELECT TenCongTy, DiaChi FROM dbo.CongTy
WHERE LinhVuc = N'Phát triển phần mềm'

--62--
SELECT TenDuAn FROM dbo.DuAn
WHERE YEAR(NgayKetThuc) = 2023

--63--
SELECT TenKyNang, CapDo FROM dbo.ChuyenGia_KyNang, dbo.KyNang
WHERE KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang

--64--
SELECT MaChuyenGia, VaiTro FROM dbo.ChuyenGia_DuAn

--65--
SELECT HoTen, NgaySinh FROM dbo.ChuyenGia
WHERE YEAR(NgaySinh) >= 1990

--66--
SELECT TenCongTy, SoNhanVien FROM dbo.CongTy
ORDER BY SoNhanVien DESC

--67--
SELECT TenDuAn, NgayBatDau FROM dbo.DuAn	
ORDER BY NgayBatDau ASC

--68--
SELECT  DISTINCT TenKyNang FROM dbo.KyNang

--69--
SELECT  TOP 5 HoTen, Email 
FROM dbo.ChuyenGia

--70--
SELECT TenCongTy FROM dbo.CongTy
WHERE TenCongTy LIKE '%Tech%'

--71--
SELECT TenDuAn, TrangThai FROM dbo.DuAn
WHERE TrangThai != N'Hoàn Thành'

--72--
SELECT HoTen, ChuyenNganh FROM dbo.ChuyenGia
ORDER BY ChuyenNganh, HoTen

--73--
SELECT TenCongTy, LinhVuc FROM dbo.CongTy
WHERE SoNhanVien BETWEEN 100 AND 200

--74--
SELECT TenKyNang, LoaiKyNang FROM dbo.KyNang
ORDER BY LoaiKyNang DESC, TenKyNang ASC

--75--
SELECT HoTen, SoDienThoai FROM dbo.ChuyenGia
WHERE Email LIKE '%email.com%'
