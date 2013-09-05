dta = LOAD '../../data/RDF/bsbm/dataset-100.nt' USING PigStorage(' '); 
SPLIT dta INTO labels IF $1 == '<http://www.w3.org/2000/01/rdf-schema#label>', prods IF $1 == '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>' AND $2 == '<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/Product>', features IF $1 == '<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/productFeature>' ;
features1 = FILTER features BY $2 == '<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/ProductFeature74>' ;
features2 = FILTER features BY $2 == '<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/ProductFeature45>' ;
results = JOIN prods BY $0, labels by $0, features1 BY $0, features2 BY $0; 
results = FOREACH results GENERATE $0, $6; 
DUMP results;