/* 
 
Cleaning Data in SQL Queries 
 
*/ 
 
 
Select * 
From NashvilleHousing.dbo.NashvilleHousing
 
-------------------------------------------------------------------------------------------------------------------------- 
 
-- Стандартизировать формат даты
 
 
Select SaleDateConverted, CONVERT(Date,SaleDate) 
From NashvilleHousing.dbo.NashvilleHousing
 
 
Update NashvilleHousing 
SET SaleDate = CONVERT(Date,SaleDate) 
 
-- If it doesn't Update properly 
 
ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date; 
 
Update NashvilleHousing 
SET SaleDateConverted = CONVERT(Date,SaleDate) 
 
 
 -------------------------------------------------------------------------------------------------------------------------- 
 
-- Наполнить Property Address data 
 
Select * 
From NashvilleHousing.dbo.NashvilleHousing
--Where PropertyAddress is null 
order by ParcelID 
 
 
 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
From NashvilleHousing.dbo.NashvilleHousing a 
JOIN NashvilleHousing.dbo.NashvilleHousing b 
 on a.ParcelID = b.ParcelID 
 AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null 
 
 
Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
From NashvilleHousing.dbo.NashvilleHousing a 
JOIN NashvilleHousing.dbo.NashvilleHousing b 
 on a.ParcelID = b.ParcelID 
 AND a.[UniqueID ] <> b.[UniqueID ] 
Where a.PropertyAddress is null 
 
 
 
 
-------------------------------------------------------------------------------------------------------------------------- 
 
-- Разделить Adress на индивилуальные столбцы (Address, City, State) 
 
 
Select PropertyAddress 
From NashvilleHousing.dbo.NashvilleHousing
--Where PropertyAddress is null 
--order by ParcelID 
 
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address 
 
From NashvilleHousing.dbo.NashvilleHousing
 
 
ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255); 
 
Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 
 
 
ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255); 
 
Update NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 
 
 
 
 
Select * 
From NashvilleHousing.dbo.NashvilleHousing
 
 
 
 
 
Select OwnerAddress 
From NashvilleHousing.dbo.NashvilleHousing
 
 
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 
From NashvilleHousing.dbo.NashvilleHousing

 
 
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
From NashvilleHousing.dbo.NashvilleHousing
 
 
 
 
-------------------------------------------------------------------------------------------------------------------------- 
 
 
-- Поменять Y и N на Yes и No в поле "Sold as Vacant"
 
 
Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
From NashvilleHousing.dbo.NashvilleHousing
Group by SoldAsVacant 
order by 2 
 
 
 
 
Select SoldAsVacant 
, CASE When SoldAsVacant = 'Y' THEN 'Yes' 
    When SoldAsVacant = 'N' THEN 'No' 
    ELSE SoldAsVacant 
    END 
From NashvilleHousing.dbo.NashvilleHousing
 
 
Update NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes' 
    When SoldAsVacant = 'N' THEN 'No' 
    ELSE SoldAsVacant 
    END
----------------------------------------------------------------------------------------------------------------------------------------------------------- 
 
-- Убрать дубликаты
 
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
 
From NashvilleHousing.dbo.NashvilleHousing
--order by ParcelID 
) 
Select * 
From RowNumCTE 
Where row_num > 1 
Order by PropertyAddress 


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
 
From NashvilleHousing.dbo.NashvilleHousing
--order by ParcelID 
) 
DELETE
From RowNumCTE 
Where row_num > 1 
--Order by PropertyAddress 
 
 
 
Select * 
From NashvilleHousing.dbo.NashvilleHousing
 
 
 
 
--------------------------------------------------------------------------------------------------------- 
 
-- Удалить ненужную столбцы
 
 
 
Select * 
From NashvilleHousing.dbo.NashvilleHousing
 
 
ALTER TABLE NashvilleHousing.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
----------------------------------------------------------------------------------------------- 
----------------------------------------------------------------------------------------------- 
 
--- Импорт данных с OPENROWSET и BULK INSERT  
 
--  Лучше но сложнее 
 
--sp_configure 'show advanced options', 1; 
--RECONFIGURE; 
--GO 
--sp_configure 'Ad Hoc Distributed Queries', 1; 
--RECONFIGURE; 
--GO 
 
 
--USE NashvilleHousing
 
--GO  
 
--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1  
 
--GO  
 
--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1  
 
--GO  
 
 
--Using BULK INSERT 
 
--USE NashvilleHousing; 
--GO 
--BULK INSERT nashvilleHousing FROM 'C:\Users\yeras\Downloads\Nashville Housing Data for Data Cleaning.csv' 
   --WITH ( 
      --FIELDTERMINATOR = ',', 
      --ROWTERMINATOR = '\n' 
--);
--GO 
 
 
--Using OPENROWSET 
--USE NashvilleHousing; 
--GO 
--SELECT * INTO nashvilleHousing 
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
    --'Excel 12.0; Database=C:\Users\yeras\Downloads\Nashville Housing Data for Data Cleaning.csv', [Sheet1$]); 
--GO
