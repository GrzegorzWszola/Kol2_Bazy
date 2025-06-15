-- (4) Stwórz widok zawierający wszystkie znajdujące się w firmie stanowiska
-- (id oraz nazwy) (1), wraz z rzeczywistymi minimalnymi oraz maksymalnymi zarobkami (1). Uwzględnij stanowiska, które nie mają zatrudnionych
-- pracowników (1). Posortuj wyniki rosnąco po liczbie zatrudnionych na
-- stanowiskach pracownikach (1).

CREATE OR REPLACE VIEW max_min_sal AS
SELECT 
  j.job_id,
  j.job_title,
  MIN(e.salary) AS min_salary,
  MAX(e.salary) AS max_salary,
  COUNT(e.employee_id) AS liczba_pracownikow
FROM 
  employees e
RIGHT JOIN jobs j ON e.job_id = j.job_id
GROUP BY 
  j.job_id,
  j.job_title
ORDER BY liczba_pracownikow;

SELECT * FROM MAX_MIN_SAL;

-- (2) Stwórz indeks zawierający imię, nazwisko oraz id działu każdego pracownika (1). Napisz zapytanie, które skorzysta ze stworzonego indeksu
-- (1).

CREATE INDEX name_sname_depid ON employees(first_name, last_name, department_id);

SELECT * FROM employees
WHERE first_name = 'John';

-- (3) (jedna kwerenda) Dla każdego kraju i działu wypisz liczbę zatrudnionych pracowników, a także sumaryczną liczbę pracowników zatrudnionych
-- w danym kraju (wymagane pola: country_name, department_name,
-- liczba_pracowników) (2). Nie uwzględniaj krajów bez działów, ale
-- uwzględnij działy bez pracowników (1). Można użyć location_id zamiast nazwy kraju za -1 pkt.,

SELECT c.country_name, d.department_name, COUNT(e.employee_id) FROM EMPLOYEES e
RIGHT JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID
JOIN locations l ON d.LOCATION_ID = l.LOCATION_ID
JOIN COUNTRIES c ON l.COUNTRY_ID = c.COUNTRY_ID
GROUP BY ROLLUP(c.country_name, d.DEPARTMENT_NAME)


-- (2) (PL\SQL) Napisz funkcję (1) wyliczającą różnicę między średnią dwóch
-- pierwszych liczb, a trzecią liczbą (1).

CREATE OR REPLACE FUNCTION difference(a NUMBER, b NUMBER, c NUMBER)
RETURN NUMBER IS wynik NUMBER;
BEGIN
    wynik := (a+b)/2 - c;

    return wynik;
END;


-- ## Zadanie 5

-- (3) (PL\SQL) Wykorzystaj funkcję z poprzedniego zadania (jeśli nie udało
-- się go zrobić, to wywołaj funkcję avg), żeby dla każdego pracownika wyświetlić jego imię, nazwisko, oraz różnicę między jego zarobkami, a średnią
-- zakładanych maksymalnych i minimalnych zarobków dla jego stanowiska
-- (z tabeli jobs)(2). Wykorzystaj do tego kursor (1).

set serveroutput on;

DECLARE
    max_sal employees.salary%type;
    min_sal employees.salary%type;
    f_name  employees.first_name%type;
    l_name  employees.last_name%type;
    emp_sal employees.salary%type;

    CURSOR c_empl IS
        SELECT e.first_name, e.last_name, e.salary, j.max_salary, j.min_salary FROM employees e
        JOIN jobs j ON e.job_id = j.job_id;

BEGIN
    OPEN c_empl;
    LOOP
        FETCH c_empl INTO f_name, l_name, emp_sal, max_sal, min_sal;
            EXIT WHEN c_empl%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(f_name || ' ' || l_name || ', roznica od sredniej: ' || abs(difference(min_sal, max_sal, emp_sal)));
    END LOOP;
    CLOSE c_empl;
END;


-- (2) (PL\SQL) Napisz wyzwalacz (1) który będzie zmieniał imię każdego
-- nowego pracownika na Paweł (1).

CREATE OR REPLACE TRIGGER name_pawel
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    :new.first_name := 'Paweł';
END;

insert into employees
    (employee_id, first_name, last_name, email, hire_date, job_id)
values ((SELECT MAX(employee_id) FROM employees) + 1, 'Jan', 'Kowalski', 'JKOWALSKI', SYSDATE, 'FI_ACCOUNT');






