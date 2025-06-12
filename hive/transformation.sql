USE airline_views;
CREATE TABLE IF NOT EXISTS temp_fact_reservation STORED AS ORC AS
SELECT 
    r.reservation_id AS Reservation_Key,
    t.ticket_id,
    c.channel_id AS channel_key,
    COALESCE(p.promotion_id, -1) AS promotion_key, -- -1 for NULL promotions
    ps.passenger_id AS passenger_key,
    fb.fare_basis_id AS fare_basis_key,
    a.aircraft_id AS aircraft_key,
    f.departure_airport_id AS source_airport,
    f.arrival_airport_id AS destination_airport,
    
    -- Date dimension keys (formatted as YYYYMMDD)
    CAST(DATE_FORMAT(f.scheduled_departure, 'yyyyMMdd') AS BIGINT) AS departure_date_key,
    f.scheduled_departure AS departure_time,
    r.reservation_date AS Reservation_timestamp,

    r.payment_method,
    s.seat_number AS seat_no,

    -- Financial calculations
    COALESCE(r.discount_amount, 0) AS Promotion_Amount,
    r.tax_amount,
    r.fees_amount AS Operational_Fees,
    COALESCE(r.cancellation_fee, 0) AS Cancelation_Fees,
    r.base_fare AS Fare_Price,
    r.total_amount AS Final_Price,
    CASE WHEN r.is_cancelled THEN 1 ELSE 0 END AS Is_Cancelled,
    
    -- Partition column (extracted from reservation date)
    CAST(DATE_FORMAT(r.reservation_date, 'yyyyMMdd') AS BIGINT) AS reservation_date_key

FROM 
    reservation r
JOIN 
    ticket t ON r.reservation_id = t.reservation_id
JOIN 
    seat s ON t.seat_id = s.seat_id
JOIN 
    flight f ON r.flight_id = f.flight_id
JOIN 
    aircraft a ON f.aircraft_id = a.aircraft_id
JOIN 
    passenger ps ON r.passenger_id = ps.passenger_id
JOIN 
    channel c ON r.channel_id = c.channel_id
JOIN 
    fare_basis fb ON r.fare_basis_id = fb.fare_basis_id
LEFT JOIN 
    promotion p ON r.promotion_id = p.promotion_id
WHERE 
    r.is_cancelled = FALSE OR r.cancellation_date IS NOT NULL;

INSERT into TABLE dwh_project.fact_reservation PARTITION(year)
SELECT
    Reservation_Key,
    ticket_id,
    channel_key,
    promotion_key,
    passenger_key,
    fare_basis_key,
    aircraft_key,
    source_airport,
    destination_airport,
    reservation_date_key,
    departure_date_key,
    departure_time,
    Reservation_timestamp,
    payment_method,
    seat_no,
    Promotion_Amount,
    tax_amount,
    Operational_Fees,
    Cancelation_Fees,
    Fare_Price,
    Final_Price,
    Is_Cancelled,
    INT(reservation_date_key/10000) AS year 
    from
    temp_fact_reservation;

drop table temp_fact_reservation;