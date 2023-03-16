--Вывести к каждому самолету класс обслуживания и количество мест этого класса
SELECT ad.model, s.fare_conditions, COUNT(*) AS quantity_seats FROM aircrafts_data AS ad
JOIN seats s ON ad.aircraft_code = s.aircraft_code
GROUP BY ad.model, s.fare_conditions;


--Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT ad.model, COUNT(*) AS quantity_seats FROM aircrafts_data AS ad
JOIN seats s ON ad.aircraft_code = s.aircraft_code
GROUP BY ad.model
ORDER BY quantity_seats DESC
LIMIT 3;


--Вывести код,модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам
SELECT ad.aircraft_code, ad.model, s.seat_no FROM aircrafts_data AS ad
JOIN seats s ON ad.aircraft_code = s.aircraft_code
WHERE s.fare_conditions != 'Economy'
AND jsonb_extract_path_text(ad.model, 'ru') = 'Аэробус A321-200'
ORDER BY s.seat_no;


--Вывести города в которых больше 1 аэропорта ( код аэропорта, аэропорт, город)
SELECT ad.airport_code, ad.airport_name, ad.city FROM airports_data AS ad
WHERE ad.city IN (
    SELECT in_ad.city FROM airports_data AS in_ad
    GROUP BY in_ad.city
    HAVING COUNT(in_ad.airport_code) > 1);


-- Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT * FROM  flights AS f
WHERE f.departure_airport IN (
    SELECT dad.airport_code FROM airports_data AS dad
    WHERE jsonb_extract_path_text(dad.city, 'ru') = 'Екатеринбург'
)
AND f.arrival_airport IN (
    SELECT aad.airport_code FROM airports_data AS aad
    WHERE jsonb_extract_path_text(aad.city, 'ru') = 'Москва'
)
AND f.status IN ('Scheduled','On Time','Delayed')
ORDER BY f.scheduled_departure
LIMIT 1;


--Вывести самый дешевый и дорогой билет и стоимость ( в одном результирующем ответе)
SELECT tf.ticket_no, tf.amount FROM  ticket_flights AS tf
WHERE tf.amount = (SELECT MAX(amount) FROM ticket_flights)
   OR tf.amount = (SELECT MIN(amount) FROM ticket_flights);

-- Написать DDL таблицы Customers , должны быть поля id , firstName, LastName, email , phone. Добавить ограничения на поля ( constraints) .
CREATE TABLE customers (
id BIGSERIAL PRIMARY KEY NOT NULL,
first_name VARCHAR(255) NOT NULL,
last_name VARCHAR(255) NOT NULL,
email VARCHAR(255) NOT NULL,
phone VARCHAR(15) DEFAULT 'Empty phone'
);


-- Написать DDL таблицы Orders , должен быть id, customerId,	quantity. Должен быть внешний ключ на таблицу customers + ограничения
CREATE TABLE orders (
id BIGSERIAL PRIMARY KEY NOT NULL,
quantity INT4 NOT NULL,
customer_id INT8 NOT NULL,
FOREIGN KEY (customer_id) REFERENCES customers(id),
CHECK (quantity >= 0)
);


-- Написать 5 insert в эти таблицы
INSERT INTO customers (id, first_name, last_name, email,phone)
VALUES (1,'Dima','Konopelko','konopelko-2023@mail.com','+375291199564');

INSERT INTO customers (id, first_name, last_name, email,phone)
VALUES (2,'Denis','Pastushkov','pasta-3063@mail.com','+375291567893');

INSERT INTO customers (id, first_name, last_name, email,phone)
VALUES (3,'Oleg','Burtsev','burtsev-2063@mail.ru','+375296781230');

INSERT INTO customers (id, first_name, last_name, email,phone)
VALUES (4,'Anton','Kolesnikov','kolesnikov-4444@mail.com','+375445089743');

INSERT INTO customers (id, first_name, last_name, email,phone)
VALUES (5,'Vlad','Brel','brel-1999@mail.ru','+375294569814');


INSERT INTO orders (id,quantity,customer_id)
VALUES (1, 5, 1);

INSERT INTO orders (id,quantity,customer_id)
VALUES (2, 6, 2);

INSERT INTO orders (id,quantity,customer_id)
VALUES (3, 2, 3);

INSERT INTO orders (id,quantity,customer_id)
VALUES (4, 8, 4);

INSERT INTO orders (id,quantity,customer_id)
VALUES (5, 3, 5);


-- удалить таблицы
DROP TABLE orders;
DROP TABLE customers;


-- Написать свой кастомный запрос ( rus + sql).
-- Найти контакты людей, которые летали из Екатеринбурга бизнес-классом на самолёте 17136б на месте 20С
SELECT t.passenger_name, t.contact_data, f.flight_id, s.seat_no FROM tickets t
JOIN ticket_flights tf on t.ticket_no = tf.ticket_no
JOIN flights f on f.flight_id = tf.flight_id
JOIN airports_data ad on ad.airport_code = f.arrival_airport
JOIN seats s on f.aircraft_code = s.aircraft_code
WHERE tf.fare_conditions = 'Business'
  AND jsonb_extract_path_text(ad.city, 'ru') = 'Екатеринбург'
  AND f.flight_id = 17136
  AND s.seat_no = '20C';