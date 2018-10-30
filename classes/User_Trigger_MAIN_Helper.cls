/**
    *	Ticket No        : APPS-20626
	*	Last Modified By : Grazitti Interactive
	*	Description      : Move the functionality of  Workflow Update Role Change Date through Apex Code. 
	*	Reference        : You can track changes by searching ticket number in code.
	
	* Last Modified By   : Sumit Bhatt Grazitti Interactive 7th June 2018
    * Reference          : Commented getSubordinateRoles, updateCustomRecord, addUserforSMB methods, these was used for Clarizen and are no longer needed. 
    * Ticket Refrence    : #APPS-19971# one can search the ticket number in code to see the changes 
	
	* Last Modified By   : Sumit Bhatt. Grazitti Interactive
    * Reference          : added code as per ticket APPS-17919, once can track changes by searching ticket number in code

**/
public class User_Trigger_MAIN_Helper{
    
    //Boolean variable to recursion in trigger execution
    public static Boolean isBeforeInsertTrigger_done = false;
    public static Boolean isBeforeUpdateTrigger_done = false;
    public static Boolean isAfterInsertTrigger_done = false;
    public static Boolean isAfterUpdateTrigger_done = false; 
    
    public static Boolean isTrigger_User_NEW_Executed = false;
    
    public static boolean isContactUpdatedrunOnce;
    
    public static Id currentUserId = UserInfo.getUserId();
    public static Set<Id> userIdsTobeUpdated;   
    public static List<Id> contactIdsToBeUpdated;
    public static Set<ID> DuplicateUserIds;
    public static Set<String> inactiveUsers = new Set<String>();    
    
    public static final Integer PACK_SIZE  = 10;    
    public static Map<String,UserTimeZoneUpdate__c> userTimeZoneMap = new Map<String,UserTimeZoneUpdate__c>(UserTimeZoneUpdate__c.getAll());
    public static Map<String,String> myMnckinLst = new Map<String,String>();
    public static List<Id> usersIdsToAddToCyberU;
    
    public static Map<string, User> supportEngineerWithManager = new Map<string, User>();
    public static Map<String, Quote_Approvers__c> quoteApproversMap = Quote_Approvers__c.getAll();

    public static void initializeGlobalVariables(){
        userIdsTobeUpdated      = new Set<Id>();
        contactIdsToBeUpdated   = new List<Id>();
        DuplicateUserIds        = new Set<ID>();
        isContactUpdatedrunOnce = true;
        usersIdsToAddToCyberU   = new List<Id>();
    }

    /**@@------------------------------------------------------------------------------
    - HELPER METHODS START HERE
    -----------------------------------------------------------------------------------@@**/   
    
    //POPULATE USER LOCALE IN CUSTOM FIELD
    public static User populateUserLocale(User usr){
        usr.User_Locale__c = usr.LocaleSidKey; 
        return usr;
    }
	
	// APPS-20626 Populate  Role Change Date Through Code Rather than (Workflow - Update Role Change Date)
    public static void updateRoleChangeDateonupdate(User usr,map<id,user> triggeroldmap){
        if((usr.Role_Group__c != null && usr.Start_Date__c < Date.Today()-integer.valueof(system.label.RolesChangeDays) && usr.Role_Group__c!= triggeroldmap.get(usr.Id).Role_Group__c) || (usr.Role_Level__c != null && usr.Start_Date__c < Date.Today()-integer.valueof(system.label.RolesChangeDays) && usr.Role_Level__c != triggeroldmap.get(usr.Id).Role_Level__c)){
        usr.Role_Change_Date__c = Date.Today();
        } 
    } // End of updateRoleChangeDateonupdate APPS-20626
    
     //POPULATE TSE Date IN CUSTOM FIELD
    public static void getTseDatePopulated(User usr){
        usr.TSE_Date__c = Date.ValueOf(System.Now()) + 56;
    }
          // Update User Role as per the ticket --- start Of APPS-17919 ------
    public static void Updateuserrole(set<id> roleids,list<user> triggernew, map<id,user> triggeroldmap){
        if(Trigger.isInsert){
            if(!(roleids.isEmpty())){ 
            Map<id,UserRole> rolemap = new Map<id,UserRole>([select id,name from UserRole where id in :roleids]);
                for(user usr : triggernew){
                    if(usr.userroleid!= null && rolemap.containskey(usr.UserRoleId)){
                        usr.User_Role__c = rolemap.get(usr.UserRoleId).Name;
                    
                    }   
                }
            }
        }
        if(Trigger.isUpdate){
            if(!(roleids.isEmpty())){
                Map<id,UserRole> rolemap = new Map<id,UserRole>([select id,name from UserRole where id in :roleids]);
                for(user usr: triggernew){
                    if((usr.UserRoleid != null&& usr.User_Role__c == null) ||(usr.UserRoleId !=triggeroldmap.get(usr.id).UserRoleId && usr.UserRoleid != null) || (usr.User_Role__c!=triggeroldmap.get(usr.Id).User_Role__c && usr.UserRoleid != null)){
                        system.debug('user trigger inside >>>>>>>>>'+rolemap.containskey(usr.UserRole.Id)+usr);
                        system.debug('>>>>>>>>>>>>>'+rolemap);
                        if(rolemap.containskey(usr.UserRoleId)){
                            usr.User_Role__c = rolemap.get(usr.UserRoleId).name;
                        }
                    }
                    else if((usr.UserRoleid !=triggeroldmap.get(usr.Id).UserRoleid && usr.UserRoleid == null)|| (usr.User_Role__c!=null && usr.UserRoleid == null)){
                        usr.User_Role__c = '';
                    }
                    
                }
            }

        }
    } // --- End Of APPS-17919 ------ 
	
    //REMOVE USER FROM CYBERU LICENSE   
    public static User removeUserFromCyberuLicense(User usr){
        if(!usr.isActive && usr.Id != currentUserId) {
            usr.lmscons__CFS_Status__c = 'Deactivated';
        }
        return usr;
    }
    
    
    public static Boolean isUpdateTimeZoneOnContactQualified(){
        if(userTimeZoneMap == null || userTimeZoneMap.size() == 0 || userTimeZoneMap.get('Setting').ActivateTimeZoneTrigger__c != true) return False; 
        If(ContactTimeZone.oneTimeUpdate == false){
            return False;
        }
        ContactTimeZone.oneTimeUpdate = false;
        return True;
    }
    
    public static User UpdateTimeZoneOnContactChecking(User usr){
        if(isUpdateTimeZoneOnContactQualified()){
            userIdsTobeUpdated.add(usr.id); 
            contactIdsToBeUpdated.add(usr.contactid);
        }
         
        return usr;
    }
    
    public static User UpdateTimeZoneOnContactChecking(User usr, Map<Id,User> oldMap){
        if(isUpdateTimeZoneOnContactQualified()){
            if(usr.TimeZoneSidKey != oldMap.get(usr.Id).TimeZoneSidKey){   
                userIdsTobeUpdated.add(usr.id); 
                contactIdsToBeUpdated.add(usr.contactid); 
            }
        }
        return usr; 
    }
    
    public static void processUpdateTimeZoneOnContact(){
        List<User> authorizedUsers = [Select Id, contactId, TimeZoneSidKey From User where 
                                                        Contact.Customer_Portal_User__c = true and
                                                        Contact.Is_Authorized_Contact__c = 'Yes' and 
                                                        Contact.Account.Type != 'Ex-Customer' and
                                                        id in:userIdsTobeUpdated];
    
        Map <Id, contact> contactIdToContact = new Map<id, contact>([Select Id, Time_Zone__c from Contact where Id IN : contactIdsToBeUpdated]);
        List<Contact> contactsToBeUpdated = new List<Contact>();
        Map<Id,String> contactIdToTimeZone = new Map<Id,String>();
        for(User usr : authorizedUsers){
            if(contactIdToContact != null && !contactIdToContact.isEmpty()){
                if(contactIdToContact.containsKey(usr.contactId)){
                    contactIdToContact.get(usr.contactId).Time_Zone__c = usr.TimeZoneSidKey;
                    contactsToBeUpdated.add(contactIdToContact.get(usr.contactId));
                }
            }
            contactIdToTimeZone.put(usr.ContactId, usr.TimeZoneSidKey);
        }
        if(trigger.isUpdate){
            if(contactsToBeUpdated != null && !contactsToBeUpdated.isEmpty()){
                update contactsToBeUpdated;
            }
        }
        if(trigger.isInsert){
            if(contactIdsToBeUpdated != null && !contactIdsToBeUpdated.isEmpty()){
                ContactTimeZone.UpdateTimeZone(contactIdsToBeUpdated,contactIdToTimeZone);
            }
        }
    }
    
    
    /*public static User MKT_CreateLMSConsumerUserProcessing(User usr){
        if (usr.lmscons__Cornerstone_ID__c == null && (usr.UserType.toLowerCase().contains('customer') || usr.IsPortalEnabled)){
            usersIdsToAddToCyberU.add(usr.Id);
        }
        return usr;
    }
    */
    /**UPDATES USER AS CONSUMERS IF Cornerstone ID IS NULL AND ISPORTALENABLED IS TRUE OR TYPE OF USER IS CUSTOMER**/
    
    /*public static void MKT_CreateLMSConsumerUser(){
        if (usersIdsToAddToCyberU.size() <= 0 || usersIdsToAddToCyberU.size() > 5) {return;}
        Id[] usrsPack = new Id[]{};
        Integer iterLeft = usersIdsToAddToCyberU.size();
          for (Id i : usersIdsToAddToCyberU) {
            iterLeft--;
            usrsPack.add(i);
            if (usrsPack.size() < PACK_SIZE && iterLeft > 0) {
              continue;
            }
            MKT_LMSConsumerUserController.SetUsersAsConsumer(usrsPack);
            usrsPack = new Id[]{};
          }
        
    }
    */
    
    //PROCESS TO POPULATE MUNCHKIN ID
    public static User processingUserMunchkinId(User usr){
        if (usr.ContactId != null && usr.Munchkin_ID__c != null) {
            myMnckinLst.put(usr.ContactId,usr.Munchkin_ID__c);
        }
        return usr;
    }
    public static User processingUserMunchkinId(User usr, Map<Id,User> oldMap){
        if(usr.Munchkin_ID__c != oldMap.get(usr.Id).Munchkin_ID__c){
            if (usr.ContactId != null && usr.Munchkin_ID__c != null && usr.IsPortalEnabled == true) {
                myMnckinLst.put(usr.ContactId,usr.Munchkin_ID__c);
            }
        }
        return usr;
    }  
     
    /**USED FOR UPDATING THE CONTACTS TIMEZONE WHEN EVER CHANGE IN MUNCHKIN ID IS THERE AND ISPORTALENABLED TO TRUE TIMEZONE IS UPDATED FOR USER  **/
    public static void UpdateContactMkIdFromPortalUser(){
        if(myMnckinLst != null && !myMnckinLst.isEmpty() && isContactUpdatedrunOnce){
            isContactUpdatedrunOnce = false;
            ContactTimeZone.updateContacts(myMnckinLst);
        } 
    }
    
    /**--- REMOVE LICENSE OF USER FROM A PACKAGE IF USER IS BEING DEACTIVATED ----**/
    public static User removeLicensesOfInactiveUser(User usr){
        if(!usr.isActive) {
            inactiveUsers.add(usr.Id);                      
        }
        return usr;
    }    
    public static void removeLicensesOfInactiveUser() {
        if(inactiveUsers != null && !inactiveUsers.isEmpty()){
            List<UserPackageLicense> usedLicenses = new List<UserPackageLicense>([SELECT Id, PackageLicenseId FROM UserPackageLicense WHERE UserId IN: inactiveUsers]);
        
            try { 
                Database.DeleteResult[] deletedLicenses = Database.delete(usedLicenses, false);
            }
            catch(Exception e){
                system.debug('EXCEPTION___'+e);
            }
        }        
    }    
    
    /***--------UPDATE SUPPORT MANAGER-------------***/
    public static User UpdateManagerOfSupportEngineerChecking(User usr, Map<Id,User> oldMap){
        if(usr.Profile_UserType__c == 'Standard' && usr.ManagerId != NULL && usr.ManagerId != oldmap.get(usr.Id).ManagerId){
            supportEngineerWithManager.put(usr.Id, usr);
        }
        return usr;
    }
    
    /**UPDATE MANEGER ID ON USER AND UPDATE THE ACTIVITY LOG WHEN MANAGER IS CHANGED **/
    public static void UpdateManagerOfSupportEngineer(){

        if(supportEngineerWithManager.isEmpty()) return; 
        List<Manger_Activity_Log__c> managerActivityLogs = new List<Manger_Activity_Log__c>([SELECT Name, SupportManager__c, TseName__c, TseName__r.Name FROM Manger_Activity_Log__c  WHERE TseName__c IN: supportEngineerWithManager.keySet()]);
        if(managerActivityLogs.isEmpty()) return;
        for(Manger_Activity_Log__c activityLog: managerActivityLogs){
            if(supportEngineerWithManager.containsKey(activityLog.TseName__c)){
                String MANG_NAME = supportEngineerWithManager.get(activityLog.TseName__c).Manager_Name__c;
                String MANG_FIRST_NAME = '';
                if(MANG_NAME != null){
                    MANG_FIRST_NAME = MANG_NAME.substring(MANG_NAME.indexOf(',')+1, MANG_NAME.Length());
                }
                activityLog.SupportManager__c = supportEngineerWithManager.get(activityLog.TseName__c).ManagerId;
                activityLog.Name = MANG_FIRST_NAME+'-'+activityLog.TseName__r.Name;
            }
            //activityLog.Name = supportEngineerWithManager.get(activityLog.TseName__c).Manager.FirstName+'-'+activityLog.TseName__r.Name;
        }
        try{
            update managerActivityLogs;
        }catch(exception e){ 
            system.debug('Exception' + e.getMessage());
            //triggerNew[0].addError(e.getMessage());
        }
    }     
    
    /**--- SMB Update Start -----*/
    /* Commented as per #APPS-19971#
    public static boolean addUserforSMB(User usr,Integer i){
        System.Debug('1>>'+System.Label.Non_SMB_Profile);
        
        String usrProfileID = usr.ProfileId;
        if(usrProfileID != null || usrProfileID != ''){
            usrProfileID = usrProfileID.subString(0,15);
        }
        System.Debug('2>>'+usrProfileID);
        if(usr.UserRoleId != null && usr.UserType == 'Standard' && !System.Label.Non_SMB_Profile.contains(usrProfileID)){
            System.Debug('!!!!!!!!!!11');
            if(i>=49) return false;            
            else{
                updateCustomRecord(usr.UserRoleId, usr.Id);
                return true;
                }
        }
        return false;
    }
    
    @future
    public static void updateCustomRecord(Id UserRoleId, Id UserId){
        Set<Id> allList = new Set<Id>();
        integer total;
        string roleLists1 ='';
        string roleLists2 ='';
        string roleLists3 ='';
        string roleLists4 ='';
        string roleLists5 ='';
        string roleLists6 ='';
        string roleLists7 ='';
        string roleLists8 ='';
        string roleLists9 ='';
        string roleLists10 ='';
        string roleLists11 ='';
        string roleLists12 ='';
        string roleLists13 ='';
        
        integer il=0;
        Set<string> allListNew = new Set<string>();
        allList.addAll(getSubordinateRoles(UserRoleId));
        String roleLists ='';
      
        total = allList.size();
        integer count = 0;
        for(string roId : allList){
            string roleListNew = roId.subString(3,15);
            if(count <19){
                roleLists1 += roleListNew+':';                    
            }else if(count>=19 && count<38){
                roleLists2 += roleListNew+':';               
            }else if(count>=38 && count<57){
                roleLists3 += roleListNew+':';               
            }
            else if(count>=57 && count<76){
                roleLists4 += roleListNew+':';               
            }else if(count>=76 && count<95){
                roleLists5 += roleListNew+':';               
            }else if(count>=95 && count<114){
                roleLists6 += roleListNew+':';               
            }else if(count>=114 && count<133){
                roleLists7 += roleListNew+':';               
            }else if(count>=133 && count<152){
                roleLists8 += roleListNew+':';               
            }else if(count>=152 && count<171){
                roleLists9 += roleListNew+':';               
            }else if(count>=171 && count<190){
                roleLists10 += roleListNew+':';               
            }else if(count>=190 && count<209){
                roleLists11 += roleListNew+':';               
            }else if(count>=209 && count<228){
                roleLists12 += roleListNew+':';               
            }else if(count>=228 && count<247){
                roleLists13 += roleListNew+':';               
            }                
            count ++;                
        }
       
        if(!String.isEmpty(roleLists1)){
            roleLists1 = roleLists1.removeEnd(':');
        }
        if(!String.isEmpty(roleLists2)){
            roleLists2 = roleLists2.removeEnd(':');
        }
        if(!String.isEmpty(roleLists3)){
            roleLists3 = roleLists3.removeEnd(':');
        }
        if(!String.isEmpty(roleLists4)){
            roleLists4 = roleLists4.removeEnd(':');
        }
        if(!String.isEmpty(roleLists5)){
            roleLists5 = roleLists5.removeEnd(':');
        }
        if(!String.isEmpty(roleLists5)){
            roleLists5 = roleLists5.removeEnd(':');
        }
        if(!String.isEmpty(roleLists6)){
            roleLists6 = roleLists6.removeEnd(':');
        }
        if(!String.isEmpty(roleLists7)){
            roleLists7 = roleLists7.removeEnd(':');
        }
        if(!String.isEmpty(roleLists8)){
            roleLists8 = roleLists8.removeEnd(':');
        }
        if(!String.isEmpty(roleLists9)){
            roleLists9 = roleLists9.removeEnd(':');
        }
        if(!String.isEmpty(roleLists10)){
            roleLists10 = roleLists10.removeEnd(':');
        }
        if(!String.isEmpty(roleLists11)){
            roleLists11 = roleLists11.removeEnd(':');
        }
        if(!String.isEmpty(roleLists12)){
            roleLists12 = roleLists12.removeEnd(':');
        }
        if(!String.isEmpty(roleLists13)){
            roleLists13 = roleLists13.removeEnd(':');
        }
        
        if(!String.isEmpty(roleLists1) && roleLists1 != ''){
            Clz_Project_Cross_Team__c ac = Clz_Project_Cross_Team__c.getInstance(UserId);
            system.debug(ac.Id);
            if(ac.Id == null){
                Clz_Project_Cross_Team__c c = new Clz_Project_Cross_Team__c(
                    SetupOwnerId = UserId,
                    My_Child_Roles__c = roleLists1,My_Child_Roles_2__c=roleLists2,My_Child_Roles_3__c=roleLists3, My_Child_Roles_4__c = roleLists4, My_Child_Roles_5__c = roleLists5, My_Child_Roles_6__c = roleLists6, My_Child_Roles_7__c = roleLists7, My_Child_Roles_8__c = roleLists8, My_Child_Roles_9__c = roleLists9, My_Child_Roles_10__c = roleLists10,
                    My_Child_Roles_11__c = roleLists11, My_Child_Roles_12__c = roleLists12, My_Child_Roles_13__c = roleLists13
                );
               
                insert c;
            }else{
                ac.My_Child_Roles__c   = roleLists1; 
                ac.My_Child_Roles_2__c = roleLists2;
                ac.My_Child_Roles_3__c = roleLists3;
                ac.My_Child_Roles_4__c = roleLists4;
                ac.My_Child_Roles_5__c = roleLists5;
                ac.My_Child_Roles_6__c = roleLists6; 
                ac.My_Child_Roles_7__c = roleLists7;
                ac.My_Child_Roles_8__c = roleLists8;
                ac.My_Child_Roles_9__c = roleLists9;
                ac.My_Child_Roles_10__c = roleLists10;
                ac.My_Child_Roles_11__c = roleLists11;
                ac.My_Child_Roles_12__c = roleLists12;
                ac.My_Child_Roles_13__c = roleLists13;
                update ac;
               
            }
        }
    }

    public static set<Id> getSubordinateRoles(Id roleId) {
        map<Id, set<Id>> parentAndChildren = new map<Id, set<Id>>();
        set<Id> children;
        for(UserRole ur : [select Id, Name, ParentRoleId from UserRole WHERE PortalType = 'None']) {
            children = parentAndChildren.containsKey(ur.ParentRoleId) ? parentAndChildren.get(ur.ParentRoleId) : new set<Id>();
            children.add(ur.Id);
            parentAndChildren.put(ur.ParentRoleId, children);
        }
        return getSubordinateRoles(roleId, parentAndChildren);
    }

    public static set<Id> getSubordinateRoles(Id roleId, map<Id, set<Id>> parentAndChildren) {
        set<Id> subordinateRoles = new set<Id>();
        set<Id> remainingSubordinateRoles = new set<Id>();
        if(parentAndChildren.containsKey(roleId)) {
            subordinateRoles.addAll(parentAndChildren.get(roleId));
            for(Id subRoleId : subordinateRoles) {
                remainingSubordinateRoles.addAll(getSubordinateRoles(subRoleId, parentAndChildren));
            }
        }
        subordinateRoles.addAll(remainingSubordinateRoles);
        return subordinateRoles;
    } Commented as per #APPS-19971# */ 
       
    /* SMB Update Ends*/
    /**@@------------------------------------------------------------------------------
    - HELPER METHODS ENDS HERE
    -----------------------------------------------------------------------------------@@**/   
    
}