-- ============================================
-- Chinook Music Store: Genre & Revenue Analysis
-- ============================================

-- Sanity check: confirm the database loaded correctly
SELECT COUNT(*) FROM Customer; -- expect 59

-- Explore raw table structure before joining
SELECT * FROM Invoice LIMIT 5;
SELECT * FROM InvoiceLine LIMIT 5;

-- Basic two-table join: connect an invoice to its line items
SELECT i.InvoiceId, i.CustomerId, il.TrackId, il.UnitPrice, il.Quantity
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
LIMIT 10;

-- Extend the join to show actual song and genre names, not just IDs
SELECT 
    i.InvoiceId,
    i.CustomerId,
    t.Name AS TrackName,
    g.Name AS GenreName,
    il.UnitPrice,
    il.Quantity
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
LIMIT 10;

-- Add Customer to bring country into view
SELECT 
    i.InvoiceId,
    c.Country,
    t.Name AS TrackName,
    g.Name AS GenreName,
    il.UnitPrice,
    il.Quantity
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
JOIN Customer c ON i.CustomerId = c.CustomerId
LIMIT 10;

-- ============================================
-- Q1: Which genre makes the store the most money?
-- ============================================
SELECT 
    g.Name AS GenreName,
    SUM(il.UnitPrice * il.Quantity) AS TotalRevenue,
    COUNT(il.InvoiceLineId) AS TracksSold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.Name
ORDER BY TotalRevenue DESC;
-- Finding: Rock leads with $826.65, more than double the #2 genre (Latin, $382.14)

-- ============================================
-- Q2: Which country makes the store the most money?
-- ============================================
SELECT 
    c.Country,
    SUM(il.UnitPrice * il.Quantity) AS TotalRevenue,
    COUNT(il.InvoiceLineId) AS TracksSold
FROM InvoiceLine il
JOIN Invoice i ON il.InvoiceId = i.InvoiceId
JOIN Customer c ON i.CustomerId = c.CustomerId
GROUP BY c.Country
ORDER BY TotalRevenue DESC;
-- Finding: USA leads at $523.06, Canada second at $303.96

-- ============================================
-- Q3: Combine genre and country to see the full breakdown
-- ============================================
SELECT 
    c.Country,
    g.Name AS GenreName,
    SUM(il.UnitPrice * il.Quantity) AS TotalRevenue,
    COUNT(il.InvoiceLineId) AS TracksSold
FROM InvoiceLine il
JOIN Invoice i ON il.InvoiceId = i.InvoiceId
JOIN Customer c ON i.CustomerId = c.CustomerId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY c.Country, g.Name
ORDER BY c.Country, TotalRevenue DESC;
-- Result: too granular to read directly (11 countries x multiple genres each) -> next step ranks this per country

-- ============================================
-- Q4: Rank each country's genres to find the #1 per country
-- ============================================
WITH genre_country_revenue AS (
    SELECT 
        c.Country,
        g.Name AS GenreName,
        SUM(il.UnitPrice * il.Quantity) AS TotalRevenue,
        COUNT(il.InvoiceLineId) AS TracksSold,
        RANK() OVER (PARTITION BY c.Country ORDER BY SUM(il.UnitPrice * il.Quantity) DESC) AS GenreRank
    FROM InvoiceLine il
    JOIN Invoice i ON il.InvoiceId = i.InvoiceId
    JOIN Customer c ON i.CustomerId = c.CustomerId
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Genre g ON t.GenreId = g.GenreId
    GROUP BY c.Country, g.Name
)
SELECT Country, GenreName, TotalRevenue, TracksSold
FROM genre_country_revenue
WHERE GenreRank = 1
ORDER BY TotalRevenue DESC;
-- Finding: every single country's #1 genre is Rock -> not a useful differentiator on its own,
-- since it just restates Q1. Re-ran at Rank = 2 to find where countries actually diverge.

-- ============================================
-- Q5: Rank 2 -- where real country-level variation shows up
-- ============================================
WITH genre_country_revenue AS (
    SELECT 
        c.Country,
        g.Name AS GenreName,
        SUM(il.UnitPrice * il.Quantity) AS TotalRevenue,
        COUNT(il.InvoiceLineId) AS TracksSold,
        RANK() OVER (PARTITION BY c.Country ORDER BY SUM(il.UnitPrice * il.Quantity) DESC) AS GenreRank
    FROM InvoiceLine il
    JOIN Invoice i ON il.InvoiceId = i.InvoiceId
    JOIN Customer c ON i.CustomerId = c.CustomerId
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Genre g ON t.GenreId = g.GenreId
    GROUP BY c.Country, g.Name
)
SELECT Country, GenreName, TotalRevenue, TracksSold
FROM genre_country_revenue
WHERE GenreRank = 2
ORDER BY TotalRevenue DESC;
-- Finding: Latin ranks #2 in 5 of 11 countries, including the top two markets (USA, Canada).
-- A separate cluster (France, Belgium, India) favors Alternative & Punk instead.
-- This is the insight the final recommendation is built on.
