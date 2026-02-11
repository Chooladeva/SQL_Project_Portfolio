-- Create Database
CREATE DATABASE HousingData;
USE HousingData;

-- Create Table
CREATE TABLE HousingData (
    UniqueID INT,
    ParcelID NVARCHAR(50),
    LandUse NVARCHAR(100),
    PropertyAddress NVARCHAR(255),
    SaleDate DATETIME,
    SalePrice INT,
    LegalReference NVARCHAR(100),
    SoldAsVacant NVARCHAR(10),
    OwnerName NVARCHAR(255),
    OwnerAddress NVARCHAR(255),
    Acreage FLOAT,
    TaxDistrict NVARCHAR(100),
    LandValue FLOAT,
    BuildingValue FLOAT,
    TotalValue FLOAT,
    YearBuilt FLOAT,
    Bedrooms FLOAT,
    FullBath FLOAT,
    HalfBath FLOAT
);

-- Data Validation
-- Check raw data and row count
Select *
From HousingData;

SELECT COUNT(*) AS row_count FROM HousingData;

-- Cleaning Data in SQL Queries

-- 1. Standardize Sale Date Format
-- Create new column 'saleDateConverted' to store date without time

Select SaleDate,
CONVERT(Date,SaleDate) AS saleDateConverted
From HousingData;

-- Add new saleDateConverted column
ALTER TABLE HousingData
ADD saleDateConverted DATE;

-- Populate the new column
UPDATE HousingData
SET saleDateConverted = CONVERT(DATE, SaleDate);

-- 2. Fill Missing Property Address data
-- Update missing addresses by looking up rows with the same ParcelID

-- Find rows where the address is missing
Select *
From HousingData
Where PropertyAddress is null
order by ParcelID

-- Compare rows with the same ParcelID
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingData a
JOIN HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

-- Update the missing values
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingData a
JOIN HousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- 3. Split PropertyAddress into Address + City
Select PropertyAddress
From HousingData;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From HousingData;

-- Create new columns
ALTER TABLE HousingData
Add PropertySplitAddress Nvarchar(255);

ALTER TABLE HousingData
ADD PropertySplitCity NVARCHAR(255);

-- Fill the newly created columns
Update HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

Update HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

Select *
From HousingData

-- 4. Split OwnerAddress into Address + City + State
Select OwnerAddress
From HousingData;

-- SQL doesn’t have a simple 3-way split
-- First,Replace commas with dots and then PARSENAME reads parts separated by dots from RIGHT to LEFT.

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From HousingData;

--Create columns
ALTER TABLE HousingData
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE HousingData
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE HousingData
Add OwnerSplitState Nvarchar(255);

-- Fill the newly created columns
Update HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

Update HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

Update HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

Select *
From HousingData;

-- 5. Standardize SoldAsVacant Column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingData
Group by SoldAsVacant
order by 2;

-- Preview the change
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From HousingData;

-- Update the table
Update HousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
END;

-- 6. Remove Duplicates

-- Identify duplicates
-- rows that have the same ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	    PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	    ORDER BY UniqueID
	) row_num

From HousingData
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

-- Delete duplicates
WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID
    ) row_num
From HousingData
)
DELETE
From RowNumCTE
Where row_num > 1;

Select *
From HousingData;

-- 7. Remove  Unused Columns
ALTER TABLE HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

-- Verify Cleaned Data
Select * From HousingData;
SELECT COUNT(*) AS row_count_after_cleaning FROM HousingData;