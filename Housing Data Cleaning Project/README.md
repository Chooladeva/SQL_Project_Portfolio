# Housing Data Cleaning Project

## Project Overview
This project demonstrates intermediate SQL skills by cleaning, transforming, and preparing a real estate housing dataset. The main objective is to show how to handle raw, messy data and convert it into a structured, analytics-ready format.  

The project covers **data validation, transformation, deduplication, string manipulation, conditional updates, window functions, and creating new calculated columns**.

---

## Dataset Source
- The dataset contains housing and property sales information, including parcel IDs, addresses, sale prices, owner details, and property features (bedrooms, bathrooms, acreage, and property values).  
- Each row represents a unique housing sale record.  
- Source: Publicly available housing data from Kaggle.  

---

## Database Model
The SQL database (`HousingData`) includes a single table `HousingData` with the following columns (after cleaning):

| Column Name             | Description |
|-------------------------|-------------|
| UniqueID                | Unique identifier for each row |
| ParcelID                | Unique parcel/property identifier |
| LandUse                 | Type of land use (residential, commercial, etc.) |
| PropertySplitAddress    | Street address extracted from `PropertyAddress` |
| PropertySplitCity       | City extracted from `PropertyAddress` |
| saleDateConverted       | Sale date without time component |
| SalePrice               | Sale price of the property |
| LegalReference          | Legal reference for the property transaction |
| SoldAsVacant            | Standardized Yes/No indicating if property sold as vacant |
| OwnerName               | Name of the property owner |
| OwnerSplitAddress       | Owner's street address |
| OwnerSplitCity          | Owner's city |
| OwnerSplitState         | Owner's state |
| Acreage                 | Size of the property in acres |
| LandValue               | Valuation of the land |
| BuildingValue           | Valuation of buildings on the property |
| TotalValue              | Combined land and building value |
| YearBuilt               | Year property was built |
| Bedrooms                | Number of bedrooms |
| FullBath                | Number of full bathrooms |
| HalfBath                | Number of half bathrooms |

---

## Data Cleaning & Transformation Steps
The data was cleaned and transformed using a combination of **Python for preprocessing** and **SQL for database-level cleaning**:

1. **Data Validation**  
   - Checked row counts and column completeness.  
   - Verified data types and identified missing or inconsistent entries.  

2. **Date Standardization**  
   - Converted `SaleDate` from `DATETIME` to `DATE` to remove time component.  

3. **Handling Missing Values**  
   - Filled missing `PropertyAddress` using values from other rows with the same `ParcelID`.  

4. **Splitting Address Columns**  
   - Split `PropertyAddress` into `PropertySplitAddress` and `PropertySplitCity`.  
   - Split `OwnerAddress` into `OwnerSplitAddress`, `OwnerSplitCity`, and `OwnerSplitState` using string parsing functions (`PARSENAME`, `REPLACE`).  

5. **Standardizing Categorical Columns**  
   - Converted `SoldAsVacant` from `Y/N` to `Yes/No`.  

6. **Removing Duplicates**  
   - Used `ROW_NUMBER()` window function to identify and delete duplicate records based on `ParcelID`, `PropertyAddress`, `SalePrice`, `SaleDate`, and `LegalReference`.  

7. **Dropping Unnecessary Columns**  
   - Removed `OwnerAddress`, `PropertyAddress`, `SaleDate`, and `TaxDistrict` to reduce redundancy.  

---

## ETL Workflow
1. **ETL using Microsoft SSIS in Visual Studio**  
   - Loaded cleaned data into SQL Server.  
   - Ensured proper column types (`NVARCHAR`, `DATE`, `FLOAT`, etc.).  
2. **SQL Data Cleaning**  
   - Performed transformations, standardizations, and de-duplication in SQL.  
3. **Analytics Ready Data**  
   - Final table ready for reporting, visualization, or further analysis.  

---

## How to Use This Project 
1. Run the SQL script in Microsoft SQL Server or Azure SQL Database.  
2. Verify the table counts and view cleaned data.  
3. Explore and analyze the data using SQL queries or BI tools like Power BI/Tableau.  

---
