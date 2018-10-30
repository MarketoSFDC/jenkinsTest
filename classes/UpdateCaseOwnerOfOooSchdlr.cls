global class UpdateCaseOwnerOfOooSchdlr implements Schedulable {

    global void execute(SchedulableContext sc) {
        try{
            map<string, Case_OwnerShip_History__c> OwnershipHistoryList = new map<string, Case_OwnerShip_History__c>();
            set<string> uniqueIds = new set<string>(); 
            map<string, Case_OwnerShip_History__c> COHToinsert = new map<string, Case_OwnerShip_History__c>();
            datetime lastHOur = system.now().AddHOurs(-1);
            for(case c : [Select Id, OwnerID, (Select CreatedDate, NewValue, CaseId From Histories Where Field = 'Owner' and createddate = today) from case where lastmodifieddate >= :lastHOur and recordtypeid ='01250000000UJwx']) { //This line is modified by the grazitti on 11/3/2017 to stop case ownership record creation for old cases. 
                for(caseHistory cc : c.Histories){
                    if( cc.NewValue != '00550000001y4AfAAI' && cc.NewValue != '00550000004KAuFAAW' && (''+cc.NewValue).startsWith('005') == True ){
                        string casIdOwnerId = c.id+'_'+cc.NewValue;
                        //system.debug('owner==>>'+cc.NewValue);
                        Case_OwnerShip_History__c COH = new Case_OwnerShip_History__c(Case__c = c.id, Case_Owner__c = (id)cc.NewValue, Assignment_Time__c = System.Now(), Unique_Id__c = casIdOwnerId );
                        OwnershipHistoryList.put(casIdOwnerId,COH);
                    }       
                }
            }
            system.debug('OwnershipHistoryList===>>>'+OwnershipHistoryList.size());
            if(OwnershipHistoryList!=null && OwnershipHistoryList.Isempty() == FALSE){
                for(Case_OwnerShip_History__c COH : [select id, Unique_Id__c from Case_OwnerShip_History__c where Unique_Id__c in : OwnershipHistoryList.keyset() ]){
                    uniqueIds.add(COH.Unique_Id__c);
                }
            
                for( string str : OwnershipHistoryList.keyset() ){
                    if( !uniqueIds.contains(str) ){
                        COHToinsert.put(str, OwnershipHistoryList.get(str));
                    }
                }
                
                system.debug('COHToinsert===>>>'+COHToinsert.size());
                upsert COHToinsert.values() Unique_Id__c;
            }
        }catch(exception e){ system.debug('errorrrrrrrrr==============>>>>>>');}
        Set<id> UserId = new Set<id>();
        List<Out_Of_Office__c> OooList = new List<Out_Of_Office__c>();
        //Get all Ooo users TSE's 
        for(Out_Of_Office__c  temp: [select id, Tse_name__c,Timezone__c,Due_Date__c,StartDateString__c,EndDAteString__c,Start_Date__c,End_Date__c,Frequency__c,Time_Zone__c,FirstRunComplete__c from Out_Of_Office__c where enddatebefore2days__c = False]){

        //-------------------------------------------->
        /* Setting time in GMT Format starts*/
        String TimeZones =  temp.Timezone__c;
        String MinStr = TimeZones.substring(TimeZones.indexof('T')+5,TimeZones.indexof(')'));
        String HourStr = TimeZones.substring(TimeZones.indexof('T')+1,TimeZones.indexof(':'));
        system.debug('------------->'+HourStr);
        
        Integer Min = Integer.valueof(MinStr.trim());
        Integer Hour = Integer.valueof(HourStr.trim());
        
        string sDate =  temp.StartDateString__c;   
        Datetime StartDateTemp = Datetime.valueofGmt(sDate);
        Datetime StartDateGMT = StartDatetemp.addHours(-Hour);
        Datetime StartDateGMTmin = StartDateGMT.addMinutes(-Min);
        
        string Edate = temp.EndDAteString__c;     
        Datetime EndDAteTemp = Datetime.valueofGmt(Edate);
        Datetime EndDAteGMT =   EndDAteTemp.addHours(-Hour);    
        Datetime EndDAteGMTmin =   EndDAteGMT.addMinutes(-Min);      
        /* Setting time in GMT Format Ends*/        
        //    -------------------------------------------->   
        if(EndDAteGMTmin > System.now() && StartDateGMTmin < System.now()){     
            if(temp.FirstRunComplete__c == false){                
                system.debug('Owner---->'+temp.Tse_name__c);
                UserId.Add(temp.Tse_name__c);
                //update due date to next due date 
                temp.FirstRunComplete__c = true;
                if(temp.Frequency__c == '30 Min'){
                string temp1 = temp.Frequency__c; 
                string y = temp1.substring(0,temp1.indexof(' '));
                    Integer x = Integer.valueOf(y);
                    temp.Due_Date__c = system.now().addMinutes(x-2);      
                }else{
                system.debug('this is heaven4');
                string temp1 = temp.Frequency__c; 
                string y = temp1.substring(0,temp1.indexof(' '));
                    Integer x = Integer.valueOf(y);
                    temp.Due_Date__c = system.now().addhours(x);
                    temp.Due_Date__c = temp.Due_Date__c.addMinutes(-2); 
                }                               
            }else if(temp.Due_Date__c <= System.now() ){    
                system.debug('Owner1--->'+temp.Tse_name__c);
                UserId.Add(temp.Tse_name__c);
                //update due date to next due date 
                if(temp.Frequency__c == '30 Min'){
                    string temp1 = temp.Frequency__c; 
                    string y = temp1.substring(0,temp1.indexof(' '));
                    Integer x = Integer.valueOf(y);
                    temp.Due_Date__c = system.now().addMinutes(x-2);      
                }else{
                    string temp1 = temp.Frequency__c; 
                    string y = temp1.substring(0,temp1.indexof(' '));
                    Integer x = Integer.valueOf(y);
                    temp.Due_Date__c = system.now().addhours(x);
                    temp.Due_Date__c = temp.Due_Date__c.addMinutes(-2); 
                }      
            }
        }
            OooList.add(temp);
        }
        
        if(!OooList.isEmpty()){update OooList;}
        
        if(!UserId.isempty()){
            list<string> ListOfStatusToReroute = Label.OooStatusToReroute.split(';');
            //Fetch cases and run DML assignment 
            list<case> CaseToBeUpdated = new list<case>([select id,status  from case where status IN :ListOfStatusToReroute AND ownerid IN :UserId and recordtypeid !='01238000000E8aV']);
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            for(case temp : CaseToBeUpdated ){
                temp.setOptions(dmo);   
            }        
            if(!CaseToBeUpdated.isempty()){
                update CaseToBeUpdated;
            }
        }
    }
}