/*
This is the main controller class for HomePage.vfp, which is the main
page where all known issues are listed.

*/
public class HomePageController {
    
    public List<Known_Issue__c> issues {get;set;}
    public List<String> productareas {get;set;}
    public String category {get;set;}
    public String status {get;set;}
    public String timeO {get;set;}
    public String noResults {get;set;}
    public String searchTermString {get;set;}
    public List<String> statuses {get;set;}
    public String visualforceURL {get;set;}
    
    public HomePageController(){
        
        /*KISettings__c kiCustomSetting = KISettings__c.getInstance('Default');
        visualforceURL = kiCustomSetting.Visualforce_Domain__c;*/
        
        noResults = '';
        visualforceURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        /*Populate the known issues main pane with open issues that have been
        opened in the last 90 days*/
        
        issues = [SELECT id, Title__c, Name , CreatedDate, Description__c, Status__c, Product_Area__c FROM Known_Issue__c
                  WHERE Status__c IN ('Tier 3 Review','Escalated to Engineering','Patching')
                  AND CreatedDate = LAST_90_DAYS
                  ORDER BY CreatedDate Desc];
        
        /*Populate the productareas list
        with the values of the Product_Area__c picklist field*/
        productareas = new List<String>();
        Schema.DescribeFieldResult fieldResult = Known_Issue__c.Product_Area__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            productareas.add(f.getLabel());
        }  
        
        /*Populate the statuses list
        with the values of the Status__c picklist field*/
        statuses = new List<String>();
        Schema.DescribeFieldResult fieldResult2 = Known_Issue__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple2)
        {
            statuses.add(f.getLabel());
        }  
    }
    
    
    /*Populate the message returned if your search
    criteria doesn't return any values*/
    public void resetResults(){
        if(issues.isEmpty()){
            noResults = 'No results found.';
        }else{
            noResults = '';
        }
    }
    /*This method is called from a commandLink in the main page. The parameter
category contains the name of the product area selected, which is then used
to filter the list of issues*/
    public void showSelectedIssuesByArea(){
        
        
        if(category == 'All'){
            issues = [SELECT id, Title__c , Name, CreatedDate, Description__c, Status__c, Product_Area__c FROM Known_Issue__c
                      WHERE Status__c IN ('Tier 3 Review','Escalated to Engineering','Patching')
                      AND CreatedDate = LAST_90_DAYS
                      ORDER BY CreatedDate Desc];
        }else{
            issues = [SELECT id, Title__c , Name, CreatedDate,Description__c, Status__c, Product_Area__c FROM Known_Issue__c
                      WHERE Product_Area__c =: category 
                     AND Status__c IN ('Tier 3 Review','Escalated to Engineering','Patching')
                      AND CreatedDate = LAST_90_DAYS
                      ORDER BY CreatedDate Desc];
        }
        
        resetResults();
    } 
    
    /*Shows known issues based on the selected Status*/
    public void showSelectedIssuesByStatus(){
        
        if(status == 'All'){
            issues = [SELECT id, Title__c, Name,  Description__c, CreatedDate,Status__c, Product_Area__c FROM Known_Issue__c
                      ORDER BY CreatedDate Desc LIMIT 30];
        }else{
            issues = [SELECT id, Title__c , Name, Description__c,CreatedDate, Status__c, Product_Area__c FROM Known_Issue__c
                      WHERE Status__c =: status 
                     AND CreatedDate = LAST_90_DAYS
                      ORDER BY CreatedDate Desc];
        }
        
        resetResults();
    }
    
    /*Shows known issues based on the selected Time rage*/
    public void showSelectedIssuesByTime(){
        
        if(timeO == 'any'){
            issues = [SELECT id, Title__c,  Name, Description__c, CreatedDate,Status__c, Product_Area__c FROM Known_Issue__c
                      WHERE Status__c IN ('Tier 3 Review','Escalated to Engineering','Patching')
                      AND CreatedDate =  LAST_90_DAYS
                      ORDER BY CreatedDate Desc];
        }else if (timeO == 'today'){
            issues = [SELECT id, Title__c , Name, Description__c,CreatedDate, Status__c, Product_Area__c FROM Known_Issue__c
                      WHERE CreatedDate = TODAY 
                      AND Status__c IN ('Tier 3 Review','Escalated to Engineering','Patching')
                      ORDER BY CreatedDate Desc];
        }else if (timeO == 'this_week'){
            issues = [SELECT id, Title__c , Name, Description__c,CreatedDate, Status__c, Product_Area__c FROM Known_Issue__c
                      WHERE CreatedDate = THIS_WEEK 
                      AND Status__c IN ('Tier 3 Review','Escalated to Engineering','Patching') ORDER BY CreatedDate Desc];
        }  else if (timeO == 'this_month'){
            issues = [SELECT id, Title__c , Name, Description__c,CreatedDate, Status__c, Product_Area__c FROM Known_Issue__c
                      WHERE CreatedDate = THIS_MONTH 
                      AND Status__c IN ('Tier 3 Review','Escalated to Engineering','Patching') ORDER BY CreatedDate Desc];
        }  else if (timeO == 'last_month'){
            issues = [SELECT id, Title__c , Name, Description__c,CreatedDate, Status__c, Product_Area__c FROM Known_Issue__c
                      WHERE CreatedDate = LAST_MONTH 
                      AND Status__c IN ('Tier 3 Review','Escalated to Engineering','Patching') ORDER BY CreatedDate Desc];
        }
        
        resetResults();
    }
    
    /*Shows known issues based on the search term passed to the input field*/
    public void showSelectedIssuesBySearch(){
        
        
        
        String modifiedSearchTerm = '\'' +searchTermString+ '*\'';
        System.debug(searchTermString);
        System.debug(modifiedSearchTerm);
        
        List<List<SObject>> searchList = [FIND :modifiedSearchTerm IN ALL FIELDS RETURNING Known_Issue__c   (Id,  Name, Title__c,Description__c, CreatedDate,Status__c, Product_Area__c)];
        
        System.debug('This are the results: '+searchList);
        
        issues = ((List<Known_Issue__c>)searchList[0]);
        System.debug('list results: '+issues);
        
       resetResults();
        
    }
}