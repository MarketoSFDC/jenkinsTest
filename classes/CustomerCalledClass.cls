public class CustomerCalledClass{

    public string commentBody{get;set;}
    public string callfunc{get;set;}
    public Id caseId;
    public CustomerCalledClass(ApexPages.StandardController controller){
        caseId = ApexPages.currentPage().getParameters().get('id');
        callfunc = '';
    }
    public void saveComment(){
        try{
            for(Case cseObj: [Select id,contact.name, OutboundCustomerCall__c from case where id =: caseId]){
                system.debug('===>'+cseObj.OutboundCustomerCall__c);
                if(cseObj.OutboundCustomerCall__c!=null) cseObj.OutboundCustomerCall__c +=1;
                else cseObj.OutboundCustomerCall__c = 1;
                update cseObj;
            }
            CaseComment cm = new CaseComment();
            cm.CommentBody = 'Called Customer: \n\n' + commentBody;
            cm.IsPublished = True;
            cm.ParentId = caseId;
            insert cm;
            
            callfunc='<script> CloseAndReWfresh(); </script>';           
        }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}  
    }
    
    public void CancelScreen(){
        try{
            callfunc='<script> CloseAndReWfresh(); </script>'; 
        }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}  
    }
}