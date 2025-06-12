
-- 1. Airport
CREATE TABLE airport (
    airport_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    airport_code VARCHAR(10) NOT NULL,
    airport_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    region VARCHAR(50),
    airport_type VARCHAR(30),
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    is_hub BOOLEAN DEFAULT FALSE,
    runway_available BOOLEAN DEFAULT TRUE,
    terminal_count INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT airport_code_unique UNIQUE (airport_code)
);

-- 2. Aircraft Model
CREATE TABLE aircraft_model (
    model_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    manufacturer VARCHAR(50) NOT NULL,
    model_name VARCHAR(50) NOT NULL,
    engine_type VARCHAR(30),
    max_speed INTEGER,
    max_range INTEGER,
    economy_capacity INTEGER,
    business_capacity INTEGER,
    first_class_capacity INTEGER
    );

-- 3. Aircraft
CREATE TABLE aircraft (
    aircraft_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    model_id INTEGER NOT NULL,
    registration_number VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    manufacture_date DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    current_airport_id INTEGER,
    CONSTRAINT aircraft_registration_unique UNIQUE (registration_number),
    CONSTRAINT aircraft_status_check CHECK (status IN ('Active', 'Maintenance', 'Retired')),
    CONSTRAINT fk_aircraft_model FOREIGN KEY (model_id) REFERENCES aircraft_model(model_id),
    CONSTRAINT fk_current_airport FOREIGN KEY (current_airport_id) REFERENCES airport(airport_id)
);

-- 4. Passenger
CREATE TABLE passenger (
    passenger_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    national_id VARCHAR(20),
    passport_number VARCHAR(20),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    email VARCHAR(100),
    phone VARCHAR(20),
    gender CHAR(1),
    preferred_language VARCHAR(20),
    marital_status VARCHAR(20),
    city VARCHAR(50),
    country VARCHAR(50),
    nationality VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT passenger_gender_check CHECK (gender IN ('M', 'F', 'O'))
);

-- 5. Passenger Profile
CREATE TABLE passenger_profile (
    profile_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    passenger_id INTEGER NOT NULL,
    frequent_flyer_number VARCHAR(20),
    tier_level VARCHAR(20),
    home_airport_id INTEGER,
    lifetime_miles INTEGER DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_passenger FOREIGN KEY (passenger_id) REFERENCES passenger(passenger_id),
    CONSTRAINT fk_home_airport FOREIGN KEY (home_airport_id) REFERENCES airport(airport_id)
);

-- 6. Promotion
CREATE TABLE promotion (
    promotion_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    promotion_code VARCHAR(20) NOT NULL,
    promotion_type VARCHAR(30) NOT NULL,
    target_segment VARCHAR(30),
    channel VARCHAR(30),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    discount_amount DECIMAL(10,2),
    discount_percentage DECIMAL(5,2),
    max_discount_amount DECIMAL(10,2),
    min_purchase_amount DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT promotion_code_unique UNIQUE (promotion_code)
);

-- 7. Channel
CREATE TABLE channel (
    channel_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    channel_name VARCHAR(50) NOT NULL,
    channel_type VARCHAR(30) NOT NULL,
    CONSTRAINT channel_type_check CHECK (channel_type IN ('Website', 'Mobile App', 'Call Center', 'Travel Agency', 'Airport Counter'))
);

-- 8. Fare Basis
CREATE TABLE fare_basis (
    fare_basis_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    class VARCHAR(20) NOT NULL,
    fare_type VARCHAR(30) NOT NULL,
    is_refundable BOOLEAN NOT NULL DEFAULT FALSE,
    change_fee DECIMAL(10,2) DEFAULT 0,
    baggage_allowance INTEGER,
    priority_boarding BOOLEAN DEFAULT FALSE,
    meal_included BOOLEAN DEFAULT FALSE,
    CONSTRAINT fare_class_check CHECK (class IN ('Economy', 'Premium Economy', 'Business', 'First'))
);

-- 9. Flight
CREATE TABLE flight (
    flight_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL,
    aircraft_id INTEGER NOT NULL,
    departure_airport_id INTEGER NOT NULL,
    arrival_airport_id INTEGER NOT NULL,
    scheduled_departure TIMESTAMP NOT NULL,
    scheduled_arrival TIMESTAMP NOT NULL,
    actual_departure TIMESTAMP,
    actual_arrival TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    gate_number VARCHAR(10),
    duration_minutes INTEGER,
    CONSTRAINT fk_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id),
    CONSTRAINT fk_departure_airport FOREIGN KEY (departure_airport_id) REFERENCES airport(airport_id),
    CONSTRAINT fk_arrival_airport FOREIGN KEY (arrival_airport_id) REFERENCES airport(airport_id),
    CONSTRAINT flight_status_check CHECK (status IN ('Scheduled', 'Boarding', 'Departed', 'Arrived', 'Cancelled', 'Delayed'))
);

-- 10. Seat
CREATE TABLE seat (
    seat_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aircraft_id INTEGER NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    class VARCHAR(20) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_aircraft FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id),
    CONSTRAINT seat_class_check CHECK (class IN ('Economy', 'Premium Economy', 'Business', 'First')),
    CONSTRAINT seat_unique UNIQUE (aircraft_id, seat_number)
);

-- 11. Reservation
CREATE TABLE reservation (
    reservation_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reservation_reference VARCHAR(20) NOT NULL,
    passenger_id INTEGER NOT NULL,
    flight_id INTEGER NOT NULL,
    fare_basis_id INTEGER NOT NULL,
    channel_id INTEGER NOT NULL,
    promotion_id INTEGER,
    reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30),
    base_fare DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    fees_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    is_cancelled BOOLEAN DEFAULT FALSE,
    cancellation_date TIMESTAMP,
    cancellation_fee DECIMAL(10,2) DEFAULT 0,
    cancellation_reason VARCHAR(100),
    CONSTRAINT reservation_reference_unique UNIQUE (reservation_reference),
    CONSTRAINT fk_passenger FOREIGN KEY (passenger_id) REFERENCES passenger(passenger_id),
    CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES flight(flight_id),
    CONSTRAINT fk_fare_basis FOREIGN KEY (fare_basis_id) REFERENCES fare_basis(fare_basis_id),
    CONSTRAINT fk_channel FOREIGN KEY (channel_id) REFERENCES channel(channel_id),
    CONSTRAINT fk_promotion FOREIGN KEY (promotion_id) REFERENCES promotion(promotion_id)
);

-- 12. Ticket
CREATE TABLE ticket (
    ticket_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reservation_id INTEGER NOT NULL,
    seat_id INTEGER NOT NULL,
    ticket_number VARCHAR(20) NOT NULL,
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    boarding_pass_issued BOOLEAN DEFAULT FALSE,
    boarding_time TIMESTAMP,
    CONSTRAINT ticket_number_unique UNIQUE (ticket_number),
    CONSTRAINT fk_reservation FOREIGN KEY (reservation_id) REFERENCES reservation(reservation_id),
    CONSTRAINT fk_seat FOREIGN KEY (seat_id) REFERENCES seat(seat_id),
    CONSTRAINT ticket_status_check CHECK (status IN ('Issued', 'Boarded', 'Used', 'Refunded', 'Voided'))
);

-- 13. Payment
CREATE TABLE payment (
    payment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reservation_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_id VARCHAR(50),
    status VARCHAR(20) NOT NULL,
    card_last_four VARCHAR(4),
    CONSTRAINT fk_reservation FOREIGN KEY (reservation_id) REFERENCES reservation(reservation_id),
    CONSTRAINT payment_status_check CHECK (status IN ('Pending', 'Completed', 'Failed', 'Refunded'))
);

-- 14. Country Holiday
CREATE TABLE country_holiday (
    holiday_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_code VARCHAR(3) NOT NULL,
    holiday_name VARCHAR(50) NOT NULL,
    holiday_date DATE NOT NULL,
    holiday_type VARCHAR(20) NOT NULL,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_pattern VARCHAR(20),
    CONSTRAINT holiday_type_check CHECK (holiday_type IN ('Civil', 'Religious'))
);

-- 15. Crew
CREATE TABLE crew (
    crew_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(30) NOT NULL,
    license_number VARCHAR(20),
    hire_date DATE NOT NULL,
    CONSTRAINT crew_role_check CHECK (role IN ('Pilot', 'Co-Pilot', 'Flight Attendant', 'Engineer'))
);

-- 16. Flight Crew
CREATE TABLE flight_crew (
    flight_crew_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flight_id INTEGER NOT NULL,
    crew_id INTEGER NOT NULL,
    role VARCHAR(30) NOT NULL,
    is_lead BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES flight(flight_id),
    CONSTRAINT fk_crew FOREIGN KEY (crew_id) REFERENCES crew(crew_id),
    CONSTRAINT flight_crew_unique UNIQUE (flight_id, crew_id)
);

-- 17. Baggage
CREATE TABLE baggage (
    baggage_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id INTEGER NOT NULL,
    weight DECIMAL(5,2) NOT NULL,
    piece_count INTEGER NOT NULL DEFAULT 1,
    status VARCHAR(20) NOT NULL,
    tracking_number VARCHAR(50),
    CONSTRAINT fk_ticket FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id),
    CONSTRAINT baggage_status_check CHECK (status IN ('Checked', 'Loaded', 'Transferred', 'Arrived', 'Lost'))
);

-- 18. Flight Status History
CREATE TABLE flight_status_history (
    history_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flight_id INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL,
    status_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks VARCHAR(100),
    CONSTRAINT fk_flight FOREIGN KEY (flight_id) REFERENCES flight(flight_id)
);
-- metadata
CREATE TABLE public.meta_data (
	id int4 NOT NULL,
	inc_time timestamp DEFAULT (CURRENT_TIMESTAMP + '03:00:00'::interval) NULL,
	CONSTRAINT meta_data_pk PRIMARY KEY (id)
);
-- 1. Insert into airport
INSERT INTO airport (airport_code, airport_name, city, country, region, airport_type, latitude, longitude, is_hub, runway_available, terminal_count)
VALUES ('JFK', 'John F. Kennedy International Airport', 'New York', 'United States', 'Northeast', 'International', 40.6413, -73.7781, TRUE, TRUE, 6);

-- 2. Insert into aircraft_model
INSERT INTO aircraft_model (manufacturer, model_name, engine_type, max_speed, max_range, economy_capacity, business_capacity, first_class_capacity)
VALUES ('Boeing', '787-9 Dreamliner', 'Turbofan', 903, 15750, 248, 35, 20);

-- 3. Insert into aircraft
INSERT INTO aircraft (model_id, registration_number, status, manufacture_date, last_maintenance_date, next_maintenance_date, current_airport_id)
VALUES (1, 'N78901', 'Active', '2020-05-15', '2023-01-10', '2023-07-10', 1);

-- 4. Insert into passenger
INSERT INTO passenger (national_id, passport_number, first_name, last_name, date_of_birth, email, phone, gender, preferred_language, marital_status, city, country, nationality)
VALUES ('A12345678', 'P987654321', 'John', 'Smith', '1985-07-22', 'john.smith@example.com', '+12025551234', 'M', 'English', 'Married', 'New York', 'United States', 'American');

-- 5. Insert into passenger_profile
INSERT INTO passenger_profile (passenger_id, frequent_flyer_number, tier_level, home_airport_id, lifetime_miles, start_date, is_active)
VALUES (1, 'FF12345678', 'Gold', 1, 45000, '2020-03-15', TRUE);

-- 6. Insert into promotion
INSERT INTO promotion (promotion_code, promotion_type, target_segment, channel, start_date, end_date, discount_amount, is_active)
VALUES ('SUMMER2023', 'Seasonal', 'All', 'Website', '2023-06-01 00:00:00', '2023-08-31 23:59:59', 50.00, TRUE);

-- 7. Insert into channel
INSERT INTO channel (channel_name, channel_type)
VALUES ('Airline Website', 'Website');

-- 8. Insert into fare_basis
INSERT INTO fare_basis (class, fare_type, is_refundable, change_fee, baggage_allowance, priority_boarding, meal_included)
VALUES ('Business', 'Flex', TRUE, 100.00, 32, TRUE, TRUE);

-- 9. Insert into flight
INSERT INTO flight (flight_number, aircraft_id, departure_airport_id, arrival_airport_id, scheduled_departure, scheduled_arrival, status, gate_number, duration_minutes)
VALUES ('AA123', 1, 1, 1, '2023-07-15 08:00:00', '2023-07-15 11:30:00', 'Scheduled', 'B12', 210);

-- 10. Insert into seat
INSERT INTO seat (aircraft_id, seat_number, class, is_available)
VALUES (1, '12A', 'Business', FALSE);

-- 11. Insert into reservation
INSERT INTO reservation (reservation_reference, passenger_id, flight_id, fare_basis_id, channel_id, promotion_id, payment_method, base_fare, tax_amount, fees_amount, discount_amount, total_amount)
VALUES ('RES-AA123-456', 1, 1, 1, 1, 1, 'Credit Card', 1200.00, 150.00, 75.00, 50.00, 1375.00);

-- 12. Insert into ticket
INSERT INTO ticket (reservation_id, seat_id, ticket_number, status, boarding_pass_issued)
VALUES (1, 1, 'TKT-78901234', 'Issued', TRUE);

-- 13. Insert into payment
INSERT INTO payment (reservation_id, amount, payment_method, transaction_id, status, card_last_four)
VALUES (1, 1375.00, 'Credit Card', 'TXN-987654321', 'Completed', '1234');

-- 14. Insert into country_holiday
INSERT INTO country_holiday (country_code, holiday_name, holiday_date, holiday_type, is_recurring, recurrence_pattern)
VALUES ('US', 'Independence Day', '2023-07-04', 'Civil', TRUE, 'Yearly');

-- 15. Insert into crew
INSERT INTO crew (first_name, last_name, role, license_number, hire_date)
VALUES ('Sarah', 'Johnson', 'Pilot', 'PLT-123456', '2015-06-10');

-- 16. Insert into flight_crew
INSERT INTO flight_crew (flight_id, crew_id, role, is_lead)
VALUES (1, 1, 'Pilot', TRUE);

-- 17. Insert into baggage
INSERT INTO baggage (ticket_id, weight, piece_count, status, tracking_number)
VALUES (1, 23.5, 2, 'Checked', 'BAG-78901234');

-- 18. Insert into flight_status_history
INSERT INTO flight_status_history (flight_id, status, remarks)
VALUES (1, 'Scheduled', 'Initial flight schedule created');

-- 1. Airport (even though it has them, we'll ensure consistency)
ALTER TABLE airport 
ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP,
ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;

-- 2. Aircraft Model
ALTER TABLE aircraft_model 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 3. Aircraft
ALTER TABLE aircraft 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 4. Passenger
ALTER TABLE passenger 
ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP,
ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;

-- 5. Passenger Profile
ALTER TABLE passenger_profile 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 6. Promotion
ALTER TABLE promotion 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 7. Channel
ALTER TABLE channel 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 8. Fare Basis
ALTER TABLE fare_basis 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 9. Flight
ALTER TABLE flight 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 10. Seat
ALTER TABLE seat 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 11. Reservation
ALTER TABLE reservation 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 12. Ticket
ALTER TABLE ticket 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 13. Payment
ALTER TABLE payment 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 14. Country Holiday
ALTER TABLE country_holiday 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 15. Crew
ALTER TABLE crew 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 16. Flight Crew
ALTER TABLE flight_crew 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 17. Baggage
ALTER TABLE baggage 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- 18. Flight Status History (adding updated_at despite being history table for consistency)
ALTER TABLE flight_status_history 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

CREATE OR REPLACE FUNCTION update_all_timestamps()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for ALL tables with updated_at
DO $$
DECLARE
    t record;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
    LOOP
        IF EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = t.table_name 
            AND column_name = 'updated_at'
        ) THEN
            EXECUTE format('
                DROP TRIGGER IF EXISTS trg_%s_update_timestamp ON %I;
                CREATE TRIGGER trg_%s_update_timestamp
                BEFORE UPDATE ON %I
                FOR EACH ROW EXECUTE FUNCTION update_all_timestamps();',
                t.table_name, t.table_name, t.table_name, t.table_name);
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;



-- Function to get the last extraction time from meta_data
CREATE OR REPLACE FUNCTION public.get_last_extraction_time()
RETURNS TIMESTAMP WITH TIME ZONE AS $$
DECLARE
    last_time TIMESTAMP WITH TIME ZONE;
BEGIN
    SELECT COALESCE(MAX(inc_time), '1970-01-01'::TIMESTAMP WITH TIME ZONE) 
    INTO last_time
    FROM public.meta_data;
    
    RETURN last_time;
END;
$$ LANGUAGE plpgsql;

-- Create incremental views for all tables (except meta_data)
-- Airport view
CREATE OR REPLACE VIEW public.vw_airport_inc AS
SELECT airport_id,airport_code, airport_name, city, country, region, airport_type, latitude, longitude, is_hub, runway_available, terminal_count FROM public.airport 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());

-- Aircraft_model view
CREATE OR REPLACE VIEW public.vw_aircraft_model_inc AS
SELECT model_id,manufacturer, model_name, engine_type, max_speed, max_range, economy_capacity, business_capacity, first_class_capacity FROM public.aircraft_model 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());



-- Aircraft view
CREATE OR REPLACE VIEW public.vw_aircraft_inc AS
SELECT aircraft_id,model_id, registration_number, status, manufacture_date, last_maintenance_date, next_maintenance_date, current_airport_id FROM public.aircraft 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());


-- Passenger view
CREATE OR REPLACE VIEW public.vw_passenger_inc AS
SELECT passenger_id,national_id, passport_number, first_name, last_name, date_of_birth, email, phone, gender, preferred_language, marital_status, city, country, nationality FROM public.passenger 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());

-- Passenger_profile view
CREATE OR REPLACE VIEW public.vw_passenger_profile_inc AS
SELECT profile_id,passenger_id, frequent_flyer_number, tier_level, home_airport_id, lifetime_miles, start_date, end_date,is_active FROM public.passenger_profile 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());

-- Promotion view
CREATE OR REPLACE VIEW public.vw_promotion_inc AS
SELECT promotion_id,promotion_code, promotion_type, target_segment, channel, start_date, end_date, discount_amount,discount_percentage,max_discount_amount,min_purchase_amount,is_active FROM public.promotion 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());


-- Channel view
CREATE OR REPLACE VIEW public.vw_channel_inc AS
SELECT channel_id,channel_name, channel_type FROM public.channel 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());


CREATE OR REPLACE VIEW public.vw_fare_basis_inc AS
SELECT fare_basis_id,class, fare_type, is_refundable, change_fee, baggage_allowance, priority_boarding, meal_included FROM public.fare_basis 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());

-- Flight view
CREATE OR REPLACE VIEW public.vw_flight_inc AS
SELECT flight_id,flight_number, aircraft_id, departure_airport_id, arrival_airport_id, scheduled_departure, scheduled_arrival,actual_departure, actual_arrival,status, gate_number, duration_minutes FROM public.flight 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());


-- Seat view
CREATE OR REPLACE VIEW public.vw_seat_inc AS
SELECT seat_id,aircraft_id, seat_number, class, is_available FROM public.seat 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());


-- Reservation view
CREATE OR REPLACE VIEW public.vw_reservation_inc AS
SELECT reservation_id,reservation_reference, passenger_id, flight_id, fare_basis_id, channel_id, promotion_id,reservation_date, payment_method, base_fare, tax_amount, fees_amount, discount_amount, total_amount,is_cancelled,cancellation_date,cancellation_fee,cancellation_reason
FROM public.reservation 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());



-- Ticket view
CREATE OR REPLACE VIEW public.vw_ticket_inc AS
SELECT ticket_id,reservation_id, seat_id, ticket_number,issue_date, status, boarding_pass_issued,boarding_time FROM public.ticket 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());

-- Payment view
CREATE OR REPLACE VIEW public.vw_payment_inc AS
SELECT payment_id,reservation_id, amount, payment_method,payment_date, transaction_id, status, card_last_four FROM public.payment 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());


-- Country_holiday view
CREATE OR REPLACE VIEW public.vw_country_holiday_inc AS
SELECT holiday_id,country_code, holiday_name, holiday_date, holiday_type, is_recurring, recurrence_pattern FROM public.country_holiday 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());


-- Crew view
CREATE OR REPLACE VIEW public.vw_crew_inc AS
SELECT crew_id,first_name, last_name, role, license_number, hire_date FROM public.crew 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());


-- Flight_crew view
CREATE OR REPLACE VIEW public.vw_flight_crew_inc AS
SELECT flight_crew_id,flight_id, crew_id, role, is_lead FROM public.flight_crew 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());

-- Baggage view
CREATE OR REPLACE VIEW public.vw_baggage_inc AS
SELECT baggage_id,ticket_id, weight, piece_count, status, tracking_number FROM public.baggage 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());


-- Flight_status_history view (special case - uses status_time)
CREATE OR REPLACE VIEW public.vw_flight_status_history_inc AS
SELECT history_id,flight_id, status,status_time, remarks FROM public.flight_status_history 
WHERE created_at > (SELECT public.get_last_extraction_time())
   OR updated_at > (SELECT public.get_last_extraction_time());
--truncate meta_data;


