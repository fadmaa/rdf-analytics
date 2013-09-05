g = LOAD '../../data/RDF/SA/graph.txt' USING PigStorage() AS (s:chararray,p:chararray,o:chararray) ; 
v_weights = LOAD './RDF-data/SA/weights.txt' USING PigStorage() AS (v:chararray, w:double); 
p_weights = LOAD './RDF-data/SA/p_weights.txt' USING PigStorage() AS (p:chararray, w:double);

w_g0 = JOIN g by s LEFT, v_weights BY v; 
w_g1 = JOIN w_g0 by p, p_weights BY p;
w_g2 = FOREACH w_g1 GENERATE w_g0::g::s AS S, w_g0::g::p AS P, w_g0::g::o AS O, (w_g0::v_weights::w * p_weights::w )AS W; 
w_g3 = JOIN w_g2 by O LEFT, v_weights BY v;      
w_g4 = FOREACH w_g3 GENERATE w_g2::S AS S, w_g2::P AS P, w_g2::O AS O, w_g2::W AS W, (v_weights::w is null?0.0:v_weights::w) AS W0;
tmp0 = GROUP w_g4 BY O;                                                                                                          
tmp1 = FOREACH tmp0 GENERATE group AS v, (SUM(w_g4.W) + AVG(w_g4.W0)) AS weight;
tmp2 = JOIN tmp1 BY v FULL, v_weights BY v ; 
v_weights = FOREACH tmp2 GENERATE (tmp1::v is null? v_weights::v : tmp1::v) AS v, (tmp1::weight is null? v_weights::w : tmp1::weight) AS w; 

w_g0 = JOIN g by s LEFT, v_weights BY v; 
w_g1 = JOIN w_g0 by p, p_weights BY p;
w_g2 = FOREACH w_g1 GENERATE w_g0::g::s AS S, w_g0::g::p AS P, w_g0::g::o AS O, (w_g0::v_weights::w * p_weights::w )AS W; 
w_g3 = JOIN w_g2 by O LEFT, v_weights BY v;      
w_g4 = FOREACH w_g3 GENERATE w_g2::S AS S, w_g2::P AS P, w_g2::O AS O, w_g2::W AS W, (v_weights::w is null?0.0:v_weights::w) AS W0;
tmp0 = GROUP w_g4 BY O;                                                                                                          
tmp1 = FOREACH tmp0 GENERATE group AS v, (SUM(w_g4.W) + AVG(w_g4.W0)) AS weight;
tmp2 = JOIN tmp1 BY v FULL, v_weights BY v ; 
v_weights = FOREACH tmp2 GENERATE (tmp1::v is null? v_weights::v : tmp1::v) AS v, (tmp1::weight is null? v_weights::w : tmp1::weight) AS w; 

DUMP v_weights;