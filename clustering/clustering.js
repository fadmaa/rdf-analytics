/*
based on: http://yarcdata.com/blog/?p=318
*/

/*
Assumes data.nt loaded in a SPARQL endpoint at http://localhost:3030/test/query
that accepts SPARQL1.1 update at http://localhost:3030/test/update
*/

function initQuery(){
  return 'PREFIX :<http://example.org/p/> ' +
  'DROP GRAPH <urn:ga/g/xjz0> ; '+
  'CREATE GRAPH <urn:ga/g/xjz0> ;' + 
  'INSERT {' + 
      'GRAPH <urn:ga/g/xjz0> {?o :cluster ?cluster}' +
  '}' +
  'WHERE { ' +
    'SELECT ?o ?cluster '+
    'WHERE{ '+
      '?o :name ?cluster. ' + 
    '}' + 
  '}' ;
}

update_endpoint = 'http://localhost:3030/test/update';
query_endpoint = 'http://localhost:3030/test/query';
  
$(function(){
  
  $.post(update_endpoint,{update:initQuery()}, function(data){
    cluster(1);
  });
  
  
});

function cluster(i){
    var uq = getUpdateQuery(i);
    $.post(update_endpoint,{update:uq}, function(data){
      $('#results').html('attempt ' + i);
      $.get(query_endpoint,{query:checkResultsQuery(i),output:"json"},function(data){
        var diff = data.results.bindings[0].vccCt.value;
        if (diff>3 && i<10) cluster(i+1)
        else clean(i);
      
      },"json");
    });
}

function clean(n){
  s = ''
  for(var i=0;i <n; i++){
    s += 'DROP GRAPH <urn:ga/g/xjz' + i + '>; ' ;
  }
   $.post(update_endpoint,{update:s}, function(data){ viewResults(n)});
}

function viewResults(n) {
  var q = 'PREFIX :<http://example.org/p/> ' +
  'SELECT ?s ?clust ' + 
  'WHERE{ ' + 
    'GRAPH <urn:ga/g/xjz' + n +'>{' + 
      '?s :cluster ?clust. ' +
    '}' + 
  '} ORDER BY ?clust';
  $.get(query_endpoint,{query:q, output:"json"}, function(data){
		tbl = '<table border ="1"><tr><th>cluster</th><th>members</th></tr>' ;
		oldC = '' ;
        var res = data.results.bindings;
        var first = true;
  		for(var i=0; i<res.length;i++){
  		  var c = res[i].clust.value;
  		  var s = res[i].s.value;
  		  if(c != oldC){
  		    oldC = c;
  		    if(!first){
  		      tbl += '</td></tr>' ;
  		    }
  		    tbl += '<tr><td>' + c + '</td><td>' + s ;
  		  }else{
  		    tbl += '<br/>' + s ;
  		  }
  		  first = false;
  		}
  		tbl += '</td></tr></table>';
  		$('#results').html(tbl);
    },"json");
}
function getUpdateQuery(i){
  var pred = i-1;
  return 'PREFIX :<http://example.org/p/> ' +
  'DROP GRAPH <urn:ga/g/xjz' + i + '> ; '+
  'CREATE GRAPH <urn:ga/g/xjz' + i + '>; ' + 
  'INSERT {' + 
      'GRAPH <urn:ga/g/xjz' + i + '> {?s :cluster ?clus3}' +
  '}' +
  'WHERE { ' +
     'SELECT ?s (SAMPLE(?clus) AS ?clus3) ' + 
 '{' +
     '{ SELECT ?s (MAX(?clusCt) AS ?maxClusCt) '+ 
     '{ ' +
         'SELECT ?s ?clus (COUNT(?clus) AS ?clusCt) '+
         'WHERE '+
         '{ '+
           '?s :knows ?o . '+
           'GRAPH <urn:ga/g/xjz' + pred + '> { ?o :cluster ?clus } '+
         '} GROUP BY ?s ?clus '+
       '} GROUP BY ?s '+
     '} '+
     '{ SELECT ?s ?clus (COUNT(?clus) AS ?clusCt) '+
       'WHERE '+
       '{ '+
         '?s :knows ?o . '+
         'GRAPH <urn:ga/g/xjz' + pred + '> { ?o :cluster ?clus } '+
       '} GROUP BY ?s ?clus '+
     '} FILTER (?clusCt = ?maxClusCt) '+
     '} GROUP BY ?s '+
    '}';
}

function checkResultsQuery(i){
var pred = i-1;

return 'PREFIX :<http://example.org/p/> '+
'SELECT (COUNT(?oNew) as ?vccCt) '+ 
'WHERE { '+
   'GRAPH <urn:ga/g/xjz' + pred +'>   {?s :cluster ?oOld} '+
   'GRAPH <urn:ga/g/xjz' + i + '> {?s :cluster ?oNew} '+
   'FILTER (?oOld != ?oNew) '+
 '}';
}



