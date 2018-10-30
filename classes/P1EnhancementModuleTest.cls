@isTest
public class P1EnhancementModuleTest{

     static{
        Support_Switches__c sw9 = new Support_Switches__c();
        sw9.Name = 'CsmNotificationModule';
        sw9.Isactive__C = 'Yes';
        insert sw9;
        
     }
    
    public static testmethod void P1EnhancementTestMethod1(){
        Case c1 =  new case();
        c1.status = 'New';
        c1.priority = 'P1';
        c1.Problem_Type__c = 'How-to';
        c1.Category__c= 'ABN';
        c1.Sub_Category__c = 'Munchkin';
        c1.recordtypeid ='01250000000UJwx';
        insert c1;
        
        Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c ();
        cm2.case__c = c1.id;        
        cm2.Milestone_Type__c = 'First Response';
        cm2.Start_Date__c = System.Now().addMinutes(-30);
        cm2.Target_Date__c = System.Now().addMinutes(-4);        
        insert cm2;
        EveryFiveMinuteScheduler sch = new EveryFiveMinuteScheduler();
        sch.execute(null);
    
    }
    public static testmethod void P1EnhancementTestMethod2(){
        Case c1 =  new case();
        c1.status = 'New';
        c1.priority = 'P1';
        c1.Problem_Type__c = 'How-to';
        c1.Category__c= 'ABN';
        c1.Sub_Category__c = 'Munchkin';
        c1.recordtypeid ='01250000000UJwx';
        insert c1;
        
        Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c ();
        cm2.case__c = c1.id;
        CM2.Checked_In_Scheduler__c = true;
        cm2.Milestone_Type__c = 'First Response';
        cm2.Start_Date__c = System.Now().addMinutes(-60);
        cm2.Target_Date__c = System.Now().addMinutes(-34);
        insert cm2;
        
        EveryFiveMinuteScheduler sch = new EveryFiveMinuteScheduler();
        sch.execute(null);
    
    }
    public static testmethod void P1EnhancementTestMethod3(){
        Case c1 =  new case();
        c1.status = 'New';
        c1.priority = 'P1';
        c1.Problem_Type__c = 'How-to';
        c1.Category__c= 'ABN';
        c1.Sub_Category__c = 'Munchkin';
        c1.recordtypeid ='01250000000UJwx';
        insert c1;
        
        Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c ();
        cm2.case__c = c1.id;
        CM2.Checked_In_Scheduler__c = true;
        cm2.Milestone_Type__c = 'First Response';
        cm2.Start_Date__c = System.Now().addMinutes(-160);
        cm2.Target_Date__c = System.Now().addMinutes(-124);
        cm2.Completed__c = false;
        cm2.Checked_In_Scheduler__c = true;
        insert cm2;
        
        EveryFiveMinuteScheduler sch = new EveryFiveMinuteScheduler();
        sch.execute(null);
    
    } 
    
    public static testmethod void P1EnhancementTestMethodfirst(){
        Case c1 =  new case();
        c1.status = 'New';
        c1.priority = 'P1';
        c1.Problem_Type__c = 'How-to';
        c1.Category__c= 'ABN';
        c1.Sub_Category__c = 'Munchkin';
        c1.recordtypeid ='01250000000UJwx';
        insert c1;
        
        Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c ();
        cm2.case__c = c1.id;
        CM2.Checked_In_Scheduler__c = true;
        cm2.Milestone_Type__c = 'First Response';
        cm2.Start_Date__c = System.Now().addMinutes(-160);
        cm2.Target_Date__c = System.Now().addMinutes(-124);
        cm2.Checked_In_Scheduler__c = true;
        insert cm2;
        
        cm2.Completed__c = true;
        cm2.Completion_Date__c = system.now();
        Update cm2;
        
        EveryFiveMinuteScheduler sch = new EveryFiveMinuteScheduler();
        sch.execute(null);
    
    } 
    
    ///////Case Update
        public static testmethod void P1EnhancementTestMethod4(){
        Case c1 =  new case();
        c1.status = 'New';
        c1.priority = 'P1';
        c1.Problem_Type__c = 'How-to';
        c1.Category__c= 'ABN';
        c1.Sub_Category__c = 'Munchkin';
        c1.recordtypeid ='01250000000UJwx';
        insert c1;
        
        Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c ();
        cm2.case__c = c1.id;        
        cm2.Milestone_Type__c = 'Case Update';
        cm2.Start_Date__c = System.Now().addMinutes(-250);
        cm2.Target_Date__c = System.Now().addMinutes(-240);        
        insert cm2;
        EveryFiveMinuteScheduler sch = new EveryFiveMinuteScheduler();
        sch.execute(null);
    
    }
    public static testmethod void P1EnhancementTestMethod5(){
        Case c1 =  new case();
        c1.status = 'New';
        c1.priority = 'P1';
        c1.Problem_Type__c = 'How-to';
        c1.Category__c= 'ABN';
        c1.Sub_Category__c = 'Munchkin';
        c1.recordtypeid ='01250000000UJwx';
        insert c1;
        
        Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c ();
        cm2.case__c = c1.id;
        CM2.Checked_In_Scheduler__c = true;
        cm2.Milestone_Type__c = 'Case Update';
        cm2.Start_Date__c = System.Now().addMinutes(-60);
        cm2.Target_Date__c = System.Now().addMinutes(-34);
        insert cm2;
        
        EveryFiveMinuteScheduler sch = new EveryFiveMinuteScheduler();
        sch.execute(null);
    
    }
    public static testmethod void P1EnhancementTestMethod6(){
        Case c1 =  new case();
        c1.status = 'New';
        c1.priority = 'P1';
        c1.Problem_Type__c = 'How-to';
        c1.Category__c= 'ABN';
        c1.Sub_Category__c = 'Munchkin';
        c1.recordtypeid ='01250000000UJwx';
        insert c1;
        
        Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c ();
        cm2.case__c = c1.id;
        CM2.Checked_In_Scheduler__c = true;
        cm2.Milestone_Type__c = 'Case Update';
        cm2.Start_Date__c = System.Now().addMinutes(-160);
        cm2.Target_Date__c = System.Now().addMinutes(-124);
        cm2.Completed__c = false;
        cm2.Checked_In_Scheduler__c = true;
        insert cm2;
        
        EveryFiveMinuteScheduler sch = new EveryFiveMinuteScheduler();
        sch.execute(null);
    
    }
    public static testmethod void P1EnhancementTestMethodUpdate(){
        Case c1 =  new case();
        c1.status = 'New';
        c1.priority = 'P1';
        c1.Problem_Type__c = 'How-to';
        c1.Category__c= 'ABN';
        c1.Sub_Category__c = 'Munchkin';
        c1.recordtypeid ='01250000000UJwx';
        insert c1;
        
        Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c ();
        cm2.case__c = c1.id;
        CM2.Checked_In_Scheduler__c = true;
        cm2.Milestone_Type__c = 'Case Update';
        cm2.Start_Date__c = System.Now().addMinutes(-160);
        cm2.Target_Date__c = System.Now().addMinutes(-124);        
        cm2.Checked_In_Scheduler__c = true;
        insert cm2;
        
        cm2.Completed__c = true;
        cm2.Completion_Date__c = system.now();
        Update cm2;
        
        EveryFiveMinuteScheduler sch = new EveryFiveMinuteScheduler();
        sch.execute(null);
    
    }
    
}