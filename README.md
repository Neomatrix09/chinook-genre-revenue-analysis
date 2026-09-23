# Chinook Music Store: Genre & Revenue Analysis

## Business Question
Which music genres and countries generate the most revenue for the store, and where should the business focus cross-promotion efforts?

## Data
The [Chinook database](https://github.com/lerocha/chinook-database) — a sample digital music store with customers, invoices, tracks, and genres across 11 countries. Analysis was done in SQLite via DB Browser for SQLite.

## Approach
Joined across 5 tables (`Invoice` → `InvoiceLine` → `Track` → `Genre`, and `Invoice` → `Customer`) to connect purchases to both what was bought and who bought it. Used `GROUP BY` for aggregation and a `RANK() OVER (PARTITION BY ...)` window function to identify each country's top genres without collapsing the underlying data.

## Key Findings

**1. Rock dominates revenue across every market**
Rock generated $826.65 — more than double the next closest genre (Latin, $382.14).

**2. USA and Canada are the top-spending markets**
USA: $523.06 · Canada: $303.96 · France: $195.10 · Brazil: $190.10

**3. Latin is the strongest secondary genre — but only past the #1 spot**
Ranking each country's #1 genre showed Rock winning everywhere — not a useful signal on its own. Looking at the #2 genre per country revealed real variation: **Latin ranks #2 in 5 of 11 countries**, including the two highest-revenue markets (USA, Canada), while a separate cluster (France, Belgium, India) favors Alternative & Punk instead.

## Recommendation
Rock is dominant everywhere and needs no promotional push. Latin, as the clear secondary preference in the store's largest markets, is a strong candidate for cross-promotion ("customers also bought") rather than treating all non-Rock genres as equally low-priority. Catalog depth for Latin would be a natural next question before considering inventory expansion. Smaller markets (e.g. Czech Republic, 8 tracks sold) had too few transactions for reliable conclusions and were excluded from genre-preference claims.

## Files
- `chinook.db` — the database
- `queries.sql` — all analysis queries, in order, with comments

## Tools
SQL (SQLite), DB Browser for SQLite
