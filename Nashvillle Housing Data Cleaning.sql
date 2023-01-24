
/* 
Cleaning Nashville Housing Data Using SQL Queries
*/

SELECT * 
FROM dbo.NashvilleHousing

-------------------------------------------------------------------------------------------
-- Standardize Date Format
SELECT SaleDate, CONVERT(datetime, SaleDate)
FROM dbo.NashvilleHousing

Update dbo.NashvilleHousing
SET SaleDate = CONVERT(datetime, SaleDate)

-- or
ALTER TABLE dbo.NashvilleHousing
ADD SaleDateConverted date

Update dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(datetime, SaleDate)


-------------------------------------------------------------------------------------------
-- Populate Property Address Data
SELECT *
FROM dbo.NashvilleHousing
-- where property address is null
where PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.parcelid = b.parcelid
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
ON a.parcelid = b.parcelid
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


-------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
SELECT *
FROM dbo.NashvilleHousing
--WHERE PropertyAddress <> OwnerAddress

SELECT PropertyAddress, left(PropertyAddress, CHARINDEX(',', PropertyAddress)-1) as Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

Update dbo.NashvilleHousing
SET PropertySplitAddress = left(PropertyAddress, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitCity varchar(255)

Update dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM dbo.NashvilleHousing

SELECT OwnerAddress, OwnerSplitAddress, OwnerCityState, left(OwnerCityState, CHARINDEX(',', OwnerCityState)-1) as OwnerSplitCity, SUBSTRING(OwnerCityState, CHARINDEX(',', OwnerCityState)+2, LEN(OwnerCityState)) as OwnerSplitState
FROM (SELECT OwnerAddress, left(OwnerAddress, CHARINDEX(',', OwnerAddress)-1) as OwnerSplitAddress, SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+2, LEN(OwnerAddress)) as OwnerCityState
FROM dbo.NashvilleHousing) as a

-- or

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),1), PARSENAME(REPLACE(OwnerAddress, ',','.'),2), PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

Update dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitCity varchar(255)

Update dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitState varchar(255)

Update dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT *
FROM dbo.NashvilleHousing


-------------------------------------------------------------------------------------------
--  Change SoldAsVacant to Yes and No
SELECT DISTINCT SoldAsVacant
FROM dbo.NashvilleHousing

SELECT 
    CASE WHEN SoldAsVacant = 1 
	     THEN 'YES' ELSE 'NO' 
		 END
FROM dbo.NashvilleHousing


--ALTER TABLE dbo.NashvilleHousing
--DROP COLUMN SoldAsVacant

ALTER TABLE dbo.NashvilleHousing
ADD SoldAsVacant1 nvarchar(255)

Update dbo.NashvilleHousing
SET SoldAsVacant1 = CASE WHEN SoldAsVacant = 1 
	     THEN 'YES' ELSE 'NO' 
		 END

SELECT *
FROM dbo.NashvilleHousing


-------------------------------------------------------------------------------------------
--  Remove Duplicates
SELECT *
FROM dbo.NashvilleHousing

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate, 
				 LegalReference
				 ORDER BY UniqueID) as row_num
FROM dbo.NashvilleHousing
)
--Order BY ParcelID

DELETE
--SELECT *
FROM RowNumCTE
Where row_num > 1


-------------------------------------------------------------------------------------------
--  Delete Unused Columns
SELECT *
FROM dbo.NashvilleHousing


ALTER TABLE dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SoldAsVacant, SaleDateConverted