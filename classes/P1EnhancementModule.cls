Public class P1EnhancementModule{
    
    public static map<string,string> lastNofifiedMap = new map<string,string>{'null' => 'Lead', 'Lead' => 'Manager', 'Manager' => 'Director', 'Director' => 'VP'};
    public static map<string,string> OwnerMap = new map<string,string>{'null' => 'TSE', 'TSE' => 'Lead', 'Lead' => 'Manager', 'Manager' => 'Director', 'Director' => 'VP'};
    
    public static void p1MilestoneTracking(){
        dateTime nowTime = System.now();
        list<Case_Update_Milestones__c> milestoneList = new list<Case_Update_Milestones__c>();
        list<Case_Update_Milestones__c> milestonesToBeVerified   = new list<Case_Update_Milestones__c>();
        milestonesToBeVerified = database.query(label.P1DynamicQuery); 
        system.Debug('+++++++++++ milestonesToBeVerified +++++++++++'+milestonesToBeVerified +milestonesToBeVerified.size());
        for(Case_Update_Milestones__c mileStone : milestonesToBeVerified){
            if(String.Valueof(mileStone.case__r.OwnerID).startsWithIgnoreCase('005')){
                Case_Update_Milestones__c mile = operatingMilestone(mileStone);
                system.debug('mile ===>>>>'+mile);
                if(mile !=null){
                    milestoneList.add(mile);    
                }
            }            
        }
        system.debug('milestoneList===>>>>>>'+milestoneList +milestoneList.size());
        if(!milestoneList.IsEmpty()){
            update milestoneList;
        }       
    }

    public static Case_Update_Milestones__c operatingMilestone(Case_Update_Milestones__c CM){        
        decimal pctViolationTime = ((System.Now().getTime())/1000/60) - ((CM.Target_Date__c.getTime())/1000/60);
        system.debug('pctViolationTime ===>>>>'+pctViolationTime + '  CM.Milestone_Type__c===>>>>>'+CM.Milestone_Type__c +' CM.Completed__c==>>>'+CM.Completed__c + 'CM.Checked_In_Scheduler==>>>' +CM.Checked_In_Scheduler__c);
        system.debug('CM.OwnerID'+CM.OwnerID + '  CM.Case_TSE__r.ManagerID==>>'+CM.Case_TSE__r.ManagerID);
        
        system.debug('CMO - '+CM.Owner__c+'-CUO-'+CM.Current_User_Owner__c+'-COM-'+CM.case__r.Case_Owner_Manager_ID__c);
        if(CM.Milestone_Type__c == 'First Response') {
            if(CM.Completed__c == false && CM.Checked_In_Scheduler__c == false){
                CM.Checked_In_Scheduler__c = true;
                CM.Last_Notified__c = lastNofifiedMap.containsKey(CM.Last_Notified__c) ? lastNofifiedMap.get(CM.Last_Notified__c) : 'Lead';
                if(CM.Current_User_Owner__c == null ){
                    CM.Current_User_Owner__c = CM.case__r.OwnerId;
                }else {
                    CM.Current_User_Owner__c = CM.case__r.Case_Owner_Manager_ID__c;
                }
                if(CM.Case_TSE__c == null ) if(CM.Case_TSE__c == null ) CM.Case_TSE__c = CM.case__r.OwnerID;
                CM.Owner__c = OwnerMap.containsKey(CM.Owner__c) ? OwnerMap.get(CM.Owner__c) : 'TSE';
                CM.Notifying_User__c = CM.Notifying_User__c == null ? CM.case__r.Case_Owner_Manager_ID__c : CM.Notifying_User__r.ManagerID;
                if(CM.Case_Milestone_Updates__c != null){
                    CM.Case_Milestone_Updates__c += '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }else{
                    CM.Case_Milestone_Updates__c = '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }
                return CM;
            }else if(CM.Completed__c == false && CM.Checked_In_Scheduler__c == true && ( (pctViolationTime > 30 && pctViolationTime < 35) || (pctViolationTime > 60 && pctViolationTime < 65) || (pctViolationTime > 120 && pctViolationTime < 125) )){
                CM.Checked_In_Scheduler__c = true;
                if(CM.Current_User_Owner__c == null ){
                    CM.Current_User_Owner__c = CM.case__r.OwnerId;
                }else {
                    CM.Current_User_Owner__c = CM.case__r.Case_Owner_Manager_ID__c;
                }
                CM.Last_Notified__c = lastNofifiedMap.containsKey(CM.Last_Notified__c) ? lastNofifiedMap.get(CM.Last_Notified__c) : 'Lead';
                if(CM.Case_TSE__c == null ) CM.Case_TSE__c = CM.case__r.OwnerID;
                CM.Owner__c = OwnerMap.containsKey(CM.Owner__c) ? OwnerMap.get(CM.Owner__c) : 'TSE';
                CM.Notifying_User__c = CM.Notifying_User__c == null ? CM.case__r.Case_Owner_Manager_ID__c : CM.Notifying_User__r.ManagerID;
                if(CM.Case_Milestone_Updates__c != null){
                    CM.Case_Milestone_Updates__c += '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }else{
                    CM.Case_Milestone_Updates__c = '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }
                return CM;
            }else if(CM.Completed__c == true && CM.Checked_In_Scheduler__c == true && ( (pctViolationTime > 30 && pctViolationTime < 35) || (pctViolationTime > 60 && pctViolationTime < 65) || (pctViolationTime > 120 && pctViolationTime < 125) )){
                CM.Checked_In_Scheduler__c = true;
                if(CM.Current_User_Owner__c == null ){
                    CM.Current_User_Owner__c = CM.case__r.OwnerId;
                }else {
                    CM.Current_User_Owner__c = CM.case__r.Case_Owner_Manager_ID__c;
                }
                CM.Last_Notified__c = lastNofifiedMap.containsKey(CM.Last_Notified__c) ? lastNofifiedMap.get(CM.Last_Notified__c) : 'Lead';
                if(CM.Case_TSE__c == null ) CM.Case_TSE__c = CM.case__r.OwnerID;
                CM.Owner__c = OwnerMap.containsKey(CM.Owner__c) ? OwnerMap.get(CM.Owner__c) : 'TSE';
                CM.Notifying_User__c = CM.Notifying_User__c == null ? CM.case__r.Case_Owner_Manager_ID__c : CM.Notifying_User__r.ManagerID; 
                if(CM.Case_Milestone_Updates__c != null){
                    CM.Case_Milestone_Updates__c += '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }else{
                    CM.Case_Milestone_Updates__c = '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }
                return CM;     
            }            
        }else if(CM.Milestone_Type__c == 'Case Update'){
            if(CM.Completed__c == false && CM.Checked_In_Scheduler__c == false){
                CM.Checked_In_Scheduler__c = true;
                if(CM.Current_User_Owner__c == null ){
                    CM.Current_User_Owner__c = CM.case__r.OwnerId;
                }else {
                    CM.Current_User_Owner__c = CM.case__r.Case_Owner_Manager_ID__c;
                }
                CM.Last_Notified__c = lastNofifiedMap.containsKey(CM.Last_Notified__c) ? lastNofifiedMap.get(CM.Last_Notified__c) : 'Lead';
                if(CM.Case_TSE__c == null ) CM.Case_TSE__c = CM.case__r.OwnerID;
                CM.Owner__c = OwnerMap.containsKey(CM.Owner__c) ? OwnerMap.get(CM.Owner__c) : 'TSE';
                CM.Notifying_User__c = CM.Notifying_User__c == null ? CM.case__r.Case_Owner_Manager_ID__c : CM.Notifying_User__r.ManagerID;
                if(CM.Case_Milestone_Updates__c != null){
                    CM.Case_Milestone_Updates__c += '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }else{
                    CM.Case_Milestone_Updates__c = '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }
                return CM;
            }else if(CM.Completed__c == false && CM.Checked_In_Scheduler__c == true && ( (pctViolationTime > 60 && pctViolationTime < 65 ) || (pctViolationTime > 120 && pctViolationTime < 125) || (pctViolationTime > 240 && pctViolationTime < 245) ) ){
                CM.Checked_In_Scheduler__c = true;
                if(CM.Current_User_Owner__c == null ){
                    CM.Current_User_Owner__c = CM.case__r.OwnerId;
                }else {
                    CM.Current_User_Owner__c = CM.case__r.Case_Owner_Manager_ID__c;
                }
                CM.Last_Notified__c = lastNofifiedMap.containsKey(CM.Last_Notified__c) ? lastNofifiedMap.get(CM.Last_Notified__c) : 'Lead';
                if(CM.Case_TSE__c == null ) CM.Case_TSE__c = CM.case__r.OwnerID;
                CM.Owner__c = OwnerMap.containsKey(CM.Owner__c) ? OwnerMap.get(CM.Owner__c) : 'TSE';
                CM.Notifying_User__c = CM.Notifying_User__c == null ? CM.case__r.Case_Owner_Manager_ID__c : CM.Notifying_User__r.ManagerID;
                if(CM.Case_Milestone_Updates__c != null){
                    CM.Case_Milestone_Updates__c += '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }else{
                    CM.Case_Milestone_Updates__c = '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }
                return CM;
            }else if(CM.Completed__c == true && CM.Checked_In_Scheduler__c == true && ( (pctViolationTime > 60 && pctViolationTime < 65 ) || (pctViolationTime > 120 && pctViolationTime < 125) || (pctViolationTime > 240 && pctViolationTime < 245) ) ){
                CM.Checked_In_Scheduler__c = true;
                if(CM.Current_User_Owner__c == null ){
                    CM.Current_User_Owner__c = CM.case__r.OwnerId;
                }else {
                    CM.Current_User_Owner__c = CM.case__r.Case_Owner_Manager_ID__c;
                }
                CM.Last_Notified__c = lastNofifiedMap.containsKey(CM.Last_Notified__c) ? lastNofifiedMap.get(CM.Last_Notified__c) : 'Lead';
                if(CM.Case_TSE__c == null ) CM.Case_TSE__c = CM.case__r.OwnerID;
                CM.Owner__c = OwnerMap.containsKey(CM.Owner__c) ? OwnerMap.get(CM.Owner__c) : 'TSE';
                CM.Notifying_User__c = CM.Notifying_User__c == null ? CM.case__r.Case_Owner_Manager_ID__c : CM.Notifying_User__r.ManagerID;   
                if(CM.Case_Milestone_Updates__c != null){
                    CM.Case_Milestone_Updates__c += '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }else{
                    CM.Case_Milestone_Updates__c = '\n Escalation at '+system.now()+ ' Notification sent to: '+CM.Last_Notified__c+ ' AND Case Owner: '+CM.Owner__c;
                }
                return CM;  
            }
        }
        return null;    
    }
    
}