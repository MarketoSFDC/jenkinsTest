/**
If current version have type field equals to 'CSM - Upsell Product Only' or 'CSM - Upsell Services/Education /Support' then this trigger used to create a 
clone of current version of Task record in TaskClone__c Object.On TaskClone__c Workflow email alert works
that send an email to sales or service department based on Type field.
**/
trigger IdentifyUpsellOpportunity on Task (after insert, after update) {
    static final String CSMUPSELLPRODUCTONLY = 'CSM – Upsell/Cross sell Product';
    static final String CSMUPSELLSERVICES = 'CSM - Upsell/Cross sell Services';
    //List<TaskClone__c> taskListtoBeInsert = new List<TaskClone__c>();
    //List<TaskClone__c> taskListtoBeUpadate = new List<TaskClone__c>();
    Set<String> tasksIds = new Set<String>();
    String serviceMailAdress = '' ;
    
    List<OrgWideEmailAddress> serviceAdress = [select Address,DisplayName from OrgWideEmailAddress where Address = 'services@marketo.com' limit 1];
    if(!serviceAdress.isEmpty()){serviceMailAdress = serviceAdress[0].Address;}else{serviceMailAdress = 'services@marketo.com';}
    Map<String,string> emailOfContactOrLead = new  Map<String,string>();
    List<String> userIds = new List<String>();
    Set<String> accountOwnerId = new Set<String>();
    for(Task tsk : Trigger.New){
       if(tsk.Type!=null && (tsk.Type.equalsIgnoreCase(CSMUPSELLPRODUCTONLY)|| tsk.Type.equalsIgnoreCase(CSMUPSELLSERVICES))){
            if(tsk.Type.equalsIgnoreCase(CSMUPSELLPRODUCTONLY) && tsk.WhatId != null){
                accountOwnerId.add(tsk.WhatId);
            }
            tasksIds.add(tsk.Id);
            userIds.add(tsk.OwnerId);
       }
    }
    Map<String, Account> accountOwnerInfoMap = new Map<String, Account>();
    for(Account acc : [select Id, Owner.Name,OwnerId,Owner.Email from account where Id in :accountOwnerId]){
        accountOwnerInfoMap.put(acc.Id, acc);
    }
    //List<TaskClone__c> updatedTaskList = [select Id,TaskId__c,Comments__c,Assigned_to_user__c from TaskClone__c where TaskId__c in : tasksIds];
    //Map<String, TaskClone__c> taskMap = new Map<String, TaskClone__c>();
    /*for(TaskClone__c tskCloned : updatedTaskList ){
       taskMap.put(tskCloned.TaskId__c,tskCloned); 
    }*/
    List<Task> TaskList = [select Type,Subject,Description,CreatedBy.Email,Owner.Email,Owner.Name,Who.Name,What.Name,Status from Task where Id in : tasksIds];
    for(Task tsk : TaskList){
        /*if(taskMap.containsKey(tsk.Id)){//After Update
            //TaskClone__c task = taskMap.get(tsk.Id);
            task.Id = taskMap.get(tsk.Id).Id;
            task = insertOrUpdate( task,tsk);
            if(task!=null)
            taskListtoBeUpadate.add(task);
        }else{//After Insert
            //TaskClone__c task = new TaskClone__c();
            task = insertOrUpdate( task,tsk);
            if(task!=null)
            //taskListtoBeInsert.add(task);
        }*/
    }
    try{//insert record in TaskClone__c object 
        /*if(!taskListtoBeInsert.isEmpty())
        insert taskListtoBeInsert;*/
    }catch(Exception e){}
    try{ //Update record in TaskClone__c object 
        /*if(!taskListtoBeUpadate.isEmpty())
        update taskListtoBeUpadate ;*/
    }catch(Exception e){}
    
     /*This return TaskClone record that may update or insert */
    /*public TaskClone__c insertOrUpdate(TaskClone__c task,Task tsk){
      if(tsk.Type.equalsIgnoreCase(CSMUPSELLPRODUCTONLY)){
        task.Email__c = accountOwnerInfoMap.get(tsk.WhatId).Owner.Email;
        task.Type__c = tsk.Type;
        task.TaskId__c = tsk.Id;
        task.subject__c = tsk.Subject;
        task.Comments__c = tsk.Description;
        task.Assigned_to_user__c = tsk.OwnerId;
        task.RelatedTo__c = tsk.What.Name;
        task.RelatedTo_Id__c = tsk.WhatId;
        task.WhoName__c = tsk.Who.Name;
        task.Status__c = tsk.Status;
        task.User_Email__c = tsk.Owner.Email;
        task.Account_Owner__c = accountOwnerInfoMap.get(tsk.WhatId).Owner.Id;
        task.Account_Owner_Mail__c = accountOwnerInfoMap.get(tsk.WhatId).Owner.Email;
        task.Call_Logged_By__c = tsk.CreatedBy.Email;
        
        if(tsk.WhoId != null){
            if(String.valueOf(tsk.WhoId).startsWith('003')){
            task.ContactId__c = tsk.WhoId;task.LeadId__c = null;
            }else
            if(tsk.WhoId != null && String.valueOf(tsk.WhoId).startsWith('00Q')){
            task.LeadId__c = tsk.WhoId;task.ContactId__c = null;}
        }else{task.LeadId__c = null;task.ContactId__c = null;}
        
     }else if(tsk.Type.equalsIgnoreCase(CSMUPSELLSERVICES)){
        task.Email__c = serviceMailAdress;
        task.Type__c = tsk.Type;
        task.TaskId__c = tsk.Id;
        task.subject__c = tsk.Subject;
        task.Comments__c = tsk.Description;
        task.Assigned_to_user__c = tsk.OwnerId;
        task.RelatedTo__c = tsk.What.Name;
        task.RelatedTo_Id__c = tsk.WhatId;
        task.WhoName__c = tsk.Who.Name;
        task.Status__c = tsk.Status;
        task.User_Email__c = tsk.Owner.Email;
        task.Account_Owner__c = null;
        task.Account_Owner_Mail__c = null;
        task.Call_Logged_By__c = null;
        if(tsk.WhoId != null){
            if(String.valueOf(tsk.WhoId).startsWith('003')){
            task.ContactId__c = tsk.WhoId;task.LeadId__c = null;
            }else
            if(tsk.WhoId != null && String.valueOf(tsk.WhoId).startsWith('00Q')){
            task.LeadId__c = tsk.WhoId;task.ContactId__c = null;}
        }else{task.LeadId__c = null;task.ContactId__c = null;}
     }
     system.debug(task+'==2'+tsk+'==');
     return task;
    }*/
 }