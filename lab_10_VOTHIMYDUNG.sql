create database QLSV
use QLSV
create table Lop(
MaLop char(5) not null primary key, 
TenLop nvarchar(20), 
SiSo int)
create table Sinhvien(
MaSV char(5) not null primary key,
Hoten nvarchar(20), 
Ngaysinh date, 
MaLop char(5) constraint fk_malop references lop(malop))
create table MonHoc(
MaMH char(5) not null primary key, 
TenMH nvarchar(20))
create table KetQua(
MaSV char(5) not null, 
MaMH char(5) not null, 
Diemthi float,
constraint fk_Masv foreign key(MaSV) references sinhvien(MaSV),
constraint fk_Mamh foreign key(MaMH) references Monhoc(MaMH),
constraint pk_Masv_Mamh primary key(Masv, mamh))
insert lop values
('A','lop a',0),
('B','lop b',0),
('C','lop c',0)
insert sinhvien values
('01','My Dung','2002-1-1','A'),
('02','Van Tan','2002-11-1','A'), 
('03','My Hanh','2001-12-12','A')
insert monhoc values
('LTHDT','Lap Trinh Huong Doi Tuong'), 
('CSDL','Co so du lieu'), 
('SQL','He quan tri CSDL'), 
('PTW','Phat trien Web')
insert KetQua values
('01','PPLT',8), 
('01','SQL',7), 
('02','PPLT',8), 
('01','CSDL',5), 
('02','PTW',5)

--1.Vi?t h�m diemtb d?ng Scarlar function t�nh ?i?m trung b�nh c?a m?t sinh vi�n b?t k?
go
create function diemtb (@msv char(5))
returns float
as
begin
 declare @tb float
 set @tb = (select avg(Diemthi)
 from KetQua
 where MaSV=@msv) 
 return @tb
end
go
select dbo.diemtb ('01')

--2.Vi?t h�m b?ng 2 c�ch (table � value fuction v� multistatement value function) t�nh ?i?m trung b�nh c?a 
--c? l?p, th�ng tin g?m MaSV, Hoten, ?iemTB, s? d?ng h�m diemtb ? c�u 1
go
--c�ch 1
create function trbinhlop(@malop char(5))
returns table
as
return
 select s.masv, Hoten, trungbinh=dbo.diemtb(s.MaSV)
 from Sinhvien s join KetQua k on s.MaSV=k.MaSV
 where MaLop=@malop
 group by s.masv, Hoten
--c�ch 2
go
create function trbinhlop1(@malop char(5))
returns @dsdiemtb table (masv char(5), tensv nvarchar(20), dtb float)
as
begin
 insert @dsdiemtb
 select s.masv, Hoten, trungbinh=dbo.diemtb(s.MaSV)
 from Sinhvien s join KetQua k on s.MaSV=k.MaSV
 where MaLop=@malop
 group by s.masv, Hoten
 return
end
go
select*from trbinhlop1('A')

--3.Vi?t m?t th? t?c ki?m tra m?t sinh vi�n ?� thi bao nhi�u m�n, tham s? l� MaSV, (VD sinh vi�n c� MaSV=01
thi 3 m�n) k?t qu? tr? v? chu?i th�ng b�o �Sinh vi�n 01 thi 3 m�n� ho?c �Sinh vi�n 01 kh�ng thi m�n 
n�o�
go
create proc ktra @msv char(5)
as
begin 
 declare @n int
 set @n=(select count(*) from ketqua where Masv=@msv)
 if @n=0 
 print 'sinh vien '+@msv + 'khong thi mon nao'
 else
 print 'sinh vien '+ @msv+ 'thi '+cast(@n as char(2))+ 'mon'
end 
go
exec ktra '01'

--4.Vi?t m?t trigger ki?m tra s? s? l?p khi th�m m?t sinh vi�n m?i v�o danh s�ch sinh vi�n th� h? th?ng c?p
--nh?t l?i siso c?a l?p, m?i l?p t?i ?a 10SV, n?u th�m v�o >10 th� th�ng b�o l?p ??y v� h?y giao d?ch
go
create trigger updatesslop
on sinhvien
for insert
as
begin
 declare @ss int
 set @ss=(select count(*) from sinhvien s 
 where malop in(select malop from inserted))
 if @ss>10
 begin
 print 'Lop day'
 rollback tran
 end
 else
 begin
 update lop
 set SiSo=@ss
 where malop in (select malop from inserted)
 end

