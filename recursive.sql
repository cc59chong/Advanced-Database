with recursive t(n) as ( values(1)
     union all
     select n + 1 from t where n < 10)
select sum(n) from t;


create table graph( 
   interm int,
   outerm int
);

insert into graph values
    (1,2),
    (2,3),
    (3,1),
    (4,5);

with recursive reachable(n) as (
     values(1)
     union
     select outerm from reachable, graph
           where graph.interm = n
)

select n from reachable;