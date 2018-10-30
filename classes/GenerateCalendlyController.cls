public class GenerateCalendlyController{

    // variables for generate calendly VF    
    public Case c {get;set;}
    public Account acc {get;set;}
    public Contact con {get;set;}
    public Date dt {get;set;}
    public String selectedEventType {get;set;}
    public String comments {get;set;}
    public String message {get;set;}
    List<String> fieldsNames = Label.CalendlyUrlParameters.split(',');
    
    public GenerateCalendlyController(ApexPages.StandardController controller) {    
        fieldsNames.add('ContactId');
        fieldsNames.add('AccountId');
        String accQuery = 'SELECT Id';
        String conQuery = 'SELECT Id';
        if(!Test.isRunningTest()) controller.addFields(fieldsNames);            
        for(String each : fieldsNames){
            
            if(each.startsWith('Account.')){
                String accFieldApi = each.subStringAfter('Account.');
                if(!accQuery.contains(accFieldApi)) accQuery += ','+accFieldApi;
            }else if(each.startsWith('Contact.')){
                String conFieldApi = each.subStringAfter('Contact.');
                if(!conQuery.contains(conFieldApi)) conQuery += ','+conFieldApi;
            }
            
        }
        
        
        c = ((Case)controller.getRecord());
                        
        if(c.AccountId != null && accQuery != 'SELECT Id'){
            accQuery += ' FROM Account WHERE Id = \''+c.AccountId+'\'';
            List<Account> accList = (List<Account>)Database.Query(accQuery);
            if(!accList.isEmpty()) acc = accList[0];
        }
        if(c.ContactId != null && conQuery != 'SELECT Id'){
            conQuery += ' FROM Contact WHERE Id = \''+c.ContactId+'\'';
            List<Contact> conList = (List<Contact>)Database.Query(conQuery);
            if(!conList.isEmpty()) con = conList[0];
        }
        dt = Date.today();   
    }

    public List<SelectOption> getEvents(){
        List<SelectOption> events = new List<SelectOption>(); 
        try{        
            List<User> currentUser = [SELECT Id, Calendly_Token__c FROM User WHERE Id =: UserInfo.getUserId()];
            String calendlyToken = currentUser[0].Calendly_Token__c;
            if(String.isNotBlank(calendlyToken)){
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint('https://calendly.com/api/v1/users/me/event_types');
                req.setHeader('X-TOKEN',calendlyToken);
                Http binding = new Http();
                HttpResponse res;
                String responseBody = '';
                if(!Test.isRunningTest()){res = binding.send(req);responseBody = res.getBody();} 
                if(Test.isRunningTest()) responseBody = GenerateCalendlyTest.fakeRes; 
                system.debug(responsebody);   
                fromJSON responseReceived = (fromJSON)System.JSON.deserialize(responseBody, fromJSON.class);                    
                if(responseReceived.type != 'authentication_error'){
                    for(cls_data data : responseReceived.data){
                        if(data.attributes != null && String.isNotBlank(data.attributes.url) && data.attributes.active){
                            events.add(new SelectOption(data.attributes.url, data.attributes.name));
                        }
                    }
                }                
            } 
        }catch(exception e){}
        return events;   
    }  
    public void sendInvite(){
        try{
            message='';
            if(String.isNotBlank(c.Id) && String.isNotBlank(selectedEventType) && dt != null){
                String calendlyLink = selectedEventType + '/' + dt.month() + '-' + dt.day() + '-' + dt.year(); 
                Set<String> exclusions = new Set<String>{'Contact.Name','ContactEmail','AccountId','ContactId'};
                String parameters = '?sfid=' + c.Id + '&name='+ EncodingUtil.urlEncode(c.Contact.Name, 'UTF-8') + '&email='+ c.ContactEmail;
                Integer i = 1;              
                for(String each : fieldsNames){
                    if(!exclusions.contains(each)){
                        if(each.startsWith('Account.') && acc != null){
                            String accFieldApi = each.subStringAfter('Account.');
                            parameters += '&a' + i + '=' + EncodingUtil.urlEncode((String)acc.get(accFieldApi), 'UTF-8');
                            i++;
                        }else if(each.startsWith('Contact.') && con != null){
                            String conFieldApi = each.subStringAfter('Contact.');
                            parameters += '&a' + i + '=' + EncodingUtil.urlEncode((String)con.get(conFieldApi), 'UTF-8');
                            i++;
                        }else{
                            parameters += '&a' + i + '=' + EncodingUtil.urlEncode((String)c.get(each), 'UTF-8');
                            i++;
                        }                        
                    }
                }                 
                String body = (String.isNotBlank(comments) ? + comments : '') + '\n\n'+ Label.CalendlyEnglishCaseComment +'\n\n' + calendlyLink + Parameters;
                
                insert new CaseComment(CommentBody = body, ParentId = c.Id, IsPublished = true);
                apexpages.addmessage(new apexpages.message(apexpages.severity.info,'Invitation Sent Successfully.'));
                message='<script> closeTab(); </script>';
                
            }
        }catch(exception e){ message='<script> closeTab(); </script>'; }
    }
    
    public class fromJSON{public cls_data[] data;public String type;public String message;}
    public class cls_data{String type;public String id;public cls_attributes attributes;}
    public class cls_attributes{public String name;public String description;public String color;public Integer duration;public String created_at;public String updated_at;public String slug;public boolean active;public String url;}
     
}