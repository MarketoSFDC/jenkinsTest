/* ********************************************************************
* Created by: GRAZITTI
* Created Date: 3/11/2017
* Purpose: This class is called through process builder "Create Provisioning Case on Closed Won Opportunity" to create provisioning case on opportunity Closed won                           
* Modification Date Wise :
1. Date [10-April-2017] As per Ticket (APPS-12903) For Creating cases for ramp deals, we have added a function "create2ndSegmentProvisioningCase" in the class to create a case 7 days before the segement start date.
2. Date [26-April-2017] As per Ticket (APPS-12976) Added a check for Excluding Existing Products on Upsell Opportunity to be added on the case.

*Last modified By    : Jade Global
*Last modifieddate   : 17th May 2017
*Purpose             : To add product to correct Solution instance in case of Multi-Instance Quote
*Changes             : Added below SOQL opportunityLineitem          
SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,
Updated the data population in soldiff map
replace oli.Instance_ID__c with oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c
Line 71-133,138,153-161,275-291
Also need to check Add Error validation on any exception occur in class  

* Last Modified By    : Priyanka Shende, Jade Global Inc.
* Last Modified Date  : 25th May 2017
* Purpose             : To handle Legacy Opportunity scenario while populating Subscriptions on Provisioning Cases
* Line No             : 87,88,91
*********************************************************************** */

/* *****************************************************************************************************
*Last modified By    : Grazitti Interactive
*Last modifieddate   : 24th May 2017
*Purpose             : To include all products irrecpective of QuotLineVisibility and exclude all products in the custom settings 1) RubiksSandboxCodes 2) RubiksProdCode except for Implementation Testing Sanbox Product.
*Changes         :  Instead of checking the QuotLineVisibility, we are now checking if the products are from the   custom setting then do not include them in the cases
***************************************************************************************************** */

/* ************************************************************************************************************************************
* Modified By         : Priyanka Shende, Jade Global Inc
* Modified Date       : 5th July 2017
* Purpose             : APPS-7353:Adding/Dropping Products - New Req
While inserting case on Close won of renewal populate Added and Dropped and Quantity Change Products on Case
*Added Lines          :109-153
************************************************************************************************************************************** */ 
/* *****************************************************************************************************************
* Modified By         : Rajesh Wani, Jade Global Inc
* Modified Date       : 23rd August 2017
* Purpose             : Added check Prior_Opportunity__c on opportunity.
*                       We are calling adding droppring class if Prior_Opportunity__c is present on Opportunity
*Modified Lines          :103 and 122
******************************************************************************************************************* */
/* ********************************************************************************************************
* Modified By         : Priyanka Shende, Jade Global Inc
* Modified Date       : 4th October 2017
* Purpose             : 1. If Added or Dropped or Quantity Changed product populated then mark send case to spa checkbox true
2. Populate account prefix on 2nd to nth segment  

*  Modified By         : Priyanka Shende, Jade Global Inc
*  Modified Date       : 26th June 2018
*  Purpose             : Handle Opportunity Closed Won - Too Many SOQL Queries Exception(Trouble Closing out Opp) - JIRA : APPS-19978,APPS-20808

* Last Modified By: Jade Global Inc, on 8th September 2018
* Purpose         : To handle Phoenix Provisioning Scenarios
                    Create Provisioning Case for Phoenix - APPS-21984: Project Phoenix Provisioning 
*********************************************************************************************************** */
public class createProvisioningCaseFromOpportunity{
    
    public static String OPPTY_PRODUCT_TYPE_SERVICES                     = System.Label.PRODUCT_TYPE_SERVICES; //The label will have values as Services
    public static String OPPTY_PRODUCT_TYPE_SUBSCRIPTIONS                = System.Label.PRODUCT_TYPE_SUBSCRIPTIONS;  //The label will have values as Subscriptions   
    public static String QUOTE_TYPE                                      = 'Amendment';
    public static String EXCLUDE_OPPTY_TYPE                              = 'Upsell/Crossell';
    public static String SANDBOX_PRODUCT_CODE                            = 'PROD-PLAT-SANDBOX';
    
    
    @InvocableMethod
    public static void createProvisioningCase(List<Opportunity> newOppVersion){
        /* ***************************************************************************************************************
    *  Modified By         : Priyanka Shende, Jade Global Inc, On 26th June 2018
    *  Purpose             : Handle Opportunity Closed Won - Too Many SOQL Queries Exception(Trouble Closing out Opp) - JIRA : APPS-19978,APPS-20808
    *********************************************************************************************************** */
    Set<Id> OppIds = new Set<Id>();
        for(Opportunity Opp: newOppVersion){
            OppIds.add(Opp.id); 
        }
        
        // Call createProvisioningCaseFuture Method
        createProvisioningCaseFuture(OppIds);
    }
    
    @future(callout=true)
    public static void createProvisioningCaseFuture(Set<Id> newOppVersion){
        try{ 
            
            String OPPORTUNITY_FIELDS = '';
            Set<String> preOpptyFields = new Set<String>{'account.name','id','type','accountid'};// FIELDS WHICH WE NEED FOR POPULATING THE CASE SUBJECT IN CASE THE FIELDS ARE NOT THERE IN CUSTOM SETTING.
                Set<Id> closedOppIds = new Set<Id>();
            Map<String,MapOpportunityFieldsToProvisioningCase__c> mapOpporToCase = new Map<String,MapOpportunityFieldsToProvisioningCase__c>();
            List<Case> caseToBeCreated = new List<Case>();
            Map<String, MapOpportunityFieldsToProvisioningCase__c> mpcaseFieldsCS = MapOpportunityFieldsToProvisioningCase__c.getAll();//FETCHING THE CUSTOM SETTING DATA.
            
            Map<String, RubiksSandboxCodes__c> mprubiksSand = RubiksSandboxCodes__c.getAll();//FETCHING THE CUSTOM SETTING DATA (RubiksSandboxCodes).
            Map<String, RubiksProdCode__c> mprubiksProd = RubiksProdCode__c.getAll();//FETCHING THE CUSTOM SETTING DATA. (RubiksProdCode)
            mprubiksSand.keyset().remove('Implementation Testing Sandbox'); //EXCLUDING THE "Implementation Testing Sandbox" Product from mprubiksSand map.
            
            for(MapOpportunityFieldsToProvisioningCase__c mapCaseFields : mpcaseFieldsCS.values()){
                if(mapCaseFields.OpportunityFieldName__c != null && mapCaseFields.IsField__c){ //CHECKING HERE THE FIELDS WHICH NEEDS TO BE QUERY
                    String OPP_FIELD = (mapCaseFields.OpportunityFieldName__c).toLowerCase();
                    if(!preOpptyFields.contains(OPP_FIELD)){
                        OPPORTUNITY_FIELDS =  OPPORTUNITY_FIELDS + OPP_FIELD + ',';
                    }else{
                        preOpptyFields.remove(OPP_FIELD);//REMOVING THE FIELDS FROM THE PRE-DEFINED SET IN CASE WE NEED TO CONCAT REMAINING FIELDS. 
                        OPPORTUNITY_FIELDS =  OPPORTUNITY_FIELDS + OPP_FIELD + ',';
                    }
                }
                mapOpporToCase.put(mapCaseFields.Name,mapCaseFields);
            }
            if(!preOpptyFields.isEmpty()){
                for(String str : preOpptyFields){
                    OPPORTUNITY_FIELDS =  OPPORTUNITY_FIELDS + str + ',';
                }
            }
            if(newOppVersion != null){
                //for(Opportunity opp : newOppVersion){
                    closedOppIds.addAll(newOppVersion);//CREATING A SET OF IDS AS SOBJECT LIST CAN NOT BE PASSED IN DATABASE.QUERY METHOD
                //}      
                /****************************************************************
                *Last modified By    : Jade Global
                *Last modifieddate   : 17th May 2017
                *Purpose             : To add product to correct Solution instance in case of Multi-Instance Quote
                *Changes             : Added below SOQL opportunityLineitem          
                SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,
                Updated the data population in soldiff map
                replace oli.Instance_ID__c with oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c
                *        
                ******************************************************************/
                //GET the SteelBrick pricebook ID stored in the custom setting
                SteelBrickCPQPricebook__c SBPB = SteelBrickCPQPricebook__c.getOrgDefaults();
                
                system.debug('SBPB ID ##########'+SBPB.ID__c);
                // Added Primary Quote -> SBQQ__LineItemsGrouped__c in field as per Phoenix requirement
                OPPORTUNITY_FIELDS = 'SELECT SBQQ__PrimaryQuote__r.Mdq_quote__c,SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c,SBQQ__RenewedContract__c,SBQQ__AmendedContract__c,SBQQ__RenewedContract__r.Primary_Asset__c,SBQQ__AmendedContract__r.Primary_Asset__c,SBQQ__RenewedContract__r.Primary_Asset__r.Acct_Prefix__c,SBQQ__AmendedContract__r.Primary_Asset__r.Acct_Prefix__c,SBQQ__PrimaryQuote__r.Rubiks_Quote__c,SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,SBQQ__PrimaryQuote__r.Instance_Rollup__c,Pricebook2Id,Prior_Opportunity__c,'+OPPORTUNITY_FIELDS+'(SELECT Id, Name,servicedate,Product_Type__c,Instance_ID__c,Contract_Quantity__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c,MKTO_Product_Name__c,SBQQ__QuoteLine__r.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c,SBQQ__QuoteLine__r.SBQQ__Existing__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Type__c,SBQQ__QuoteLine__r.SBQQ__SubscriptionPercent__c,SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c ,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,SBQQ__QuoteLine__c,Product2.Name,ProductCode,SBQQ__QuoteLine__r.Qty_Diff__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,SBQQ__QuoteLine__r.SBQQ__Group__c,SBQQ__QuoteLine__r.SBQQ__Group__r.Name FROM OpportunityLineitems order by MKTO_Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Group__r.Name ASC ) FROM Opportunity WHERE ID IN : closedOppIds';
                for(Opportunity opp : Database.query(OPPORTUNITY_FIELDS)){
                    Map<string,string> soldiff                                = new Map<string,string>();
                    Map<String, Map<string,string>>  groupAndBundleProductMap = new Map<String, Map<string,string>>();
                    //String subscriptionProducts = '';
                    String serviceProducts = '';
                    Case cs = new Case();
                    /* ************************************************************************************
                    * Modified By         : Priyanka Shende, Jade Global Inc
                    * Modified Date       : 5th July 2017
                    * Purpose             : APPS-7353:Adding/Dropping Products - New Req
                    While inserting case on Close won of renewal populate Added and Dropped Product on Case
                    *Added Lines           :110-153
                    *************************************************************************************** */            
                    
                    if(opp.Type!='New Business'){
                        Map<string,list<string>> AddedDroppedMap = new Map<string,list<string>>();
                        if(Test.isRunningTest()){
                            createProvisioningCaseTest cObj = new createProvisioningCaseTest();
                            AddedDroppedMap=cObj.ReturnProductMap();                          
                        }else if(opp.Prior_Opportunity__c!=null){                    
                            AddedDroppedMap=AddingDroppingProdController.populateAddedDroppedProductsOnCase(opp);
                        }
                        if(!AddedDroppedMap.IsEmpty()){
                            if(AddedDroppedMap.containsKey('Added Products')){
                                List<string> AddedProducts=AddedDroppedMap.get('Added Products');
                                if(!AddedProducts.IsEmpty()){
                                    integer addedProductcount=0;
                                    integer addedProductSize=AddedProducts.size();
                                    system.debug('############# addedProductSize'+addedProductSize);
                                    for(String s:AddedProducts){
                                        addedProductcount++;
                                        if(opp.SBQQ__PrimaryQuote__r.Instance_Rollup__c > 1.0){
                                            if(addedProductcount==1){
                                                cs.Added_Products__c=s;
                                            }else if(cs.Added_Products__c!=null && addedProductcount!=addedProductSize){
                                                cs.Added_Products__c=cs.Added_Products__c + s +',';    
                                            }
                                            if(addedProductcount==addedProductSize){
                                                cs.Added_Products__c=cs.Added_Products__c+s;
                                            }
                                        }//Multi Instance
                                        else{
                                            if(cs.Added_Products__c==NULL){                         
                                                cs.Added_Products__c=s;
                                            }
                                            else{
                                                cs.Added_Products__c=cs.Added_Products__c + ',' + s; 
                                            }
                                        }//single instance
                                    }
                                } 
                            }
                        }// End of Added Products                      
                        if(!AddedDroppedMap.IsEmpty()){
                            if(AddedDroppedMap.containsKey('Dropped Products')){
                                List<string> DroppedProducts=AddedDroppedMap.get('Dropped Products');
                                if(!DroppedProducts.IsEmpty()){  
                                    integer droppedCount=0;
                                    integer droppedSize=DroppedProducts.size();
                                    for(String s:DroppedProducts){
                                        droppedCount++;
                                        if(opp.SBQQ__PrimaryQuote__r.Instance_Rollup__c > 1.0){
                                            if(droppedCount==1){
                                                cs.Dropped_Products__c=s;
                                            }else if(cs.Dropped_Products__c!=null && droppedCount!=droppedSize){
                                                cs.Dropped_Products__c=cs.Dropped_Products__c + s +',';    
                                            }
                                            if(droppedCount==droppedSize){
                                                cs.Dropped_Products__c=cs.Dropped_Products__c+s;
                                            }
                                        }//Multi Instance
                                        else{
                                            if(cs.Dropped_Products__c==NULL){                           
                                                cs.Dropped_Products__c=s;
                                            }
                                            else{   
                                                cs.Dropped_Products__c=cs.Dropped_Products__c +',' + s;     
                                            }
                                        }//Single Instance
                                    }
                                }
                            }
                        }//End of Dropped Products   
                        
                        if(!AddedDroppedMap.IsEmpty()){
                            if(AddedDroppedMap.containsKey('QuantityChangedProduct')){
                                List<string> QuantityChangedProducts=AddedDroppedMap.get('QuantityChangedProduct');
                                if(!QuantityChangedProducts.IsEmpty()){                         
                                    integer qtyChangeCount=0;
                                    integer qtyChangeSize=QuantityChangedProducts.size();
                                    for(String s:QuantityChangedProducts){
                                        qtyChangeCount++;
                                        if(opp.SBQQ__PrimaryQuote__r.Instance_Rollup__c > 1.0){
                                            if(qtyChangeCount==1){
                                                cs.Quantity_Change_on_Existing_Products__c=s;
                                            }else if(cs.Quantity_Change_on_Existing_Products__c!=null && qtyChangeCount!=qtyChangeSize){
                                                cs.Quantity_Change_on_Existing_Products__c=cs.Quantity_Change_on_Existing_Products__c + s +',';    
                                            }
                                            if(qtyChangeSize==qtyChangeCount){
                                                cs.Quantity_Change_on_Existing_Products__c=cs.Quantity_Change_on_Existing_Products__c+s;
                                            }
                                        }//Multi Instance
                                        else{
                                            if(cs.Quantity_Change_on_Existing_Products__c==NULL){                           
                                                cs.Quantity_Change_on_Existing_Products__c=s;
                                            }
                                            else{   
                                                cs.Quantity_Change_on_Existing_Products__c=cs.Quantity_Change_on_Existing_Products__c +',' + s;     
                                            }
                                        }//Singel Instance
                                    }
                                }
                            }
                        }//End of Quantity Change If
                        
                        if(!AddedDroppedMap.IsEmpty()){
                            if(AddedDroppedMap.containsKey('AddedDroppedQtyChange')){
                                List<string> QuantityChangedProducts=AddedDroppedMap.get('AddedDroppedQtyChange');
                                if(!QuantityChangedProducts.IsEmpty()){ 
                                    cs.Added_Dropped_QtyChange__c=QuantityChangedProducts.get(0);
                                }//End of If 
                            }//End of If 
                        }//End of If
                        
                        
                    }//End of Adding,Dropping And Quantity Change If
                    
                    if(opp.SBQQ__PrimaryQuote__r.Mdq_quote__c== TRUE){
                        cs.Segment_Index__c = 1;
                    }
                    //If added product or Droppoed product or quantity changed product not equals to null then that case send to provision
                    if(cs.Added_Products__c!=null || cs.Dropped_Products__c!=null || cs.Quantity_Change_on_Existing_Products__c!=null){
                        cs.Send_Case_to_SPA__c=true;
                    }
                    //FETCHING THE SUBSCRIPTION AND SERVICES PRODUCT NAME AND CONTRACT QUANITY FROM THE RELATED LINE ITEMS.
                    if(opp.OpportunityLineitems != null){
                        
                        Map<String,String> BundleWithGroupMap = new Map<String,String>();
                        for(OpportunityLineitem oli: opp.OpportunityLineitems){
                            System.debug('##########@@@@@@@@@@@@@@####### :'+oli);
                            // Added Primary Quote -> SBQQ__LineItemsGrouped__c as per Phoenix pricebook is Different
                            if((opp.Pricebook2Id==SBPB.ID__c && opp.SBQQ__PrimaryQuote__r.Rubiks_Quote__c==TRUE)|| opp.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c){
                                // Below Condition is Excluding Existing Products on Upsell Opportunity- Related Ticket(APPS-12976)
                                
                                if(!(opp.Type == EXCLUDE_OPPTY_TYPE && oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Type__c == QUOTE_TYPE && oli.SBQQ__QuoteLine__r.SBQQ__Existing__c && oli.SBQQ__QuoteLine__r.SBQQ__SubscriptionPercent__c != null && (oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c <0 || oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c ==1))){
                                    if(opp.SBQQ__PrimaryQuote__r.Mdq_quote__c){
                                        if(oli.servicedate == opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c){
                                            if(oli.Product_Type__c == OPPTY_PRODUCT_TYPE_SUBSCRIPTIONS && !mprubiksSand.containsKey(oli.Product2.Name) && !mprubiksProd.containsKey(oli.Product2.Name)){
                                                // && oli.SBQQ__QuoteLine__r.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c != 'Never'){    
                                                if(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null && soldiff.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)){
                                                    String str = soldiff.get(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);
                                                    if(opp.Type == EXCLUDE_OPPTY_TYPE && oli.ProductCode == SANDBOX_PRODUCT_CODE ){
                                                        if(oli.SBQQ__QuoteLine__r.SBQQ__Existing__c){
                                                            if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c > 0){  
                                                                if(oli.SBQQ__QuoteLine__r.Qty_Diff__c > 0){
                                                                    str = str + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.Qty_Diff__c  + '\n';
                                                                }
                                                            }
                                                        }else if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c > 0){
                                                            str = str + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c  + '\n';
                                                        }
                                                    }else if(oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c > 0 ){
                                                        str = str + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n';
                                                    }
                                                    soldiff.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,str);
                                                    // This code added as part of Phoenix on 25th July 2018 
                                                    if(oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && !BundleWithGroupMap.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c) && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name!=null){
                                                        BundleWithGroupMap.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                                                    }//End of If
                                                }
                                                else if(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null && !soldiff.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)){
                                                    String subscriptionProducts = '';
                                                    if(opp.Type == EXCLUDE_OPPTY_TYPE && oli.ProductCode == SANDBOX_PRODUCT_CODE ){
                                                        if(oli.SBQQ__QuoteLine__r.SBQQ__Existing__c){
                                                            if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c > 0){  
                                                                if(oli.SBQQ__QuoteLine__r.Qty_Diff__c > 0){
                                                                    subscriptionProducts = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.Qty_Diff__c  + '\n';
                                                                }
                                                            }
                                                        }else if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c > 0){
                                                            subscriptionProducts = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c  + '\n';
                                                        }
                                                    }else if(oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c > 0){
                                                        subscriptionProducts = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n';
                                                    }
                                                    soldiff.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,subscriptionProducts);
                                                    // This code added as part of Phoenix on 25th July 2018 
                                                    if(oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && !BundleWithGroupMap.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c) && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name!=null){
                                                        BundleWithGroupMap.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                                                    }//End of If
                                                }
                                            }
                                            //Adding Bundle Lines to the Map soldiff
                                            if(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c == null && soldiff.containsKey(oli.SBQQ__QuoteLine__c)){
                                                String BundleProduct = soldiff.get(oli.SBQQ__QuoteLine__c);
                                                if(oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c >0){
                                                    BundleProduct = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n' + BundleProduct;
                                                }
                                                soldiff.put(oli.SBQQ__QuoteLine__c,BundleProduct);
                                                // This code added as part of Phoenix on 25th July 2018 
                                                if(oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && !BundleWithGroupMap.containsKey(oli.SBQQ__QuoteLine__c) && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name!=null){
                                                    BundleWithGroupMap.put(oli.SBQQ__QuoteLine__c,oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                                                }//End of If
                                            }
                                            
                                            if(oli.Product_Type__c == OPPTY_PRODUCT_TYPE_SERVICES && !mprubiksSand.containsKey(oli.Product2.Name) && !mprubiksProd.containsKey(oli.Product2.Name) && oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c > 0){
                                                // && oli.SBQQ__QuoteLine__r.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c != 'Never'){
                                                serviceProducts = serviceProducts + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n';
                                            }
                                        }
                                    }
                                    else{
                                        if(oli.Product_Type__c == OPPTY_PRODUCT_TYPE_SUBSCRIPTIONS && !mprubiksSand.containsKey(oli.Product2.Name) && !mprubiksProd.containsKey(oli.Product2.Name)){
                                            // && oli.SBQQ__QuoteLine__r.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c != 'Never' ){      
                                            if(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null && soldiff.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)){
                                                String str = soldiff.get(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);
                                                if(opp.Type == EXCLUDE_OPPTY_TYPE && oli.ProductCode == SANDBOX_PRODUCT_CODE ){
                                                    if(oli.SBQQ__QuoteLine__r.SBQQ__Existing__c){
                                                        if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c > 0){  
                                                            if(oli.SBQQ__QuoteLine__r.Qty_Diff__c > 0){
                                                                str = str + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.Qty_Diff__c  + '\n';
                                                            }
                                                        }
                                                    }else if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c > 0){
                                                        str = str + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c  + '\n';
                                                    }
                                                }else if(oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c >0){
                                                    str = str + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n';
                                                }
                                                soldiff.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,str);
                                                // This code added as part of Phoenix on 25th July 2018 
                                                if(oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && !BundleWithGroupMap.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c) && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name!=null){
                                                    system.debug('########### 3 '+oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                                                    BundleWithGroupMap.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                                                }//End of If
                                            }else if(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null && !soldiff.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)){
                                                String subscriptionProducts = '';
                                                if(opp.Type == EXCLUDE_OPPTY_TYPE && oli.ProductCode == SANDBOX_PRODUCT_CODE ){
                                                    if(oli.SBQQ__QuoteLine__r.SBQQ__Existing__c){
                                                        if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c > 0){  
                                                            if(oli.SBQQ__QuoteLine__r.Qty_Diff__c > 0){
                                                                subscriptionProducts = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.Qty_Diff__c  + '\n';
                                                            }
                                                        }
                                                    }else if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c > 0) {
                                                        subscriptionProducts = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c  + '\n';
                                                    }
                                                }else if(oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c > 0){
                                                    subscriptionProducts = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n';
                                                }
                                                soldiff.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,subscriptionProducts);
                                                // This code added as part of Phoenix on 25th July 2018 
                                                if(oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && !BundleWithGroupMap.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c) && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name!=null){
                                                    system.debug('########### 1 '+oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                                                    BundleWithGroupMap.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                                                }//End of If
                                            }                                     
                                        }
                                        //Adding Bundle Lines to the Map soldiff
                                        if(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c == null && soldiff.containsKey(oli.SBQQ__QuoteLine__c)){
                                            String BundleProduct = soldiff.get(oli.SBQQ__QuoteLine__c);
                                            if(oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c > 0){
                                                BundleProduct = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n' + BundleProduct;
                                            }
                                            // This code added as part of Phoenix on 25th July 2018 
                                            if(oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && !BundleWithGroupMap.containsKey(oli.SBQQ__QuoteLine__c) && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name!=null){
                                                system.debug('########### 2 '+oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                                                BundleWithGroupMap.put(oli.SBQQ__QuoteLine__c,oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                                            }//End of If
                                            soldiff.put(oli.SBQQ__QuoteLine__c,BundleProduct);
                                        }
                                        system.debug('Non MDQ Check map'+soldiff); 
                                        
                                        if(oli.Product_Type__c == OPPTY_PRODUCT_TYPE_SERVICES && !mprubiksSand.containsKey(oli.Product2.Name) && !mprubiksProd.containsKey(oli.Product2.Name) && oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c > 0){
                                            // && oli.SBQQ__QuoteLine__r.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c != 'Never'){
                                            serviceProducts = serviceProducts + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n';
                                        }
                                    }
                                } 
                            }//End of SBPB
                            /****************************************************************
                            *Last modified By    : Priyanka Shende, Jade Global Inc.
                            *Last modifieddate   : 25th May 2017
                            *Purpose             : To handle Legacy Opty Scenario
                            *Line No             :  164 to 179     
                            *        
                            ******************************************************************/
                            else{
                                system.debug('Inside Legacy @@@@@@@@@@@@@');
                                string soldiffKeyForLegacy='Legacy';
                                if( oli.Product_Type__c == OPPTY_PRODUCT_TYPE_SUBSCRIPTIONS && oli.MKTO_Product_Name__c!=null && !soldiff.containsKey(soldiffKeyForLegacy)){
                                    string legacyProduct=oli.MKTO_Product_Name__c + ' - ' + oli.Contract_Quantity__c  + '\n';
                                    system.debug('############### legacyProduct If'+ legacyProduct);
                                    soldiff.put(soldiffKeyForLegacy,legacyProduct);
                                }//End of If
                                else If(oli.Product_Type__c == OPPTY_PRODUCT_TYPE_SUBSCRIPTIONS  && soldiff.containsKey(soldiffKeyForLegacy) ){
                                    string legacyProduct=oli.MKTO_Product_Name__c + ' - ' + oli.Contract_Quantity__c  + '\n';
                                    string str= soldiff.get(soldiffKeyForLegacy);
                                    string finalstr= str + legacyProduct;
                                    system.debug('finalstr #######'+finalstr);
                                    soldiff.put(soldiffKeyForLegacy,finalstr);
                                }//End of else
                                if(oli.Product_Type__c == OPPTY_PRODUCT_TYPE_SERVICES){
                                    serviceProducts = serviceProducts + oli.MKTO_Product_Name__c + ' - ' + oli.Contract_Quantity__c  + '\n';
                                }
                            }//End of non Steelbrick If
                            
                        }
                        boolean checker=false;
                        cs.Subscriptions__c = '';
                        
                        integer counter = 0;
                        Set<String> GroupNames = new Set<String>();
                        map<String, List<String>> phonixSubscriptionMap = new map<String, List<String>>();
                        for(string s:soldiff.keyset()){
                            
                            counter++;
                            if(opp.SBQQ__PrimaryQuote__r.Instance_Rollup__c != null && opp.SBQQ__PrimaryQuote__r.Instance_Rollup__c > 1 && opp.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c==false){ // Added the check to Include only MultiInstance
                                cs.Subscriptions__c += '---------Solution #'+counter+'---------'+'\n'+soldiff.get(s);
                            }
                            else if(opp.SBQQ__PrimaryQuote__r.Instance_Rollup__c != null && opp.SBQQ__PrimaryQuote__r.Instance_Rollup__c == 1 && opp.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c==false){ // Added the check to Include Single Instance 
                                cs.Subscriptions__c += '---------Solution---------'+'\n'+soldiff.get(s);
                            }
                            // Added Phoenix condition to display subscription based on Group
                            else if(opp.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c){
                                if(BundleWithGroupMap.containsKey(s)){
                                    system.debug('########### Bundle Map'+ BundleWithGroupMap.get(s));
                                    if(phonixSubscriptionMap.containsKey(BundleWithGroupMap.get(s))){ 
                                        phonixSubscriptionMap.get(BundleWithGroupMap.get(s)).add(soldiff.get(s));
                                    }else{
                                        phonixSubscriptionMap.put(BundleWithGroupMap.get(s),new List<string>{soldiff.get(s)});
                                    }
                                }//End of If
                            }
                            else if(opp.Pricebook2Id!=SBPB.ID__c && !SBPB.Phoenix_Price_Books__c.contains(opp.Pricebook2Id) && opp.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c== false){
                                cs.Subscriptions__c += '---------Legacy Solution---------'+'\n'+soldiff.get(s);
                            }
                        }
                        // Added Phoenix condition to display subscription based on Group
                        if(!phonixSubscriptionMap.KeySet().isEmpty()){
                            for(String GroupName: phonixSubscriptionMap.KeySet()){
                                cs.Subscriptions__c += '\n'+GroupName+'\n';
                                integer bundleCounter = 0;
                                for(String bundleSubscriptions: phonixSubscriptionMap.get(GroupName)){
                                    bundleCounter++;
                                    cs.Subscriptions__c += '---------Phoenix #'+bundleCounter+' ---------'+'\n'+bundleSubscriptions;
                                }
                            }
                        }
                        system.debug('Subscriptions - '+cs.Subscriptions__c);    
                        if(serviceProducts != ''){
                            cs.Services__c = serviceProducts;
                        }
                        system.debug('Services - '+cs.Services__c);
                        if(opp.Type != null && opp.AccountId != null){
                            cs.Subject = opp.Type + '-' + opp.Account.Name;
                        }
                        for(String flName : mapOpporToCase.keySet()){
                            String OPPTY_FIELD_NAME = mapOpporToCase.get(flName).OpportunityFieldName__c;
                            if(mapOpporToCase.get(flName).IsField__c){
                                Object oppFieldObject ;
                                sObject oliRec = opp;
                                String oppFieldName = OPPTY_FIELD_NAME;
                                //BELOW CODE CHECKS IF THERE IS ANY LOOKUP FIELD THEN FETCH THE DATA FORM THAT FIELD
                                if(oppFieldName != null || oppFieldName != ''){                                            
                                    if(oppFieldName.contains('.')){
                                        List<String> subfield = oppFieldName.split('\\.');
                                        sObject finalObj;
                                        integer lstSze = subfield.Size();
                                        for(integer i = 0; i < (lstSze - 1) ; i++){
                                            if(finalObj != null){
                                                finalObj = finalObj.getSObject(subfield[i]);
                                            }else{
                                                finalObj = opp.getSObject(subfield[i]);
                                            }
                                        }
                                        if(finalObj != null){
                                            oppFieldObject = finalObj.get(subfield[lstSze - 1]);
                                        }
                                    }else{
                                        oppFieldObject = oliRec.get(oppFieldName);
                                    }
                                }
                                if(oppFieldObject != null){
                                    cs.put(flName,oppFieldObject);
                                }
                            }else{
                                cs.put(flName,OPPTY_FIELD_NAME);// DIRECTLY PASSING THE FIELD VALUE FORM THE CUSTOM SETTING RECORD.
                            }
                        }
                        //if account prefix not populated on case it will take from its contract -> primary Assets -> prefix
                        if(cs.Account_String__c==null && (opp.type==label.OPPORTUNITY_TYPE_RENEWAL && opp.SBQQ__RenewedContract__c!=null && opp.SBQQ__RenewedContract__r.Primary_Asset__c!=null) || (opp.type==label.OPPORTUNITY_TYPE_UPSELL_CROSSELL && opp.SBQQ__AmendedContract__c!=null && opp.SBQQ__AmendedContract__r.Primary_Asset__c!=null)){
                            if(opp.type==label.OPPORTUNITY_TYPE_RENEWAL){
                                cs.Account_String__c = opp.SBQQ__RenewedContract__r.Primary_Asset__r.Acct_Prefix__c; 
                            }else if(opp.type==label.OPPORTUNITY_TYPE_UPSELL_CROSSELL){
                                cs.Account_String__c = opp.SBQQ__AmendedContract__r.Primary_Asset__r.Acct_Prefix__c;
                            }
                        }
                        caseToBeCreated.add(cs);
                        
                    }  
                }
                if(!caseToBeCreated.isEmpty()){
                    Database.DMLOptions dmo = new Database.DMLOptions();//TO RUN THE ASSIGNMENT RULES FROM HERE
                    dmo.assignmentRuleHeader.useDefaultRule = true;
                    dmo.EmailHeader.triggerAutoResponseEmail = true;
                    dmo.EmailHeader.triggerUserEmail=true;
                    Database.insert(caseToBeCreated, dmo);
                }
            }
        }catch(Exception e){
            system.debug('EXCEPTION IN CASE PROVISIONING');
            system.debug('============================================'+e.getMessage());
            system.debug('============================================'+e.getCause());
            system.debug('============================================'+e.getLineNumber());
            /* ***************************************************************************************************************
         *  Modified By         : Priyanka Shende, Jade Global Inc, On 26th June 2018
         *  Purpose             : Handle Opportunity Closed Won - Too Many SOQL Queries Exception(Trouble Closing out Opp) - JIRA : APPS-19978,APPS-20808
         *********************************************************************************************************** */
        List<Opportunity> oppList = [select Id , Provisioning_Case_Creation_Exception__c from Opportunity where Id IN:newOppVersion];
        for(Opportunity opp : oppList){
            opp.Provisioning_Case_Creation_Exception__c= e.getMessage()+':'+e.getLineNumber();
        }
        update oppList; 
        } 
    }
    
    /******* APPS-12903 For Creating cases for ramp deals *********/
    public static void create2ndSegmentProvisioningCase(Opportunity opp){
        /// system.debug('segmentedOLIids---->'+segmentedOLIids);
        
        try{ 
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
                    }
                }
                mapOpporToCase.put(mapCaseFields.Name,mapCaseFields);
            }
            //On New Business opportunity not populating the account prefix and for 2nd to nth segment populating the prefix from contract
            Map<Id,String> OppIdAndAccountPrefix = new Map<Id,String>();
            for(Contract con:[SELECT id,SBQQ__Opportunity__c,Primary_Asset__c,Primary_Asset__r.Acct_Prefix__c From Contract WHERE Primary_Asset__c!=null AND Primary_Asset__r.Acct_Prefix__c!=null AND SBQQ__Opportunity__c=:opp.id]){
                OppIdAndAccountPrefix.put(con.SBQQ__Opportunity__c,con.Primary_Asset__r.Acct_Prefix__c);
            }
            system.debug('OppIdAndAccountPrefix ###########'+OppIdAndAccountPrefix);
            /****************************************************************
            *Last modified By    : Jade Global
            *Last modifieddate   : 18th May 2017
            *Purpose             : To add product to correct Solution instance in case of Multi-Instance Quote
            *Changes             : Added below SOQL opportunityLineitem          
            SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,
            Updated the data population in soldiff map
            replace oli.Instance_ID__c with oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c
            *        
            *
            ******************************************************************/
            
            Map<string,string> soldiff = new Map<string,string>();
            //String subscriptionProducts = '';
            String serviceProducts = '';
            Case cs = new Case();
            //FETCHING THE SUBSCRIPTION AND SERVICES PRODUCT NAME AND CONTRACT QUANITY FROM THE RELATED LINE ITEMS.
            /* ************************************************************************************
            * Modified By         : Priyanka Shende, Jade Global Inc
            * Modified Date       : 16th August 2017
            * Purpose             : APPS-15440: Adding Dropping Products on MDQ Renewals
            While inserting 2ndSegment case on Close won of Opty populate Added and Dropped Product on Case
            *************************************************************************************** */ 
            if(opp.OpportunityLineitems != null){
                Map<String,String> BundleWithGroupMap = new Map<String,String>();
                if(opp.OpportunityLineitems[0].SBQQ__QuoteLine__c!=null){
                    segementStartDate = opp.OpportunityLineitems[0].SBQQ__QuoteLine__r.SBQQ__StartDate__c;
                    segementEndDate   = opp.OpportunityLineitems[0].SBQQ__QuoteLine__r.SBQQ__EndDate__c;
                    segmentIndex      = opp.OpportunityLineitems[0].SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c;
                }
                
                if(segmentIndex!=null){
                    cs.Segment_Index__c=segmentIndex;
                }
                
                Map<string,list<string>> AddedDroppedMap = new Map<string,list<string>>();
                if(Test.isRunningTest()){
                    createProvisioningCaseTest cObj = new createProvisioningCaseTest();
                    AddedDroppedMap=cObj.ReturnProductMap();                          
                }else{
                    AddedDroppedMap=AddingDroppingProdController.populateAddedDroppedProductsOnMDQ2ndSegmentCase(opp);
                }
                
                if(!AddedDroppedMap.IsEmpty()){
                    if(AddedDroppedMap.containsKey('Added Products')){
                        
                        List<string> AddedProducts=AddedDroppedMap.get('Added Products');
                        
                        if(!AddedProducts.IsEmpty()){
                            for(String s:AddedProducts){
                                
                                if(cs.Added_Products__c==NULL){                         
                                    cs.Added_Products__c=s;
                                }
                                else{
                                    cs.Added_Products__c=cs.Added_Products__c + ',' + s; 
                                }
                            }
                        } 
                    }//End of Added Product  
                    
                    if(AddedDroppedMap.containsKey('Dropped Products')){
                        
                        List<string> DroppedProducts=AddedDroppedMap.get('Dropped Products');
                        
                        if(!DroppedProducts.IsEmpty()){ 
                            
                            for(String s:DroppedProducts){
                                
                                if(cs.Dropped_Products__c==NULL){                           
                                    cs.Dropped_Products__c=s;
                                }
                                else{   
                                    cs.Dropped_Products__c=cs.Dropped_Products__c +',' + s;     
                                }
                            }
                        }
                    }//End of Dropped Products
                    
                    if(AddedDroppedMap.containsKey('QuantityChangedProduct')){
                        
                        List<string> QuantityChangedProducts=AddedDroppedMap.get('QuantityChangedProduct');
                        system.debug('QuantityChangedProducts ############'+QuantityChangedProducts);
                        if(!QuantityChangedProducts.IsEmpty()){ 
                            for(String s:QuantityChangedProducts){
                                
                                if(cs.Quantity_Change_on_Existing_Products__c==NULL){                           
                                    cs.Quantity_Change_on_Existing_Products__c=s;
                                }
                                else{   
                                    cs.Quantity_Change_on_Existing_Products__c=cs.Quantity_Change_on_Existing_Products__c +',' + s;     
                                }
                            }
                        }
                    }//End of Quantity Change                 
                }//End of Adding,Dropping And Quantity Change If
                //If added product or Droppoed product or quantity changed product not equals to null then that case send to provision
                if(cs.Added_Products__c!=null || cs.Dropped_Products__c!=null || cs.Quantity_Change_on_Existing_Products__c!=null){
                    cs.Send_Case_to_SPA__c=true;
                }
                system.debug('cs.Quantity_Change_on_Existing_Products__c'+cs.Quantity_Change_on_Existing_Products__c);
                for(OpportunityLineitem oli: opp.OpportunityLineitems){
                    
                    if(opp.SBQQ__PrimaryQuote__r.Mdq_quote__c){
                        
                        if(oli.Product_Type__c == OPPTY_PRODUCT_TYPE_SUBSCRIPTIONS && !mprubiksSand.containsKey(oli.Product2.Name) && !mprubiksProd.containsKey(oli.Product2.Name)){
                            // && oli.SBQQ__QuoteLine__r.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c != 'Never'){    
                            if(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null && soldiff.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)){
                                String str = soldiff.get(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);
                                if(opp.Type == EXCLUDE_OPPTY_TYPE && oli.ProductCode == SANDBOX_PRODUCT_CODE ){
                                    if(oli.SBQQ__QuoteLine__r.SBQQ__Existing__c){
                                        if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c > 0){  
                                            if(oli.SBQQ__QuoteLine__r.Qty_Diff__c > 0){
                                                str = str + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.Qty_Diff__c  + '\n';
                                            }
                                        }
                                    }else if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c >0){
                                        str = str + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c  + '\n';
                                    }
                                }else if(oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c >0){
                                    str = str + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n';
                                }
                                soldiff.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,str);
                                // This code added as part of Phoenix
                                if(oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && !BundleWithGroupMap.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c) && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name!=null){
                                    BundleWithGroupMap.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                                }//End of If
                            }
                            else if(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null && !soldiff.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)){
                                string subscriptionProducts = '';
                                if(opp.Type == EXCLUDE_OPPTY_TYPE && oli.ProductCode == SANDBOX_PRODUCT_CODE ){
                                    if(oli.SBQQ__QuoteLine__r.SBQQ__Existing__c){
                                        if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c > 0){  
                                            if(oli.SBQQ__QuoteLine__r.Qty_Diff__c > 0){
                                                subscriptionProducts = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.Qty_Diff__c  + '\n';
                                            }
                                        }
                                    }else if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c >0){
                                        subscriptionProducts = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c  + '\n';
                                    }
                                }else if(oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c > 0){
                                    subscriptionProducts = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n';
                                }
                                soldiff.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,subscriptionProducts);
                                // This code added as part of Phoenix
                                if(oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && !BundleWithGroupMap.containsKey(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c) && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name!=null){
                                    BundleWithGroupMap.put(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                                }//End of If
                            }
                        }
                        //Adding Bundle Lines to the Map soldiff
                        if(oli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c == null && soldiff.containsKey(oli.SBQQ__QuoteLine__c)){
                            String BundleProduct = soldiff.get(oli.SBQQ__QuoteLine__c);
                            if(oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c>0){
                                BundleProduct = oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n' + BundleProduct;
                            }
                            soldiff.put(oli.SBQQ__QuoteLine__c,BundleProduct);
                            // This code added as part of Phoenix
                            if(oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && !BundleWithGroupMap.containsKey(oli.SBQQ__QuoteLine__c) && oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name!=null){
                                BundleWithGroupMap.put(oli.SBQQ__QuoteLine__c,oli.SBQQ__QuoteLine__r.SBQQ__Group__r.Name);
                            }//End of If
                        }
                        if(oli.Product_Type__c == OPPTY_PRODUCT_TYPE_SERVICES && !mprubiksSand.containsKey(oli.Product2.Name) && !mprubiksProd.containsKey(oli.Product2.Name) && oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c>0){
                            //&& oli.SBQQ__QuoteLine__r.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c != 'Never'){
                            serviceProducts = serviceProducts + oli.MKTO_Product_Name__c + ' - ' + oli.SBQQ__QuoteLine__r.SBQQ__Quantity__c  + '\n';
                        }
                        
                    }
                }
                boolean checker=false;
                integer cnt = 0;
                cs.Subscriptions__c = '';
                map<String, List<String>> phonixSubscriptionMap = new map<String, List<String>>();
                for(string s:soldiff.keyset()){
                    cnt++;
                    // This additional condition SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c-> false is added as part of Phoenix
                    if(opp.SBQQ__PrimaryQuote__r.Instance_Rollup__c != null && opp.SBQQ__PrimaryQuote__r.Instance_Rollup__c > 1 && opp.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c==false){ // Added the check to Include only MultiInstance instance 
                        cs.Subscriptions__c += '---------Solution #'+cnt+'---------'+'\n'+soldiff.get(s);
                    }
                    else if(opp.SBQQ__PrimaryQuote__r.Instance_Rollup__c != null && opp.SBQQ__PrimaryQuote__r.Instance_Rollup__c == 1 && opp.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c==false){ // Added the check to Include Single Instance 
                        cs.Subscriptions__c += '---------Solution---------'+'\n'+soldiff.get(s);
                    }
                    //This code is added as part of Phoenix
                    else if(opp.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c){
                        if(BundleWithGroupMap.containsKey(s)){
                            system.debug('########### Bundle Map'+ BundleWithGroupMap.get(s));
                            if(phonixSubscriptionMap.containsKey(BundleWithGroupMap.get(s))){ 
                                phonixSubscriptionMap.get(BundleWithGroupMap.get(s)).add(soldiff.get(s));
                            }else{
                                phonixSubscriptionMap.put(BundleWithGroupMap.get(s),new List<string>{soldiff.get(s)});
                            }
                        }//End of If
                    }//End of else If   
                }
                // Added Phoenix condition to display subscription based on Group
                if(!phonixSubscriptionMap.KeySet().isEmpty()){
                    for(String GroupName: phonixSubscriptionMap.KeySet()){
                        cs.Subscriptions__c += '\n'+GroupName+'\n';
                        integer bundleCounter = 0;
                        for(String bundleSubscriptions: phonixSubscriptionMap.get(GroupName)){
                            bundleCounter++;
                            cs.Subscriptions__c += '---------Phoenix #'+bundleCounter+' ---------'+'\n'+bundleSubscriptions;
                        }
                    }//End of For
                }//End of If
                system.debug('Subscriptions - '+cs.Subscriptions__c);    
                if(serviceProducts != ''){
                    cs.Services__c = serviceProducts;
                }
                system.debug('Services - '+cs.Services__c);
                if(opp.Type != null && opp.AccountId != null){
                    cs.Subject = opp.Type + '-' + opp.Account.Name;
                }
                for(String flName : mapOpporToCase.keySet()){
                    String OPPTY_FIELD_NAME = mapOpporToCase.get(flName).OpportunityFieldName__c;
                    if(mapOpporToCase.get(flName).IsField__c){
                        Object oppFieldObject ;
                        sObject oliRec = opp;
                        String oppFieldName = OPPTY_FIELD_NAME;
                        //BELOW CODE CHECKS IF THERE IS ANY LOOKUP FIELD THEN FETCH THE DATA FORM THAT FIELD
                        if(oppFieldName != null || oppFieldName != ''){                                            
                            if(oppFieldName.contains('.')){
                                List<String> subfield = oppFieldName.split('\\.');
                                sObject finalObj;
                                integer lstSze = subfield.Size();
                                for(integer i = 0; i < (lstSze - 1) ; i++){
                                    if(finalObj != null){
                                        finalObj = finalObj.getSObject(subfield[i]);
                                    }else{
                                        finalObj = opp.getSObject(subfield[i]);
                                    }
                                }
                                if(finalObj != null){
                                    oppFieldObject = finalObj.get(subfield[lstSze - 1]);
                                }
                            }else{
                                oppFieldObject = oliRec.get(oppFieldName);
                            }
                        }
                        if(oppFieldObject != null){
                            cs.put(flName,oppFieldObject);
                        }
                    }else{
                        cs.put(flName,OPPTY_FIELD_NAME);// DIRECTLY PASSING THE FIELD VALUE FORM THE CUSTOM SETTING RECORD.
                    }
                }
                cs.Master_Sub_End_Date__c=segementEndDate;
                cs.Master_Sub_Start_Date__c=segementStartDate;
                
                // populate account string on 2nd to nth segment
                if(cs.Account_String__c==null && (opp.type==label.OPPORTUNITY_TYPE_NEW_BUSINESS || opp.type==label.OPPORTUNITY_TYPE_RENEWAL) && OppIdAndAccountPrefix.containsKey(opp.id)){
                    cs.Account_String__c =OppIdAndAccountPrefix.get(opp.id);
                }else if(cs.Account_String__c==null && opp.type==label.OPPORTUNITY_TYPE_UPSELL_CROSSELL && opp.SBQQ__AmendedContract__c!=null && opp.SBQQ__AmendedContract__r.Primary_Asset__c!=NULL && opp.SBQQ__AmendedContract__r.Primary_Asset__r.Acct_Prefix__c!=null){
                    cs.Account_String__c=opp.SBQQ__AmendedContract__r.Primary_Asset__r.Acct_Prefix__c;
                }//End of If
                
                segementEndDate=null;
                segementStartDate=null;
                if(cs.Segment_Index__c!=1)
                {
                    caseToBeCreated.add(cs);
                }
            }  
            system.debug('===============caseToBeCreated========'+caseToBeCreated);
            
            if(!caseToBeCreated.isEmpty()){
                Database.DMLOptions dmo = new Database.DMLOptions();//TO RUN THE ASSIGNMENT RULES FROM HERE
                dmo.assignmentRuleHeader.useDefaultRule = true;
                dmo.EmailHeader.triggerAutoResponseEmail = true;
                dmo.EmailHeader.triggerUserEmail=true;
                Database.insert(caseToBeCreated, dmo);
                
            }
            //}
        }catch(Exception e){
            system.debug('EXCEPTION IN SEGMENT CASE PROVISIONING-  ');
            system.debug('============================================'+e.getMessage());
            system.debug('============================================'+e.getCause());
            system.debug('============================================'+e.getLineNumber());
            system.debug('============================================'+e.getStackTraceString());
        }
    }
    /******* APPS-12903 For Creating cases for ramp deals *********/
    
    public static  void testAddingDroppingProducts(){      
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
        List<Account> accountsToInsertList = new List<Account>();

        for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            //accnt.RecordTypeId = '01250000000ULb7AAG'; 
            accountsToInsertList.add(accnt);
        }
            //insert accountsToInsertList;
            for(Account acc : accountsToInsertList){
                accountsToInsertSet.add(acc.Id);
            }
           
        list<Contact> ContactToInsert = new list<Contact>();
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,2);
       for(Contact con:ContactToInsert ){
                con.pse__Salesforce_User__c  =null;
              
         }
        //Contact con = new Contact(firstname='First Name', lastname='Last Name', AccountId=accountsToInsertList[0].id);
        //insert ContactToInsert;
        for(Contact c: ContactToInsert)
        {
             c.pse__Salesforce_User__c  =null;
        }
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(5);
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
          productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTPtest'; 
        productToInsertList[2].Family= 'Product test';
         productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTPtest'; 
        productToInsertList[2].Family= 'Product test';
         productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTPtest'; 
        productToInsertList[2].Family= 'Product test';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTPtest'; 
        productToInsertList[2].Family= 'Product test';
        
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        List<Contract> contractList = new List<Contract>();
        List<Contract> contractList1 = new List<Contract>();
        List<Contract> contractList2 = new List<Contract>();
        List<Contract> contractList3 = new List<Contract>();
           
         Contract contract1 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true, ContractTerm = 2);         
         Contract contract2 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
         Contract contract3 = new Contract(Name='Test Contract ',  StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 3);
         Contract contract4 = new Contract(Name='Test Contract ',  StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm =4 );
         Contract contract5 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true, ContractTerm = 2);         
         Contract contract6 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
         Contract contract7 = new Contract(Name='Test Contract ',  StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 3);
         Contract contract8 = new Contract(Name='Test Contract ',  StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm =4 );
         contractList.add(contract1);
         contractList.add(contract2);
         contractList.add(contract3);
         contractList.add(contract4);
         contractList.add(contract6);
         contractList.add(contract7);
         contractList.add(contract8);
         
        for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            //accnt.RecordTypeId = '01250000000ULb7AAG'; 
            accountsToInsertList.add(accnt);
        }
         for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            //accnt.RecordTypeId = '01250000000ULb7AAG'; 
            accountsToInsertList.add(accnt);
        }
        
		 for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            //accnt.RecordTypeId = '01250000000ULb7AAG'; 
            accountsToInsertList.add(accnt);
        }
         for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            //accnt.RecordTypeId = '01250000000ULb7AAG'; 
            accountsToInsertList.add(accnt);
        }
        
        // insert products into standard pricebook
        List<Contract> contractListDetails = new List<Contract>();
        List<Contract> contractLists = new List<Contract>();
        List<Contract> contractListDetail = new List<Contract>();
        List<Contract> contractDataList = new List<Contract>();
           
         Contract contract12 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true, ContractTerm = 2);         
         Contract contract22 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
         Contract contract31 = new Contract(Name='Test Contract ',  StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 3);
         Contract contract42 = new Contract(Name='Test Contract ',  StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm =4 );
         Contract contract51 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true, ContractTerm = 2);         
         Contract contract62 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
         Contract contract73 = new Contract(Name='Test Contract ',  StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 3);
         
         // insert products into standard pricebook
        List<Contract> contractList12Details = new List<Contract>();
        List<Contract> contract34Lists = new List<Contract>();
        List<Contract> contract12ListDetail = new List<Contract>();
        List<Contract> contract45DataList = new List<Contract>();
    }
    
}