/*eg.1 */
with recursive strings(s) as (
    values('')
    union all
    select s||'a' from strings where length(s) < 3
)
select * from strings;

/*eg.2 */
with recursive palindormes(s) as (
   values(''),('a'),('b')
   union all
   select column1||s||column1 from palindormes, (values('a'),('b')) as q
   where length(s) <2
)
select * from palindormes;


select * from (values('a'),('b')) as q;

drop table if exists q;
create table q(
    column1 text
);

insert into q values
    ('a'),
    ('b');

select * from q;

with recursive palindormes(s) as (
   values(''),('a'),('b')
   union all
   select column1||s||column1 from palindormes, q
   where length(s) <2
)
select * from palindormes;

/*eg.3 */
with recursive distances(node, distance) as (
   values(1,0)
   union
   select outerm, distance + 1 from distances, graph
   where interm = node and distance < 5
)

select node, min(distance) from distances group by node;