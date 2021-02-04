drop table if exists tt;
create table tt(
       a int primary key,
       b text

);

/*
create or replace function nodups() returns trigger as $$
begin
      if (select a from tt where New.a =a) is null
            then return NEW;
      else return null;
      end if;
end;
$$ language plpgsql;
*/

/*
create or replace function nodups() returns trigger as $$
begin
      if (select a from tt where New.a =a) is null
            then raise notice 'inserting%.', NEW;
            return NEW;
      else raise notice 'not inserting%.', NEW;
            return null;
      end if;
end;
$$ language plpgsql;
*/

create or replace function nodups() returns trigger as $$
begin
      if (select a from tt where New.a =a) is null
            then raise notice 'inserting%.', NEW;
            return NEW;
      else  
            NEW.a := NEW.a + 1;
            insert into tt values (NEW.a, NEW.b);
            raise notice 'trying to insert %.', NEW;
            return null;
      end if;
end;
$$ language plpgsql;

create trigger nodupstrig before insert on tt for each row 
       execute procedure nodups();


create or replace function nodel() returns trigger as $$
begin
         return null;
end;
$$ language plpgsql;

create trigger nodeletes before delete on tt for each row 
       execute procedure nodel();
       
 
/*
create trigger nodeletes after delete on tt for each row 
       execute procedure nodel();u
 */

create or replace function upchz() returns trigger as $$
begin
      if OLD.b = 'apples' AND NEW.b = 'oranges' then
            NEW.b := 'cheese';
            return NEW;
      else
            return null;
      end if;
end;
$$ language plpgsql; 

create or replace function sumToN(n int) returns int as $$
declare   
        x int;
        ans int;
begin
        x := 1;
        ans := 0;
        loop
                ans := ans + x;
                x := x + 1;
               -- exit when x = n + 1;
                exit when x = n;
                x := x + 1;
        end loop;
        return ans;
end;
$$ language plpgsql; 


create trigger upchztrig before delete on tt for each row 
       execute procedure upchz();

insert into tt values (1, 'cheese');
insert into tt values (1, 'chalk');
insert into tt values (1, 'apples');
insert into tt values (3, 'apples');

delete from tt where a=3;

update tt set b = 'oranges' where b= 'apples';
--update tt set b = 'apples' where b= 'cheese';

select * from tt;
select sumToN(5);
