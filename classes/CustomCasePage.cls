public class CustomCasePage
{
    Public String caseRecId{get;set;}
    private final ApexPages.StandardController controller;
    public CustomCasePage()
    {
        caseRecId = ApexPages.currentPage().getParameters().get('Id');        
    }
    public CustomCasePage(ApexPages.StandardController controller)
    {
        this.controller = controller;
        caseRecId = ApexPages.currentPage().getParameters().get('Id');        
    }    
    public pagereference supportRedirect()
    {
        try {       
            System.debug('caseRecId ' + caseRecId );       
            Case myCase = [SELECT ID, RecordTypeID from Case Where Id = : caseRecID Limit 1] ;
            RecordType myRecType = [select id, Name from RecordType where sObjectType = 'Case' and Id = :myCase.RecordTypeId Limit 1];        
            if(myRecType != null) {
                Pagereference newPage;        
                if(myRecType.Name == 'Situation Management - Services')
                {
                    newPage = Page.SituationServicesDetail;                    
                    newPage.getParameters().put('type','serv');
                    newPage.getParameters().put('id',caseRecId);                   
                    return (newPage.setRedirect(true));                
                }
                /*else if(myRecType.Name == 'Situation Management - Support')
                {
                    newPage = Page.SituationSupportDetail;
                    newPage.getParameters().put('type','supp');
                    newPage.getParameters().put('id',caseRecId);
                    return (newPage.setRedirect(true));                           
                }
                else if(myRecType.Name == 'Situation Management - Escalation Manager')
                {
                    newPage = Page.EscalateManagerDetail;
                    newPage.getParameters().put('type','EscMan');
                    newPage.getParameters().put('id',caseRecId);
                    return (newPage.setRedirect(true));                           
                }*/
                /*else if(myRecType.Name == 'Situation Management - Support Feedback')
                {
                    newPage = Page.SituationFeedbackDetail;
                    newPage.getParameters().put('type','feed');
                    newPage.getParameters().put('id',caseRecId);
                    return (newPage.setRedirect(true));                           
                }*/
                else 
                {  
                    //return null;
                    newPage = new PageReference('/'+caseRecId);
                    Map <String,String> urlParameters = new Map<String, String>();
                    urlParameters = ApexPages.currentPage().getParameters();
                    urlParameters.remove('sfdc.override');
                    urlParameters.remove('nooverride');
                    for(String urlkey:urlParameters.keySet()){
                        newPage.getParameters().put(urlKey,urlParameters.get(urlKey));
                    }
                    newPage.getParameters().put('nooverride','0');
                    return newPage;                    
                }            
            }
        }
        catch (Exception ex)
        {
            
        }    
        return null;
    }        
    
    @isTest(SeeAllData=true)
    public static void myTestMethod()
    {
        String  recTypeName = 'Situation Management - Services';                    
        List<RecordType> recTypeList = [select id, Name from RecordType where sObjectType = 'Case' and Name = :recTypeName];    
        if(recTypeList != null && recTypeList.size() > 0) {
            String recTypeId = recTypeList[0].id;
            Case mySmCase = [select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name from Case where RecordTypeId = :recTypeId Limit 1];            
            ApexPages.StandardController ctrl = new ApexPages.StandardController(mySmCase);              
            ApexPages.currentPage().getParameters().put('id', mySmCase.Id);   
            CustomCasePage myPg =  new CustomCasePage();            
            myPg.supportRedirect();                                       
        }
        recTypeName = 'Situation Management - Support';            
        List<RecordType> recTypeList2 = [select id, Name from RecordType where sObjectType = 'Case' and Name = :recTypeName];    
        if(recTypeList2 != null && recTypeList2.size() > 0) {
            String recTypeId = recTypeList2[0].id;        
            Case mySmCase = [select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name from Case where RecordTypeId = :recTypeId Limit 1];
            ApexPages.StandardController ctrl = new ApexPages.StandardController(mySmCase);              
            ApexPages.currentPage().getParameters().put('id', mySmCase.Id);   
            CustomCasePage myPg =  new CustomCasePage();            
            myPg.supportRedirect();                                   
        } 
        
        recTypeName = 'Situation Management - MarketoCares';            
        List<RecordType> recTypeList3 = [select id, Name from RecordType where sObjectType = 'Case' and Name = :recTypeName];    
        if(recTypeList3 != null && recTypeList3.size() > 0) {
            String recTypeId = recTypeList3[0].id;        
            Case mySmCase = [select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name from Case where RecordTypeId = :recTypeId Limit 1];
            ApexPages.StandardController ctrl = new ApexPages.StandardController(mySmCase);              
            ApexPages.currentPage().getParameters().put('id', mySmCase.Id);   
            CustomCasePage myPg =  new CustomCasePage();            
            myPg.supportRedirect();                                   
        }  
        
        /*recTypeName = 'Situation Management - Escalation Manager';            
        List<RecordType> recTypeList4 = [select id, Name from RecordType where sObjectType = 'Case' and Name = :recTypeName];    
        if(recTypeList4 != null && recTypeList4.size() > 0) {
            String recTypeId = recTypeList4[0].id;        
            Case mySmCase = [select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name from Case where RecordTypeId = :recTypeId Limit 1];
            ApexPages.StandardController ctrl = new ApexPages.StandardController(mySmCase);              
            ApexPages.currentPage().getParameters().put('id', mySmCase.Id);   
            CustomCasePage myPg =  new CustomCasePage();            
            myPg.supportRedirect();                                   
        }*/
        
        recTypeName = 'Support Cases';            
        List<RecordType> recTypeList5 = [select id, Name from RecordType where sObjectType = 'Case' and Name = :recTypeName];    
        if(recTypeList5 != null && recTypeList5.size() > 0) {
            String recTypeId = recTypeList5[0].id;        
            Case mySmCase = [select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name from Case where RecordTypeId = :recTypeId Limit 1];
            ApexPages.StandardController ctrl = new ApexPages.StandardController(mySmCase);              
            ApexPages.currentPage().getParameters().put('id', mySmCase.Id);   
            CustomCasePage myPg =  new CustomCasePage();            
            myPg.supportRedirect();                                   
        }
                                             
    }    
            
}