SELECT * FROM layoffs;

-- 1. Remove Duplicates
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT layoffs_staging SELECT * FROM layoffs;

with duplicates_cte as
(SELECT *, row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, 'date', funds_raised_millions) as row_num 
FROM layoffs_staging)
select * from duplicates_CTE where row_num>1;

select * from layoffs_staging where company like 'Casper';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

insert into layoffs_staging2
SELECT *, row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, 'date', funds_raised_millions) as row_num 
FROM layoffs_staging;

delete from layoffs_staging2 where row_num>1;

 -- 2. Standardazing data
select company,trim(company) from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select * from layoffs_staging2 where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto' 
where industry like 'Crypto%';

select distinct country  from layoffs_staging2 where country like'United States%';

select distinct country, trim(trailing '.' from country) from layoffs_staging2 order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like'United States%';

select `date`, str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');
alter table layoffs_staging2
modify column `date` DATE;

-- 3. Null and blank values and removing columns

select * from layoffs_staging2
 where total_laid_off is null and percentage_laid_off is null;
 
 select distinct industry from layoffs_staging2
 where industry is null or industry = '';
 
 select * from layoffs_staging2
 where company like'Bally%';
 
 select * from layoffs_staging2 t1
 join layoffs_staging2 t2 on t1.company = t2.company and t1.location = t2.location
 where (t1.industry is null or t1.industry ='') and t2.industry is not null;
 
 update layoffs_staging2
 set industry = null
 where industry = '';
 
 update layoffs_staging2 t1
 join layoffs_staging2 t2 on t1.company = t2.company and t1.location = t2.location
 set t1.industry = t2.industry where t1.industry is null and t2.industry is not null;
 
 delete from layoffs_staging2
 where  total_laid_off is null and percentage_laid_off is null;
 
 alter table layoffs_staging2
 drop column row_num;
 
 select * from layoffs_staging2;
 
 
 -- Exploratory Data Analysis
 
 Select max(total_laid_off), max(percentage_laid_off)
 from layoffs_staging2;
 
 select * from layoffs_staging2 where percentage_laid_off=1
 order by funds_raised_millions desc; 
 
 select company, sum(total_laid_off)
 from layoffs_staging2 group by company order by 2 desc;
 
  select min(`date`), MAX(`date`) from layoffs_staging2;
 
 select industry, sum(total_laid_off)
 from layoffs_staging2 group by industry order by 2 desc;
 
 select country, sum(total_laid_off)
 from layoffs_staging2 group by country order by 2 desc; 
 
 select year(`date`), sum(total_laid_off)
 from layoffs_staging2 group by year(`date`) order by 1 desc;
 
 select stage, sum(total_laid_off)
 from layoffs_staging2 group by stage order by 1 desc; 
 
 select company, sum(percentage_laid_off)
 from layoffs_staging2 group by company order by 2 desc;
 
 
 select substring(`date`,1,7) as `month` , sum(total_laid_off)
 from layoffs_staging2 where substring(`date`,1,7) is not null 
 group by `month`
 order by 1 asc;
 
with rolling_total as (
 select substring(`date`,1,7) as `month` , sum(total_laid_off) as total_off
 from layoffs_staging2 where substring(`date`,1,7) is not null 
 group by `month`
 order by 1 asc
)
select `month`, total_off,sum(total_off) over(order by `month`) as rolling_total
from rolling_total;

 select company, sum(total_laid_off)
 from layoffs_staging2 group by company order by 2 desc;
  
  select company, year(`date`),sum(total_laid_off)
 from layoffs_staging2 group by company,year(`date`) order by 3 desc;
 
 with company_year(company, years, total_laid_off) as(
   select company, year(`date`),sum(total_laid_off)
 from layoffs_staging2 group by company,year(`date`) 
 ), 
 company_year_rank as(
 select *, dense_rank() over(partition by years order by total_laid_off desc) as `ranking`
 from company_year
 where years is not null)
 select * from company_year_rank
 where ranking <=5;
 
 
 
 