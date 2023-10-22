--Cleaning data in SQL queries

SELECT ConvertedSaleDate
FROM NashvilleHousing


--Standardizing and changing the date format
SELECT SaleDate, CAST(SaleDate AS date)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
add ConvertedSaleDate date;

UPDATE NashvilleHousing
SET ConvertedSaleDate = CAST(SaleDate AS date)




--Populating Property Address Data
SELECT PropertyAddress
FROM NashvilleHousing

--SELECT PropertyAddress
--FROM NashvilleHousing
--WHERE PropertyAddress IS NULL

--SELECT *
--FROM NashvilleHousing
--WHERE PropertyAddress IS NULL

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL





--Breaking Down Address into Address, City, and State
SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing



SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)








--Changing Y and N to Yes and No in the SoldAsVacant Column
SELECT SoldAsVacant
FROM NashvilleHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END







--Remove Duplicates
SELECT *
FROM NashvilleHousing

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER(
		PARTITION BY ParcelID, 
		SaleDate, 
		SalePrice,
		PropertyAddress,
		LegalReference
		ORDER BY
			UniqueID) RowNum
FROM NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE RowNum > 1
--ORDER BY ParcelID









--Delete Unused Columns
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict
