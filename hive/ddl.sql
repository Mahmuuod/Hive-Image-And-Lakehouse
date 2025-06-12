CREATE DATABASE IF NOT EXISTS DWH_Project
COMMENT 'Data Warehouse Project Database'
WITH DBPROPERTIES (
  'created.by' = 'Mahmoud',
  'purpose' = 'Data warehouse for reservation system'
);
-----
SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;
SET hive.enforce.bucketing = true;
SET hive.enforce.sorting = true;

USE DWH_Project;

/*Dim Air_Port*/
CREATE EXTERNAL TABLE IF NOT EXISTS  dim_airport (
    AirPortKey INT,
    Airport_name STRING,
    City STRING,
    Country STRING,
    Region STRING,
    airport_type STRING,
    Latitude FLOAT,
    Longitude FLOAT,
    Hub_Status STRING,
    Runway_available BOOLEAN,
    no_of_Terminal INT
)
STORED AS ORC
LOCATION '/user/hive/warehouse/tables/dim_AirPort';
/*FACT fact_reservation*/
CREATE EXTERNAL TABLE IF NOT EXISTS stage_fact_reservation (
    Reservation_Key         BIGINT,
    ticket_id               BIGINT,
    channel_key             BIGINT,
    promotion_key           BIGINT,
    passenger_key           BIGINT,
    fare_basis_key          BIGINT,
    aircraft_key            BIGINT,
    source_airport          BIGINT,
    destination_airport     BIGINT,
    reservation_date_key bigint,

    departure_date_key      BIGINT,
    departure_time          TIMESTAMP,
    Reservation_timestamp   TIMESTAMP,

    payment_method          STRING,
    seat_no                 STRING,

    Promotion_Amount        DECIMAL(10,2),
    tax_amount              DECIMAL(10,2),
    Operational_Fees        DECIMAL(10,2),
    Cancelation_Fees        DECIMAL(10,2),
    Fare_Price              DECIMAL(10,2),
    Final_Price             DECIMAL(10,2),  
    Is_Cancelled            TINYINT
)
STORED AS ORC
location '/user/hive/warehouse/tables/fact_reservation/';

CREATE EXTERNAL TABLE IF NOT EXISTS fact_reservation(
    Reservation_Key         BIGINT,
    ticket_id               BIGINT,
    channel_key             BIGINT,
    promotion_key           BIGINT,
    passenger_key           BIGINT,
    fare_basis_key          BIGINT,
    aircraft_key            BIGINT,
    source_airport          BIGINT,
    destination_airport     BIGINT,

    reservation_date_key    BIGINT,  -- moved up to main schema
    departure_date_key      BIGINT,
    departure_time          TIMESTAMP,
    Reservation_timestamp   TIMESTAMP,

    payment_method          STRING,
    seat_no                 STRING,

    Promotion_Amount        DECIMAL(10,2),
    tax_amount              DECIMAL(10,2),
    Operational_Fees        DECIMAL(10,2),
    Cancelation_Fees        DECIMAL(10,2),
    Fare_Price              DECIMAL(10,2),
    Final_Price             DECIMAL(10,2),  
    Is_Cancelled            TINYINT
)
PARTITIONED BY (year INT)
CLUSTERED BY (Reservation_Key) INTO 16 BUCKETS
STORED AS ORC
LOCATION '/user/hive/warehouse/tables/fact_reservation/bucketed_fact_reservation'
TBLPROPERTIES (
    'orc.compress' = 'ZLIB'
);


INSERT OVERWRITE TABLE fact_reservation PARTITION (year)
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
    INT(reservation_date_key/10000) AS year  -- convert to year
FROM stage_fact_reservation;




drop table stage_fact_reservation;
/*Dim dim_passenger*/
CREATE TABLE IF NOT EXISTS dim_passenger (
    passenger_key             BIGINT,
    passenger_id              BIGINT,
    passenger_national_id     STRING,
    passenger_passport_id     STRING,
    passenger_firstname       STRING,
    passenger_lastname        STRING,
    passenger_dob             DATE,
    passenger_city            STRING,
    passenger_nationality     STRING,
    passenger_country         STRING,
    passenger_email           STRING,
    passenger_phoneno         STRING,
    passenger_gender          STRING,
    passenger_language        STRING,
    passenger_marital_status  STRING
)
CLUSTERED BY (passenger_key) INTO 16 BUCKETS
STORED AS ORC
LOCATION '/user/hive/warehouse/tables/dim_Passenger';

/*Dim dim_promotions*/
CREATE EXTERNAL TABLE IF NOT EXISTS stage_dim_promotions (
    promotion_id               BIGINT,
    promotion_key              BIGINT,
    promotion_type             STRING,
    promotion_target_segment   STRING,
    promotion_channel          STRING,
    promotion_start_date       DATE,
    promotion_end_date         DATE,
    is_current                 CHAR(1),
    discount                   DECIMAL(10,2)
)
STORED AS ORC
LOCATION '/user/hive/warehouse/tables/dim_promotion';


CREATE  TABLE IF NOT EXISTS dim_promotions (
    promotion_id               BIGINT,
    promotion_key              BIGINT,
    promotion_type             STRING,
    promotion_target_segment   STRING,
    promotion_channel          STRING,
    promotion_start_date       DATE,
    promotion_end_date         DATE,
    is_current                 CHAR(1),
    discount                   DECIMAL(10,2)
)
CLUSTERED BY (promotion_key) INTO 16 BUCKETS
STORED AS ORC
LOCATION '/user/hive/warehouse/tables/bucketed_dim_promotion'
TBLPROPERTIES (
    'transactional'='true'
);
INSERT INTO TABLE dim_promotions
SELECT 
    promotion_id,
    promotion_key,
    promotion_type,
    promotion_target_segment,
    promotion_channel,
    promotion_start_date,
    promotion_end_date,
    is_current,
    discount
FROM stage_dim_promotions;

/*Dim dim_date*/

CREATE EXTERNAL TABLE IF NOT EXISTS dim_date (
    DateKey      BIGINT,
    Full_date    DATE,
    DayNumber    BIGINT,
    DayName      STRING,
    monthName    STRING,
    yearNo       BIGINT,
    season       STRING,
    quarter      BIGINT
)
STORED AS ORC
LOCATION '/user/hive/warehouse/tables/dim_date';

/*Dim dim_passenger_profile_history*/

CREATE EXTERNAL TABLE IF NOT EXISTS dim_passenger_profile_history (
    profile_history_key    BIGINT,
    profile_key            BIGINT,
    frequent_flyer_tier    STRING,
    home_airport           STRING,
    lifetime_mileage_tier  STRING,
    start_date             DATE,
    end_date               DATE
)
STORED AS ORC
LOCATION '/user/hive/warehouse/tables/dim_passenger_profile_history';

/*Dim dim_aircraft*/
CREATE EXTERNAL TABLE IF NOT EXISTS dim_aircraft (
    aircraft_key             BIGINT,
    aircraft_manufacturer           STRING,
    aircraft_capacity        BIGINT,
    aircraft_model    STRING,
    aircraft_enginetype      STRING,
    aircraft_status          STRING,
    economy_seats_range      STRING,
    business_seats_range     STRING,
    firstclass_seats_range   STRING,
    max_miles                BIGINT,
    max_speed                BIGINT
)
STORED AS ORC
LOCATION '/user/hive/warehouse/tables/dim_AirCraft';

/*Dim dim_channel*/

CREATE EXTERNAL TABLE IF NOT EXISTS dim_channel (
    channel_key    BIGINT,
    channel_name   STRING,
    channel_type   STRING
)
STORED AS ORC
LOCATION '/user/hive/warehouse/tables/dim_channel';

/*Dim dim_farebasis*/
CREATE EXTERNAL TABLE IF NOT EXISTS dim_farebasis (
    farebasis_key               BIGINT,
    farebasis_class              STRING,
    farebasis_type               STRING,
    Refundability               STRING,
    ChangeFee    bigint,
    BaggageAllowance        BIGINT,
    PriorityBoarding      boolean

)
STORED AS ORC
LOCATION '/user/hive/warehouse/tables/dim_FareBase';

/*Dim dim_country_specific_date*/
CREATE EXTERNAL TABLE IF NOT EXISTS dim_country_specific_date (
    date_key                BIGINT,
    country_key             BIGINT,
    country_name            STRING,
    civil_name              STRING,
    civil_holiday_flag      STRING,
    civil_holiday_name      STRING,
    religious_holiday_flag  STRING,
    religious_holiday_name  STRING,
    weekday_indicator       STRING,
    season_name             STRING
)
STORED AS ORC
LOCATION '/user/hive/warehouse/tables/dim_country_specific_date';
