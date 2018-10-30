/* ********************************************************************
* Created Date       : 17th August 2016
* Create By          : Jade Global 
* Last Modified By   : Jade Global 17th August 2016
* Purpose            : This is used for
1.Updating OpportunityLineItem related to MDQ opportunity with Segment Stat Date field.
*********************************************************************** */
/* ********************************************************************
* Modified By          : Grazitti 
* Purpose            : This is used for
1.Updating OpportunityLineItem related to MDQ opportunity with Segment Stat Date field and creating the case for the segement of oli's 7 days before there start date.

*********************************************************************** */
/* ********************************************************************
* Modified By          : Grazitti 
* Purpose            : This is used for
1.Updating OpportunityLineItem related to MDQ opportunity with Segment Stat Date field and creating the case for the segement of oli's 7 days before there start date.

*********************************************************************** */
/* *****************************************************************************************
* Modified By       : Priyanka Shende, Jade Global Inc.
* Modified Date     : On 4th October 2017
* Purpose           : 1. Avoid 7 Days before case creation for 1st segment
*                     2. If create provision checkbox checked then only create cases for 1st segment
****************************************************************************************** */
global class QuoteSegmentStartDateBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    // DATE FOR CREATING THE PROVISIONING CASE 7 DAYS BEFORE SEGMENT START DATE
    public Date dt= System.Today().addDays(7);
    public Date FUTURE_PROVISIONING_DATE = date.newinstance(dT.year(), dT.month(), dT.day());
    public Date today= date.newinstance(system.today().year(), system.today().month(), system.today().day());
    global set<Id> processedOppIds = new set<id>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        system.debug('llllllll'+system.now()+'   '+FUTURE_PROVISIONING_DATE);
        //Added the Create_Provisioning_Case__c check in the SOQL to handle the split, migration and ghost scenario
        return Database.getQueryLocator('SELECT ID, OpportunityId, Opportunity.Iswon,Opportunity.Stagename, Opportunity.Actual_Close_Date__c,Opportunity.SBQQ__PrimaryQuote__c, Opportunity.CAM_Owner_Email__c, Opportunity.Owner.Email, Segment_Start_Date__c,SBQQ__QuoteLine__r.SBQQ__SegmentLabel__c, SBQQ__QuoteLine__r.SBQQ__SegmentKey__c, SBQQ__QuoteLine__r.SBQQ__StartDate__c, Product_Start_Date__c,SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__StartDate__c, SBQQ__QuoteLine__r.SBQQ__Quote__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c FROM OpportunitylineItem WHERE  Opportunity.isWon= true AND Opportunity.Create_Provisioning_Case__c=true AND (Opportunity.Actual_Close_Date__c = : today OR  Product_Start_Date__c = : FUTURE_PROVISIONING_DATE) AND SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c != null AND SBQQ__QuoteLine__r.SBQQ__StartDate__c != null AND SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c = true AND SBQQ__QuoteLine__r.SBQQ__SegmentLabel__c != null AND SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c!=1.0 ORDER BY SBQQ__QuoteLine__r.SBQQ__StartDate__c ASC');               }//End of Start Method
    
    global void execute(Database.BatchableContext BC, List<OpportunitylineItem> scope) {
        List<OpportunityLineItem> UpdateOLIList = new list<OpportunityLineItem> ();
        Set<Id> qualifiedOpptyIds = new Set<Id>();
        Set<Id> qualifiedOLIIds = new Set<Id>();
        map<id,list<OpportunitylineItem>> OppIdWithOLI = new map<id,list<OpportunitylineItem>>();
        List<Opportunity> OpportunityList = new list<Opportunity> ();
        if(!scope.isEmpty()){
            system.debug('llllllllscope'+scope);
            set<string> uniquedateandopp=new set<string>();
            // Iterate OLI to populate the CAM Owner, Segment Start date and Opportunity Owner Email
            for(OpportunitylineItem oli : scope){
                // Previous code merged to populate one of the oli's Segment_Start_Date__c to send email
                if(oli.Opportunity.isWon && oli.Opportunity.Actual_Close_Date__c == System.Today()){
                    system.debug('oli@@@@'+oli);
                    if(oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__StartDate__c != oli.Product_Start_Date__c && !uniquedateandopp.contains(oli.opportunityid + string.valueof(oli.Product_Start_Date__c))){
                        oli.Segment_Start_Date__c= oli.Product_Start_Date__c;
                        oli.CAM_Owner_Email__c= oli.Opportunity.CAM_Owner_Email__c;
                        oli.Opportunity_OwnerEmail__c = oli.Opportunity.owner.email;
                        UpdateOLIList.add(oli);
                        uniquedateandopp.add(oli.opportunityid + string.valueof(oli.Product_Start_Date__c));
                    }//End of If  
                }//End of If
                
                // Previous code merged to populate one of the oli's Segment_Start_Date__c to send email
                if(oli.Product_Start_Date__c == FUTURE_PROVISIONING_DATE && oli.Opportunity.stagename == 'Closed Won'){
                    qualifiedOpptyIds.add(oli.OpportunityId);
                    qualifiedOLIIds.add(oli.Id);
                }//End of CASE CREATION IF block
                
            }//End of For Loop
            String OPPORTUNITY_FIELDS = '';
            Set<String> preOpptyFields = new Set<String>{'account.name','id','type','accountid'};// FIELDS WHICH WE NEED FOR POPULATING THE CASE SUBJECT IN CASE THE FIELDS ARE NOT THERE IN CUSTOM SETTING.
                Set<Id> closedOppIds = new Set<Id>();
            Map<String,MapOpportunityFieldsToProvisioningCase__c> mapOpporToCase = new Map<String,MapOpportunityFieldsToProvisioningCase__c>();
            List<Case> caseToBeCreated = new List<Case>();
            Map<String, MapOpportunityFieldsToProvisioningCase__c> mpcaseFieldsCS = MapOpportunityFieldsToProvisioningCase__c.getAll();//FETCHING THE CUSTOM SETTING DATA.
            
            Map<String, RubiksSandboxCodes__c> mprubiksSand = RubiksSandboxCodes__c.getAll();//FETCHING THE CUSTOM SETTING DATA (RubiksSandboxCodes).
            Map<String, RubiksProdCode__c> mprubiksProd = RubiksProdCode__c.getAll();//FETCHING THE CUSTOM SETTING DATA. (RubiksProdCode)
            mprubiksSand.keyset().remove('Implementation Testing Sandbox'); //EXCLUDING THE "Implementation Testing Sandbox" Product from mprubiksSand map.
            Date segementStartDate = null;
            date segementEndDate   = null;
            double segmentIndex    = null;
            
            for(MapOpportunityFieldsToProvisioningCase__c mapCaseFields : mpcaseFieldsCS.values()){
                if(mapCaseFields.OpportunityFieldName__c != null && mapCaseFields.IsField__c){ //CHECKING HERE THE FIELDS WHICH NEEDS TO BE QUERY
                    String OPP_FIELD = (mapCaseFields.OpportunityFieldName__c).toLowerCase();
                    if(!preOpptyFields.contains(OPP_FIELD)){
                        OPPORTUNITY_FIELDS =  OPPORTUNITY_FIELDS + OPP_FIELD + ',';
                    }else{
                        preOpptyFields.remove(OPP_FIELD);//REMOVING THE FIELDS FROM THE PRE-DEFINED SET IN CASE WE NEED TO CONCAT REMAINING FIELDS. 
                        OPPORTUNITY_FIELDS =  OPPORTUNITY_FIELDS + OPP_FIELD + ',';
                    }//End of Else
                }//End of If
                mapOpporToCase.put(mapCaseFields.Name,mapCaseFields);
            }//End of For
            
            if(!preOpptyFields.isEmpty()){
                for(String str : preOpptyFields){
                    OPPORTUNITY_FIELDS =  OPPORTUNITY_FIELDS + str + ',';
                }
            }
            
            //SOQL for Opportunity and Opportunity Products
            OPPORTUNITY_FIELDS = 'SELECT SBQQ__PrimaryQuote__r.Mdq_quote__c,SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,SBQQ__PrimaryQuote__r.Instance_Rollup__c,'+OPPORTUNITY_FIELDS+'(SELECT Id, Name,servicedate,Product_Type__c,Instance_ID__c,Contract_Quantity__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c,SBQQ__QuoteLine__r.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c,SBQQ__QuoteLine__r.SBQQ__Existing__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Type__c,SBQQ__QuoteLine__r.SBQQ__SubscriptionPercent__c,SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c ,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,SBQQ__QuoteLine__c,MKTO_Product_Name__c,Product2.Name,ProductCode,SBQQ__QuoteLine__r.SBQQ__StartDate__c,SBQQ__QuoteLine__r.SBQQ__EndDate__c,SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c,OpportunityId FROM OpportunityLineitems WHERE SBQQ__QuoteLine__r.SBQQ__StartDate__c = : FUTURE_PROVISIONING_DATE AND SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c!=1 AND SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c!=1.0 order by MKTO_Product_Name__c ASC) FROM Opportunity WHERE Create_Provisioning_Case__c=true AND ID IN : qualifiedOpptyIds';
            OpportunityList = Database.query(OPPORTUNITY_FIELDS);
            
            // Previous code merged to populate one of the oli's Segment_Start_Date__c to send email before 7 days through workflow 
            if(!UpdateOLIList.isEmpty()){
                //Update OpportuniutyLineItem list
                update UpdateOLIList;
            }//End of IF block
            // Previous code merged to populate one of the oli's Segment_Start_Date__c to send email before 7 days through workflow
        }//End of Scope If
        
        //This Logic invoked 7 Days before of segment Start Date
        if(!OpportunityList.isEmpty()){
            //FOR CREATING THE SEGMENTED PROVISIONING CASES
            for(Opportunity Opp :OpportunityList){
                if(!processedOppIds.contains(opp.id)){
                    createProvisioningCaseFromOpportunity.create2ndSegmentProvisioningCase(Opp);
                    processedOppIds.add(opp.id);
                }//End of If
            }// End of For Loop
        }//End of OpportunityList If
        
    }//End of Execute Method
    
    global void finish(Database.BatchableContext BC) {
        
    }//End of Finish Method
}