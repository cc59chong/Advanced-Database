bdrop table if exists t;
drop type if exists int_pair;

create type int_pair as (
        a int,
        b int
);

drop table if exists t;
create table t (
        x int_pair
);

insert into t values ('(5, 4)'), 
                     ('(3, 2)'),
                     ('(8, 0)'),
                     ('(6, 4)');

select * from t;
select * from t where x = '(3, 2)' :: int_pair;

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



drop function if exists sample_sum_step(curr sample_sum_state, nxt integer);
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

        