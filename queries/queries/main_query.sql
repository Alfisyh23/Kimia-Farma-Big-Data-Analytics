CREATE OR REPLACE TABLE `rakamin-kf-analytics-507521.Kimia_Farma.analisa_kimia_farma` AS
WITH base_data AS (
  SELECT 
    t.transaction_id,
    t.date,
    t.branch_id,
    c.branch_name,
    c.kota,
    c.provinsi,
    c.rating AS rating_cabang,
    t.customer_name,
    t.product_id,
    p.product_name,
    p.price AS actual_price,
    t.discount_percentage,
    -- Logika persentase gross laba berdasarkan harga obat
    CASE 
      WHEN p.price <= 50000 THEN 0.10
      WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
      WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
      WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
      ELSE 0.30
    END AS persentase_gross_laba,
    t.rating AS rating_transaksi
  FROM `rakamin-kf-analytics-507521.Kimia_Farma.kf_final_transaction` t
  LEFT JOIN `rakamin-kf-analytics-507521.Kimia_Farma.kf_product` p 
    ON t.product_id = p.product_id
  LEFT JOIN `rakamin-kf-analytics-507521.Kimia_Farma.kf_kantor_cabang` c 
    ON t.branch_id = c.branch_id
)
SELECT 
  transaction_id,
  date,
  branch_id,
  branch_name,
  kota,
  provinsi,
  rating_cabang,
  customer_name,
  product_id,
  product_name,
  actual_price,
  discount_percentage,
  persentase_gross_laba,
  -- Perhitungan Nett Sales (Harga setelah diskon)
  actual_price * (1 - (discount_percentage / 100.0)) AS nett_sales,
  -- Perhitungan Nett Profit (Keuntungan Kimia Farma)
  (actual_price * (1 - (discount_percentage / 100.0))) * persentase_gross_laba AS nett_profit,
  rating_transaksi
FROM base_data;
