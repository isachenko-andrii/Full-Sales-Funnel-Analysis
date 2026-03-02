![Project-logo](https://github.com/isachenko-andrii/Full-Sales-Funnel-Analysis/blob/main/Project-logo.png)
<div align="center">  
    
## Full-Sales-Funnel-Analysis<br>(User Funnel)   
  
</div>

##  Project description  
  
This project is dedicated to analyzing the sales funnel of an online store based on the User Funnels Dataset. The goal of the analysis is to track the user's journey from the first visit to the site to a successful purchase, identify critical drop-off points, and provide sound recommendations for improving conversion.

**Data source:** [Kaggle: User Funnels Dataset](https://www.kaggle.com/datasets/amirmotefaker/user-funnels-dataset)  
  
## Technology stack  

**Database:** PostgreSQL (SQL for ETL, cleansing and analysis).  
**Programming language:** Python 3.x.  
**Libraries:** Pandas, Matplotlib, NumPy.  

  ## Project implementation process (Step-by-Step)  
  
**1. Data Acquisition and Loading (ETL)**  
At this stage, the analysis infrastructure was prepared. Data from the raw CSV file was imported into a relational database to ensure integrity and the ability to write complex queries.  
  
**Tools:** PostgreSQL, SQL.  
  
**What was done:** The user_funnels table schema was defined, data types were configured, and the import was performed using the COPY command.  
  
**File:** 01_create_table.sql  
  
**2. Data Cleaning and Validation**  
Before calculations, the data was checked for sterility. The quality of the results directly depends on the purity of the source data.  
  
**Checks:**  
  
 - Finding and processing NULL values ​​and empty strings.  
 - Checking for duplicates (uniqueness of user_id + stage pairs).  
 - Business logic validation: funnel stages match the specified list.  
  
**Result:** The dataset is considered valid (17,175 records, 0 gaps).  
  
**File:** 02_data_cleaning.sql  
  
**3. Exploratory Analysis (EDA)**  
Initial review of the data to understand general trends and distributions.  
  
**Metrics:**
 - Total number of unique users at each stage.
 - Percentage of completed and incomplete conversions.
 - User Journey Mapping for visual sequence verification.  

**File:** 03_eda.sql  
  
**4. Deep Funnel Analysis (Funnel Analysis)**
The main analytical section, where the product's key performance indicators (KPIs) are calculated.  
  
**Calculations:**  
  
 - *Step-to-Step Conversion:* The percentage of users who move from the current step to the next.  
 - Drop-off Rate: The percentage of users who drop off at each step.  
 - Cumulative Conversion (Overall CR): The total conversion rate from the first step to a purchase.  
  
**Methods:** Using window functions (LAG, FIRST_VALUE) to compare data between rows.  
  
**File:** 04_funnel_analysis.sql  
  
**5. User Segmentation**  
Dividing the audience into groups based on their behavior (funnel depth) for targeted marketing.  
  
**Segments:** Bounce (homepage only), Browser (product viewer), Cart Abandoner (abandoned cart), Buyer.  
**Result:** It was found that 49% of users are bouncers, indicating a traffic or content relevance issue on the homepage.  
  
**File:** 05_segmentation.sql  

**6. Calculating key business metrics**
Based on the cleaned data, key business metrics were calculated to assess the effectiveness of the product's sales funnel.
  
 **File:** 06_advanced_metrics.sql  
  
## Key Results  
  
According to the analysis:  
**Overall Conversion Rate (Overall CR):** 2.25%.  
**Highest churn:** Occurs at Product Page → Cart (70% loss) and Cart → Checkout (70% loss).  
**Segmentation:** Almost 50% of users leave the site after viewing only the main page (Bounce rate).  
  
## Visualization  
  Transforming dry numbers into understandable visuals for business.  
  
 *  **Visual funnel with drop-off**
   
  ![Funnel chart](https://github.com/isachenko-andrii/Full-Sales-Funnel-Analysis/blob/main/images/funnel_chart.png)  
    
 * **Step conversion & drop-off pie**
   
  ![Conversion charts](https://github.com/isachenko-andrii/Full-Sales-Funnel-Analysis/blob/main/images/conversion_charts.png)  
  
 * **Cumulative conversion curve**  
    
  ![Cumulative conversion](https://github.com/isachenko-andrii/Full-Sales-Funnel-Analysis/blob/main/images/cumulative_conversion.png)  
    
## Project structure  

  **User-Funnels/** — project directory  
    ├── data/ — project data  
    │ ├──  raw/ — raw data  
    │ └──  processed/ — cleaned data  
    │  
    ├── sql/  - sql queries  
    │   ├── 01_create_table.sql    # Schema + data loading  
    │   ├── 02_data_cleaning.sql   # Validation & quality checks  
    │   ├── 03_eda.sql             # Exploratory data analysis  
    │   ├── 04_funnel_analysis.sql # Core funnel metrics  
    │   ├── 05_segmentation.sql    # User segmentation  
    │   └── 06_advanced_metrics.sql # Window functions & advanced SQL  
    │  
    ├── images/  - visualization  
    │   ├── funnel_chart.png       # Visual funnel with drop-off  
    │   ├── conversion_charts.png  # Step conversion + drop-off pie  
    │   └── cumulative_conversion.png # Cumulative conversion curve  
    │  
    └── notebooks/  - colab or jupyter notebook files  
    │ └── notebook.ipynb           # Сreating visualizations  
    ├── reports/ — report of project  
    │ └── report.pdf               # Project report file  
    ├── Project-logo.png — project cover  
    ├── LICENSE — MIT License  
    ├── requirements.txt — list of libraries to run the project  
    └── README.md — project description.  
  
---

## How to start the project  

 - Clone the repository.   
 - Run the SQL scripts from the /sql folder in your PostgreSQL environment.  
 - To create diagrams use notebook.ipynb, run it in Colab or Jupyter Notebook.  
  
 ## Contact  
    
**Name:** [Andrii Isachenko](https://isachenko-andrii.github.io)    
**LinkedIn:** [Andrii Isachenko](https://www.linkedin.com/in/isachenko-andrii/)  
**E-mail:** isao.datastudio@gmail.com   
  
## Acknowledgments    

 - Thanks to [Amir Motefaker](https://www.kaggle.com/datasets/amirmotefaker/user-funnels-dataset) for providing this rich dataset for the data community.
 - Special thanks to the [Kaggle](https://www.kaggle.com/) platform for hosting the data.
 - Thanks to the [Data Analyst/GoIT](https://goit.global/ua/courses/data-analytics/) course, which was part of this project.

---
  
**Project Status:** Completed.
    
**License:** MIT License.   
