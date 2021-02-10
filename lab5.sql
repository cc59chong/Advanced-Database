drop table if exists ccc;
create table ccc(aa int, b int, c boolean);
insert into ccc values
        (336, 10, false),
        (305, 20, true),
        (311, 40, false),
        (318, 55, true);

select * from ccc;

create or replace function zzz() returns integer as $$
declare
     cccCur cursor for select * from ccc;
begin
    --open cccCur;
    for erow in cccCur loop
          if erow.c then
             raise notice 'row is %', erow;
          end if;
    end loop;
    return 5;
    --lose cccCur;
end;
$$language plpgsql;
select zzz();

create or replace function zzz3() returns integer as $$
declare
     cccCur cursor for select * from ccc;
     erow ccc%rowtype;
begin
    open cccCur;
    fetch cccCur into erow;
    while found loop 
          raise notice 'row is %', erow;
          fetch cccCur into erow;
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;

select zzz3();

create or replace function zzz1() returns integer as $$
declare
     cccCur cursor for select * from ccc;
begin
    --open examsCur;
    for erow in cccCur loop
          if erow.c then
             update ccc set c = false where
                    current of cccCur;
          end if;
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;
select zzz1();

create or replace function zzz2() returns integer as $$
declare
     cccCur cursor for select * from ccc;
begin
    --open examsCur;
    for erow in cccCur loop
          if erow.b <= 20 then
             delete from ccc where current of cccCur;
          end if;
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;
select zzz2();


/* bound- cursors*******************************************************************/
create or replace function zzz0(a integer) returns integer as $$
declare
     cccCur cursor(x int) for select * from ccc where aa = x;
begin
    --open examsCur;
    for erow in cccCur(a) loop
          if erow.b <= 40 then
             delete from ccc where current of cccCur;
          end if;
    end loop;
    return 5;
    --close examsCur;
end;
$$language plpgsql;
select zzz0(305);

select * from ccc;

/*cartesian ...............................................*/
create or replace function zzz4() returns integer as $$
declare
     cccCur2 cursor for (select * from ccc as n, ccc);
     --erow exams%rowtype;
begin
    --open examsCur;
    for erow in cccCur2 loop
           raise notice 'row is %', erow;
    
    end loop;
    return 5;
    close cccCur2;
end;
$$language plpgsql;

select zzz4();

select * from ccc;