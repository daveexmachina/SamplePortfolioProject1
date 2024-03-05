select
*
from
PortfolioProjects..NashvilleHousing

--standardize date format

select
nh.SaleDate
, CONVERT(date, nh.SaleDate)
from
PortfolioProjects..NashvilleHousing nh

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

-- doesn't work, I think, because column definition is still datetime
-- this works instead

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

-- populate property address data using parcel ID

select
*
from
PortfolioProjects..NashvilleHousing nh
--where
--nh.PropertyAddress is null
order by
nh.ParcelID

select
nh.ParcelID
, nh.PropertyAddress
, nh2.ParcelID
, nh2.PropertyAddress
, ISNULL(nh.PropertyAddress, nh2.PropertyAddress)
from
PortfolioProjects..NashvilleHousing nh
join PortfolioProjects..NashvilleHousing nh2
	on nh.ParcelID = nh2.ParcelID
	and nh.[UniqueID ] <> nh2.[UniqueID ]
where
nh.PropertyAddress is null

update nh
set PropertyAddress = ISNULL(nh.PropertyAddress, nh2.PropertyAddress)
from
PortfolioProjects..NashvilleHousing nh
join PortfolioProjects..NashvilleHousing nh2
	on nh.ParcelID = nh2.ParcelID
	and nh.[UniqueID ] <> nh2.[UniqueID ]
where
nh.PropertyAddress is null

-- split address into separate columns

select
nh.PropertyAddress
from
PortfolioProjects..NashvilleHousing nh

select
substring(nh.PropertyAddress, 1, CHARINDEX(',', nh.PropertyAddress)-1) Address
, substring(nh.PropertyAddress, CHARINDEX(',', nh.PropertyAddress)+1, LEN(nh.PropertyAddress)) City
from
PortfolioProjects..NashvilleHousing nh

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--split owner address into separate columns

select
OwnerAddress
from
PortfolioProjects..NashvilleHousing

select
PARSENAME(replace(OwnerAddress, ',', '.'), 3)
, PARSENAME(replace(OwnerAddress, ',', '.'), 2)
, PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from
PortfolioProjects..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

-- change Y and N to Yes and No in Sold as Vacant

select 
distinct(SoldAsVacant)
, COUNT(SoldAsVacant)
from
PortfolioProjects..NashvilleHousing
group by
SoldAsVacant
order by 2

select 
SoldAsVacant
, case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from
PortfolioProjects..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- remove duplicates

with RowNumCTE as (
select
*
, ROW_NUMBER() over (
	partition by 
		ParcelID,
		PropertyAddress,
		SaleDate,
		LegalReference
	order by
		UniqueID
	) RowNum
from
PortfolioProjects..NashvilleHousing 
)
select
*
from
RowNumCTE
where
RowNum > 1
order by
PropertyAddress

with RowNumCTE as (
select
*
, ROW_NUMBER() over (
	partition by 
		ParcelID,
		PropertyAddress,
		SaleDate,
		LegalReference
	order by
		UniqueID
	) RowNum
from
PortfolioProjects..NashvilleHousing 
)
delete from
RowNumCTE
where
RowNum > 1

-- delete unused columns

select
*
from
PortfolioProjects..NashvilleHousing

alter table PortfolioProjects..NashvilleHousing
drop column 
OwnerAddress,
TaxDistrict,
PropertyAddress