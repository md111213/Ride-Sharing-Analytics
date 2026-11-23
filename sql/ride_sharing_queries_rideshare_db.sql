use rideshare;

SELECT COUNT(*) AS Rides FROM rides;
SELECT COUNT(*) AS Users FROM users;
SELECT COUNT(*) AS Drivers FROM drivers;
SELECT COUNT(*) AS Payments FROM payments;
SELECT COUNT(*) AS SupportTickets FROM supporttickets;

ALTER TABLE rides CHANGE COLUMN `ï»¿RideID` RideID VARCHAR(10);
ALTER TABLE drivers CHANGE COLUMN `ï»¿DriverID` DriverID VARCHAR(10);
ALTER TABLE payments CHANGE COLUMN `ï»¿PaymentID` PaymentID VARCHAR(10);
ALTER TABLE supporttickets CHANGE COLUMN `ï»¿TicketID` TicketID VARCHAR(10);

SELECT RideID FROM rides LIMIT 3;
SELECT DriverID FROM drivers LIMIT 3;
SELECT PaymentID FROM payments LIMIT 3;
SELECT TicketID FROM supporttickets LIMIT 3;

SELECT RideDate FROM rides LIMIT 3;
SELECT JoinDate FROM users LIMIT 3;
SELECT PaymentDate FROM payments LIMIT 3;
SELECT OpenDate, CloseDate FROM supporttickets LIMIT 3;

SHOW COLUMNS FROM rides;

SELECT TABLE_NAME, COLUMN_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'rideshare' AND COLUMN_NAME LIKE 'ï%';



-- Q1. Users jo 2024 mein join hue aur referral use kiya (expected 374 rows)

SELECT UserID, Name, JoinDate, City, ReferralUsed
FROM users
WHERE JoinDate BETWEEN '2024-01-01' AND '2024-12-31' AND ReferralUsed = 'YES'
ORDER BY JoinDate, UserID;

-- Q2. 30 km se lambi, Wallet se paid, completed rides (961)

SELECT RideID, RideDate, UserID, DriverID, Start_Location, End_Location, Distance_km, Fare, PaymentMethod, Status
FROM rides
WHERE Distance_km > 30 AND PaymentMethod = 'Wallet' AND Status = 'Completed'
ORDER BY Distance_km DESC, RideID;

-- Q3. Har driver ki rides ki ginti (320)
SELECT d.DriverID, d.Name, d.City, d.VehicleType,
       COUNT(r.RideID) AS total_rides,
       SUM(CASE WHEN r.Status = 'Completed' THEN 1 ELSE 0 END) AS completed_rides
FROM drivers d
LEFT JOIN rides r ON r.DriverID = d.DriverID
GROUP BY d.DriverID, d.Name, d.City, d.VehicleType
ORDER BY total_rides DESC, d.DriverID;

-- Q4. Pichle 60 din mein koi completed ride nahi (5). "Aaj" = data ki last date
SELECT d.DriverID, d.Name, d.City, d.VehicleType, d.IsActive,
       (SELECT MAX(r2.RideDate) FROM rides r2
         WHERE r2.DriverID = d.DriverID AND r2.Status = 'Completed') AS last_completed_ride
FROM drivers d
WHERE NOT EXISTS (
        SELECT 1 FROM rides r
        WHERE r.DriverID = d.DriverID AND r.Status = 'Completed'
          AND DATEDIFF((SELECT MAX(RideDate) FROM rides), r.RideDate) <= 60)
ORDER BY last_completed_ride, d.DriverID;

-- Q5. Unresolved tickets: user name, ride date, issue type (57)

DROP VIEW IF EXISTS users_unique;
CREATE VIEW users_unique AS
SELECT UserID, MIN(Name) AS Name, COUNT(*) AS UserRows
FROM users
GROUP BY UserID;

SELECT COUNT(*) FROM users_unique;

SELECT t.TicketID, t.UserID, u.Name AS user_name, u.UserRows AS user_name_variants,
       r.RideDate, t.IssueType, t.Status
FROM supporttickets t
LEFT JOIN users_unique u ON u.UserID = t.UserID
LEFT JOIN rides r ON r.RideID = t.RideID
WHERE t.Status <> 'Resolved'
ORDER BY t.Status, t.TicketID;


-- Q6. Vehicle type ka average fare (5)
SELECT d.VehicleType, COUNT(*) AS rides, ROUND(AVG(r.Fare), 2) AS avg_fare
FROM rides r JOIN drivers d ON d.DriverID = r.DriverID
GROUP BY d.VehicleType
ORDER BY avg_fare DESC;

-- Q7. Har city mein har payment method se completed rides (24)
SELECT d.City, r.PaymentMethod, COUNT(*) AS completed_rides
FROM rides r JOIN drivers d ON d.DriverID = r.DriverID
WHERE r.Status = 'Completed'
GROUP BY d.City, r.PaymentMethod
ORDER BY d.City, completed_rides DESC, r.PaymentMethod;

-- Q8. Har driver ka average distance aur duration (320)
SELECT d.DriverID, d.Name, COUNT(*) AS rides,
       ROUND(AVG(r.Distance_km), 2) AS avg_distance_km,
       ROUND(AVG(r.Duration_min), 2) AS avg_duration_min
FROM drivers d JOIN rides r ON r.DriverID = d.DriverID
GROUP BY d.DriverID, d.Name
ORDER BY d.DriverID;

-- Q9. Sabse zyada average tip-to-fare ratio wale drivers, top 10
SELECT d.DriverID, d.Name, d.City, COUNT(*) AS rides,
       ROUND(AVG(r.Tip / r.Fare), 4) AS avg_tip_to_fare_ratio
FROM rides r JOIN drivers d ON d.DriverID = r.DriverID
GROUP BY d.DriverID, d.Name, d.City
ORDER BY avg_tip_to_fare_ratio DESC, d.DriverID
LIMIT 10;

-- Q10. Issue type aur city ke hisaab se tickets (30)
SELECT d.City, t.IssueType, COUNT(*) AS tickets
FROM supporttickets t
JOIN rides r ON r.RideID = t.RideID
JOIN drivers d ON d.DriverID = r.DriverID
GROUP BY d.City, t.IssueType
ORDER BY d.City, tickets DESC, t.IssueType;

-- Q11. City ke andar drivers ki rank, completed rides ke hisaab se (320)
WITH driver_completed AS (
    SELECT d.DriverID, d.Name, d.City, COUNT(r.RideID) AS completed_rides
    FROM drivers d
    LEFT JOIN rides r ON r.DriverID = d.DriverID AND r.Status = 'Completed'
    GROUP BY d.DriverID, d.Name, d.City
)
SELECT City, RANK() OVER (PARTITION BY City ORDER BY completed_rides DESC) AS city_rank,
       DriverID, Name, completed_rides
FROM driver_completed
ORDER BY City, city_rank, DriverID;

-- Q12. Har user ka cumulative revenue RideDate ke order mein (4690)
SELECT UserID, RideDate, RideID,
       ROUND(Fare + Tip, 2) AS ride_revenue,
       ROUND(SUM(Fare + Tip) OVER (PARTITION BY UserID ORDER BY RideDate, RideID
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_revenue
FROM rides
WHERE Status = 'Completed'
ORDER BY UserID, RideDate, RideID;

-- Q13. Har user ki last ride date (799)
SELECT UserID, MAX(RideDate) AS last_ride_date, COUNT(*) AS total_rides
FROM rides
GROUP BY UserID
ORDER BY last_ride_date DESC, UserID;

-- Q14. Har ride par, us user ka ab tak ka average fare (5200)
SELECT RideID, UserID, RideDate, Fare,
       ROUND(AVG(Fare) OVER (PARTITION BY UserID ORDER BY RideDate, RideID
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS avg_fare_so_far
FROM rides
ORDER BY UserID, RideDate, RideID;

-- Q15. Tickets wale users jinhone kabhi tip nahi diya (0 rows aana sahi hai)
SELECT t.UserID, u.Name AS user_name, COUNT(*) AS tickets,
       (SELECT COUNT(*) FROM rides r2 WHERE r2.UserID = t.UserID) AS rides_taken
FROM supporttickets t
LEFT JOIN users_unique u ON u.UserID = t.UserID
WHERE NOT EXISTS (SELECT 1 FROM rides r WHERE r.UserID = t.UserID AND r.Tip > 0)
GROUP BY t.UserID, u.Name
ORDER BY tickets DESC, t.UserID;

-- Q16. CTE: pichle 3 mahino mein monthly average rating badhti hui (44)
WITH monthly AS (
    SELECT DriverID, YEAR(RideDate) * 12 + MONTH(RideDate) AS month_no, AVG(Rating) AS avg_rating
    FROM rides
    GROUP BY DriverID, YEAR(RideDate) * 12 + MONTH(RideDate)
),
latest AS (SELECT MAX(month_no) AS last_month FROM monthly)
SELECT d.DriverID, d.Name, d.City,
       ROUND(m1.avg_rating, 2) AS rating_2_months_ago,
       ROUND(m2.avg_rating, 2) AS rating_previous_month,
       ROUND(m3.avg_rating, 2) AS rating_latest_month
FROM latest l
JOIN monthly m3 ON m3.month_no = l.last_month
JOIN monthly m2 ON m2.DriverID = m3.DriverID AND m2.month_no = l.last_month - 1
JOIN monthly m1 ON m1.DriverID = m3.DriverID AND m1.month_no = l.last_month - 2
JOIN drivers d ON d.DriverID = m3.DriverID
WHERE m1.avg_rating < m2.avg_rating AND m2.avg_rating < m3.avg_rating
ORDER BY (m3.avg_rating - m1.avg_rating) DESC, d.DriverID;

-- Q17. Subquery: total revenue ke hisaab se top 3 cities (Pune, Chennai, Hyderabad)
SELECT t.city, ROUND(t.revenue_completed, 2) AS revenue_completed, t.total_fare_all_rides
FROM (
    SELECT d.City AS city,
           SUM(CASE WHEN r.Status = 'Completed' THEN r.Fare + r.Tip ELSE 0 END) AS revenue_completed,
           SUM(r.Fare) AS total_fare_all_rides
    FROM rides r JOIN drivers d ON d.DriverID = r.DriverID
    GROUP BY d.City
) t
ORDER BY t.revenue_completed DESC
LIMIT 3;

-- Q18. Driver ki home city se shuru hui completed rides (320)
SELECT d.DriverID, d.Name, d.City AS home_city,
       COUNT(r.RideID) AS completed_rides_in_home_city
FROM drivers d
LEFT JOIN rides r ON r.DriverID = d.DriverID
                 AND r.Start_Location = d.City AND r.Status = 'Completed'
GROUP BY d.DriverID, d.Name, d.City
ORDER BY completed_rides_in_home_city DESC, d.DriverID;

-- Q19. 1000 se zyada rides wale drivers mein sabse common vehicle type (SUV, 56)
SELECT VehicleType, COUNT(*) AS drivers_over_1000_rides
FROM drivers
WHERE TotalRides > 1000
GROUP BY VehicleType
ORDER BY drivers_over_1000_rides DESC, VehicleType;

-- Q20. 5 se zyada rides, lekin koi 'Success' payment nahi (20)
SELECT r.UserID, COUNT(DISTINCT r.RideID) AS rides,
       COUNT(p.PaymentID) AS payments,
       SUM(CASE WHEN p.Status = 'Failed' THEN 1 ELSE 0 END) AS failed_payments,
       SUM(CASE WHEN p.Status = 'Success' THEN 1 ELSE 0 END) AS success_payments
FROM rides r
LEFT JOIN payments p ON p.RideID = r.RideID
GROUP BY r.UserID
HAVING COUNT(DISTINCT r.RideID) > 5
   AND SUM(CASE WHEN p.Status = 'Success' THEN 1 ELSE 0 END) = 0
ORDER BY rides DESC, r.UserID;

-- Q21. 10 km se lambi rides par sabse zyada average fare per minute, top 10
SELECT d.DriverID, d.Name, d.City, d.VehicleType,
       COUNT(*) AS rides_over_10km,
       ROUND(AVG(r.Fare / r.Duration_min), 2) AS avg_fare_per_min
FROM rides r JOIN drivers d ON d.DriverID = r.DriverID
WHERE r.Distance_km > 10
GROUP BY d.DriverID, d.Name, d.City, d.VehicleType
ORDER BY avg_fare_per_min DESC, d.DriverID
LIMIT 10;

USE rideshare;
SELECT UserID, Name, CustomerTag FROM users LIMIT 5;
SHOW COLUMNS FROM users;

SELECT CustomerTag, Name FROM users LIMIT 5;
