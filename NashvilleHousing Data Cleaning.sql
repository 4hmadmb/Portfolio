 /*

Cleaning the Nashville Housing Data using SQL

*/


Select *
From NashvilleHousing


-- Standardize Date Format

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date;

Select SaleDate
From NashvilleHousing


-- Populating Null Property Address using self join

Select *
From PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID


Select N1.ParcelID, N1.PropertyAddress, N2.ParcelID, N2.PropertyAddress, ISNULL(N1.PropertyAddress,N2.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing N1
JOIN PortfolioProject.dbo.NashvilleHousing N2
	on N1.ParcelID = N2.ParcelID
	AND N1.[UniqueID ] != N2.[UniqueID ]
Where N1.PropertyAddress is null


Update N1
SET PropertyAddress = ISNULL(N1.PropertyAddress,N2.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing N1
JOIN PortfolioProject.dbo.NashvilleHousing N2
	on N1.ParcelID = N2.ParcelID
	AND N1.[UniqueID ] != N2.[UniqueID ]
Where N1.PropertyAddress is null



-- Breaking out Property & Owner Address into Individual Columns (Address, City, State)

--Property Adress using Substring and CharIndex

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




--Owner address using parsename

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Removing Duplicates

WITH RowNoCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_no

From PortfolioProject.dbo.NashvilleHousing
)
--DELETE
--From RowNoCTE
--Where row_no > 1
Select *
from RowNoCTE
where row_no > 1
order by PropertyAddress



-- Deleting Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


