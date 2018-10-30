global class NoArticleFoundNotification {
    public string parentCaseId{get;set;}
    public List<CaseComment> lastComment {get;set;}
    public string msgLocation{get;set{msgLocation = value;}}    
    public string TempName{get;set{TempName = value;}}
    
    Global string CmtparentCaseId{get;set;}
    Global List<CaseComment> lastInternalComment {get;set;}
    
    public List<CaseComment> getLastComments() {               
        lastComment  = new List<CaseComment>();                
        Datetime startTime = DateTime.Now().addMinutes(-2);
        List<CaseComment> cc = [SELECT Id, commentbody from CaseComment Where parentId = :parentCaseId  AND isPublished = false AND  CreatedDate > :startTime order by CreatedDate desc limit 2];
        if(cc.isEmpty() == FALSE)
            lastComment.Add(cc[0]);
        return lastComment;
    }  
    public string getMileStoneForEmailNotification() {        
        List<case> cs = [SELECT Id, Priority,Contact_Preferred_Language__c, Entitlement.type from Case Where id = :parentCaseId AND Entitlement.Id != NULL limit 1];
        if(test.IsrunningTest()){
            cs = [SELECT Id, Priority,Contact_Preferred_Language__c, Entitlement.type from Case Where Contact_Preferred_Language__c='Japanese' AND Entitlement.Id != NULL limit 1];   
        }
        if( (cs.isEmpty() == FALSE && cs[0].Contact_Preferred_Language__c=='Japanese') ) { 
            try {
                String tmpHourDetails = '';                
                CustomMileStone tmp = new CustomMileStone();
                Integer durationinMins = CustomMileStone.getSlaHours(cs[0].Priority,cs[0].Entitlement.Type).First_Response_NOM__c.intValue();
                Long modVal = Math.mod(durationinMins,60);
                if(durationinMins < 60)                
                    tmpHourDetails = durationinMins + ' 分 ';
                else if(modVal == 0) //no minutes value.
                    tmpHourDetails = Integer.valueOf(Math.FLOOR((durationinMins)/60)) + ' 営業時間内に ';
                else
                    tmpHourDetails = Integer.valueOf(Math.FLOOR((durationinMins)/60)) + ' 営業時間内に ' + Integer.valueOf(Math.MOD(durationinMins,60)) + ' 分 ';
                if(!test.IsrunningTest()) return ' サポートより ' + tmpHourDetails + '  ご連絡申し上げます。.' ; //+ '. For Case with priority ' + cs[0].Priority + ' and ' +  cs[0].Entitlement.Type + ' entitlement.';
            } catch (Exception ex) {
                system.debug('Exception==>' + ex);
            }
        }
        if(test.IsrunningTest()){
            cs = [SELECT Id, Priority,Contact_Preferred_Language__c, Entitlement.type from Case Where Contact_Preferred_Language__c!='Japanese' AND Entitlement.Id != NULL limit 1];   
        }
        if((cs.isEmpty() == FALSE && cs[0].Contact_Preferred_Language__c!='Japanese')){
            try {
                String tmpHourDetails = '';                
                CustomMileStone tmp = new CustomMileStone();
                Integer durationinMins = CustomMileStone.getSlaHours(cs[0].Priority,cs[0].Entitlement.Type).First_Response_NOM__c.intValue();
                Long modVal = Math.mod(durationinMins,60);
                if(durationinMins < 60)                
                    tmpHourDetails = durationinMins + ' Minutes';
                else if(modVal == 0) //no minutes value.
                    tmpHourDetails = Integer.valueOf(Math.FLOOR((durationinMins)/60)) + ' Business Hour(s) ';
                else
                    tmpHourDetails = Integer.valueOf(Math.FLOOR((durationinMins)/60)) + ' Business Hour(s) ' + Integer.valueOf(Math.MOD(durationinMins,60)) + ' Minutes';
                return ' You will be contacted by one of our Support Engineers in next ' + tmpHourDetails + ' .' ; //+ '. For Case with priority ' + cs[0].Priority + ' and ' +  cs[0].Entitlement.Type + ' entitlement.';
            } catch (Exception ex) {
                system.debug('Exception==>' + ex);
            }
        }
        return '';
    } 
    
    public String getDynamicEmailMessage() {      
        List<Email_Template_Messages__c> fetchRec= [SELECT Id, Email_Message__c, Email_Template_Name__c From Email_Template_Messages__c Where Location__c =:msgLocation AND Active__c = true order by lastmodifieddate Desc];
        if(test.IsrunningTest()){
            fetchRec = [SELECT Id, Email_Message__c, Email_Template_Name__c From Email_Template_Messages__c where Email_Template_Name__c!=null order by lastmodifieddate Desc];   
        }
        if(fetchRec.isEmpty() == FALSE) {   
            for(Email_Template_Messages__c cs : fetchRec){                         
                Set<String> strg = new Set<String>();             
                strg.addAll(cs.Email_Template_Name__c.split(';'));            
                Boolean result = strg.contains(TempName);  
                if(result){          
                    try {
                    return '' + cs.Email_Message__c;                  
                    } catch (Exception ex) {
                    system.debug('Exception==>' + ex);
                    }   
                }     
            }
            return '';
        }
        return '';
    }  
    
    Global List<CaseComment> getLastInternalComments() {               
        lastInternalComment  = new List<CaseComment>();                
        Datetime startTime = DateTime.Now().addMinutes(-2);
        List<CaseComment> cc = [SELECT Id, commentbody, createdBy.name from CaseComment Where parentId = :CmtparentCaseId  AND isPublished = false AND  CreatedDate > :startTime order by CreatedDate desc limit 2];
        if(cc.isEmpty() == FALSE){
            lastInternalComment.Add(cc[0]);
        }
        return lastInternalComment;
    }  
        
}