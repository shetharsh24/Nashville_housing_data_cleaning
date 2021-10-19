-------Converting SaleDate into proper format------
select SaleDateConverted, CONVERT(Date,SaleDate)
from dbo.[Nashville Housing Data for Data Cleaning]

update dbo.[Nashville Housing Data for Data Cleaning]
set SaleDate = CONVERT(Date,SaleDate)

alter table dbo.[Nashville Housing Data for Data Cleaning]
add SaleDateConverted Date

update dbo.[Nashville Housing Data for Data Cleaning]
set SaleDateConverted = CONVERT(Date,SaleDate)

-------Removing Nulls from Property Address Data------

--- Looking at the null values---
select *
from dbo.[Nashville Housing Data for Data Cleaning]
--where PropertyAddress is null
order by ParcelID

--By looking at the columns we can determine that Parcel id is same where property address is also same. So, we can populate the property address with the help
--of Parcel id

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.[Nashville Housing Data for Data Cleaning] a
join dbo.[Nashville Housing Data for Data Cleaning] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.[Nashville Housing Data for Data Cleaning] a
join dbo.[Nashville Housing Data for Data Cleaning] b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--- Breaking the Address into Individual Columns (Address, City, State)

select PropertyAddress,
substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address
from dbo.[Nashville Housing Data for Data Cleaning]

alter table dbo.[Nashville Housing Data for Data Cleaning]
add PropertyAddressSplit Nvarchar(255)

update dbo.[Nashville Housing Data for Data Cleaning]
set PropertyAddressSplit = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table dbo.[Nashville Housing Data for Data Cleaning]
add PropertyCity Nvarchar(255)

update dbo.[Nashville Housing Data for Data Cleaning]
set PropertyCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select 
Parsename(Replace(OwnerAddress,',','.'), 3),
Parsename(Replace(OwnerAddress,',','.'), 2),
Parsename(Replace(OwnerAddress,',','.'), 1)
from dbo.[Nashville Housing Data for Data Cleaning]

alter table dbo.[Nashville Housing Data for Data Cleaning]
add OwnerStateName Nvarchar(255)

update dbo.[Nashville Housing Data for Data Cleaning]
set OwnerStateName = Parsename(Replace(OwnerAddress,',','.'), 1)

alter table dbo.[Nashville Housing Data for Data Cleaning]
add OwnerStateCity Nvarchar(255)

update dbo.[Nashville Housing Data for Data Cleaning]
set OwnerStateCity = Parsename(Replace(OwnerAddress,',','.'), 2)

alter table dbo.[Nashville Housing Data for Data Cleaning]
add OwnerStateAddress Nvarchar(255)

update dbo.[Nashville Housing Data for Data Cleaning]
set OwnerStateAddress = Parsename(Replace(OwnerAddress,',','.'), 3)


--Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldasVacant), COUNT(SoldasVacant)
from dbo.[Nashville Housing Data for Data Cleaning]
group by SoldAsVacant
order by COUNT(SoldasVacant) asc

select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from dbo.[Nashville Housing Data for Data Cleaning]

update dbo.[Nashville Housing Data for Data Cleaning]
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
				   when SoldAsVacant = 'N' then 'No'
				   else SoldAsVacant
	               end

select *
from dbo.[Nashville Housing Data for Data Cleaning]

-- Remove Duplicates


with rownumCTE as(
select *,
		ROW_NUMBER() over(
		partition by ParcelID,
					 PropertyAddress,
					 SaleDate,
					 SalePrice,
					 LegalReference
					 order by uniqueid)
					 row_num


from dbo.[Nashville Housing Data for Data Cleaning]
--order by parcelid
)

delete
from rownumCTE
where row_num > 1


--Delete ununsed columns


select *
from dbo.[Nashville Housing Data for Data Cleaning]

alter table dbo.[Nashville Housing Data for Data Cleaning]
drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate