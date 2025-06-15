-- (4) Stwórz widok departments_summary (1) zawierający pola: de-
-- partment_id, department_name (1), manager (w formie Imię Na-
-- zwisko (1), address (w formie ulica, kod pocztowy miasto, nazwa kraju)
-- z odpowiednich tabel (1).

CREATE OR REPLACE VIEW departments_summary AS
SELECT d.department_id, d.department_name, CONCAT(e.first_name, ' ', e.last_name) AS Manager, l.street_address, l.postal_code, c.country_name FROM departments d
LEFT JOIN employees e ON d.manager_id = e.employee_id
JOIN locations l ON l.location_id = d.location_id 
JOIN countries c ON l.country_id = c.country_id;

SELECT * FROM departments_summary;

-- (3) Stwórz sekwencję zawierającą liczby naturalne podzielne przez 5, ale
-- niepodzielne przez 10 (1). Dodaj opcję umożliwiającą szybki dostęp do 5
-- kolejnych wartości sekwencji (1). Dodaj nowy dział, korzystając z utwo-
-- rzonej sekwencji przy wpisywaniu id (1).

CREATE SEQUENCE div_by5_not10 
START WITH 5 INCREMENT BY 10
CACHE 5
NOCYCLE
NOMAXVALUE;

INSERT INTO departments(department_id, department_name)
VALUES (DIV_BY5_NOT10.nextval, 'Jakies gowno');

SELECT * FROM departments;

-- (2) Wyświetl maksymalne i minimalne zarobki na wszystkich stanowiskach
-- u każdego z managerów (1). Uwzględnij również podumowanie dla każdego
-- stanowiska bez względu na managera, oraz dla managera bez względu na
-- stanowisku (1).

SELECT j.job_title, CONCAT(e1.first_name, ' ', e1.last_name) AS Manager, MAX(e.salary), MIN(e.salary) FROM employees e
JOIN jobs j ON j.job_id = e.job_id 
JOIN employees e1 ON e.manager_id = e1.employee_id 
GROUP BY CUBE(j.job_title, Manager);

-- (4) (PL\SQL)Napisz procedurę (1) wyświetlającą imię i nazwisko każdego
-- pracownika (1) wraz z informacją, czy jest managerem (1). Wykorzystaj
-- kursor do iterowania po pracownikach (1).

CREATE OR REPLACE PROCEDURE fn_ln_isMan IS
    var_employee_id employees.employee_id%type;
    var_first_name employees.first_name%type;
    var_last_name employees.last_name%type;
    is_manager varchar(3);
    var_is_manager NUMBER;

    CURSOR c_empl IS
        SELECT employee_id, first_name, last_name FROM employees;

BEGIN
    OPEN c_empl;
    LOOP
        FETCH c_empl INTO var_employee_id, var_first_name, var_last_name;
        EXIT WHEN c_empl%NOTFOUND;

        SELECT COUNT(*) INTO var_is_manager FROM employees 
        WHERE var_employee_id IN (SELECT DISTINCT manager_id FROM employees);

        IF var_is_manager > 0 THEN is_manager := 'TAK';
        ELSE is_manager := 'NIE';
        END IF;
        DBMS_OUTPUT.PUT_LINE(var_first_name || ' ' || var_last_name || ' ' || is_manager);
    END LOOP;
    CLOSE c_empl;
END;

SET SERVEROUTPUT ON;
BEGIN
    fn_ln_isMan;
END;

-- (3) (PL\SQL) Stwórz wyzwalacz, który będzie zwiększał o 1000 (1) zarobki
-- co drugiego (1) nowo dodanego pracownika (1).

CREATE OR REPLACE TRIGGER bigger_by_1000
BEFORE INSERT ON employees 
FOR EACH ROW               
BEGIN
    IF MOD(:NEW.employee_id, 2) = 0 THEN
        :NEW.salary := :NEW.salary + 1000;
    END IF;
END bigger_by_1000;



