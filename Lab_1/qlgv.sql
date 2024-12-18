CREATE DATABASE QuanLyGiaoVu;

USE QuanLyGiaoVu;

---------------- Cau 1 -----------------
-- Tạo quan hệ và khai báo tất cả các ràng buộc khóa chính, khóa ngoại. Thêm vào 3 thuộc tính 
-- GHICHU, DIEMTB, XEPLOAI cho quan hệ HOCVIEN. 

-------------------------- KHOA ----------------------
CREATE TABLE KHOA (
	MAKHOA VARCHAR(4),
	TENKHOA VARCHAR(40),
	NGTLAP SMALLDATETIME,
	TRGKHOA CHAR(4)
);

ALTER TABLE KHOA 
ALTER COLUMN MAKHOA VARCHAR(4) NOT NULL;

ALTER TABLE KHOA 
ADD CONSTRAINT PK_KHOA PRIMARY KEY (MAKHOA);

--------------------------- MONHOC ----------------------------
CREATE TABLE MONHOC (
	MAMH VARCHAR(10) NOT NULL PRIMARY KEY,
	TENMH VARCHAR(40),
	TCLT TINYINT,
	TCTH TINYINT,
	MAKHOA VARCHAR(4)
);

ALTER TABLE MONHOC
ADD CONSTRAINT FK_MONHOC_MAKHOA FOREIGN KEY (MAKHOA)
REFERENCES KHOA (MAKHOA);

-------------------- DIEUKIEN ---------------------
CREATE TABLE DIEUKIEN (
	MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC (MAMH),
	MAMH_TRUOC VARCHAR(10),

	PRIMARY KEY(MAMH, MAMH_TRUOC)
);

------------------- GIAOVIEN ----------------------
CREATE TABLE GIAOVIEN (
	MAGV CHAR(4) NOT NULL PRIMARY KEY,
	HOTEN VARCHAR(40),
	HOCVI VARCHAR(10),
	HOCHAM VARCHAR(10),
	GIOITINH VARCHAR(3),
	NGSINH SMALLDATETIME,
	NGVL SMALLDATETIME,
	HESO NUMERIC(4,2),
	MUCLUONG MONEY,
	MAKHOA VARCHAR(4)
);

ALTER TABLE GIAOVIEN
ADD CONSTRAINT FK_GIAOVIEN_MAKHOA FOREIGN KEY (MAKHOA)
REFERENCES KHOA(MAKHOA);

---------------------------- LOP -----------------------
CREATE TABLE LOP (
	MALOP CHAR(3) NOT NULL PRIMARY KEY,
	TENLOP VARCHAR(40),
	TRGLOP CHAR(5),
	SISO TINYINT,
	MAGVCN CHAR(4) FOREIGN KEY REFERENCES GIAOVIEN(MAGV)
);

------------------------ HOCVIEN ----------------------
CREATE TABLE HOCVIEN (
	MAHV CHAR(5) NOT NULL PRIMARY KEY,
	HO VARCHAR(40),
	TEN VARCHAR(10),
	NGSINH SMALLDATETIME,
	GIOITINH VARCHAR(3),
	NOISINH VARCHAR(40),
	MALOP CHAR(3) FOREIGN KEY REFERENCES LOP(MALOP)
);

------------------------------- GIANGDAY -----------------------
CREATE TABLE GIANGDAY (
	MALOP CHAR(3) FOREIGN KEY REFERENCES LOP(MALOP),
	MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
	MAGV CHAR(4) FOREIGN KEY REFERENCES GIAOVIEN(MAGV),
	HOCKY TINYINT,
	NAM SMALLINT,
	TUNGAY SMALLDATETIME,
	DENNGAY SMALLDATETIME,

	PRIMARY KEY(MALOP, MAMH)
);

--------------------------- KETQUATHI ----------------------
CREATE TABLE KETQUATHI (
	MAHV CHAR(5) FOREIGN KEY REFERENCES HOCVIEN(MAHV),
	MAMH VARCHAR(10) FOREIGN KEY REFERENCES MONHOC(MAMH),
	LANTHI TINYINT,
	NGTHI SMALLDATETIME,
	DIEM NUMERIC(4,2),
	KQUA VARCHAR(10),

	PRIMARY KEY(MAHV, MAMH, LANTHI)
);

ALTER TABLE HOCVIEN 
ADD GHICHU VARCHAR(60);

ALTER TABLE HOCVIEN 
ADD DIEMTB NUMERIC(4, 2);

ALTER TABLE HOCVIEN 
ADD XEPLOAI VARCHAR(10);

--------------------------- Cau 2 --------------------
-- Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học 
-- viên trong lớp. VD: “K1101” 
ALTER TABLE HOCVIEN
ADD CONSTRAINT MAHV_CHECK 
CHECK (
	LEN(MAHV) = 5 AND 
	SUBSTRING(MAHV, 1, 3) = MALOP AND 
	ISNUMERIC(SUBSTRING(MAHV, 4, 2)) = 1
);

--------------------------- Cau 3 --------------------
-- Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”. 
ALTER TABLE GIAOVIEN 
ADD CONSTRAINT GIOITINH_CHECK_GIAOVIEN CHECK (GIOITINH IN('Nam', 'Nu'));

ALTER TABLE HOCVIEN
ADD CONSTRAINT GIOITINH_CHECK_HOCVIEN CHECK (GIOITINH IN('Nam', 'Nu'));

-------------------------- Cau 4 ---------------------
-- Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22).
ALTER TABLE KETQUATHI
ADD CONSTRAINT DIEM_CHECK 
CHECK (DIEM >= 0 AND DIEM <= 10);

-------------------------- Cau 5 ---------------------
-- Kết quả thi là “Dat” nếu điểm từ 5 đến 10  và “Khong dat” nếu điểm nhỏ hơn 5. 
ALTER TABLE KETQUATHI
DROP COLUMN KQUA;

ALTER TABLE KETQUATHI
ADD KQUA AS (
	CASE 
		WHEN (DIEM >= 5 and DIEM <= 10) THEN 'Dat'
		ELSE 'Khong dat'
	END ) PERSISTED;


--------------------------- Cau 6 --------------------
-- Học viên thi một môn tối đa 3 lần. 
ALTER TABLE KETQUATHI
ADD CONSTRAINT LANTHI_CHECK CHECK (LANTHI <= 3);

--------------------------- Cau 7 --------------------
-- Học kỳ chỉ có giá trị từ 1 đến 3. 
ALTER TABLE GIANGDAY
ADD CONSTRAINT HOCKY_CHECK CHECK(HOCKY BETWEEN 1 AND 3);

--------------------------- Cau 8 --------------------
-- Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”. 
ALTER TABLE GIAOVIEN
ADD CONSTRAINT HOCVI_CHECK CHECK(HOCVI IN('CN', 'KS', 'Ths', 'TS', 'PTS'));
