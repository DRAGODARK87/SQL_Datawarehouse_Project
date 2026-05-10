# **Data Dictionay for Gold layer**

## ** Overview **

The Gold Layer is the business - level data representation, structured to support analytical and reporting use case. It consists of **dimension tables** and **fact tables** for specific business metrics.



### **1. gold.dim_customers**

+ **Purpose :** Stores customer details enriched with demographic and geographic data.<br>
+ **Columns :** 

| Column Name     | Data Type     | Description                                                                 |
|-----------------|---------------|-----------------------------------------------------------------------------|
| customer_key    | INT           | Surrogate key uniquely identifying each customer record in the dimension table |
| customer_id     | INT           | Unique numerical identifier assigned to each customer                       |
| customer_number | NVARCHAR(50)  | Alphanumeric identifier representing the customer, used for tracking and reference |
| first_name      | NVARCHAR(50)  | The customer's first name as recorded in the system                         |
| last_name       | NVARCHAR(50)  | The customer's last name or family name                                     |
| country         | NVARCHAR(50)  | The country of residence for the customer (eg. Australia)                   |
| martial_status  | NVARCHAR(50)  | The martial status of the customer (eg. Married, Single)                    |
| gender          | NVARCHAR(50)  | The gender of a customer (eg. Male, Female, n/a)                            |
| birth_date      | Date          | Date the customer was born in YYYY-MM-DD format (eg. 1971-10-26)            |
| create_date     | Date          | The date and time when the customer record was created in the system        |


### **2. gold.dim_products**

+ **Purpose :** Provides information about the products and their attributes.<br>
+ **Columns :**

| Column Name    | Data Type    | Description                                                                              |
|----------------|--------------|------------------------------------------------------------------------------------------|
| product_key    | INT          | Surrogate key uniquely identifying each product record in the dimension table            |
| product_id     | INT          | Unique numerical identifier assigned to each product                                     |
| product_number | NVARCHAR(50) | Alphanumeric identifier representing the product, used for tracking and reference        |
| product_name   | NVARCHAR(50) | Descriptive name of the product, including details such as type, color and size          |
| category_id    | NVARCHAR(50) | A unique identifier for the product's category, linking to its high level classification |
| category       | NVARCHAR(50) | The broader category of the product (eg. Bikes)                                          |
| subcategory    | NVARCHAR(50) | A more detailed classification of the product within the category, such as product type  |
| maintenance    | NVARCHAR(50) | Indicates whether the product requires maintenance (eg. Yes, No)                         |
| cost           | INT          | The cost or base price of the product, measured in monetary units                        |
| product_line   | NVARCHAR(50) | The specific product line or series to which the product belongs (eg. Road, Mountain)    |
| start_date     | DATETIME     | The date when the product became available for sale, stored in DATETIME format           |


###**3. gold.fact_sales**

+ **Purpose :** Stores transactional sales data for analytical purposes.<br>
+ **Columns :**

| Column Name   | Data Type    | Description                                                                             |
|---------------|--------------|-----------------------------------------------------------------------------------------|
| order_number  | NVARCHAR(50) | A unique alphanumeric identifier for each sales order (eg. 'SOS4496')                  |
| product_key   | INT          | Surrogate key linking the order to the product dimension table                          |
| customer_key  | INT          | Surrogate key linking the order to the customer dimension table                         |
| order_date    | Date         | The date when the order was placed                                                      |
| shipping_date | Date         | The date when the order was shipped to the customer                                     |
| due_date      | Date         | The date when the order payment was due                                                 |
| sales_amount  | INT          | The total monetary value of the sale for the line item, in whole currency units (eg. 25)|
| quantity      | INT          | The number of units of the product ordered for the line item (eg. 1)                   |
| price         | INT          | The price per unit of the product for the line item, in whole currency units (eg. 25)  |
