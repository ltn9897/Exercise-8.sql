CREATE DATABASE QLKhoaHoc
GO
USE QLKhoaHoc
GO
CREATE TABLE HocVien
(
	mahv INT PRIMARY KEY,
	hohv VARCHAR(30),
	tenhv VARCHAR(20),
	ngaysinh SMALLDATETIME,
	diachi NVARCHAR(50)
)
CREATE TABLE KhoaHoc
(
	makh CHAR(10) PRIMARY KEY,
	tenkh VARCHAR(50),
	ngaybd SMALLDATETIME,
	ngaykt SMALLDATETIME
)
CREATE TABLE GiaoVien
(
	magv INT PRIMARY KEY,
	hoten VARCHAR(50)
)
CREATE TABLE LopHoc
(
	malop INT PRIMARY KEY,
	tenlop VARCHAR(30),
	makh CHAR(10) FOREIGN KEY REFERENCES KhoaHoc,
	magv INT FOREIGN KEY REFERENCES giaovien,
	siso INT,
	phonghoc INT
)
CREATE TABLE Bienlai
(
	sobl INT IDENTITY(1,1) PRIMARY KEY,
	makh CHAR(10) FOREIGN KEY REFERENCES KhoaHoc,
	malop INT FOREIGN KEY REFERENCES LopHoc,
	mahv INT FOREIGN KEY REFERENCES HocVien,
	diem FLOAT DEFAULT 0,
	ketqua VARCHAR (20),
	hocphi MONEY
)
--Q1: tao trigger bang khoaHoc,
-- kiem tra rang buoc ngaybd phai nho hon ngaykt
GO
ALTER TRIGGER tg_NgayKH
ON KhoaHoc FOR INSERT, UPDATE
AS
	--DECLARE @ngaybd SMALLDATETIME
	--DECLARE @ngaykt SMALLDATETIME
	--SELECT @ngaybd = ngaybd, @ngaykt = ngaykt FROM inserted
	--IF (@ngaybd >= @ngaykt)
	IF (UPDATE(ngaybd) or UPDATE(ngaykt))
		IF exists (SELECT * FROM inserted i, deleted d 
			WHERE i.makh = d.makh and i.ngaybd > i.ngaykt)
			BEGIN
				PRINT 'KHONG THE CAP NHAT NGAY.'
				ROLLBACK TRAN
				RETURN
			END
	IF exists (SELECT * FROM inserted WHERE ngaybd > ngaykt)
		BEGIN
			PRINT 'NGAY BAT DAU PHAI NHO HON NGAY KET THUC'
			ROLLBACK TRAN
			RETURN
		END
GO
SET DATEFORMAT DMY
INSERT INTO KhoaHoc VALUES ('TH22','Java Web','01-07-2020','01-06-2020')
UPDATE KhoaHoc SET ngaybd = '01-07-2020' WHERE makh = 'TH20'
UPDATE KhoaHoc SET ngaykt = '01-03-2020' WHERE makh = 'TH20'
UPDATE KhoaHoc SET ngaykt = '01-03-2020', ngaybd = '01-07-2020' WHERE makh = 'TH20'
SELECT * FROM KhoaHoc
GO
--Q2: tao trigger bang BienLai,
-- kiem tra rang buoc diem phai nam trong khoang 0- 10
CREATE TRIGGER tg_DiemBL
ON BienLai FOR INSERT, UPDATE
AS
	--DECLARE @diem FLOAT
	--SELECT @diem = diem FROM inserted
	--IF (@diem < 0 OR @diem > 10)
	IF (UPDATE(diem))
		IF exists (SELECT * FROM inserted i, deleted d
			WHERE i.sobl = d.sobl and i.diem < 0 or i.diem > 10)
			BEGIN
				PRINT 'KHONG THE CAP NHAT DIEM'
				ROLLBACK TRAN
				RETURN
			END
	IF exists (SELECT * FROM inserted WHERE diem < 0 or diem > 10)
		BEGIN 
			PRINT 'DIEM KHONG HOP LE.'
			ROLLBACK TRAN
			RETURN
		END
GO
INSERT INTO GiaoVien VALUES (1,'BINH')
INSERT INTO LopHoc VALUES (1, 'Lap Trinh', 'TH20', 1, 10, 101)
SELECT * FROM LopHoc
INSERT INTO HocVien VALUES (1, 'TRAN', 'KHOA', '15-05-1996','1 LE LAI, HCM')
INSERT INTO Bienlai (makh, malop, mahv, diem, ketqua, hocphi)
VALUES ('TH20',1,1,-1,'DAU',2000)
UPDATE Bienlai SET diem = -20 WHERE sobl = 2
SELECT * FROM Bienlai
GO
--Q3: tao trigger bang BienLai,
-- kiem tra rang buoc  ketqua chi nhan gia 'khong dau' va 'dau'
ALTER TRIGGER tg_KetQuaBL
ON BienLai FOR INSERT, UPDATE
AS
	--select * from inserted
	--select * from deleted
	--DECLARE @ketqua VARCHAR(20)
	--SELECT @ketqua = @ketqua FROM inserted
	--IF (@ketqua != 'kHONG DAU' OR @ketqua != 'DAU')
	IF (UPDATE(ketqua))
		IF exists (SELECT * FROM inserted i, deleted d
			WHERE i.sobl = d.sobl and i.ketqua <> 'KHONG DAU' and i.ketqua <> 'DAU')
			BEGIN
				PRINT 'KHONG THE CAP NHAT KET QUA.'
				ROLLBACK TRAN
				RETURN
			END
	IF exists (SELECT * FROM inserted 
		WHERE ketqua <> 'KHONG DAU' and ketqua <> 'DAU')
		BEGIN
			PRINT 'KET QUA NHAP VAO KHONG HOP LE.'
			ROLLBACK TRAN
			RETURN
		END
GO
INSERT INTO Bienlai (makh, malop, mahv, diem, ketqua, hocphi)
VALUES ('TH20',1,1,10,'rot',2000)
UPDATE Bienlai SET ketqua = 'trung' WHERE sobl = 2
SELECT * FROM Bienlai
GO
--IF ('khong Dau' <> 'KHONG DAU')
--print 'true' else print 'false'
--GO
--Q4: tao trigger bang LopHoc,
-- kiem tra makh co ton tai chua khi them 1 lophoc moi.
-- Neu chua hien thi thong bao loi.
ALTER TRIGGER tg_MakhLH
ON LopHoc INSTEAD OF INSERT
AS
	IF not exists (SELECT * FROM inserted i, KhoaHoc kh WHERE i.makh = kh.makh)
		BEGIN
			PRINT 'MA KHOA HOC KHONG TON TAI.'
			ROLLBACK TRAN
			RETURN
		END
	INSERT INTO LopHoc SELECT * FROM inserted
GO
INSERT INTO LopHoc VALUES (4, 'HTML5', 'TH21', 1, 10, 102)
INSERT INTO KhoaHoc VALUES ('TH22','Java Web','01-03-2020','01-06-2020')
SELECT * FROM LopHoc
SELECT * FROM KhoaHoc