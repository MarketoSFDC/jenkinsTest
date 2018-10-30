public class searchAjaxRespController {
    public String result {get;set;}
     
    /** invoked on an Ajax request */   
    public void doSearch() {
          result = '';
          String searchText = ApexPages.currentPage().getParameters().get('q');
          
          if (searchText.length() > 1) {
          /*
              List<List<SObject>> searchList = [FIND 'lead*'  IN ALL FIELDS RETURNING searchQuery__c(searchString__c, relevancy__c ORDER BY relevancy__c) LIMIT 10];
              searchQuery__c [] queries = ((List<searchQuery__c>)searchList[0]);
              System.debug('__________Queries_Search_List________'+queries);  
            */  
             // searchQuery__c[] Allqueries = [select id,searchString__c,relevancy__c from searchQuery__c LIMIT 100];       
             // System.debug(Allqueries);
              
              searchText = searchText+'%';//SObject[] obj = Database.query('SELECT Id FROM SObjectName WHERE Name LIKE' + '%' + s + '%');
              searchQuery__c[] queries = [select id,searchString__c,relevancy__c from searchQuery__c where searchString__c LIKE :searchText order by relevancy__c DESC LIMIT 5];       
              
              for(searchQuery__c qry_itr:queries) {
                  if(qry_itr.searchString__c != null){
                      result += qry_itr.searchString__c+'\n';
                  }
              }
              System.debug('__________Queries_Result________'+result);
          } else {
              result = '';
          } 
    }
    
    public static testMethod void testSearchController() {
      
      PageReference pg = Page.searchSuggAjaxResponder; 
      pg.getParameters().put('q', 'test');
      
      Test.setCurrentPage(pg);
      
      searchAjaxRespController c = new searchAjaxRespController();      
      c.doSearch();  
 
    }
}