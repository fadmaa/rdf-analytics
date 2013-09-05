function initQuery(){
  return 'PREFIX :<http://example.org/p/>  ' +
  'DROP GRAPH <urn:ga/g/sxjz0> ; '+
  'CREATE GRAPH <urn:ga/g/sxjz0> ;' + 
  'INSERT {' + 
      'GRAPH <urn:ga/g/sxjz0> {?s :w 0}' +
  '}' +
  'WHERE { ' +
    'SELECT DISTINCT ?s '+
    'WHERE{ '+
      '?s a <http://example.org/c/Person> . ' + 
    '}' + 
  '};'  +
  'INSERT { ' + 
      'GRAPH <urn:ga/g/sxjz0> {<http://example.org/person/fadi-maali> <http://example.org/p/w> 2}' + 
  '} WHERE{};' ;
}

update_endpoint = 'http://localhost:3030/test/update';
query_endpoint = 'http://localhost:3030/test/query';
  
$(function(){
  
  $.post(update_endpoint,{update:initQuery()}, function(data){
    sa(1);
  });
  
  
});

function sa(i){
    $.post(update_endpoint,{update:getUpdateQuery(i)}, function(data){
      $('#results').html('attempt ' + i);
      $.get(query_endpoint,{query:checkResultsQuery(i),output:"json"},function(data){
        var diff = data.results.bindings[0].diff.value;
        if (diff>0.2 && i<10) sa(i+1)
        else clean(i);
      
      },"json");
    });
}

function clean(n){
  s = ''
  for(var i=0;i <n; i++){
    s += 'DROP GRAPH <urn:ga/g/sxjz' + i + '>; ' ;
  }
   $.post(update_endpoint,{update:s}, function(data){
   		$.get(query_endpoint,{query:'PREFIX :<http://example.org/p/> '+
'SELECT ?s ?o ' + 
'WHERE{'+ 
  'GRAPH <urn:ga/g/sxjz' + n + '> {' + 
  '?s :w ?o' + 
 '}' + 
'} ORDER BY desc(?o)',output:"json"},function(data){

		//viewing results
		tbl = '<table border ="1"><tr><th>person</th><th>activation value</th></tr>' ;
        var res = data.results.bindings;
  		for(var i=0; i<res.length;i++){
  		  tbl +='<tr><td>' + res[i].s.value + '</td><td>' + res[i].o.value + '</td></tr>';
  		}
		tbl += '</table>';
		$('#results').html(tbl);

},"json");
   
   
   });
}
function getUpdateQuery(i){
  var pred = i-1;
  return 'PREFIX :<http://example.org/p/>  ' +
  'DROP GRAPH <urn:ga/g/sxjz' + i + '> ; '+
  'CREATE GRAPH <urn:ga/g/sxjz' + i + '>; ' + 
  'INSERT {' + 
      'GRAPH <urn:ga/g/sxjz' + i + '> {?o :w ?weight}' +
  '}' +
  'WHERE { ' +
     'SELECT ?o  ((?w0 + 0.1 * SUM(?in_w)) AS ?weight) ' +
     'WHERE{ ' +
       '?s :knows ?o . ' +
       '{ ' +
         'GRAPH <urn:ga/g/sxjz' + pred + '> { ' +
           '?o :w ?w0. ' +
           '?s :w ?in_w . ' +
         '} ' +
       '}  ' +
     '} GROUP BY ?o ?w0 ' + 
    '}';
}

function checkResultsQuery(i){
var pred = i-1;
return 'PREFIX :<http://example.org/p/>  '+
'SELECT (?w2 - ?w1 AS ?diff) '+
'WHERE{ '+
'GRAPH <urn:ga/g/sxjz' + pred + '> { '+
  '?s :w ?w1 '+
'} '+
'GRAPH <urn:ga/g/sxjz' + i + '> { '+
  '?s :w ?w2 '+
'} '+
'}ORDER BY desc(?diff) '+
'LIMIT 1 ';
}



