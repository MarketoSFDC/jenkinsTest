public with sharing class Graph { 

    public boolean isSupportCase{get;set;} 
    Public List<Case> caseObj{get;set;}
    Public Long milliSeconds1 {get;set;}
    Public Integer timeInterval1{get;set;}
    Public decimal widthInterval{get;set;} 
    public Datetime TargetDate1{get;set;}
    public String Type1{get;set;}
    public String dateOutput1{get;set;}
     
    Public Long milliSeconds2 {get;set;}
    Public Integer timeInterval2{get;set;}
    Public decimal widthInterval2{get;set;} 
    public Datetime TargetDate2{get;set;}
    public String Type2{get;set;}
    public String dateOutput2{get;set;}
     
     
    public Graph(ApexPages.StandardController controller) {
        Id caseId = ApexPages.currentPage().getParameters().get('id');
        caseObj = [Select id,AgeInDays__c,Time_Remaining__c, recordtypeid,(select id,Milestone_Type__c,Target_Date__c, Start_Date__c from Case_Milestones__r where Completed__c = false) from case where id =:caseId and (recordtypeid = '01250000000UJwx' OR recordtypeid =: Label.CCareRecordTypeId18)];
        widthInterval = 0;
        widthInterval2 = 0;
        if(caseObj.Isempty() || caseObj[0].Case_Milestones__r.Isempty()){
            isSupportCase = false;
        }else{        
            isSupportCase = true;
            getPieData();
            getPieData2();
        }        
    }
    
    public List<PieWedgeData> getPieData(){  
        List<PieWedgeData> data = new List<PieWedgeData>();        
        for(case caseObj1 : caseObj){
            for(Case_Update_Milestones__c cMil :caseObj1.Case_Milestones__r){
                if(cMil.Milestone_Type__c != 'Resolution Response' ){
                    milliSeconds1 = (cMil.Target_Date__c.getTime() - cMil.Start_Date__c.getTime());                    
                    widthInterval = ((System.Now().getTime() * 100 - cMil.Start_Date__c.getTime() * 100)/milliSeconds1);
                    timeInterval1 = Integer.ValueOf(milliSeconds1/100000);
                    if(cMil.Target_Date__c != null){
                        TargetDate1 = cMil.Target_Date__c;
                        dateOutput1 = TargetDate1.format();
                    }
                    Type1 = cMil.Milestone_Type__c;
                    if(widthInterval>100){
                        widthInterval = 100;
                    }
                    data.add(new PieWedgeData('',widthInterval)); 
                    data.add(new PieWedgeData('',100-widthInterval));
                }
            }
        }
        return data;
    }        
         
    public List<PieWedgeData> getPieData2(){  
    List<PieWedgeData> data = new List<PieWedgeData>();        
        for(case caseObj1 : caseObj){
            for(Case_Update_Milestones__c cMil :caseObj1.Case_Milestones__r){
                if(cMil.Milestone_Type__c == 'Resolution Response' ){
                    milliSeconds2 = (cMil.Target_Date__c.getTime() - cMil.Start_Date__c.getTime());                    
                    widthInterval2 = ((System.Now().getTime() * 100 - cMil.Start_Date__c.getTime() * 100)/milliSeconds2);
                    timeInterval2 = Integer.ValueOf(milliSeconds2/100000);
                    if(cMil.Target_Date__c != null){
                        TargetDate2 = cMil.Target_Date__c;
                        dateOutput2 = TargetDate2.format();
                    }
                    Type2 = cMil.Milestone_Type__c;
                    if(widthInterval2>100){
                        widthInterval2 = 100;
                    }
                    data.add(new PieWedgeData('',widthInterval2)); 
                    data.add(new PieWedgeData('',100-widthInterval2));
                }
            }
        }
        return data;
    }   
   
    public pagereference CallActionPoller(){
        getPieData();
        getPieData2();
        return null;
    }
    
    // Wrapper class  
    public class PieWedgeData {  
        public String name { get; set; }  
        public Decimal data { get; set; }  
        
        public PieWedgeData(String name, Decimal data) {  
            this.name = name;  
            this.data = data;  
        }  
    }
      
}