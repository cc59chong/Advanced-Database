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
        return null;
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
        return NEW;
end;
$$ language plpgsql;

create trigger bs after insert on salespersons for each row 
        execute procedure badsalesman();

create trigger tigger after insert on customers for each row
       execute procedure insertnotice(); 

insert into customers values
        ('Chris', null),
        ('Chrelsea', null),
        ('Christian', null),
        ('Chloe', null),
        ('Clifford', null),
        ('Clark', null);



 select * from customers;

 insert into salespersons values (4, 'Sauruman');
 insert into salespersons values (5, 'Samu');

 select * from salespersons; 

 /*select salespersons.id from customers right outer join salespersons
        on salespersons.id = customers.id group by 
        salespersons.id having count(customers.firstname) = 
        (select min(count) from
                (select count(customers.firstname) from 
                 salespersons left outer join customers
                 on salespersons.id = customers.id group by
                 salespersons.id) as t); */