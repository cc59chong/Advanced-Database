/*1 ******************************/
with recursive fibnacci(a,b,n) as (
   values(0,1,0)
   union
   select b, a + b, n + 1 from fibnacci where n < 20
)
select a from fibnacci;
/*2 ******************************/
drop table if exists tree;
create table tree(
     parent integer,
     child  integer
);

insert into tree values
            	(1, 2),
            	(2, 3),
            	(3, 4),
            	(1, 5),
            	(5, 6),
            	(6, 7),
            	(7, 8),
            	(1, 9),
            	(9, 10),
            	(10, 11);

select * from tree;
     
with recursive heights(node,height) as (
   select t1.child, 0
   from tree t1 
   left outer join tree t2
   on t2.parent = t1.child
   where t2.child is NULL
   
   union
   
   select parent, height + 1 from
   heights, tree where child = node
)

select max(height) from heights;



