SELECT *
FROM NashvilleDataCleaning.dbo.NashvilleHousingData;

--Separating out owner address into separate columns 
SELECT CONVERT(DATE,SaleDate) AS SalesDate
FROM NashvilleDataCleaning.dbo.NashvilleHousingData;

UPDATE NashvilleDataCleaning.dbo.NashvilleHousingData
SET SaleDate = CONVERT(DATE,SaleDate);

ALTER TABLE NashvilleHousingData
ADD SalesDate DATE;
--used ALTER TABLE because UPDATE wouldn't work 

UPDATE NashvilleHousingData
SET SalesDate = CONVERT(DATE,SaleDate);


--Populate Property Address data
SELECT *
FROM NashvilleDataCleaning.dbo.NashvilleHousingData
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleDataCleaning.dbo.NashvilleHousingData AS a
JOIN NashvilleDataCleaning.dbo.NashvilleHousingData AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;
 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleDataCleaning.dbo.NashvilleHousingData AS a
JOIN NashvilleDataCleaning.dbo.NashvilleHousingData AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


--Breaking out PropertyAddress into individual columns (Address, City)
SELECT PropertyAddress
FROM NashvilleDataCleaning.dbo.NashvilleHousingData;

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM NashvilleDataCleaning.dbo.NashvilleHousingData;

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1);


ALTER TABLE NashvilleHousingData
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));


SELECT *
FROM NashvilleDataCleaning.dbo.NashvilleHousingData;
--run this to check for changes


--Breaking out OwnerAddress into individual columns (Address, City, State)
SELECT OwnerAddress
FROM NashvilleDataCleaning.dbo.NashvilleHousingData;

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM NashvilleDataCleaning.dbo.NashvilleHousingData;


ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3);


ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2);


ALTER TABLE NashvilleHousingData
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1);

SELECT *
FROM NashvilleDataCleaning.dbo.NashvilleHousingData;
--run this to check for changes



--Change Y and N to Yes and No in SoldAsVacant column

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleDataCleaning.dbo.NashvilleHousingData
GROUP BY SoldAsVacant 
ORDER BY 2;


SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END 
FROM NashvilleDataCleaning.dbo.NashvilleHousingData;

UPDATE NashvilleDataCleaning.dbo.NashvilleHousingData
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;

--Remove duplicates
WITH row_num_cte AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS row_num
FROM NashvilleDataCleaning.dbo.NashvilleHousingData
)

DELETE 
FROM row_num_cte
WHERE row_num >1;


--Delete unused columns
ALTER TABLE NashvilleDataCleaning.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress, SaleDate;

