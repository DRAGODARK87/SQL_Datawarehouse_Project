# **Data Dictionay for Gold layer**

## ** Overview **

The Gold Layer is the business - level data representation, structured to support analytical and reporting use case. It consists of **dimension tables** and **fact tables** for specific business metrics.



### **1. gold.dim_customers**

**+ Purpose :** Stores customer details enriched with demographic and geographic data.<br>
**+ Columns :** 

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

**+ Purpose :** Provides information about the products and their attributes.
**+ Columns :**
