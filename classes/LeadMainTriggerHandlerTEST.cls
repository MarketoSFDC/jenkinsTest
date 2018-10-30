@isTest
public class LeadMainTriggerHandlerTEST{
    static Set<ID> leadIds = new Set<Id>();
     @testsetup static  void Method1(){
        List<Lead> leadLists = new List<Lead>();
        Lead l = new Lead();
        l.LastName = '12Test1Lead 1';
        l.Company = 'TestCompany';
        l.SDR_Owner__c = 'Aara Zakariaei';
        l.Touch_Stage__c = 'Untouched';
        l.NMQLA__c = True;
        l.Act_Now__c = True;
        l.Fresh_Lead__c = True;
        l.Email = 'gmackrell@canwest.com.full';
        l.Call_Now__c = True;
        l.Last_Act_Now_Date__c = Date.today().addDays(5);
        l.Last_Call_Now_Date__c = Date.today().addDays(4);
        l.Last_NMQLA_Created_Date__c = Date.today().addDays(3);
        l.Fresh_Lead_Date__c = Date.today().addDays(1);
        leadLists.add(l);
        
        Lead l2 = new Lead();
        l2.LastName = '12Test1Lead 2';
        l2.Company = 'TestCompany';
        l2.SDR_Owner__c = 'Aara Zakariaei';
        l2.Touch_Stage__c = 'Untouched';
        l2.NMQLA__c = True;
        l2.Fresh_Lead__c = True;
        l2.Email = 'gmackrell@canwest.com.full';
        l2.Call_Now__c = True;
        l2.Last_Act_Now_Date__c = Date.today().addDays(5);
        l2.Last_Call_Now_Date__c = Date.today().addDays(4);
        l2.Last_NMQLA_Created_Date__c = Date.today().addDays(3);
        l2.Fresh_Lead_Date__c = Date.today().addDays(1);
        leadLists.add(l2);
        
        Lead l3 = new Lead();
        l3.LastName = '12Test1Lead 3';
        l3.Company = 'TestCompany';
        l3.SDR_Owner__c = 'Aara Zakariaei';
        l3.Touch_Stage__c = 'Untouched';
        l3.NMQLA__c = True;
        l3.Email = 'gmackrell@canwest.com.full';
        l3.Fresh_Lead__c = True;
        l3.Last_Act_Now_Date__c = Date.today().addDays(5);
        l3.Last_Call_Now_Date__c = Date.today().addDays(4);
        l3.Last_NMQLA_Created_Date__c = Date.today().addDays(3);
        l3.Fresh_Lead_Date__c = Date.today().addDays(1);
        leadLists.add(l3);
        
        Lead l4 = new Lead();
        l4.LastName = '12Test1Lead 4';
        l4.Company = 'TestCompany';
        l4.SDR_Owner__c = 'Aara Zakariaei';
        l4.Touch_Stage__c = 'Call List';
        l4.Email = 'gmackrell@canwest.com.full';
        l4.Fresh_Lead__c = True;
        l4.Last_Act_Now_Date__c = Date.today().addDays(5);
        l4.Last_Call_Now_Date__c = Date.today().addDays(4);
        l4.Last_NMQLA_Created_Date__c = Date.today().addDays(3);
        l4.Fresh_Lead_Date__c = Date.today().addDays(1);
        leadLists.add(l4);
        
         Id SDRownerId;
        list<User> userList=[select id, name,Profile.Name from User where Profile.Name='Sales Development' limit 1];
        if(!userList.isEmpty()){
            for(User u:userList){
                SDRownerId=u.Id;
            }
        }
        Lead l5 = new Lead();
        l5.LastName = 'JadeTest';
        l5.Company = 'JadeGlobal';
        l5.Status='Ex-Pending';
        //l5.SDR_Owner__c = 'Aara Zakariaei';
        l5.Touch_Stage__c = 'Call List';
        l5.Email = 'gmackrell@canwest.com.full';
        l5.Fresh_Lead__c = True;
        l5.Last_Act_Now_Date__c = Date.today().addDays(5);
        l5.Last_Call_Now_Date__c = Date.today().addDays(4);
        l5.Last_NMQLA_Created_Date__c = Date.today().addDays(3);
        l5.Fresh_Lead_Date__c = Date.today().addDays(1);
        l5.ownerId=SDRownerId;
        leadLists.add(l5);
        
        
        insert leadLists;
   
    }
    static TestMethod void Method2(){
        
        list <lead> newlead=new list <lead>();
       
        for(lead ld : [select id,touch_stage__c from lead]){
        ld.touch_stage__c ='Stage 1';
        newlead.add(ld);        
        }
        Database.LeadConvert lc = new database.LeadConvert();

    lc.setLeadId(newlead.get(4).Id); 

    LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];

    lc.setConvertedStatus(convertStatus.MasterLabel); 

    Database.LeadConvertResult lcr = Database.convertLead(lc);


       

 update newlead;
    }
}