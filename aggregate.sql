drop table if exists t;
drop type if exists int_pair;

create type int_pair as (
        a int,
        b int
);


create table t (
        x int_pair
);

insert into t values ('(5, 4)'), 
                     ('(3, 2)'),
                     ('(8, 0)'),
                     ('(6, 9)'),
                     ('(7, 3)'),
                     ('(10, 5)');

select * from t;
select * from t where x = '(3, 2)' :: int_pair;
select * from t where (x).a + (x).b >= 9;
select (x).a as a, (x).b as b from t where (x).a + (x).b >= 9;

drop table if exists t1;

create table t1 (
      a int,
      b int
);

insert into t1 values (5, 4), 
                      (3, 2),
                      (8, 0),
                      (6, 4);

select * from t1;

select * from t1 where a = 3 and b = 2;



/*---------------------------------------------------------------------*/
drop function if exists nonsense(integer);
create function nonsense(x integer) returns text AS $$
BEGIN
     IF x < 5 THEN RETURN 'ONE';
     ELSE RETURN 'TWO';
     END IF;
END;
$$ language plpgsql;
select nonsense(3);

--select w, nonsense(w) from table_name;

--select 2, nonsense(2) from t; 

drop function if exists nonsense(integer,integer);
create function nonsense( x integer, y integer)
       returns boolean as $$
BEGIN
       if x = y then return null;
       elsif x < y then return true;
       else return false;
       end if;
END;
$$ language plpgsql;

select (nonsense(5,5), nonsense(5,4), nonsense(4,5));


/*---------------------------------------------------------------------*/
drop aggregate if exists sample_sum(integer);
drop function if exists sample_sum_final(sample_sum_state);
drop function if exists sample_sum_step(sample_sum_state, nxt integer);
drop type if exists sample_sum_state;
create type sample_sum_state as(
        count integer,
        sum integer
);
create function sample_sum_step(curr sample_sum_state, nxt integer)
       returns sample_sum_state as $$
begin
       if curr.count = 0 then return (1, nxt);
       elsif curr.count % 3 = 0 then return (curr.count +1, curr.sum + nxt);
       else return (curr.count + 1, curr.sum);
       end if;
end;
$$ language plpgsql;

create function sample_sum_final(x sample_sum_state)
          returns INT as $$
BEGIN
          return x.sum;
END

$$ language plpgsql;

create aggregate sample_sum(INTEGER) (
        stype = sample_sum_state,
        sfunc = sample_sum_step,
        finalfunc = sample_sum_final,
        initcond = '(0,0)'
);


select sample_sum((x).a) from t;
select sample_sum((x).b) from t; 

--select sample_sum((x).a) from t order by rendom; ?

drop aggregate if exists all_even(integer);
drop function if exists all_even_step(boolean, integer);
create function all_even_step(curr boolean, nxt integer)
       returns boolean as $$
BEGIN
               --raise notice 'nxt =(%)', nxt;
               if nxt % 2 = 1 then return false;
               else return curr;
               end if;
END;
$$ language plpgsql;

create aggregate all_even(integer)(
       initcond = true,
       sfunc = all_even_step,
       stype = boolean
);

drop table if exists tt;
create table tt(a integer);
insert into tt values (4),(2),(8),(5),(2);
select all_even(a) from tt where a !=5;  




  