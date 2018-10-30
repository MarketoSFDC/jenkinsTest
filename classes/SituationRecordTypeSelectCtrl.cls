/****************************************************
Class Name: SituationRecordTypeSelectCtrl
Author: ClearTeask
Created Date: 19/09/2012
Usage: This class is used for showing record type selection page.
*****************************************************/
public class SituationRecordTypeSelectCtrl {
    
    // setected record type value
    public String selectedRecType { get; set; }
    // record type list
    public List<RecTypeDetail> recTypeDetailList { get; set; }
    
    // setected record id value
    public ID selectedRecID { get; set; }
    
    // query record type add in wrapper list - constructor
    public situationRecordTypeSelectCtrl() {
        selectedRecType = 'Services';
        recTypeDetailList = new List<RecTypeDetail>();
        
        List<RecordType> recTypeList = new List<RecordType>();
        if(ApexPages.currentPage().getParameters().get('id') != null){
        recTypeList = [select id, Name, Description from RecordType where sObjectType = 'Case' and (Name like '%Situation Management%' OR Name like '%Support Cases%') ];
        }else{
        recTypeList = [select id, Name, Description from RecordType where sObjectType = 'Case' and Name like '%Situation Management%'];
        } 
        for(RecordType rt :recTypeList) {
        recTypeDetailList.add(new RecTypeDetail(rt.Name, rt.Description));
        }
    }
    
    // get options for record type selection
    public List<SelectOption> getOptions(){
        List<SelectOption> option = new List<SelectOption>();
        option.add(new SelectOption('Services','Situation Management - Services' ));
        option.add(new SelectOption('Support', 'Situation Management - Support'));
        option.add(new SelectOption('MarketoCares', 'Situation Management - MarketoCares'));
        if(ApexPages.currentPage().getParameters().get('id') != null){
        option.add(new SelectOption('Standard', 'Support Cases'));        
        }
        return option;
    }
    
    // continue to create case after selecting record type
    public PageReference doContinue() {
        String page = ApexPages.currentPage().getParameters().get('page');
        String accid = ApexPages.currentPage().getParameters().get('accid');
        String conid = ApexPages.currentPage().getParameters().get('conid');
        String recid = ''; 
        try {
            recid = ApexPages.currentPage().getParameters().get('id');
            //System.debug('selectedRecType=>' + selectedRecType);
            Id selectedRecTypeId = recTypeAssignment(selectedRecType);
            //System.debug('selectedRecType=>' + selectedRecType + ' ' + selectedRecTypeId);
            Case myCase = [SELECT ID, RecordTypeId,Situation_Account__c,Situation_Contact__c from case where ID =:recid LIMIT 1];
            myCase.RecordTypeId = selectedRecTypeId ;  
            update myCase;
            //System.debug('selectedRecType=>' + selectedRecType);
            PageReference pgRef;   
                   
            if(selectedRecType.equals('Standard')) {
                if(myCase.Account == null) myCase.AccountId = myCase.Situation_Account__c;
                if(myCase.Contact == null) myCase.ContactId = myCase.Situation_Contact__c;
                myCase.Situation_Contact__c = null;
                myCase.Situation_Account__c = null;
                update myCase;                
                String url = '/apex/CustomCasePage?id=' + recid;                
                pgRef = new PageReference(url);                
            } else if(selectedRecType.equals('Services')) {
                String url = '/apex/SituationServicesDetail?type=serv';
                url += (recid== null) ? '' : ('&id=' + recid);                
                pgRef = new PageReference(url);                
            } else if(selectedRecType.equals('Support')) {
                String url = '/apex/SituationSupportDetail?type=supp';
                url += (recid== null) ? '' : ('&id=' + recid);                
                pgRef = new PageReference(url);
            } 
           /* else if(selectedRecType.equals('Feedback')) {
                String url = '/apex/SituationFeedbackDetail?type=feed';
                url += (recid== null) ? '' : ('&id=' + recid);                
                pgRef = new PageReference(url);
            } */           
            pgRef.setRedirect(true);
            return pgRef;
                   
        }
        catch(Exception ex)
        {
            recid = '';            
        }
        
        PageReference pgRef;
        
        
        if(selectedRecType.equals('Services')) {
            String url = '/apex/SituationServicesCreate?type=serv';
            url += (page == null) ? '' : ('&page=' + page);
            url += (accid == null) ? '' : ('&accid=' + accid);
            url += (conid == null) ? '' : ('&conid=' + conid);
            pgRef = new PageReference(url);
            
        } else if(selectedRecType.equals('Support')) {
            String url = '/apex/SituationSupportCreate?type=supp';
            url += (page == null) ? '' : ('&page=' + page);
            url += (accid == null) ? '' : ('&accid=' + accid);
            url += (conid == null) ? '' : ('&conid=' + conid);
            pgRef = new PageReference(url);
        } else if(selectedRecType.equals('Feedback')) {
            String url = '/apex/SituationFeedbackCreate?type=feed';
            url += (page == null) ? '' : ('&page=' + page);
            url += (accid == null) ? '' : ('&accid=' + accid);
            url += (conid == null) ? '' : ('&conid=' + conid);
            pgRef = new PageReference(url);
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    // go to list page
    public PageReference doCancel() {
        /*String recid = '';
        try {
            recid = ApexPages.currentPage().getParameters().get('id');  
            if(recid.length() > 0){
                          
                PageReference pgRef;          
                if(selectedRecType.equals('Services')) {
                    String url = '/apex/SituationServicesDetail?type=serv';
                    url += (recid== null) ? '' : ('&id=' + recid);                
                    pgRef = new PageReference(url);                
                } else if(selectedRecType.equals('Support')) {
                    String url = '/apex/SituationSupportDetail?type=supp';
                    url += (recid== null) ? '' : ('&id=' + recid);                
                    pgRef = new PageReference(url);
                } else if(selectedRecType.equals('Feedback')) {
                    String url = '/apex/SituationFeedbackDetail?type=feed';
                    url += (recid== null) ? '' : ('&id=' + recid);                
                    pgRef = new PageReference(url);
                }                        
                pgRef.setRedirect(true);
                return pgRef;
            }       
        }
        catch(Exception ex)
        {
            recid = '';            
        }*/
        
        String retUrl = ApexPages.currentPage().getParameters().get('retURL') != null?ApexPages.currentPage().getParameters().get('retURL'):'/apex/SituationList';
        PageReference pgRef = new PageReference(retUrl);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    // wrapper class
    public class RecTypeDetail {
        public String name { get; set; }
        public String description { get; set; }
        
        public recTypeDetail(String name, String description) {
            this.name = name;
            this.description = description;
        }
    }
    
    public Id recTypeAssignment(String type) {
    
        System.debug( 'recTypeNametype =>'+type);
        String recTypeName = '';Id recTypeId;
        
        if(type != null && type.equals('Standard'))
            recTypeName = 'Support Cases';  
        if(type != null && type.equals('Services'))
            recTypeName = 'Situation Management - Services';
        if(type != null && type.equals('Support'))
            recTypeName = 'Situation Management - Support';                         
        if(type != null && type.equals('Feedback'))
            recTypeName = 'Situation Management - MarketoCares';  
                                           
        List<RecordType> recTypeList = [select id, Name from RecordType where sObjectType = 'Case' and Name = :recTypeName];        
        if(recTypeList != null && recTypeList.size() > 0) {
            recTypeId = recTypeList[0].id;
        }
        return recTypeId;
    }
}