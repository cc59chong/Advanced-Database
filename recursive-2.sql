drop table if exists garbage;
create table garbage(
  data int[]
);

insert into garbage values ('{5,3,2}');
insert into garbage values (array[2,5]);

select * from garbage where data @> array[5];

update garbage set data = data||4
    where data = '{5,3,2}';

with recursive paths(node, path, distance) as (
   values (1, array[1], 0)
   union
   select outerm, path || outerm, distance + 1 from paths, graph
     where node = interm and not (path @>array[outerm,node])
)

select * from paths;