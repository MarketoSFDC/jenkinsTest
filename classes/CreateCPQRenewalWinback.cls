/*****************************************************************************
Created By    : Jade Global Inc
Created Date  : 19th May 2018
Purpose       : Winback Opportunity Creation - Automation

LastModified By    : Snehal Khot
Modified Date      : 7th June 2018
Purpose            : APPS-20901:Win Back button issue

LastModified By    : Priyanka Shende
Modified Date      : 4th July 2018
Purpose            : APPS-20961 :Win Back button doesn't work on a Closed Lost Renewal

* Last modified By : Tushar Misri, Grazitti Interactive, 10th Aug 2018
* Purpose          : APPS-20840, Field Cleanup Project - Phase One
                     Fields which are being commented out:
                     Implementation__c
******************************************************************************/

Global class CreateCPQRenewalWinback{
        
       // Method is created to create winback Opportuniy
       webservice static void GetWinBackOpportunity(Id OpportunityId){
     
        // This is the object for which we required data.
        Map<String, Schema.SObjectField> objfieldMap = Opportunity.sObjectType.getDescribe().fields.getMap();
         
        String strfieldName = '';
        //Add no of days to be added to populate plan of record renwal date
        string addNoOfDays   = Label.AddDaysInPlanOfRecordRenewalDate;
        
        List<Winback_Opp_Owner__c> WinbackOwner=new List<Winback_Opp_Owner__c>();
        
        //Add all fields in string
        for(Schema.SObjectField Field : objfieldMap.Values())
        {
             Schema.DescribeFieldResult fieldResult = Field.getDescribe();
             strfieldName += fieldResult.getName() + ',';
        }
         
        strfieldName = strfieldName.substring(0, strfieldName.length()-1);
        
        // Build a Dynamic Query String.
        List<Opportunity> OppList = Database.query('select ' + strfieldName + ' ,SBQQ__RenewedContract__r.EndDate,owner.isActive,owner.ManagerId,owner.Manager.isActive  from Opportunity where Id=:OpportunityId AND Is_Winback_Created__c=false');
        
        system.debug('OppList'+OppList);       
        
        try{
          //Clone existing Opportunity to create new winback Opportunity
          Opportunity clonedOpp = OppList[0].clone(false, true, false, false);
          system.debug('clonedOpp owner'+clonedOpp.ownerId);
          
          //Set parameters to new winback Opportunity
          clonedOpp.Adjusted_POR__c=0;
          clonedOpp.Prior_Opportunity__c=OppList[0].Id;
          clonedOpp.Renewal_Type__c='Churn Win-Back';
          clonedOpp.Name=OppList[0].Name+' '+'WINBACK';
          clonedOpp.Previous_Year_ACV__c = 0;
          
          /*********************************************************
          LastModified By    : Snehal Khot
          Modified Date      : 7th June 2018
          Purpose            : APPS-20901:Win Back button issue
         
      Modified Date      : 4th July 2018
          Purpose            : APPS-20961 :Win Back button doesn't work on a Closed Lost Renewal
          *********************************************************/
          
          clonedOpp.StageName='A - Not Contacted';
          
           if(clonedOpp.Rep_Forecast__c=='Omitted'){
            clonedOpp.Rep_Forecast__c='';         
          }
          
            if(clonedOpp.Tout_External_Id__c!=null){
              clonedOpp.Tout_External_Id__c='';
          
          }
         
          clonedOpp.Plan_of_Record_Renewal_Date__c = clonedOpp.Plan_of_Record_Renewal_Date__c!=null?clonedOpp.Plan_of_Record_Renewal_Date__c.addDays(Integer.valueOf(addNoOfDays)):OppList[0].SBQQ__RenewedContract__c!=null?OppList[0].SBQQ__RenewedContract__r.EndDate.addDays(Integer.valueOf(addNoOfDays)):clonedOpp.closeDate.addDays(Integer.valueOf(addNoOfDays));
          
          clonedOpp.closeDate = clonedOpp.Plan_of_Record_Renewal_Date__c!=null?clonedOpp.Plan_of_Record_Renewal_Date__c:clonedOpp.closeDate;
          
          If(OppList[0].owner.isActive==true){
                clonedOpp.OwnerId=OppList[0].ownerId;               
              
          }
          else if(OppList[0].owner.ManagerId!=null && OppList[0].owner.Manager.isActive){
                clonedOpp.OwnerId=OppList[0].owner.ManagerId;               
          }
          else {
                WinbackOwner=[select id,User_Id__c from Winback_Opp_Owner__c];
                clonedOpp.OwnerId=Id.valueOf(WinbackOwner[0].User_Id__c);               
          }            
          
            //Set all required parameters to Closed lost existing Opportunity
            if(OppList[0].StageName!='Closed Lost'){
            OppList[0].DealLostReason__c='Win Back Opportunity Created in Current Month';
            OppList[0].Lost_Reason_Sub__c ='Win Back';
            OppList[0].Deal_Won_By__c ='None';
            OppList[0].Competitor_Swap__c ='None';
            OppList[0].Competitive_MA__c='Unknown';
            OppList[0].Competitive_ESP__c ='Unknown';
           // OppList[0].Implementation__c = 'No';
            OppList[0].Primary_Competitor__c ='Unknown';
            OppList[0].MainCompetitor__c ='Unknown';
            OppList[0].StageName='Closed Lost';
            OppList[0].Loss_Description__c='Past Due';
           
            }
            
             OppList[0].Is_Winback_Created__c=True;
             
            //Closed Lost existing Opportunity
            if(!OppList.isEmpty()){
                update OppList;
            }//End of if  
           

           if(clonedOpp!=null){
                system.debug('clonedOpp.Rep_Forecast__c'+clonedOpp.Rep_Forecast__c);
                system.debug('clonedOpp'+clonedOpp);
                Insert clonedOpp;
                system.debug('clonedOpp'+clonedOpp);
            }//End of if
            
        }catch(Exception ex){
            System.debug('Exception Found =================='+ex.getMessage());
            System.debug('Exception Found =================='+ex.getLineNumber());
            System.debug('Exception Found =================='+ex.getcause());
        }//End of Catch block
    }// End of GetWinBackOpportunity() method

}