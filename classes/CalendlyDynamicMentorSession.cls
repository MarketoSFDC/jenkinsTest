public class CalendlyDynamicMentorSession{

    public String caseId {get;set;}
    
    public String getmentorUrl(){
        String linkToReturn = Label.MentorSessionURL + '?'+'calendlyLink='+Label.CalendlyLinkForMentoring;    
        List<String> fieldsNames = Label.CalendlyUrlParameters.split(',');    
        try{        
            if(String.isNotBlank(caseId)){
                String queryString = 'SELECT Id,AccountId,ContactId,' + Label.CalendlyUrlParameters +' FROM Case WHERE contactId != null AND Id =\''+caseId+'\' LIMIT 1';
                Account acc;
                Contact con;
                List<Case> queriedCase = Database.query(queryString);
                if(!queriedCase.isEmpty()){
                    String parameters = '&name='+ EncodingUtil.urlEncode(queriedCase[0].Contact.Name, 'UTF-8') + '&email='+ queriedCase[0].ContactEmail;
                    String accQuery = 'SELECT Id';
                    String conQuery = 'SELECT Id';
                                
                    for(String each : fieldsNames){                        
                        if(each.startsWith('Account.')){
                            String accFieldApi = each.subStringAfter('Account.');
                            if(!accQuery.contains(accFieldApi)) accQuery += ','+accFieldApi;
                        }else if(each.startsWith('Contact.')){
                            String conFieldApi = each.subStringAfter('Contact.');
                            if(!conQuery.contains(conFieldApi)) conQuery += ','+conFieldApi;
                        }
                    }
                                       
                    if(queriedCase[0].AccountId != null && accQuery != 'SELECT Id'){
                        accQuery += ' FROM Account WHERE Id = \''+queriedCase[0].AccountId+'\'';
                        List<Account> accList = (List<Account>)Database.Query(accQuery);
                        if(!accList.isEmpty()) acc = accList[0];
                    }
                    if(queriedCase[0].ContactId != null && conQuery != 'SELECT Id'){
                        conQuery += ' FROM Contact WHERE Id = \''+queriedCase[0].ContactId+'\'';
                        List<Contact> conList = (List<Contact>)Database.Query(conQuery);
                        if(!conList.isEmpty()) con = conList[0];
                    }
                    
                    Integer i = 1;
                    for(String each : fieldsNames){
                        if(each != 'Contact.Name' && each != 'ContactEmail'){
                            if(each.startsWith('Account.') && acc != null){
                                String accFieldApi = each.subStringAfter('Account.');
                                parameters += '&a' + i + '=' + EncodingUtil.urlEncode(String.valueOf(acc.get(accFieldApi)), 'UTF-8');
                                i++;
                            }else if(each.startsWith('Contact.') && con != null){
                                String conFieldApi = each.subStringAfter('Contact.');
                                parameters += '&a' + i + '=' + EncodingUtil.urlEncode(String.valueOf(con.get(conFieldApi)), 'UTF-8');
                                i++;
                            }else{
                                parameters += '&a' + i + '=' + EncodingUtil.urlEncode(String.valueOf(queriedCase[0].get(each)), 'UTF-8');
                                i++;
                            }
                        }                        
                    }
                    linkToReturn += parameters;
                }
            }
        }catch(exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        return linkToReturn;   
    }
}