/* 
 1.a.  Write an aggregate that counts the number of even integers in a table.
   b.  Test your aggregate */


drop aggregate if exists count_even(integer);
drop function if exists even_step(count integer, nxt integer);

create function even_step(count integer, nxt integer)
       returns INT as $$
BEGIN	
       if nxt % 2 = 0 then return (count + 1);
       end if;
       return (count);
END;
$$ language plpgsql;



create aggregate count_even(integer)(
       stype = integer,
       sfunc = even_step,
       initcond = 0
);

drop table if exists cc;
create table cc(a integer);
insert into cc values (1), (8), (2), (6), (7), (3);
select count_even(a) from cc;

-- The results should be 3. 



/* 2. Write an aggregate that finds the third largest integer in a column. */
drop aggregate if exists third_largest(integer);
drop function if exists final_res(x biggest_3_nums_state);
drop function if exists biggest_3_nums_step(biggest_3_nums_state, integer);
drop type if exists biggest_3_nums_state;
create type biggest_3_nums_state as(
       fir_biggest int,
       sed_biggest int,
       thir_biggest int
);

create function biggest_3_nums_step(curr biggest_3_nums_state, nxt integer)
       returns biggest_3_nums_state as $$
BEGIN	
       if curr.fir_biggest = NULL then return (nxt, NULL, NULL);
       elsif nxt > curr.fir_biggest then return (nxt, curr.fir_biggest, curr.sed_biggest);
       elsif nxt > curr.sed_biggest then return (curr.fir_biggest, nxt, curr.sed_biggest);
       elsif nxt > curr.thir_biggest then return (curr.fir_biggest,curr.sed_biggest, nxt);
       else return (curr.fir_biggest,curr.sed_biggest, curr.thir_biggest);
       end if;  
       
END;
$$ language plpgsql;

create function final_res(x biggest_3_nums_state)
       returns INT as $$
BEGIN	
       return x.thir_biggest;
       
END;
$$ language plpgsql;

create aggregate third_largest(integer)(
       stype = biggest_3_nums_state,
       sfunc = biggest_3_nums_step,
       finalfunc = final_res,
       initcond = '(0,0,0)'
);

drop table if exists cc;
create table cc(a integer);
insert into cc values (1), (8), (2), (6), (7), (3);
select third_largest(a) from cc;

-- The results should be 6. 