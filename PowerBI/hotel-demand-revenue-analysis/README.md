# Hotel Demand & Revenue Analysis – Power BI Project

## Project Overview

This project analyzes demand, revenue structure, and cancellation risk in the hotel market using Power BI.

The goal of the analysis is not only to calculate revenue metrics but to understand the structural dynamics of the business model and derive strategic insights.

The analysis focuses on:

- Revenue development over time
- Booking cancellation behavior
- Comparison of hotel business models (City vs Resort)
- Market segment performance
- Strategic risk-return evaluation

The project was developed as part of a Data Analytics training program and demonstrates end-to-end analytical workflow: data preparation, modeling, DAX calculations, dashboard design, and business interpretation.

---

# Business Questions

The analysis addresses several key management questions:

1. How is hotel revenue evolving over time?
2. How high is the cancellation risk and how does it affect business stability?
3. What structural differences exist between City and Resort hotels?
4. Which market segments generate the most revenue?
5. Which segments carry the highest operational risk?
6. How can revenue and cancellation risk be evaluated together for strategic decision making?

---

# Dataset

Source: Kaggle – Hotel Booking Demand Dataset

The dataset contains booking information such as:

- hotel type
- booking date
- market segment
- customer type
- average daily rate (ADR)
- length of stay
- cancellations

Revenue is modeled as:

ADR × Length of Stay

This represents a revenue proxy rather than actual financial accounting data.

Extreme ADR outliers were analytically filtered to avoid distortion.

---

# Data Model

The report uses a **Star Schema architecture**.

Fact Table:

`fact_hotel_bookings`

Dimension Tables:

- `dim_hoteltype`
- `dim_marketsegment`
- `dim_customer_type`
- `dim_country`
- `dim_date`

This structure improves model clarity and performance for analytical queries.

---

# Key Metrics (DAX)

The analysis uses several calculated measures:

### Revenue (cleaned)

Revenue is calculated using:

ADR × nights stayed

Extreme ADR values (>500) were excluded to prevent unrealistic revenue distortion.

### Bookings

Total number of bookings.

### Cancellation Rate

Percentage of cancelled bookings relative to total bookings.

### Average Revenue per Stay

Revenue divided by completed bookings.

### Rolling 12 Month Revenue

Used to identify structural trends and reduce monthly volatility.

---

# Analytical Structure

The report follows a structured analytical sequence:

1. Executive Overview  
   Revenue trend, YoY change, cancellation rate

2. Business Model Comparison  
   City vs Resort hotels

3. Market Segment Analysis  
   Revenue contribution and cancellation risk

4. Risk-Return Matrix  
   Strategic positioning of segments

5. Strategic Recommendations

---

# Key Insights

Main findings from the analysis:

- Revenue grew strongly until 2017 and later stabilized.
- Cancellation rates are structurally significant (~37%).
- City hotels show higher cancellation risk.
- Resort hotels generate higher revenue per stay.
- Online Travel Agencies (OTA) drive large booking volume but also show higher cancellation risk.
- Direct and Corporate bookings are more stable.

These insights highlight the trade-off between demand volume and operational risk.

---

# Strategic Recommendations

Based on the analysis:

1. Improve cancellation management in OTA segments.
2. Strengthen booking stability through stricter group booking policies.
3. Expand stable booking channels such as Direct and Corporate.
4. Improve seasonal pricing strategies for Resort hotels.

The goal is to achieve a better balance between revenue growth and operational stability.

---

# Dashboard

The Power BI dashboard contains four pages:

1. Executive Overview
2. Business Model Comparison
3. Segment Analysis
4. Risk-Return Matrix

The dashboard is designed for management-level interpretation with clear KPI structure and visual hierarchy.

---

# Tools Used

Power BI  
Power Query  
DAX  
Star Schema Modeling  

---

# Project Structure
