/**  Description  :  Handler class for Trigger_User trigger. 
     DEVELOPED BY : GRAZITTI
	 
	*	Ticket No        : APPS-20626
	*	Last Modified By : Grazitti Interactive
	*	Description      : Move the functionality of  Workflow Update Role Change Date through Apex Code. 
	*	Reference        : You can track changes by searching ticket number in code.

     
    * Last Modified By   : Cassandrea Steiner (Marketo) 30th April 2018
    * Reference          : Cleaned up code to make it more readable. Added call to new CFS logic for LMS project.  
    * 
    * Last Modified By   : Cassandrea Steiner (Marketo) 27th March 2018
    * Reference          : Commented the references to "addUserforSMB" method, this was used for Clarizen and is no longer needed. 
	
	* Last Modified By   : Sumit Bhatt. Grazitti Interactive
    * Reference          : added code as per ticket APPS-17919, once can track changes by searching ticket number in code 
**/
public class User_Trigger_MAIN_Handler {
public static set<id> uuroleid = new set<id>();
    /***----------------------------------------------------------------------------------------------------------------------------------
    BEFORE INSERT HANDLER----PLACE HERE YOUR CODE TO BE EXECUTE BEFORE INSERTING THE RECORDS
    -----------------------------------------------------------------------------------------------------------------------------------***/ 
    public static void beforeInsertTrigger(List<User> triggernew) {
        try{    
            if(User_Trigger_MAIN_Helper.isBeforeInsertTrigger_done) return;
            User_Trigger_MAIN_Helper.isBeforeInsertTrigger_done = true;
            User_Trigger_MAIN_Helper.initializeGlobalVariables();
            
            for(User usr : triggerNew) {
                //POPULATE USER LOCALE IN CUSTOM FIELD
                usr = User_Trigger_MAIN_Helper.populateUserLocale(usr);
                //REMOVE USER FROM CYBERU LICENSE  
                usr = User_Trigger_MAIN_Helper.removeUserFromCyberuLicense(usr); 
                //POPULATE TSE Date IN CUSTOM FIELD
                User_Trigger_MAIN_Helper.getTseDatePopulated(usr); 
				//populate User Role as per the Ticket APPS-17919
                if(usr.UserRoleid!=null){
                    uuroleid.add(usr.UserRoleid);   
                }      				
            }
		 //  ****** APPS-17919(start) *****
          if(!(uuroleid.isEmpty())){
              User_Trigger_MAIN_Helper.Updateuserrole(uuroleid,(list<user>)Trigger.new,(Map<id,user>)Trigger.oldMap);
          }
          //  ****** APPS-17919(End) *****
        }catch(Exception ex){
            
            triggernew[0].addError(ex.getMessage());
        }
    }
    
    /***----------------------------------------------------------------------------------------------------------------------------------
    BEFORE UPDATE HANDLER----PLACE HERE YOUR CODE TO BE EXECUTE BEFORE UPDATING THE RECORDS
    -----------------------------------------------------------------------------------------------------------------------------------***/ 
    public static void beforeUpdateTrigger(List<User> triggernew) {
        try{
            if(User_Trigger_MAIN_Helper.isBeforeUpdateTrigger_done) return;
            User_Trigger_MAIN_Helper.isBeforeUpdateTrigger_done = true;
            User_Trigger_MAIN_Helper.initializeGlobalVariables();
            
            for(User usr : triggerNew) {
                //POPULATE USER LOCALE IN CUSTOM FIELD
                usr = User_Trigger_MAIN_Helper.populateUserLocale(usr);
                //REMOVE USER FROM CYBERU LICENSE  
                usr = User_Trigger_MAIN_Helper.removeUserFromCyberuLicense(usr); 
				// update User Role as per the ticket APPS-17919
                    if(usr.UserRoleid!= null){
                    uuroleid.add(usr.UserRoleid);
                } 
			// APPS-20626 Populate Role Change Date Through Code Rather than (Workflow - Update Role Change Date)
                User_Trigger_MAIN_Helper.updateRoleChangeDateonupdate(usr,(Map<id,user>)Trigger.oldMap);  				
            }
			 //  ****** APPS-17919(start) *****
             if(!(uuroleid.isEmpty())){
                User_Trigger_MAIN_Helper.Updateuserrole(uuroleid,triggernew,(Map<id,user>)Trigger.oldMap);
             }
           // ******* APPS-17919 (End) ***** 
        }catch(Exception ex){            
            triggernew[0].addError(ex.getMessage());
        }    
    }
     /***----------------------------------------------------------------------------------------------------------------------------------
    AFTER INSERT HANDLER----PLACE HERE YOUR CODE TO BE EXECUTE AFTER INSERTING THE RECORDS
    -----------------------------------------------------------------------------------------------------------------------------------***/ 
    public static void afterInsertTrigger(Map<Id, User> triggernewmap) {
        try{
            //Integer i = 0;
            if(User_Trigger_MAIN_Helper.isAfterInsertTrigger_done) return;
            User_Trigger_MAIN_Helper.isAfterInsertTrigger_done = true;
            User_Trigger_MAIN_Helper.initializeGlobalVariables();
            
            for (User u : triggernewmap.values()) {  
                u = User_Trigger_MAIN_Helper.UpdateTimeZoneOnContactChecking(u); 
				u = User_Trigger_MAIN_Helper.processingUserMunchkinId(u);
                //u = User_Trigger_MAIN_Helper.MKT_CreateLMSConsumerUserProcessing(u);
                //u = User_Trigger_MAIN_Helper.DuplicateUserNameNotificationInsertionChecking(u); 
              }
            User_Trigger_MAIN_Helper.processUpdateTimeZoneOnContact();
            User_Trigger_MAIN_Helper.UpdateContactMkIdFromPortalUser();
            CfsUserTriggerHelper.onAfterInsert(triggernewmap);//Cornerstone for Salesforce LMS Logic
            /** This method was used to updated Clarizen records and is no longer needed.
            User_Trigger_MAIN_Helper.addUserforSMB(triggernewmap.Values()[0],0);//FOR SMB REPORTING
            */
            //User_Trigger_MAIN_Helper.processDuplicateUserNameNotification();
            //User_Trigger_MAIN_Helper.MKT_CreateLMSConsumerUser();
        }catch(Exception ex){     
            triggernewmap.values()[0].addError(ex.getMessage());
        }
        //CODE COMMENTED AS LMS HAS BEEN MOVED TO MERIDIAN LMS
        //User_Trigger_MAIN_Helper.addUniversityUserInLearningPassGroup(triggerNewMap, new Map<Id, User>(), true,  false);
    }
    
    /***----------------------------------------------------------------------------------------------------------------------------------
    AFTER UPDATE HANDLER----PLACE HERE YOUR CODE TO BE EXECUTE AFTER UPDATING THE RECORDS
    -----------------------------------------------------------------------------------------------------------------------------------***/ 
    public static void afterUpdateTrigger(List<User> newTrigger, Map<Id,User> triggernewmap, Map<Id,User> triggeroldmap) {
        try{
            //Integer i = 0;
            if(User_Trigger_MAIN_Helper.isAfterUpdateTrigger_done) return;
            User_Trigger_MAIN_Helper.isAfterUpdateTrigger_done = true;
            User_Trigger_MAIN_Helper.initializeGlobalVariables();

            for(User u : triggernewmap.values()) {
                u = User_Trigger_MAIN_Helper.UpdateTimeZoneOnContactChecking(u,triggeroldmap);                 
                u = User_Trigger_MAIN_Helper.processingUserMunchkinId(u, triggeroldmap); 
                u = User_Trigger_MAIN_Helper.removeLicensesOfInactiveUser(u);//REMOVE INACTIVE USER LICENSES  
                u = User_Trigger_MAIN_Helper.updateManagerOfSupportEngineerChecking(u,triggeroldmap);
            }         
            User_Trigger_MAIN_Helper.processUpdateTimeZoneOnContact(); 
            User_Trigger_MAIN_Helper.UpdateContactMkIdFromPortalUser();
            User_Trigger_MAIN_Helper.removeLicensesOfInactiveUser(); 
            User_Trigger_MAIN_Helper.UpdateManagerOfSupportEngineer();
            CfsUserTriggerHelper.onAfterUpdate(triggernewmap, triggeroldmap);//Cornerstone for Salesforce LMS Logic
            /**
            ** This method was used to updated Clarizen records and is no longer needed.
            User_Trigger_MAIN_Helper.addUserforSMB(triggernewmap.Values()[0],0);//FOR SMB REPORTING
            ** CODE COMMENTED AS LMS HAS BEEN MOVED TO MERIDIAN LMS
            User_Trigger_MAIN_Helper.addUniversityUserInLearningPassGroup(triggerNewMap, triggeroldmap, false,  true);
            */
        }catch(Exception ex){
            triggernewmap.values()[0].addError(ex.getMessage());
        }
    }    
 }