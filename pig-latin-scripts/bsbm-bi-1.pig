/*
prefix bsbm: <http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/>
prefix rev: <http://purl.org/stuff/rev#>

Select ?productType ?reviewCount
{
 { Select ?productType (count(?review) As ?reviewCount)
  {
   ?productType a bsbm:ProductType .
   ?product a ?productType .
   ?product bsbm:producer ?producer .
   ?producer bsbm:country <http://downlode.org/rdf/iso-3166/countries#GB> .
   ?review bsbm:reviewFor ?product .
   ?review rev:reviewer ?reviewer .
   ?reviewer bsbm:country <http://downlode.org/rdf/iso-3166/countries#KR> .
  }
  Group By ?productType
 }
}
Order By desc(?reviewCount) ?productType
Limit 10
*/

dta = LOAD './RDF-data/bsbm/dataset-100.nt' USING PigStorage(' '); 
producer = FILTER dta BY $1 =='<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/producer>' ;                                                        
country = FILTER dta BY $1 =='<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/country>' AND $2 == '<http://downlode.org/rdf/iso-3166/countries#GB>';  
prods = JOIN producer BY $2, country BY $0;
prods = FOREACH prods GENERATE $0 ;

types = FILTER dta BY $1 == '<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>' ;
prods_types = JOIN types BY $0, prods BY $0;
prods_types = FOREACH prods_types GENERATE $4, $2;

revs = FILTER dta BY $1 =='<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/reviewFor>' ;
prods_revs = JOIN revs BY $2, prods_types BY $0 ;
prods_revs = FOREACH prods_revs GENERATE $0, $4, $5 ;

country = FILTER dta BY $1 =='<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/country>' AND $2 == '<http://downlode.org/rdf/iso-3166/countries#KR>';  
reviewers = FILTER dta BY $1 =='<http://purl.org/stuff/rev#reviewer>' ;
reviewers_cntry = JOIN reviewers BY $2, country BY $0 ;
revs = FOREACH reviewers_cntry GENERATE $0;
prod_revs = JOIN prods_revs BY $0, revs BY $0;
grps = GROUP prod_revs BY $2;
results = FOREACH grps GENERATE group, COUNT(prod_revs);
DUMP results;