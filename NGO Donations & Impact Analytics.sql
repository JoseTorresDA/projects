SELECT donor_name, donor_type, sum(amount) AS total_donated
FROM donors dn
JOIN donations dt ON dn.donor_id = dt.donor_id
GROUP BY donor_name
ORDER BY amount DESC
LIMIT 10;

SELECT region, strftime('%Y', dt.donation_date) AS year, sum(amount) AS total_donations
FROM countries c
JOIN donors d ON c.country_id = d.country_id
JOIN donations dt ON d.donor_id = dt.donor_id
GROUP BY region, year
ORDER BY year, total_donations DESC;

WITH yearly_donations AS (
    SELECT donor_id, CAST(strftime('%Y', donation_date) AS INTEGER) AS donation_year
    FROM donations
    GROUP BY donor_id, donation_year
),
donation_history AS (
SELECT donor_id, donation_year,
       LAG(donation_year) OVER (PARTITION BY donor_id ORDER BY donation_year) AS previous_year
FROM yearly_donations)
SELECT *
FROM donation_history
WHERE donation_year - previous_year = 1;


WITH sector_yearly AS (
    SELECT p.sector, strftime('%Y', d.donation_date) AS year, SUM(d.amount) AS total
    FROM donations d
    JOIN projects p ON d.project_id = p.project_id
    GROUP BY p.sector, year
)
SELECT sector, year, total,
       total - LAG(total) OVER (PARTITION BY sector ORDER BY year) AS yoy_change
FROM sector_yearly
ORDER BY sector, year;


SELECT p.project_name, p.budget, SUM(b.beneficiaries_reached) AS total_beneficiaries,
       ROUND(p.budget * 1.0 / NULLIF(SUM(b.beneficiaries_reached), 0), 2) AS cost_per_beneficiary
FROM projects p
JOIN beneficiaries b ON p.project_id = b.project_id
GROUP BY p.project_id
ORDER BY cost_per_beneficiary ASC;


SELECT c.region, p.project_name, SUM(d.amount) AS total_donations,
       RANK() OVER (PARTITION BY c.region ORDER BY SUM(d.amount) DESC) AS rank_in_region
FROM donations d
JOIN projects p ON d.project_id = p.project_id
JOIN countries c ON p.country_id = c.country_id
GROUP BY c.region, p.project_id;


WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY donor_id, project_id, donation_date, amount ORDER BY donation_id) AS rn
    FROM donations
)
SELECT * FROM ranked WHERE rn > 1;  



