/*
PREFIX bsbm-inst: <http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/>
PREFIX bsbm: <http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT DISTINCT ?product ?label
WHERE { 
 ?product rdfs:label ?label .
 ?product a <http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/Product> .

 ?product bsbm:productFeature <http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/ProductFeature74> . 
 ?product bsbm:productFeature <http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/ProductFeature45> . 


	}
ORDER BY ?label

*/
A = LOAD '../../data/RDF/bsbm/dataset-100.nt' USING PigStorage(' '); 
types = FILTER A BY $1=='<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>' AND $2 == '<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/Product>' ;
labels = FILTER A BY $1 == '<http://www.w3.org/2000/01/rdf-schema#label>' ;
features = FILTER A BY $1=='<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/productFeature>' ;    
features1 = FILTER features BY $2 == '<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/ProductFeature74>' ;    
features2 = FILTER features BY $2 == '<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/ProductFeature45>' ;    
results = JOIN types BY $0, labels by $0, features1 BY $0, features2 BY $0;
results = FOREACH results GENERATE $0, $6;
dump results;