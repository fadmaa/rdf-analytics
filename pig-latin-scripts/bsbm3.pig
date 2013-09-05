/*
exec ../../scripts/bsbm3.pig
*/

/* === SPARQL query ===
prefix bsbm: <http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/>
  prefix bsbm-inst: <http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/instances/>
  prefix rev: <http://purl.org/stuff/rev#>
  prefix dc: <http://purl.org/dc/elements/1.1/>
  prefix xsd: <http://www.w3.org/2001/XMLSchema#>

  Select ?product (xsd:float(?monthCount)/?monthBeforeCount As ?ratio)
  {
    { Select ?product (count(?review) As ?monthCount)
      {
        ?review bsbm:reviewFor ?product .
        ?review dc:date ?date .
        Filter(?date >= "2008-06-01"^^<http://www.w3.org/2001/XMLSchema#date> && ?date < "2008-07-01"^^<http://www.w3.org/2001/XMLSchema#date>) 
      }
      Group By ?product
    }  {
      Select ?product (count(?review) As ?monthBeforeCount)
      {
        ?review bsbm:reviewFor ?product .
        ?review dc:date ?date .
        Filter(?date >= "2008-05-01"^^<http://www.w3.org/2001/XMLSchema#date> && ?date < "2008-06-01"^^<http://www.w3.org/2001/XMLSchema#date>) #
      }
      Group By ?product
      Having (count(?review)>0)
    }
  }
  Order By desc(xsd:float(?monthCount) / ?monthBeforeCount) ?product
  Limit 10
*/


/* === RDFAL query === 

revs1 = {
        ?review bsbm:reviewFor ?product .
        ?review dc:date ?date .
        Filter(?date >= "2008-06-01"^^<http://www.w3.org/2001/XMLSchema#date> && ?date < "2008-07-01"^^<http://www.w3.org/2001/XMLSchema#date>) 
      };

groups1 = Group revs1 By product ;

counts1 = FOREACH groups1 GENERATE product, (count(review) As monthCount);

revs2 = {
        ?review bsbm:reviewFor ?product .
        ?review dc:date ?date .
        Filter(?date >= "2008-06-01"^^<http://www.w3.org/2001/XMLSchema#date> && ?date < "2008-07-01"^^<http://www.w3.org/2001/XMLSchema#date>) 
      };
      
groups2 = Group revs2 By product ;

counts2 = FOREACH groups2 GENERATE product, (count(review) As monthCount);

joined_data = JOIN counts1 BY product, counts2 BY product ;

ratios = FOREACH joined_data generate product, ( (float) counts2::monthCount / counts1::monthCount) As ratio ;
      
*/

rdf_data = LOAD '../../data/RDF/bsbm/dataset-100.nt' USING PigStorage(' ') AS (S,P,O);

SPLIT rdf_data INTO months1 IF $1 == '<http://purl.org/dc/elements/1.1/date>' AND $2 < '"2008-06-01"' AND $2 >= '"2008-05-01"' ,
months2 IF $1 == '<http://purl.org/dc/elements/1.1/date>' AND $2 < '"2008-07-01"' AND $2 >= '"2008-06-01"' ,                    
reviews IF $1 == '<http://www4.wiwiss.fu-berlin.de/bizer/bsbm/v01/vocabulary/reviewFor>' ;

revs1 = JOIN months1 BY $0, reviews BY $0 ;

revs2 = JOIN months2 BY $0, reviews BY $0 ;

grps1 = GROUP revs1 BY $5 ;
 
grps2 = GROUP revs2 BY $5 ;

counts1 = FOREACH grps1 GENERATE group, COUNT(revs1) AS count;                                                                          

counts2 = FOREACH grps2 GENERATE group, COUNT(revs2) AS count; 

ratios = JOIN counts1 BY group, counts2 BY group ;

ratios = FOREACH ratios GENERATE counts1::group AS prod, ((float)counts2::count / counts1::count) AS ratio ;

DUMP ratios;
