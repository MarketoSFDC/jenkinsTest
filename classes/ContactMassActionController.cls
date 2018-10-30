public class ContactMassActionController{

    public Contact con {get;set;}
    String buttonInfo;
    Set<String> contactIds = new Set<String>();
    PageReference returnUrl = null;
    public ContactMassActionController(){       
        con = new Contact();
        con.ownerId = UserInfo.getUserId(); //con.Contact_Status__c = 'Opportunity';
        buttonInfo = ApexPages.currentPage().getParameters().get('contactType');
        contactIds.addAll(ApexPages.currentPage().getParameters().get('key').split(','));        
        returnUrl = new PageReference(ApexPages.currentPage().getParameters().get('retUrl'));
    } 
     
    public PageReference save(){
        
        List<Contact> contacts = new List<Contact>([SELECT OwnerId, Contact_Status__c, Touch_Stage__c,Recycled_Reason__c FROM Contact WHERE Id IN : contactIds]);
        if(buttonInfo == 'Contact_CHANGEOWNER'){
            for(Contact cont : contacts){
                cont.OwnerId = con.OwnerId;
            }
        }
        else if(buttonInfo == 'CONTACT_CHANGE_TOUCH_STAGE'){
            for(Contact cont : contacts){
                cont.Touch_Stage__c = con.Touch_Stage__c;
            }
        }
        else if(buttonInfo == 'CONTACT_Recycle_contact'){
            for(Contact cont : contacts){
                 
                cont.Recycled_Reason__c= con.Recycled_Reason__c;
                cont.Contact_Status__c = con.Contact_Status__c;
            }
        } 
        else{
            for(Contact cont : contacts){
                cont.Contact_Status__c = con.Contact_Status__c;
            }
        } 
        update contacts;
        system.debug(returnUrl+'===');
        return returnUrl;      
    }
    
    public PageReference cancel(){
        
        return returnUrl;
    }
    
    /***test code started***/
    static testMethod void testContactMassActionController() {
        
        Account acc = Utility.insertAccountInTestClasses();
        acc.Type = 'Customer';
        acc.RecordTypeId = '01250000000ULb7';
        insert acc;
        Contact con = Utility.insertContactInTestClasses(acc.Id);
        insert con;   
           
        PageReference pageRef = Page.ContactMassAction;
        pageRef.getParameters().put('id', String.valueOf(con.Id));
        pageRef.getParameters().put('contactType','CONTACT_Recycle_contact');
        pageRef.getParameters().put('key',con.Id);
        pageRef.getParameters().put('retUrl','/'+con.Id);
        Test.setCurrentPage(pageRef);
        ContactMassActionController cmc = new ContactMassActionController();
        cmc.save();
        cmc.cancel();     
        
        Contact con2 = Utility.insertContactInTestClasses(acc.Id);
        insert con2;
        
        PageReference pageRef2 = Page.ContactMassAction;
        pageRef2.getParameters().put('id', String.valueOf(con2.Id));
        pageRef2.getParameters().put('contactType','Contact_CHANGESTATUS');
        pageRef2.getParameters().put('key',con2.Id);
        pageRef2.getParameters().put('retUrl','/'+con2.Id);
        Test.setCurrentPage(pageRef2);
        ContactMassActionController cmc2 = new ContactMassActionController();
        cmc2.save();
        cmc2.cancel();        
    
    }
    
}