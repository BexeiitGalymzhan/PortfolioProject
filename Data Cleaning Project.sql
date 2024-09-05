select *
from projectportfolio..NashvilleHousing




--Standardize date format
select saledateconverted, CONVERT(date,saledate)
from projectportfolio..NashvilleHousing

update projectportfolio..NashvilleHousing
set SaleDate =  cast(saledate as date)

alter table projectportfolio..NashvilleHousing
add SaleDateConverted date

update projectportfolio..NashvilleHousing
set SaleDateConverted =  cast(saledate as date)


--Populate property address data
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from projectportfolio..NashvilleHousing a
join projectportfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID and 
		a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a 
set a.propertyaddress = isnull(a.PropertyAddress, b.PropertyAddress)
from projectportfolio..NashvilleHousing a
join projectportfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID and 
		a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into individual columns
select SUBSTRING(propertyaddress , 1, charindex(',',propertyaddress)-1),
SUBSTRING(propertyaddress ,charindex(',',propertyaddress)+1, len(propertyaddress))
from projectportfolio..NashvilleHousing

alter table projectportfolio..NashvilleHousing
add propertysplitaddress nvarchar(255)

update projectportfolio..NashvilleHousing
set propertysplitaddress = SUBSTRING(propertyaddress , 1, charindex(',',propertyaddress)-1)

alter table projectportfolio..NashvilleHousing
add propertysplitcity nvarchar(255)

update projectportfolio..NashvilleHousing
set propertysplitcity = SUBSTRING(propertyaddress ,charindex(',',propertyaddress)+1, len(propertyaddress))

select *
from projectportfolio..NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
		PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from projectportfolio..NashvilleHousing


alter table projectportfolio..NashvilleHousing
add ownersplitaddress nvarchar(255)

update projectportfolio..NashvilleHousing
set ownersplitaddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

alter table projectportfolio..NashvilleHousing
add ownerspitcity nvarchar(255)

update projectportfolio..NashvilleHousing
set ownerspitcity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


alter table projectportfolio..NashvilleHousing
add ownersplitstate nvarchar(255)

update projectportfolio..NashvilleHousing
set ownersplitstate = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)



--change Y and N to Yes and No in 'Sold as Vacant' column

select distinct(soldasvacant)
from projectportfolio..NashvilleHousing


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from projectportfolio..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 
	case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end


--Remove Duplicates
with rownumcte as(
select *, 
ROW_NUMBER() over(
partition by parcelid, 
			 propertyaddress,
			 saleprice,
			 saledate,
			 legalreference
			 order by uniqueid
			 ) row_num
from projectportfolio..NashvilleHousing
)
delete
from rownumcte
where row_num >1
--order by PropertyAddress


--Delete unused columns 
select *
from projectportfolio..NashvilleHousing


ALTER TABLE projectportfolio..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

