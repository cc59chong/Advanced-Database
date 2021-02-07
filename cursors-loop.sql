drop table if exists exams;
create table exams(class_id int, whenithappens time, cheatsheet boolean);
insert into exams values
        (336, '1:00am', false),
        (305, '6:00am', true),
        (311, '12:00pm', false),
        (318, '3:00pm', true);

select * from exams;

create or replace function feasible_tf() returns trigger as $$
declare
     examsCur cursor for select * from exams;
begin
     for erow in examsCur loop
             if NEW.whenithappens > erow.whenithappens
                  + interval '-2.5 hours' AND 
                  NEW.whenithappens < erow.whenithappens + '2.5 hours' then
                  raise notice 'second if %', erow;
                  return NULL;
            end if;
     end loop;
     return NEW;
end
$$ language plpgsql;

create trigger feasible_t before insert on exams for each row
       execute procedure feasible_tf();

insert into exams values
       (398, '9:00am', false),--should be inserted.
       (399, '12:02pm', false);
    

/*       
create or replace function something() returns integer as $$
declare
     examsCur cursor for select * from exams;
     erow exams%rowtype;
begin
    open examsCur;
    fetch examsCur into erow;
    while found loop 
          raise notice 'row is %', erow;
          fetch examsCur into erow;
    end loop;
    return 5;
    close examsCur;
end;
$$language plpgsql;

select something();
*/
/*
create or replace function something2() returns integer as $$
declare
     examsCur cursor for select * from exams;
     erow exams%rowtype;
begin
    open examsCur;
    fetch examsCur into erow;
    while found loop 
          raise notice 'row is %', erow;
          fetch examsCur into erow;
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;

select something2();
*/

/*
create or replace function something() returns integer as $$
declare
     examsCur cursor for select * from exams;
     erow exams%rowtype;
begin
    --open examsCur;
    for erow in examsCur loop
           raise notice 'row is %', erow;
    
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;
select something();
*/

/*
create or replace function something() returns integer as $$
declare
     examsCur cursor for select * from exams;
begin
    --open examsCur;
    for erow in examsCur loop
          if erow.cheatsheet then
             raise notice 'row is %', erow;
          end if;
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;
select something();
*/

/*
create or replace function something() returns integer as $$
declare
     examsCur cursor for select * from exams;
begin
    --open examsCur;
    for erow in examsCur loop
          if erow.cheatsheet then
             update exams set cheatsheet = false where
                    current of examsCur;
          end if;
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;
select something();
select * from exams;
*/

/*
create or replace function something() returns integer as $$
declare
     examsCur cursor for select * from exams;
begin
    --open examsCur;
    for erow in examsCur loop
          if erow.cheatsheet then
             update exams set cheatsheet = false where
                    current of examsCur;
          end if;
          if erow.whenithappens <= '8:00am' then
             delete from exams where current of examsCur;
          end if;
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;
select something();
select * from exams;
*/

/* bound- cursors*******************************************************************/
/*create or replace function something(id integer) returns integer as $$
declare
     examsCur cursor(x int) for select * from exams where class_id = x;
begin
    --open examsCur;
    for erow in examsCur(id) loop
          if erow.cheatsheet then
             update exams set cheatsheet = false where
                    current of examsCur;
          end if;
          if erow.whenithappens <= '8:00am' then
             delete from exams where current of examsCur;
          end if;
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;
select something(318);
*/

/*
create or replace function something() returns integer as $$
declare
     examsCur cursor for select * from exams;
     erow exams%rowtype;
begin
    --open examsCur;
    for erow in (select * from exams) loop
           raise notice 'row is %', erow;
    
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;
*/

/*
create or replace function something() returns integer as $$
declare
     examsCur cursor for select * from exams;
     erow exams%rowtype;
begin
    --open examsCur;
    for erow in (select * from exams as a, exams) loop
           raise notice 'row is %', erow;
    
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;
select something();
*/

/*
create or replace function something4() returns integer as $$
declare
     examsCur2 cursor for (select * from exams as a, exams);
     --erow exams%rowtype;
begin
    --open examsCur;
    for erow in examsCur2 loop
           raise notice 'row is %', erow;
    
    end loop;
    return 5;
    close examsCur2;
end;
$$language plpgsql;
select something4();
*/

create or replace function something4() returns integer as $$
declare
     examsCur2 cursor for (select * from exams as a, exams);
     --erow exams%rowtype;
     x boolean;
begin
    --open examsCur;
    x := true;
    for erow in examsCur2 loop
            if x then 
                    alter table exams add column useless int;
                    x := false;    
    end loop;
    return 5;
    --close examsCur2;
end;
$$language plpgsql;