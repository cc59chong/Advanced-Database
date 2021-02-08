
drop table if exists employees;

create table employees
(
      emp_no int primary key,
      firstname text,
      salary int

);

insert into employees values
       (45, 'Jack', 40000),
       (34, 'Sam', 35000),
       (12, 'Pat', 45000);

/*2*********************************************************/
create or replace function nullsalary() returns trigger as $$
begin
     if NEW.salary is null then
        NEW.salary := (select min(salary) from employees) + 5000;
     return NEW;
     end if;
end;
$$ language plpgsql;

create trigger nullsal before insert on employees for each row
       execute procedure nullsalary();

insert into employees values (20, 'Tracy', null);

/*1*********************************************************/
create or replace function lowsalary() returns trigger as $$
begin
     if NEW.salary < (select min(salary) from employees) then
        raise exception 'low salary must not be added.';
        return null;
     end if;
     return NEW;
end;
$$ language plpgsql;

create trigger lows before insert on employees for each row
       execute procedure lowsalary();

insert into employees values (11, 'Amy', 60000);
insert into employees values (87, 'Sally', 20000);


/*3*********************************************************/
create or replace function autups() returns trigger as $$
begin
     if (select emp_no from employees where New.emp_no = emp_no) is null
            then raise notice 'inserting%.', NEW;
            return NEW;
      else  
            NEW.emp_no := NEW.emp_no + 1;
            insert into employees values (NEW.emp_no, NEW.firstname, NEW.salary);
            raise notice 'trying to insert %.', NEW;
            return null;
      end if;
end;
$$ language plpgsql;


create trigger autadd before insert on employees for each row
       execute procedure autups(); 

insert into employees values (12, 'Eva', 55000);
insert into employees values (45, 'Cici', 56000);
select * from employees;

/*4********************************************************
The trigger created in question 3 is not always work because the regular computer is hard to execute 
1 million rows, 1 billion rows at once. It is possible to set up a cursor that encapsulates the query,
and then read the query result a few rows at a time. One reason for doing this is to avoid memory overrun
when the result contains a large number of rows. (However, PL/pgSQL users do not normally need to 
worry about that, since FOR loops automatically use a cursor internally to avoid memory problems.) 
*/

