/************************************************************************
Updated by: Jade Global Inc.
Updated On: 4th June 2017
Updated for: 
# Reference:Added Code for SDR Owner Functinality
# Jira Ticket: APPS-13173: Tasks in the Requirement document for Sprint 4
*************************************************************************/

public class LeadMainTriggerHandler{

    public static boolean isBeforeInsertDone = false;
    public static boolean isBeforeUpdateDone = false;
    public static set<Id> SDROwnerId=new set<Id>();
    public static Map<Id,User> SDROwnerMapNew=new  Map<Id,User>();
    

    public static void BeforeInsertHandler(List<Lead> newList){
        populateSDROwneronLead(newList,null);  
    }
    
    public static void BeforeUpdateHandler(List<Lead> newList, Map<Id,Lead> oldMap){
        populateSDROwneronLead(newList,oldMap);
        populateStageBeforeTouchOnLead(newList, oldMap);
    }
    
     /************************************************************************************
     * Last modified By    :Snehal Khot, Jade Global Inc.
     * Last modified Date  :16th May 2017
     * Change              : Updating below fields base on lead owner profile/Role
     *                      SDR_Owner__c,SDR_Owner_Lookup__c.SDR_Owner_Email__c
     * 
     ***********************************************************************************/
    public static void populateSDROwneronLead(List<Lead> newList, Map<Id,Lead> leadOldMap){
        for(Lead ld : newList){                    
            if(ld.SDR_Owner_Lookup__c != ld.OwnerId && string.valueOf(ld.OwnerId).startsWith('005') ){     
               SDROwnerId.add(ld.OwnerId);
                if(ld.SDR_Owner_Lookup__c!=null){
                    SDROwnerId.add(ld.SDR_Owner_Lookup__c);
                }
            }// End of If            
        }// End of For
        
        if(!SDROwnerId.isEmpty()){
            Id SalesDevId=Label.Sales_Development;
            String SDR=Label.SDR;
            SDROwnerMapNew=new Map<Id,User>([SELECT id,name,Email,Profile.Name,ProfileId,UserRole.Name FROM User WHERE Id IN: SDROwnerId AND ( ProfileId=:SalesDevId OR UserRole.Name LIKE '%SDR%' )]);
            
            if(!SDROwnerMapNew.isEmpty()){    
               for(Lead ld : newList){ 
                    if(ld.SDR_Owner_Lookup__c != ld.OwnerId){
                        id SDRUserId = ld.OwnerId;
                        if(ld.SDR_Owner_Lookup__c!=null && !leadOldMap.isEmpty() && leadOldMap.get(ld.id).SDR_Owner_Lookup__c!=ld.SDR_Owner_Lookup__c){
                            SDRUserId  = ld.SDR_Owner_Lookup__c;
                        }//End of IF block of SDR_Owner_Lookup__c 
                        if(SDROwnerMapNew.ContainsKey(SDRUserId)){
                            User u= SDROwnerMapNew.get(SDRUserId);                                    
                                   ld.SDR_Owner__c          = u.name;
                                   ld.SDR_Owner_Lookup__c   = u.id;
                                   ld.SDR_Owner_Email__c    = u.Email;                                       
                        }// End of IF  
                    }//End of IF block of owner and SDR equals check
                 } // End of FOR loop of Lead 
            }//End of IF -SDROwnerMapNew IS EMPTY check
        }//End of IF -SDROwnerId IS NOT EMPTY check
    }// End of populateSDROwneronLead()
    
    public static void populateStageBeforeTouchOnLead(List<Lead> newList, Map<Id,Lead> oldMap){
        String TOUCH_STAGE_UNTOUCHED = 'Untouched';
        String TOUCH_STAGE_CALL_LIST = 'Call List';
        String s_ACT_NOW             = 'Act Now';
        String s_CALL_NOW            = 'Call Now';
        String s_MQL                 = 'MQLA';
        String s_FRESH_LEAD          = 'Fresh Lead';
        String s_EVERYTHING_ELSE     = 'Everything Else';
        String s_LEAD_STATUS         = 'Recycled';
        String s_NEW_LEAD_STATUS     = 'Lead';
        String TO_VALID_TOUCH_STAGE  = System.Label.Valid_Touch_Stage;
        Date TODAY_DATE = Date.today();
        
        for(Lead ld : newList){
            System.Debug('########'+ld.Touch_Stage__c);
            if(oldMap.get(ld.Id).Touch_Stage__c != ld.Touch_Stage__c && (oldMap.get(ld.Id).Touch_Stage__c == TOUCH_STAGE_UNTOUCHED || oldMap.get(ld.Id).Touch_Stage__c == TOUCH_STAGE_CALL_LIST ) && TO_VALID_TOUCH_STAGE.contains(ld.Touch_Stage__c)){    
            String TO_POPULATE;
                if(ld.Act_Now__c || ld.Call_Now__c || ld.NMQLA__c || ld.Fresh_Lead__c){
                    
                    boolean ACT_NOW         = ld.Act_Now__c;
                    boolean CALL_NOW        = ld.Call_Now__c;
                    boolean MQL             = ld.NMQLA__c;
                    boolean FRESH_LEAD      = ld.Fresh_Lead__c;
                    Date ACT_NOW_DATE       = ld.Last_Act_Now_Date__c;
                    Date CALL_NOW_DATE      = ld.Last_Call_Now_Date__c;
                    Date MQL_DATE           = ld.Last_NMQLA_Created_Date__c;
                    Date FRESH_LEAD_DATE    = ld.Fresh_Lead_Date__c;
                    Date TO_COMPARE;
                    
                    
                    if(ACT_NOW){
                        if(ACT_NOW_DATE != null){TO_COMPARE = ACT_NOW_DATE;}else{TO_COMPARE = TODAY_DATE.addYears(999);}
                        TO_POPULATE = s_ACT_NOW;
                        
                        if(CALL_NOW){
                            if(TO_COMPARE > CALL_NOW_DATE && CALL_NOW_DATE != null){
                                TO_COMPARE = CALL_NOW_DATE;
                                TO_POPULATE = s_CALL_NOW;
                            }
                        }
                        if(MQL){
                            if(TO_COMPARE > MQL_DATE && MQL_DATE != null){
                                TO_COMPARE = MQL_DATE;
                                TO_POPULATE = s_MQL;
                            }
                        }
                        if(FRESH_LEAD){
                            if(TO_COMPARE > FRESH_LEAD_DATE && FRESH_LEAD_DATE != null){
                                TO_COMPARE = FRESH_LEAD_DATE;
                                TO_POPULATE = s_FRESH_LEAD;
                            }
                        }
                    }else if(CALL_NOW){
                        if(CALL_NOW_DATE != null){TO_COMPARE = CALL_NOW_DATE;}else{TO_COMPARE = TODAY_DATE.addYears(999);}
                        TO_POPULATE = s_CALL_NOW;
                        
                        if(MQL){
                            if(TO_COMPARE > MQL_DATE && MQL_DATE != null){
                                TO_COMPARE = MQL_DATE;
                                TO_POPULATE = s_MQL;
                            }
                        }
                        if(FRESH_LEAD){
                            if(TO_COMPARE > FRESH_LEAD_DATE && FRESH_LEAD_DATE != null){
                                TO_COMPARE = FRESH_LEAD_DATE;
                                TO_POPULATE = s_FRESH_LEAD;
                            }
                        }
                    }else if(MQL){
                        if(MQL_DATE != null){TO_COMPARE = MQL_DATE;}else{TO_COMPARE = TODAY_DATE.addYears(999);}
                        TO_POPULATE = s_MQL;
                        
                        if(FRESH_LEAD){
                            if(TO_COMPARE > FRESH_LEAD_DATE && FRESH_LEAD_DATE != null){
                                TO_COMPARE = FRESH_LEAD_DATE;
                                TO_POPULATE = s_FRESH_LEAD;
                            }
                        }
                    }else if(FRESH_LEAD){
                        TO_POPULATE = s_FRESH_LEAD;
                    }
                }
                else{
                    TO_POPULATE = s_EVERYTHING_ELSE;
                }
                //ld.Status_Before_Touch__c = TO_POPULATE;
            }
            /*if(ld.Status_Before_Touch__c != null && oldMap.get(ld.Id).Status == s_LEAD_STATUS && ld.Status == s_NEW_LEAD_STATUS){
                ld.Status_Before_Touch__c = '';
            }*/
        }
    }
    
    
    public static void SetPrimaryContact (List<Lead> newList, Map<Id,Lead> oldMap){
        Map<Id,Lead> qualifiedLeads = new Map<Id,Lead>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        Map<Id, Contact> convertedContactMap = new Map<Id,Contact>();
        for(Lead ld : newList){
            if(ld.isConverted == true && oldMap.get(ld.Id).isConverted == false){
                if(ld.ConvertedOpportunityId != null && ld.ConvertedContactId != null){
                    qualifiedLeads.put(ld.Id, ld);
                    oppIds.add(ld.ConvertedOpportunityId);
                    conIds.add(ld.ConvertedContactId);
                    if(ld.HasOptedOutOfEmail){
                        Contact con = new Contact(ID = ld.ConvertedContactId);
                        con.HasOptedOutOfEmail = ld.HasOptedOutOfEmail;
                        convertedContactMap.put(con.Id,con);
                    }
                }
            }
        }
        if(!qualifiedLeads.isEmpty()){
            List<OpportunityContactRole> ocrListToUpdate = new List<OpportunityContactRole>();
            for(OpportunityContactRole ocr : [SELECT Id,IsPrimary FROM OpportunityContactRole WHERE OpportunityId IN : oppIds and ContactId IN :conIds]){
                ocr.IsPrimary = true;
                ocrListToUpdate.add(ocr);
            }
            if(!ocrListToUpdate.isEmpty()){
                update ocrListToUpdate;
            }
        }
        if(!convertedContactMap.isEmpty()){
            update convertedContactMap.values();
        }
    }
    
    
    
}