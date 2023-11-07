/*
Cleaning Data in SQL Queries
*/
select *
from PortfolioProjects..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

select SaleDate
from PortfolioProjects..NashvilleHousing


Select SaleDate, Convert(Date,SaleDate)
from PortfolioProjects..NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert (Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)

Select SaleDateConverted, Convert(Date,SaleDate)
from PortfolioProjects..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data

select*
from PortfolioProjects..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--After the Update Function rerun the main function

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProjects..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
from PortfolioProjects..NashvilleHousing

--To remove the comma from the address from the two different columns at the back of the first column and at the front of the second column


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)  -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)  +1 , LEN(PropertyAddress)) AS Address
from PortfolioProjects..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)  -1)

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)  +1 , LEN(PropertyAddress))

select *
from PortfolioProjects..NashvilleHousing


--To split the owner address with Parsename instead of using substring

select
PARSENAME(Replace(OwnerAddress, ',', '.') , 3) 
,PARSENAME(Replace(OwnerAddress, ',', '.') , 2) 
,PARSENAME(Replace(OwnerAddress, ',', '.') , 1) 
from PortfolioProjects..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 3) 

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') , 2) 

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') , 1) 

select *
from PortfolioProjects..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

select  Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProjects..NashvilleHousing
Group by SoldAsVacant
Order by 2

 --using the Case statement

 select SoldAsVacant
 , Case when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 end
from PortfolioProjects..NashvilleHousing


Update NashvilleHousing
SET  SoldAsVacant =
Case when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 end

 select  Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProjects..NashvilleHousing
Group by SoldAsVacant
Order by 2

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates using CTE'S

with RowNumCTE AS(
select *, 
Row_NUMBER() over (
partition by 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by
UniqueID
) row_num
from PortfolioProjects..NashvilleHousing
--order by ParcelID
)
Select *
from RowNumCTE
Where Row_Num > 1
Order by PropertyAddress

--Deleting the duplicate

with RowNumCTE AS(
select *, 
Row_NUMBER() over (
partition by 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by
UniqueID
) row_num
from PortfolioProjects..NashvilleHousing
--order by ParcelID
)
Delete
from RowNumCTE
Where Row_Num > 1
--Order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Deleting	Unused Columns

select *
from PortfolioProjects..NashvilleHousing

Alter Table PortfolioProjects..NashvilleHousing
Drop column SaleDate, OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProjects..NashvilleHousing
Drop column SalesDateConverted
