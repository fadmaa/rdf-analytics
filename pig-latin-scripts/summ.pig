REGISTER pig_bag_concat.jar 

rdf_data = LOAD './RDF-data/houses-by-occupancy-status.nt' USING PigStorage(' ') AS (S:chararray,P:chararray,O:chararray);
types = FILTER rdf_data BY $1=='<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>' ;

s_types = GROUP types BY S ; 
clusters = FOREACH s_types GENERATE group, org.deri.pig.rdf.ConcatBag(types) AS types ;
t_clusters = GROUP clusters BY types;
cnts = FOREACH t_clusters GENERATE group, COUNT(clusters) ;  
STORE cnts INTO 'classes.tsv' ;

-- calculate properties now
tmp0 = JOIN rdf_data BY S, clusters BY group ;  
s_types = FOREACH tmp0 GENERATE clusters::types AS sub_types, rdf_data::P AS P, rdf_data::O AS O;
tmp2 = JOIN s_types BY O LEFT, clusters BY group;
s_o_types = FOREACH tmp2 GENERATE s_types::sub_types AS sub_types, s_types::P AS P, clusters::types AS obj_types;
tmp4 = GROUP s_o_types BY *;
tmp5 = FOREACH tmp4 GENERATE group , COUNT(s_o_types);   
        

STORE tmp5 INTO 'properties.tsv';