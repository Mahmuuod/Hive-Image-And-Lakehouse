-- Create database for the views
drop database if exists airline_views cascade;
CREATE database airline_views;
USE airline_views;
-- Airport table
CREATE EXTERNAL TABLE airport (
    airport_id INT,
    airport_code STRING,
    airport_name STRING,
    city STRING,
    country STRING,
    region STRING,
    airport_type STRING,
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    is_hub BOOLEAN,
    runway_available BOOLEAN,
    terminal_count INT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_airport_inc.orc';

-- Aircraft_model table
CREATE EXTERNAL TABLE aircraft_model (
    model_id INT,
    manufacturer STRING,
    model_name STRING,
    engine_type STRING,
    max_speed INT,
    max_range INT,
    economy_capacity INT,
    business_capacity INT,
    first_class_capacity INT,
    total_capacity INT
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_aircraft_model_inc.orc';

-- Aircraft table
CREATE EXTERNAL TABLE aircraft (
    aircraft_id INT,
    model_id INT,
    registration_number STRING,
    status STRING,
    manufacture_date DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    current_airport_id INT,
    created_at TIMESTAMP
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_aircraft_inc.orc';

-- Passenger table
CREATE EXTERNAL TABLE passenger (
    passenger_id INT,
    national_id STRING,
    passport_number STRING,
    first_name STRING,
    last_name STRING,
    date_of_birth DATE,
    email STRING,
    phone STRING,
    gender STRING,
    preferred_language STRING,
    marital_status STRING,
    city STRING,
    country STRING,
    nationality STRING,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_passenger_inc.orc';

-- Passenger_profile table
CREATE EXTERNAL TABLE passenger_profile (
    profile_id INT,
    passenger_id INT,
    frequent_flyer_number STRING,
    tier_level STRING,
    home_airport_id INT,
    lifetime_miles INT,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_passenger_profile_inc.orc';

-- Promotion table
CREATE EXTERNAL TABLE promotion (
    promotion_id INT,
    promotion_code STRING,
    promotion_type STRING,
    target_segment STRING,
    channel STRING,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    discount_amount DECIMAL(10,2),
    discount_percentage DECIMAL(5,2),
    max_discount_amount DECIMAL(10,2),
    min_purchase_amount DECIMAL(10,2),
    is_active BOOLEAN
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_promotion_inc.orc';

-- Channel table
CREATE EXTERNAL TABLE channel (
    channel_id INT,
    channel_name STRING,
    channel_type STRING
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_channel_inc.orc';

-- Fare_basis table
CREATE EXTERNAL TABLE fare_basis (
    fare_basis_id INT,
    class STRING,
    fare_type STRING,
    is_refundable BOOLEAN,
    change_fee DECIMAL(10,2),
    baggage_allowance INT,
    priority_boarding BOOLEAN,
    meal_included BOOLEAN
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_fare_basis_inc.orc';

-- Flight table
CREATE EXTERNAL TABLE flight (
    flight_id INT,
    flight_number STRING,
    aircraft_id INT,
    departure_airport_id INT,
    arrival_airport_id INT,
    scheduled_departure TIMESTAMP,
    scheduled_arrival TIMESTAMP,
    actual_departure TIMESTAMP,
    actual_arrival TIMESTAMP,
    status STRING,
    gate_number STRING,
    duration_minutes INT
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_flight_inc.orc';

-- Seat table
CREATE EXTERNAL TABLE seat (
    seat_id INT,
    aircraft_id INT,
    seat_number STRING,
    class STRING,
    is_available BOOLEAN
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_seat_inc.orc';

-- Reservation table
CREATE EXTERNAL TABLE reservation (
    reservation_id INT,
    reservation_reference STRING,
    passenger_id INT,
    flight_id INT,
    fare_basis_id INT,
    channel_id INT,
    promotion_id INT,
    reservation_date TIMESTAMP,
    payment_method STRING,
    base_fare DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    fees_amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    is_cancelled BOOLEAN,
    cancellation_date TIMESTAMP,
    cancellation_fee DECIMAL(10,2),
    cancellation_reason STRING
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_reservation_inc.orc';

-- Ticket table
CREATE EXTERNAL TABLE ticket (
    ticket_id INT,
    reservation_id INT,
    seat_id INT,
    ticket_number STRING,
    issue_date TIMESTAMP,
    status STRING,
    boarding_pass_issued BOOLEAN,
    boarding_time TIMESTAMP
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_ticket_inc.orc';

-- Payment table
CREATE EXTERNAL TABLE payment (
    payment_id INT,
    reservation_id INT,
    amount DECIMAL(10,2),
    payment_method STRING,
    payment_date TIMESTAMP,
    transaction_id STRING,
    status STRING,
    card_last_four STRING
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_payment_inc.orc';

-- Country_holiday table
CREATE EXTERNAL TABLE country_holiday (
    holiday_id INT,
    country_code STRING,
    holiday_name STRING,
    holiday_date DATE,
    holiday_type STRING,
    is_recurring BOOLEAN,
    recurrence_pattern STRING
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_country_holiday_inc.orc';

-- Crew table
CREATE EXTERNAL TABLE crew (
    crew_id INT,
    first_name STRING,
    last_name STRING,
    role STRING,
    license_number STRING,
    hire_date DATE
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_crew_inc.orc';

-- Flight_crew table
CREATE EXTERNAL TABLE flight_crew (
    flight_crew_id INT,
    flight_id INT,
    crew_id INT,
    role STRING,
    is_lead BOOLEAN
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_flight_crew_inc.orc';

-- Baggage table
CREATE EXTERNAL table baggage (
    baggage_id INT,
    ticket_id INT,
    weight DECIMAL(5,2),
    piece_count INT,
    status STRING,
    tracking_number STRING
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_baggage_inc.orc';

-- Flight_status_history table
CREATE EXTERNAL TABLE flight_status_history (
    history_id INT,
    flight_id INT,
    status STRING,
    status_time TIMESTAMP,
    remarks STRING
)
STORED AS ORC
LOCATION '/user/hive/warehouse/views/vw_flight_status_history_inc.orc';

