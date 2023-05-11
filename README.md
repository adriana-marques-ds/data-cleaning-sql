# Nashville Housing Data Cleaning Script

**Description**
This script aims to perform data cleaning and transformation tasks on the Nashville Housing Data. It includes steps to standardize data formats, fill in missing values, separate address information into individual columns, and handle data inconsistencies. The script's purpose is to enhance the data quality and usability of the Nashville Housing Data for subsequent analysis or applications.

## Prerequisites
To use this script, you need the following:
- SQL Server
- Access to the Nashville Housing Data source file

## Script Structure
The script is structured into the following sections:
1. Create Table and Import Data: Defines the table structure and imports the Nashville Housing Data from the source file using the BULK INSERT statement.
2. Cleaning Data in SQL Queries: Executes various data cleaning tasks, including standardizing date formats, populating missing property addresses, separating address information into individual columns, and modifying "Sold as Vacant" field values.
3. Remove Duplicates: Identifies and deletes duplicate rows from the HousingData table.
4. Delete Unused Columns: Removes unnecessary columns from the HousingData table to optimize storage.

**Authorship and Contributions**
This data cleaning script was adapted from a [tutorial](https://www.youtube.com/watch?v=8rO7ztF4NtU&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=3) by [AlexTheAnalyst](https://github.com/AlexTheAnalyst) and further customized by me.

*Note: For a detailed explanation of each section and its corresponding code, please refer to the script file itself.*

Feel free to contact me for any questions or suggestions regarding this script.

Thank you for using the Nashville Housing Data Cleaning Script!
