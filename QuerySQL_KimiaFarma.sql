
-- /* create table base */
-- with tablebase as (
-- SELECT p1.tanggal, case when extract(month from tanggal)  = 1 then 'January'
--             when extract(month from tanggal)  = 2 then 'February'
--             when extract(month from tanggal)  = 3 then 'March'
--             when extract(month from tanggal)  = 4 then 'April'
--             when extract(month from tanggal)  = 5 then 'May' 
--             else 'June' end as bulan, 
-- p1.id_invoice, p1.id_customer, p2.string_field_1 as level, p2.string_field_2 as nama, p2.	
-- string_field_3 as id_cabang_sales, p2.string_field_4 as cabang_sales, p2.string_field_5 as id_distributor,
-- p2.string_field_6 as grup, p1.id_barang, b.nama_barang, b.sektor,  b.tipe, b.nama_tipe, p1.unit, p1.mata_uang, 
-- p1.jumlah_barang, p1.harga, round(sum(p1.jumlah_barang * p1.harga),3) as total_penjualan 
-- FROM `propane-avatar-329612.BIA_KimiaFarma.data_penjualan` as p1
-- left join `propane-avatar-329612.BIA_KimiaFarma.data_pelanggan` as p2 on p1.id_customer = p2.string_field_0
-- left join `propane-avatar-329612.BIA_KimiaFarma.data_barang` as b on  p1.id_barang=b.kode_barang

-- group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
-- ),
-- tablebase2 as (
-- select tanggal, bulan, id_invoice, id_customer, level, nama, id_cabang_sales, cabang_sales,
-- case when cabang_sales = 'Tangerang' then 'Banten'
--      when cabang_sales = 'Jakarta' then 'DKI Jakarta'
--      when cabang_sales = 'Aceh' then 'Aceh'
--      when cabang_sales = 'Lampung' then 'Lampung'
--      when cabang_sales = 'Padang' then 'Sumatera Barat'
--      else 'Jawa Barat' end as Provinsi,
-- id_distributor, grup, id_barang, nama_barang, sektor, tipe, nama_tipe, unit, mata_uang, jumlah_barang, harga, total_penjualan from tablebase
-- ) select* tablebase2;


/*mencari 3 barang terlaris dari setiap kota di bulan mei 2022 */
with barang_terlaris as ( 
select bulan, id_cabang_sales,cabang_sales, provinsi, nama_barang, sum(jumlah_barang) as barang_terjual, rank() over (partition by cabang_sales order by sum(jumlah_barang) desc) as rank from `propane-avatar-329612.BIA_KimiaFarma.dataset_penjualan` where cabang_sales not in ('Jakarta','Lampung','Aceh') and bulan = 'May'
group by 1,2,3,4,5

) select * from barang_terlaris 
where rank between 1 and 3
order by cabang_sales, rank asc;


/*mencari transaksi terbesar di bulan juni*/
select * from `propane-avatar-329612.BIA_KimiaFarma.dataset_penjualan`
where total_penjualan = (select max(total_penjualan) from `propane-avatar-329612.BIA_KimiaFarma.dataset_penjualan` where bulan ='June') and bulan = 'June';

/*mencari rata-rata penjualan, penjualan terbesar, penjualan terkecil pada setiap bulan */
select bulan, round(avg(total_penjualan),3) as avg_penjualan, max(total_penjualan) as max_penjualan, min(total_penjualan) as min_penjualan from `propane-avatar-329612.BIA_KimiaFarma.dataset_penjualan` 
group by 1;

/*mencari rata-rata penjualan, penjualan terbesar, penjualan terkecil pada setiap nama distributor*/
select nama as nama_distributor,  round(avg(total_penjualan),3) as avg_penjualan, max(total_penjualan) as max_penjualan, min(total_penjualan) as min_penjualan from `propane-avatar-329612.BIA_KimiaFarma.dataset_penjualan` 
group by 1;

 /* analisis penjualan di 3 bulan terakhir per provinsi*/
select bulan, provinsi, sum(jumlah_barang) as jumlah_barang, round(sum(total_penjualan),2) as revenue
from `propane-avatar-329612.BIA_KimiaFarma.dataset_penjualan` 
where extract(month from tanggal) between 4 and 6
group by 1,2
order by 
case bulan when 'April' then 1
           when 'May' then 2
           else 3
           end, 4 desc;

/*Analisis mingguan penjualan di bulan mei*/
with agg_mei as (
select extract(week from tanggal) as Mei, sum(jumlah_barang) as jumlah_barang, round(sum(total_penjualan),2) as revenue from `propane-avatar-329612.BIA_KimiaFarma.dataset_penjualan`
where tanggal between '2022-05-01' and '2022-05-31'
group by 1
order by 1
 ) select *, case Mei when 18 then 'Minggu -1'
                      when 19 then 'Minggu -2'
                      when 20 then 'Minggu -3'
                      when 21 then 'Minggu -4'
                      else 'Minggu -5' end as minggu
                      from agg_mei;

/* Analisis penjualan harian pada bulan mei di provinsi DKI Jakarta*/
select tanggal, count(id_customer) as transaksi,sum(jumlah_barang) as barang_tejual, round(sum(total_penjualan),2) as revenue from `propane-avatar-329612.BIA_KimiaFarma.dataset_penjualan`
where extract(month from tanggal) = 5 and Provinsi = 'DKI Jakarta'
group by 1
order by 1;

/* mencari Pembeli terbanyak di bulan mei di provinsi DKI Jakarta*/
select id_customer, count(id_customer) as transaksi, sum(jumlah_barang) as `total barang dibeli`, sum(total_penjualan) as `total pembelian`
from `propane-avatar-329612.BIA_KimiaFarma.dataset_penjualan`
where extract(month from tanggal) = 5 and provinsi = 'DKI Jakarta'
group by 1
order by 4 desc;
                      

/*Perbandingan total revenue dari seluruh provinsi*/
with rev_provinsi as (
select Provinsi, round(sum(total_penjualan),2) as revenue from `propane-avatar-329612.BIA_KimiaFarma.dataset_penjualan`
group by 1
)select *,concat(round(rev_provinsi.revenue / (select sum(revenue) from rev_provinsi) * 100,1), '%') as percentage
from rev_provinsi;

/*Analisis penjualan di Provinsi Jawa Barat*/
with cabang_sales as (
select cabang_sales,  count(id_customer) as `Total Transaksi`, sum(jumlah_barang) as `Barang Terjual`, round(sum(total_penjualan),2) as `Revenue` from `propane-avatar-329612.BIA_KimiaFarma.dataset_penjualan`
where Provinsi = 'Jawa Barat'
group by 1
)select *, concat(round(Revenue / (select sum(Revenue) from cabang_sales) *100,2), '%') as `persentasi perbandingan revenue di Jawa Barat`  from cabang_sales




-- Query lebih lengkap bisa di lihat di Google Big Query




