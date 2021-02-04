drop table if exists customers;
drop table if exists salespersons;

create table salespersons
(
     id integer primary key,
     firstname text
);

create table customers(
     firstname text primary key,
     id integer references salespersons(id)
);

insert into salespersons values
        (1, 'Sam'),
        (2, 'Sally'),
        (3, 'Stephen');

drop function if exists insertnotice();
create function insertnotice() returns trigger as $$
begin
        raise notice '% just inserted!', NEW.firstname;
        return NEW; -- Always return new!
end
$$ language plpgsql;

drop function if exists assignSalesFunc();
create function assignSalesFunc() returns trigger as $$ 
begin
       NEW.id := (select salespersons.id from customers right outer join salespersons
        on salespersons.id = customers.id group by 
        salespersons.id having count(customers.firstname) = 
        (select min(count) from
                (select count(customers.firstname) from 
                 salespersons left outer join customers
                 on salespersons.id = customers.id group by
                 salespersons.id) as t) limit 1);
        return NEW;   
end;
$$ language plpgsql;
create trigger assignSales before insert on customers for each row
       execute procedure assignSalesFunc(); 

-- trigger as constraint.
-- salesperson Sauruman is bad, we don't want to add him to the table.

drop function if exists badsalesman();
create function badsalesman() returns trigger as $$
begin
        if NEW.firstname = 'Sauruman' then
               raise exception 'Sauruman must not be added.';
               return null;
        end if;
        return null;
end;
$$ language plpgsql;

create trigger bs after insert on salespersons for each row 
        execute procedure badsalesman();


insert into customers values
        ('Chris', null),
        ('Chrelsea', null),
        ('Christian', null),
        ('Chloe', null),
        ('Clifford', null),
        ('Clark', null);

 select * from customers;

drop function if exists redistributeSalespeopleFunc();
create function redistributeSalespeopleFunc() returns trigger as $$
declare
spcur scroll cursor(sid integer) for select * from
        salespersons where id != sid;
customersOf cursor(sid integer) for select  * from customers where id = sid;
salesperson record;
customer record;
begin
       open spcur(OLD.id);
       for customer in customersOf(OLD.id) loop
             fetch spcur into salesperson;
             if not found then
                     fetch first from spcur into salesperson;
             end if;
             update customers set id = salesperson.id where
                    current of customersOf;
                    
       end loop;
       close spcur;
       return OLD;
end;
$$ language plpgsql;

create trigger redistributesalespeople before delete on salespersons
       for each row
       execute procedure redistributeSalespeopleFunc();

delete from salespersons where id =1;
delete from salespersons where id =2;

--insert into salespersons values (4, 'Sauruman');

--select * from salespersons;
 