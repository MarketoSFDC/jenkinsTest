public class CreateTaskTriggerController
{
    
    @future
    public static void CreateRecurringTasks(Map<Id,Id> Tasks,string type)
    {
    List<Task> tasklist = new List<task>();
        if(type == 'Elite/Key'){
        for(Id i:Tasks.keyset())
        {
           /* Task obj1 = new Task();
                obj1.Ownerid=Tasks.get(i);
                obj1.whatid=i;
                obj1.Ownerid=Tasks.get(i);
                obj1.Subject = 'Weekly Meeting Setup Needed';
                obj1.Description='Please schedule a weekly meeting with our new Elite/Key Customer!';
           //   obj1.ActivityDate=date.today()+7; 
                obj1.Isrecurrence = true;
                obj1.recurrenceStartDateOnly = date.today();
                obj1.recurrenceEndDateOnly = date.today()+364; 
                obj1.recurrencetype = 'RecursWeekly';
                obj1.RecurrenceDayOfWeekMask = 1;
                obj1.RecurrenceInterval= 1;*/
              
                
         Task obj2 = new Task();
                obj2.whatid=i;//record.id;
                obj2.Ownerid=Tasks.get(i); //record.Customer_Success_Manager__c;
                obj2.Subject = 'Monthly Instance Review';
                obj2.Description='Please schedule a monthly instance review for our Elite/Key Customer!';
              //  obj2.ActivityDate=date.today()+30; 
                obj2.Isrecurrence = true;
                obj2.recurrenceStartDateOnly = date.today();
                obj2.recurrenceEndDateOnly = date.today()+364; 
                obj2.recurrencetype = 'RecursMonthly';
              //  obj2.RecurrenceDayOfWeekMask = 1;
                obj2.RecurrenceInterval= 1; 
                obj2.RecurrenceDayOfMonth=1;
                //tasklist.add(obj1);
                tasklist.add(obj2);
             }
           }
              if(type == 'Enterprise'){
        for(Id i:Tasks.keyset())
        {
            Task obj2 = new Task();
                obj2.whatid=i;
                obj2.Ownerid=Tasks.get(i);
                obj2.Subject = 'Monthly Instance Review';
                obj2.Description='Please schedule a monthly instance review for our Elite/Key Customer!';
         //       obj2.ActivityDate=date.today()+30;
                obj2.Isrecurrence = true;
                obj2.recurrenceStartDateOnly = date.today();
                obj2.recurrenceEndDateOnly = date.today()+364; 
                obj2.recurrencetype = 'RecursMonthly' ;
                obj2.RecurrenceDayOfMonth = 1;
                obj2.RecurrenceInterval= 1;
                Tasklist.add(obj2);
             }
           }   
               
       if(tasklist.size()>0)         
       insert tasklist;       
                
    }
    public static testmethod void futuretesting(){
    Account acc= new account();
    acc.name='Test Account';
    acc.CurrencyIsoCode='USD';
    //acc.Customer_Success_Manager__c=userinfo.getuserid();
    //acc.CSM_Trigger__c = 'Elite/Key' ;
    insert acc;
    
    map<id,id> createrec = new map<id,id>();
    createrec.put(acc.id,userinfo.getuserid());
    CreateRecurringTasks(createrec,'Elite/Key');
    CreateRecurringTasks(createrec,'Enterprise');
    
    
   // CreateRecurringTasks(Map<Id,Id> Tasks,string type)

    }
}