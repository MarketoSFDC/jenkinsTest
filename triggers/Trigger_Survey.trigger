trigger Trigger_Survey on QualtricsSurvey__c (before insert, after insert) {

    Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.QualtricsSurvey__c.fields.getMap();
    string MarketoNPSSurvey = Label.MarketoNPSSurvey;
    string Label_Marketo_NPS_Survey = Label.Label_Marketo_NPS_Survey;
    string Label_90_Days_Survey = Label.Label_90_Days_Survey;
        
    if(trigger.isBefore) {
        
        Map<String, Contact> contactInfo = new Map<String, Contact>();
        
        Set<string> emails = new Set<String>();
        string contactSearchQuery = 'SELECT Id, Account.Name, Email, AccountId FROM Contact';
        
        String HTML_TAG_PATTERN = '<.*?>';
        Pattern myPattern = Pattern.compile(HTML_TAG_PATTERN);  
        Set<String> questionFieldsAPINames = new Set<String>(Label.Qualtrics_Survey_Number_of_Questions.split(','));
        Set<string> contactIds = new Set<String>();
        Set<string> accountName = new Set<string>();
        //Set<String> camOwnersId = new Set<String>();
        
        for(QualtricsSurvey__c survey : trigger.new) {
            if(survey.Contact__c != null) {
                contactIds.add(survey.Contact__c);
               
            }
            
            if(survey.Email__c!= null) {
                emails.add(survey.Email__c);
               
            }   
            
        }
        
        //TO HANDLE THE SCENARIO IF WRONG CONTACT ID IS ADDED IN QUALTRICS PANEL
        Map<Id, Contact> recipeintsMap = new Map<Id, Contact>([SELECT Id,AccountId FROM Contact WHERE Id IN: contactIds]);
        
        
        if(!emails.isEmpty()){
            contactSearchQuery += ' WHERE Email IN: emails';
            
            for(Contact con : Database.Query(contactSearchQuery)) {
                contactInfo.put(con.Email, con);
                contactInfo.put(con.Email+'-'+con.Account.Name, con); 
            }       
        }  
        
        
        for(QualtricsSurvey__c survey : trigger.new) {
            for(String fieldName : schemaFieldMap.keySet())
            {   
        
                Schema.DisplayType fieldDataType = schemaFieldMap.get(fieldName).getDescribe().getType();
                
                if(fieldDataType == Schema.DisplayType.String || fieldDataType == Schema.DisplayType.TextArea) {
                
                    String fieldValue = (String)survey.get(fieldName);
                    if(fieldValue!= null && fieldValue !=''){                    
                        string result = fieldValue.replaceAll('&nbsp;', '');
                       
                        system.debug(questionFieldsAPINames.contains(fieldName)+'-->'+fieldName);
                    
                        if(questionFieldsAPINames.contains(fieldName)){
                            result = '<b>'+result+'</b>';
                        }
                        survey.put(fieldName, result);
                    }
                }                
            }
             
            if(survey.Contact__c == null) {
                if(survey.Email__c != null) {
                    
                    string key = survey.Account_Name__c!= null?survey.Email__c+'-'+survey.Account_Name__c:survey.Email__c;
                    if(contactInfo.containsKey(key)) {
                        survey.Contact__c = contactInfo.get(key).ID;
                        survey.Account__c = contactInfo.get(key).AccountId;
                    }  
                }                
            }else if(!recipeintsMap.containsKey(survey.Contact__c)) {
                 
                string key = survey.Account_Name__c!= null?survey.Email__c+'-'+survey.Account_Name__c:survey.Email__c;
                survey.Contact__c =         contactInfo.get(key).ID;
                survey.Account__c = contactInfo.get(key).AccountId;  
                       
             }
             else{
                string key = survey.Account_Name__c!= null?survey.Email__c+'-'+survey.Account_Name__c:survey.Email__c;
                survey.Account__c = recipeintsMap.get(survey.Contact__c).AccountId; 
             }
        }
    
    }else if(trigger.isAfter){
        List<Contact> updateContacts = new List<Contact>();
        Set<String> contactFields = new Set<String>(Label.Qualtrics_Survey_Fields_on_Contact.split('#'));
        Set<String> contactIds =  new Set<String>();
        Set<string> NPSSurveyAPINames = new Set<String>(Label.MarketoNPSSurvey.split(','));
        Set<string> DaysSurvey90 = new Set<string>(Label.DaysSurvey90.split(','));
         
        for(QualtricsSurvey__c survey : trigger.new){
            if(survey.Contact__c != null) contactIds.add(survey.Contact__c);   
        }
        Map<Id, string> contactWithSurveys = new Map<Id, string>();
        for(QualtricsSurvey__c survey:[SELECT Contact__c, NPS_Type__c FROM QualtricsSurvey__c WHERE Contact__c IN: contactIds]){
            if(survey.NPS_Type__c != null && survey.Contact__c != null){
                if(contactWithSurveys.containsKey(survey.Contact__c)) {
                    String type = contactWithSurveys.get(survey.Contact__c);
                    if(!type.contains(survey.NPS_Type__c)) contactWithSurveys.put(survey.Contact__c, type+','+survey.NPS_Type__c);
                }else{
                    contactWithSurveys.put(survey.Contact__c, survey.NPS_Type__c);
                }
            }
        }
        for(QualtricsSurvey__c survey : trigger.new){
            if(survey.Contact__c != null) {
                Contact con = new Contact (Id = survey.Contact__c, Survey_Response_In_SFDC__c = survey.Id, Survey_Response_Date__c = Datetime.now());
                if(contactWithSurveys.containsKey(survey.Contact__c)){con.All_Participated_Surveys__c = contactWithSurveys.get(survey.Contact__c);}
                for(String fieldName : contactFields)
                {   
                    /*
                    String answernoHTML = (String)survey.get(fieldName);
                    
                    if(answernoHTML != null && answernoHTML.trim()!= ''){
                        String unescapedHTML = answernoHTML.unescapeHtml4();
                        con.put(fieldName, unescapedHTML.replaceAll('<[^<>]*>',''));
                    }else{
                        con.put(fieldName, survey.get(fieldName));
                    }*/
                    if(survey.NPS_Type__c == Label_Marketo_NPS_Survey ){
                            if(NPSSurveyAPINames.contains(fieldName)){
                                String answer1 = (String)survey.get(fieldName);
                                if(answer1 != null && answer1.trim()!= ''){
                                    integer indexBR = answer1.indexOfAny('<br>');
                                    if(indexBR > 0){
                                        answer1 = answer1.substring(0,indexBR);
                                        if(answer1 != null && answer1.trim() != ''){
                                            con.put(fieldName, answer1.trim());
                                        }
                                    }else{
                                        con.put(fieldName,answer1);
                                    }
                                }else{
                                    con.put(fieldName,answer1);
                                }
                            }else{
                                String answernoHTML = (String)survey.get(fieldName);
                                if(answernoHTML != null && answernoHTML.trim()!= ''){
                                    con.put(fieldName, answernoHTML.replaceAll('<[/a-zAZ0-9]*>',''));
                                }else{
                                    con.put(fieldName, survey.get(fieldName));
                                }
                            }
                        }else{
                            if(DaysSurvey90.contains(fieldName)){
                                String answer1 = (String)survey.get(fieldName);
                                if(answer1 != null && answer1.trim()!= ''){
                                    integer indexBR = answer1.indexOfAny('<br>');
                                    if(indexBR > 0){
                                        answer1 = answer1.substring(0,indexBR);
                                        if(answer1 != null && answer1.trim() != ''){
                                            con.put(fieldName, answer1.trim());
                                        }
                                    }else{
                                        con.put(fieldName,answer1);
                                    }
                                }else{
                                    con.put(fieldName,answer1);
                                }
                            }else{
                                String answernoHTML = (String)survey.get(fieldName);
                                if(answernoHTML != null && answernoHTML.trim()!= ''){
                                    con.put(fieldName, answernoHTML.replaceAll('<[/a-zAZ0-9]*>',''));
                                }else{
                                    con.put(fieldName, survey.get(fieldName));
                                }
                            }
                        }
                }
                updateContacts.add(con);
                 system.debug('updateContacts');
            }
        }       
        database.update(updateContacts, false);
       system.debug('updatedContacts');
    }
    
}