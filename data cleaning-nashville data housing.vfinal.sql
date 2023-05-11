*.sql linguagem=sql

-- Create a table and import data
DROP TABLE IF EXISTS HousingData
CREATE TABLE HousingData (
    UniqueID INT,
    ParcelID VARCHAR(50),
    LandUse VARCHAR(50),
    PropertyAddress VARCHAR(500),
    SaleDate VARCHAR(20), 
    SalePrice VARCHAR(100),
    LegalReference VARCHAR(100),
    SoldAsVacant VARCHAR(100),
    OwnerName VARCHAR(100),
    OwnerAddress VARCHAR(500),
    Acreage VARCHAR(100),
    TaxDistrict VARCHAR(200)
    LandValue DECIMAL(18, 2),
    BuildingValue DECIMAL(18, 2),
    TotalValue DECIMAL(18, 2),
    YearBuilt INT,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
);

-- Perform import using BULK INSERT

BULK INSERT HousingData
FROM 'C:\Users\adria\OneDrive\Área de Trabalho\PROJETOS\Projetos para o Portfolio\data_cleaning\Nashville Housing Data for Data Cleaning.v5.csv'
WITH (
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n' 
);

/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM HousingData

--- Standardize Date Format

--Identify the rows in the table that have invalid values in the SaleDate column
SELECT SaleDate
FROM HousingData
WHERE ISDATE(SaleDate) = 0

--Convert Saledate to the date data type
SELECT saleDate, CONVERT(Date,SaleDate)
FROM HousingData

--Update Saledate data type
UPDATE HousingData
SET SaleDate = CONVERT(Date,SaleDate)



--- Populate Property Address data

SELECT *
FROM HousingData
WHERE PropertyAddress is null
--order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingData a
JOIN HousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingData a
JOIN HousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



--- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM HousingData
--Where PropertyAddress is null
--order by ParcelID

--Splitting PropertyAddress column
SELECT
    REVERSE(SUBSTRING(REVERSE(PropertyAddress), 1, CHARINDEX(' ', REVERSE(PropertyAddress)) - 1)) AS LastWord
FROM HousingData;
SELECT
    REVERSE(SUBSTRING(REVERSE(PropertyAddress), CHARINDEX(' ', REVERSE(PropertyAddress)) + 1, LEN(PropertyAddress))) AS RestOfAddress
FROM HousingData;

ALTER TABLE HousingData
ADD PropertySplitAddress Nvarchar(255);
UPDATE HousingData
SET PropertySplitAddress = REVERSE(SUBSTRING(REVERSE(PropertyAddress), CHARINDEX(' ', REVERSE(PropertyAddress)) + 1, LEN(PropertyAddress))) 


ALTER TABLE HousingData
ADD PropertySplitCity Nvarchar(255);
UPDATE HousingData
SET PropertySplitCity = REVERSE(SUBSTRING(REVERSE(PropertyAddress), 1, CHARINDEX(' ', REVERSE(PropertyAddress)) - 1)) 

--Splitting OwnerAddress column
SELECT
    SUBSTRING(OwnerAddress, 1, LEN(OwnerAddress) - CHARINDEX(' ', REVERSE(OwnerAddress))) AS RestOfAddress,
    SUBSTRING(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(' ', REVERSE(OwnerAddress)) + 2, 2) AS State
FROM HousingData
WHERE OwnerAddress IS NOT NULL;

ALTER TABLE HousingData
ADD RestOfAddress Nvarchar(255);
UPDATE HousingData
SET RestOfAddress = SUBSTRING(OwnerAddress, 1, LEN(OwnerAddress) - CHARINDEX(' ', REVERSE(OwnerAddress)))

ALTER TABLE HousingData
ADD State Nvarchar(255);
UPDATE HousingData
SET State = SUBSTRING(OwnerAddress, LEN(OwnerAddress) - CHARINDEX(' ', REVERSE(OwnerAddress)) + 2, 2)


SELECT
    SUBSTRING(RestOfAddress, 1, LEN(RestOfAddress) - CHARINDEX(' ', REVERSE(RestOfAddress))) AS OwnerSplitAddress,
    REVERSE(SUBSTRING(REVERSE(RestOfAddress), 1, CHARINDEX(' ', REVERSE(RestOfAddress)))) AS OwnerSplitCity
FROM HousingData
WHERE RestOfAddress IS NOT NULL;

ALTER TABLE HousingData
ADD OwnerSplitAddress Nvarchar(255);
UPDATE HousingData
SET OwnerSplitAddress = SUBSTRING(RestOfAddress, 1, LEN(RestOfAddress) - CHARINDEX(' ', REVERSE(RestOfAddress)))

ALTER TABLE HousingData
ADD OwnerSplitCity Nvarchar(255);
UPDATE HousingData
SET OwnerSplitCity = REVERSE(SUBSTRING(REVERSE(RestOfAddress), 1, CHARINDEX(' ', REVERSE(RestOfAddress)))) 



--- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
FROM HousingData
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM HousingData

UPDATE HousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



--- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM HousingData
--order by ParcelID
)
-- DELETE -- replace the select with delete to delete the duplicates
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



--- Delete Unused Columns

Select *
From HousingData

ALTER TABLE HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
