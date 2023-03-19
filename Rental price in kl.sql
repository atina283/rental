-- to check for duplication
select ads_id ,count( ads_id) from  rental.rentalkl group by 1;
select count(prop_name),count(ads_id) from rental.rentalkl;

select ads_id,count(ads_id) from rental.rentalkl
group by 1
having count(ads_id)>1

USE rental;


-- Clean table
-- drop table rental_kl;
create temporary table rental_kl 
select ads_id,
prop_name,
completion_year,
replace(trim(trailing 'per month' from SUBSTRING(MONTHLY_RENT,4)),' ',"")as Monthly_rent2, -- to remove RM PER month from strings
trim(leading 'Kuala Lumpur -' from location) as location2, -- remove KUALA LUMPUR from string
property_type,
rooms,
parking,
bathroom,
trim(trailing 'sq.ft.' from size) as unit_size, -- remove sqft from strings
furnished,
facilities,
additional_facilities
from (select *,
row_number()over(partition by ads_id order by ads_id asc) as row_num -- remove duplication
from rental.rentalkl )a
where a.row_num=1
;

-- to change data type for easy sorting
ALTER TABLE rental_kl    
MODIFY Monthly_rent2 integer;  

-- some property listed are for sell instead of rental and some are not accurate
-- drop table rental_kl2;
create temporary table rental_kl2
select * from rental_kl
where monthly_rent2 between '400' and '20000'
and unit_size>400
; 


-- checking: select * from rental_kl where ads_id='100323185'
select count(*)from rental_kl--9481
select count(*)from rental_kl2-9345

-- TO CALCULATE AVERAGE OF MONTHLY RENT BASED ON ROOM SIZE 
select prop_name, unit_size, furnished, round(avg(monthly_rent2),2) as average_monthly
from rental_kl 
group by 1,2,3

-- Prop name with the highest montly rent
select prop_name, unit_size, furnished, facilities,monthly_rent2 from rental_kl2 
order by monthly_rent2 desc 
limit 1;
-- Embassyview	7506	Partially Furnished	Security, Barbeque area, Sauna, Playground, Swimming Pool, Tennis Court, Jogging Track, Gymnasium, Parking, Lift	18500

-- top 5 area with highest property montly rent
select distinct location2, max(monthly_rent2) from rental_kl2
group by 1
order by max(monthly_rent2) desc 
limit 5;

 /*  Ampang Hilir	18500
 KLCC	17000
 City Centre	13500
 Mont Kiara	13000
 Cheras	12500*/


-- top 5 area with the lowest property monthly rent for 1000sqft
select distinct location2, MIN(monthly_rent2) from rental_kl2
group by 1
order by MIN(monthly_rent2) asc
limit 5;
 /* Wangsa Maju	400
 Setapak	450
 Cheras	500
 Bukit Jalil	530
 OUG	550*/

-- property type vs rental price
select distinct property_type, max(monthly_rent2) from rental_kl2
group by 1
order by max(monthly_rent2) asc
-- others include terrace, rumah kampung, shop lot

 /*Flat	1800
Others	4000
Studio	5000
Duplex	7500
Service Residence	9500
Townhouse Condo	13500
Apartment	15000
Condominium	18500  */


-- COMPARING PRICE PER SQFT
-- top 10 prop with highest price per sqft
select distinct PROP_NAME, MONTHLY_RENT2/unit_size as PSF from rental_kl2
order by psf desc
limit 10;

/*Lucentia Residence @ Bukit Bintang City Centre KL	8.1498
Scarletz	7.7778
Banyan Tree	7.6468
Scarletz	7.5556
Lucentia Residence @ Bukit Bintang City Centre KL	7.4890
Banyan Tree	7.2491
Banyan Tree	6.9477
Expressionz Professional Suites	6.9337
Lucentia Residence @ Bukit Bintang City Centre KL	6.5537
Pavilion Suites	6.5278*/

