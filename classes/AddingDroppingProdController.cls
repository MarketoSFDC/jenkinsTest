/* ********************************************************************************************************************
* Created By        : Priyanka Shende on 5th July 2017, Jade global Inc.
* Purpose           : Provisioning team should know which products are being added or dropped during a renewal opportunity.

* Last Modified By  : Priyanka Shende on 4th October 2017, Jade Global Inc.
* Purpose           : 1. Handle Early Renewal Dropped Scenario

* Last Modified By  : Priyanka Shende on 9th November 2017, Jade Global Inc.
* Purpose           : 1. If Opportunity Line is not created for Early renewal record(Product Quantity = 0) then the product should not dropped.
		     
* Last modified By : Priyanka Shende, Jade Global Inc on 1st August 2018
* Purpose          : Change quantity associated with Life Cycle Modeler : APPS-20694 

* Last modified By : Tushar Misri, Grazitti Interactive, 27th July 2018
* Purpose          : APPS-20840, Field Cleanup Project - Phase One
                     Fields which are being commented out:
                     sandbox_account_prefix__c

* Last Modified By: Jade Global Inc, on 8th September 2018
* Purpose         : To handle Phoenix Provisioning Scenarios
					Added Group Line Item Change, populated added,Dropped and Quantity changed Products for phoenix
* *********************************************************************************************************************/

public class AddingDroppingProdController{
    
    //To display list of OLI on VF Component
    public  static list<string> AddedProducts                                = new  list<string>();
    public  static list<string> DroppedProducts                              = new  list<string>();
    public  static list<string> QuantityChangedProducts                      = new  list<string>();
    public  static Map<String, List<String>> MultiInstAddedProducts          = new  Map<String, List<String>>();
    public  static Map<string,List<string>> MultiInstDroppedProducts         = new  Map<string,List<string>>();
    public  static Map<string,List<string>> MultiInstQuantityChangedProducts = new Map<string,List<string>>();
    public  static id opportunityId,priorOpportunityId;
    public  static map<string,list<string> > AddedDroppedMap                 = new map<string,list<string> >();
    public  static list<SBQQ__Subscription__c> PriorOppsSubscriptionList     = new list<SBQQ__Subscription__c> (); 
    public  static list<SBQQ__Subscription__c> PriorOppSubList               = new list<SBQQ__Subscription__c> ();   
    public  static map<string,string> BundleAndMunchkinMap                   = new map<string,string>();
    public  static Set<Id> AcctPrefixAssetIds                                = new Set<Id>();
    Public  static Map<String,String> accPrefixAndMunchkin                   = new Map<String,String>();
    public  static Map<String,Map<String,String>> MunchkinAndProducts        = new Map<String,Map<String,String>>();
    public  static Map<Id,Id> OLIRequiredByAndAssetId                        = new Map<Id,Id>();
    
    public  static map<string,list<string> > populateAddedDroppedProductsOnCase(Opportunity o) {   
        opportunityId                                                                       = o.Id;
        string AddedProduct                                                                 = '';
        string QuantityChangedProduct                                                       = '';
        string DroppedProduct                                                               = '';
        Double priorOptyInstanceRollup;
        // string MKTO_PriceBook_ID=Label.MKTOPriceBookId;
        Map<String,String> rubikProdCodeMap                                                 = new Map<String,String>();
        Map<String,Product_SKU_Engineering_Code__c> ProductSKUEngineeringCode               = new Map<String,Product_SKU_Engineering_Code__c>();
        String RENEWAL_OPPTY                                                                = Label.OPPORTUNITY_TYPE_RENEWAL;
        string Product_Type                                                                 = Label.PRODUCT_TYPE_SUBSCRIPTIONS;
        String CLOSED_WON_OPPTY                                                             = Label.OPPORTUNITY_STAGE_CLOSED_WON;
        Set<ID> oppIdSetRecHandler                                                          = new Set<Id>();
        Opportunity OppInstance                                                             = new Opportunity();
        List<Opportunity> relevantOppsList                                                  = new List<Opportunity>();
        Id ContractId;
        Set<String> AccountPrefix                                                           = new Set<String>();
        Decimal OptyInstanceRollup;
        Boolean PhoenixQuote = false;                                                         
        //account id to opportunity map
        Map<Id,List<Opportunity>> accIdToOpportunitiesMap                                   = new Map<Id,List<Opportunity>>(); 
        map<string,opptyLineItems> ProdCodeToPriorSubMap                                    = new map<string,opptyLineItems> ();
        map<string,opptyLineItems> ProdCodeToOldOLIMapRenewal                               = new map<string,opptyLineItems> ();
        String MunchkinId;
        //Current opportunity product code to OLI map
        Map<String,List<OpportunityLineItem>> prodCodeToOliMap                              = new Map<String,List<OpportunityLineItem>>();
        
        //Current opp Id to OLI map
        Map<Id,List<OpportunityLineItem>> newOppIdToOliMap                                  = new Map<Id,List<OpportunityLineItem>>();
        list<string>list1=new list<string>();
        //used for handle multi instance scenario
        List<OpportunityLineItem> OLIList                                                   = new List<OpportunityLineItem>();
        
        set<id> PriorReqIds                                                                 = new set<id>();
        map<id,id> curReqByIdPriorReqIds                                                    = new map<id,id>();
        map<id,set<string>> PriorReqIdWithChildQLIIds                                       = new map<id,set<string>>();
        map<id,id> curReqByIdtoPriorAssetId                                                 = new map<id,id>();
        String Reqby                                                                        ='';
        Decimal subQuantity,currentOLIMaxDB,difOfOliQty,maxDBSize,maxDBDif,maxDBSize2,oliQuantity1,currentOLIMaxDB1,difOfOliQty1,maxDBSize1,maxDBDif1,oliQuantity ;
        String EnggCode,AccntId;
        Boolean priorOptyContractRubiksQuote,ProvisioningQuote=False;
        
        //ProductSKUEngineeringCode populated to consider products from Product_SKU_Engineering_Code__c in Adding Dropping Functionality 
        for(Product_SKU_Engineering_Code__c thisCustSetRec :Product_SKU_Engineering_Code__c.getAll().values()){
            ProductSKUEngineeringCode.put(thisCustSetRec.Product_Code__c, thisCustSetRec);
        }//end of for loop  
        
        if(opportunityId!=null ){ 
            
            //Variable declaration
            Date CurrentOptyContractStartDate = null;
            Boolean EarlyRenewal = false;
            
            // Latest Closed won OLI List
            OppInstance=[SELECT Id,Prior_Opportunity__c,SBQQ__PrimaryQuote__r.Instance_Rollup__c,SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,Type,SBQQ__Contracted__c,isWon,Name,StageName,/*Sandbox_account_prefix__c,*/Account_String__c,CloseDate,AccountId,Prior_Opportunity__r.id,Prior_Opportunity__r.CloseDate,Prior_Opportunity__r.isWon,Prior_Opportunity__r.Opportunity_ARR2012__c,Sub_End_Date__c,Sub_Start_Date__c,Prior_Opportunity_ExchangeRate_Date__c,SBQQ__PrimaryQuote__r.Rubiks_Quote__c,SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c,SBQQ__PrimaryQuote__r.Early_Renewal__c,Prior_Opportunity__r.SBQQ__PrimaryQuote__r.Rubiks_Quote__c,Prior_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c,SBQQ__RenewedContract__r.SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__RenewedContract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,SBQQ__AmendedContract__r.SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__AmendedContract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,SBQQ__RenewedContract__c,SBQQ__AmendedContract__c,(SELECT Id,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c,Opportunity.Sub_End_Date__c, Opportunity.Sub_Start_Date__c, Name, ProductCode, Quantity, OpportunityId, Opportunity.Maximum_Database_Size__c,Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quantity__c,opportunity.Pricebook2Id,PricebookEntry.Product2.Name,QuoteLine_Quantity__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__QuoteLine__r.Bundle_Package__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.MKTO_Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c,ServiceEndDate__c,SBQQ__QuoteLine__r.SBQQ__Group__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c FROM OpportunityLineItems where Product_Type__c=:Product_Type AND ProductCode IN: ProductSKUEngineeringCode.keySet() AND(SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c=false OR (SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c=true AND(SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c=1.0 OR SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c=null)))) FROM Opportunity where Id=:opportunityId AND Prior_Opportunity__c!=null AND Type!='New Business' AND StageName =: CLOSED_WON_OPPTY AND AccountId!=null ]; 

            //Current Opportunity Master Sub Start Date
            CurrentOptyContractStartDate = OppInstance.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c;
            
            //Current opportunity is early renewed or not 
            EarlyRenewal = OppInstance.SBQQ__PrimaryQuote__r.Early_Renewal__c;
            
            // Added SBQQ__LineItemsGrouped__c check as part of Phoenix and Phoenix Quote We are sending to Provisioning(Provisioning Type = )
            boolean priorSolutionQuote = false;
            //Adding Dropping logic will execute in Renewal to Renewal Scenario
            if(OppInstance.Type==Label.OPPORTUNITY_TYPE_RENEWAL){
                if(OppInstance.SBQQ__RenewedContract__c!=null){
                    ContractId  =   OppInstance.SBQQ__RenewedContract__c;
                }
                if((OppInstance.SBQQ__RenewedContract__r.SBQQ__Quote__r.Rubiks_Quote__c==TRUE || OppInstance.SBQQ__RenewedContract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c) && (OppInstance.SBQQ__PrimaryQuote__r.Rubiks_Quote__c==TRUE || OppInstance.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c || Test.isRunningTest())){
                    ProvisioningQuote  =   TRUE;
                    priorSolutionQuote = OppInstance.SBQQ__RenewedContract__r.SBQQ__Quote__r.Rubiks_Quote__c; 
                }
            }//End of Renewal If
            //If Opportunity type is upsell then refer the ameded contract
            else if(OppInstance.Type==Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL){
                if(OppInstance.SBQQ__AmendedContract__c!=null){
                    ContractId  =   OppInstance.SBQQ__AmendedContract__c;
                }
                if((OppInstance.SBQQ__AmendedContract__r.SBQQ__Quote__r.Rubiks_Quote__c==TRUE || OppInstance.SBQQ__AmendedContract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c) && (OppInstance.SBQQ__PrimaryQuote__r.Rubiks_Quote__c==TRUE || OppInstance.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c)){
                    ProvisioningQuote  =   TRUE;
                    priorSolutionQuote = OppInstance.SBQQ__AmendedContract__r.SBQQ__Quote__r.Rubiks_Quote__c; 
                }
            }//End of Upsell/Crossell If
            
            // Execute the adding dropping logic for rubiks to rubiks deal
            if(ProvisioningQuote){
                
                //Instance rollup used for identifying multi instance scenario
                if(OppInstance.SBQQ__PrimaryQuote__r.Instance_Rollup__c > 0){
                    OptyInstanceRollup  =   OppInstance.SBQQ__PrimaryQuote__r.Instance_Rollup__c;
                }else{
                    PhoenixQuote        =   OppInstance.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c;
                }
                
                //This exceute for multi instance 
                if(OppInstance.SBQQ__PrimaryQuote__r.Instance_Rollup__c > 1.0 || OppInstance.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c){
                    //Prepare account prefix map - based on account prefix renewed
                    if(OppInstance.Account_String__c!=null){
                        if(OppInstance.Account_String__c.contains(',')){
                            for(string prefix:OppInstance.Account_String__c.split(',')){
                                AccountPrefix.add(prefix.trim());
                            }//End of For
                        }else if(OppInstance.Account_String__c!=null){
                            AccountPrefix.add(OppInstance.Account_String__c.trim());
                        }//End of Else If
                    }//End of Account Prefix If
                    
                    //Asset and its munchkin based on AccountPrefix
                    list<Asset> newAssetList=new list<Asset>();
                    for(Asset ast: [SELECT id,Munchkin_ID__c,Acct_Prefix__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.MKTO_Product_Name__c FROM Asset where Acct_Prefix__c IN:AccountPrefix AND Munchkin_ID__c!=null]){
                        accPrefixAndMunchkin.put(ast.Acct_Prefix__c,ast.Munchkin_ID__c);
                        newAssetList.add(ast);
                    }//End of Asset
                    
                    //We are taking munchkin id from asset history if execute old to new after closer of the current opportunity
                    for(AssetHistory AssetList:[SELECT AssetId,Asset.Munchkin_ID__c,Asset.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.MKTO_Product_Name__c,Field,Id,IsDeleted,NewValue,OldValue FROM AssetHistory where Asset.accountid=:OppInstance.AccountId]){
                        string acctPrefix= String.valueOf(AssetList.OldValue);
                        if(AccountPrefix.contains(acctPrefix)){
                            string munchkin='';
                            if(accPrefixAndMunchkin.containsKey(acctPrefix)){
                                munchkin=accPrefixAndMunchkin.get(acctPrefix);
                            }//End of If
                            BundleAndMunchkinMap.put(AssetList.AssetId,munchkin);
                        }//End of If
                    }//End of AssetHistory For
                    
                    if(BundleAndMunchkinMap.keyset().isEmpty()){
                        for(Asset ast:newAssetList){
                            if(AccountPrefix.contains(ast.Acct_Prefix__c)){
                                BundleAndMunchkinMap.put(ast.id,ast.Munchkin_ID__c);
                            }
                        }//End of For  
                    }//End of If
                }//End of multi instance loop
                
                //list of prior subscriptions related to prior contract 
                PriorOppSubList=[SELECT id,SBQQ__Contract__c,Production_Asset__c,SBQQ__ContractNumber__c,SBQQ__Quantity__c,SBQQ__SegmentQuantity__c ,Subscription_Product_Code__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.MKTO_Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,SBQQ__Contract__r.EndDate,SBQQ__SegmentIndex__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__SegmentEndDate__c,SBQQ__SegmentStartDate__c,SBQQ__QuoteLine__r.SBQQ__Group__c from SBQQ__Subscription__c where SBQQ__Contract__r.ID=:ContractId AND Subscription_Product_Code__c IN: ProductSKUEngineeringCode.keySet()];

                Date PriorOptyContractEndDate = null;
                
                //Iterate the prior opportunity Subscriptions 
                if(!PriorOppSubList.isEmpty()){
                    
                    //Prepare list of prior opportunity subscriptions
                    for(SBQQ__Subscription__c sub: PriorOppSubList){
                        //Prior contract End Date
                        if((PriorOptyContractEndDate==null && sub.SBQQ__Contract__r.EndDate!=null && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c!=opportunityId) || sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c){
                            PriorOptyContractEndDate= sub.SBQQ__Contract__r.EndDate;
                        }//End Of If
                        
                        //Multi Instance
                        if(((sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c > 1.0)||(OptyInstanceRollup >1.0 && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c == 1.0)) || sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c){
                            if(BundleAndMunchkinMap.containsKey(sub.Production_Asset__c)){
                                PriorOppsSubscriptionList.add(sub);
                            }//End of If
                            else if((OptyInstanceRollup >1.0 && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c == 1.0) || sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c){
                                PriorOppsSubscriptionList.add(sub);
                            }
                            if(sub.Production_Asset__c!=null && sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c!=null){
                                curReqByIdtoPriorAssetId.put(sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,sub.Production_Asset__c);
                            }
                        }//End of If
                        //Single Instance
                        else if(sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c == 1.0){
                            if((sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c==false) || (sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c==true && (sub.SBQQ__SegmentEndDate__c==sub.SBQQ__Contract__r.EndDate || sub.SBQQ__SegmentIndex__c==null))){
                                PriorOppsSubscriptionList.add(sub);
                            }//End of If
                        }//End of Else If
                    }//End of prior Subscriptions
                }
                                
                // Iterate Prior Opportunity Subscriptions for preparing ProdCodeToPriorSubMap 
                if(!PriorOppsSubscriptionList.isEmpty()){
                    //Iterate Prior Opportunity Subscription
                    for(SBQQ__Subscription__c sub:PriorOppsSubscriptionList){
                        opptyLineItems wrapperOLI= new opptyLineItems();
                        maxDBSize=0.0;
                        oliQuantity =0.0;
                        subQuantity =0.0;
                        string ProdCodeKey;
                        //Prepare the Prior Opportunity Subscription Map for multi instance and single instance
                        if((sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c > 1.0 || (OptyInstanceRollup >1.0 && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c == 1.0)) || sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c){
                            ProdCodeKey=sub.Production_Asset__c+';'+sub.Subscription_Product_Code__c;
                        }else{
                            ProdCodeKey=sub.Subscription_Product_Code__c;
                        }
                        
                        //Prepare Subscription map of PuctCode + RequiredBy and Wrapper Class
                        if(ProdCodeToPriorSubMap.containsKey(ProdCodeKey)){
                            
                            //This is used for handle the MDQ Scenario - For MDQ Consider Segmented Quantity
                            double subscriptionQuantity =(sub.SBQQ__SegmentQuantity__c==null)? sub.SBQQ__Quantity__c:sub.SBQQ__SegmentQuantity__c;
                            if(ProdCodeToPriorSubMap.get(ProdCodeKey).Quantity!=null){
                                subQuantity=ProdCodeToPriorSubMap.get(ProdCodeKey).Quantity+subscriptionQuantity;
                            }//End of if loop
                            else{
                                subQuantity=subscriptionQuantity;
                            }//End of else loop
                                                        
                            wrapperOLI.ProductCode     = sub.Subscription_Product_Code__c;
                            wrapperOLI.Quantity        = subQuantity;
                            wrapperOLI.ProductEnggCode = ProductSKUEngineeringCode.get(sub.Subscription_Product_Code__c).Engineering_Code__c;
                            wrapperOLI.BundleName      = sub.Production_Asset__c;
                            wrapperOLI.instanceRollup  = sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c;
                            
                            ProdCodeToPriorSubMap.put(ProdCodeKey,wrapperOLI);                 
                            
                        }//End of if loop                                             
                        else{
                            wrapperOLI.ProductCode     = sub.Subscription_Product_Code__c;
                            wrapperOLI.ProductEnggCode = ProductSKUEngineeringCode.get(sub.Subscription_Product_Code__c).Engineering_Code__c;
                            wrapperOLI.BundleName      = sub.Production_Asset__c;
                            wrapperOLI.instanceRollup  = sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c;
                            
                            if(sub.SBQQ__Quantity__c!=null || sub.SBQQ__SegmentQuantity__c!=null){
                                wrapperOLI.Quantity    = (sub.SBQQ__SegmentQuantity__c==null)? sub.SBQQ__Quantity__c:sub.SBQQ__SegmentQuantity__c;
                            } //End of if loop  
                            
                            ProdCodeToPriorSubMap.put(ProdCodeKey,wrapperOLI);                     
                            system.debug(' ProdCodeToPriorSubMap'+ ProdCodeToPriorSubMap);
                        }//End of Else                                  
                    }//End of else loop   
                    
                }//End of If
                
                // If Multi Instance Opportunity then we are Comparing the Products based on the Account Prefix renewed
                for(OpportunityLineItem oppOli:OppInstance.OpportunityLineItems){
                    if((oppOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c >1.0 && oppOli.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c!=null) || (oppOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c)){
                        OLIRequiredByAndAssetId.put(oppOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id,oppOli.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c);
                    }//End of If
                    system.debug('OLIRequiredByAndAssetId========================='+OLIRequiredByAndAssetId);
                    
                    if((oppOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c >1.0 || oppOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c) && oppOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c!=null){
                        PriorReqIds.add(oppOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c);
                        if(oppOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id!=null && !curReqByIdPriorReqIds.containsKey(oppOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id)){
                            curReqByIdPriorReqIds.put(oppOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id,oppOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c);
                        }
                    }//End of If
                    if((oppOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c >1.0 ||  oppOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c) && (BundleAndMunchkinMap.containsKey(oppOli.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c) || (oppOLI.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c==null && oppOLI.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id!=null))){
                        OLIList.add(oppOli);
                    }else if(oppOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c ==1.0){
                        OLIList.add(oppOli);
                    }//End of If
                    
                }//End of For OLI
                
                system.debug('########### PriorReqIds '+ PriorReqIds);
                //Iterate on Quote Line to handle multi instance scenario
                for(SBQQ__QuoteLine__c PriorQLI:[SELECT id,SBQQ__ProductCode__c,SBQQ__RequiredBy__c,SBQQ__RenewedSubscription__r.Production_Asset__c,SBQQ__RenewedSubscription__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c IN :PriorReqIds AND  SBQQ__ProductCode__c IN :ProductSKUEngineeringCode.keySet()]){
                    if(PriorReqIdWithChildQLIIds.containskey(PriorQLI.SBQQ__RequiredBy__c)){
                        PriorReqIdWithChildQLIIds.get(PriorQLI.SBQQ__RequiredBy__c).add(PriorQLI.SBQQ__ProductCode__c);
                    }
                    else{
                        PriorReqIdWithChildQLIIds.put(PriorQLI.SBQQ__RequiredBy__c,new set<string>{PriorQLI.SBQQ__ProductCode__c});
                    }

                }//End of QLI FOR loop
                
                
                //Prepare the map of Current OLIs(Preparing key Dynamically Based on the Single or Multi Instance)
                for(OpportunityLineItem oppOli: OLIList){
                    // Current Opp and it's OLI
                    //prepare key for ProdCodeToOldOLIMapRenewal
                    string CurProdCode;
                    if((oppOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c > 1.0 ||(oppOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c >1.0 && priorOptyInstanceRollup == 1.0) ) ||  (oppOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && priorSolutionQuote==false)){
                        if(oppOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c!=null &&  curReqByIdPriorReqIds.containsKey(oppOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)){
                            id priorReById=curReqByIdPriorReqIds.get(oppOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);
                            if(curReqByIdtoPriorAssetId.containsKey(priorReById)){
                                CurProdCode=curReqByIdtoPriorAssetId.get(priorReById)+';'+oppOli.ProductCode;
                            }//End of If
                        }//End of If
                    }else{
                        CurProdCode=oppOli.ProductCode;
                    }//End of Else
                    
                    if(prodCodeToOliMap.containsKey(CurProdCode)){
                        prodCodeToOliMap.get(CurProdCode).add(oppOli); 
                    }//End of If
                    else{
                        prodCodeToOliMap.put(CurProdCode,new List<OpportunityLineItem>{oppOli});
                    }//End of else loop
                    
                    
                    if(newOppIdToOliMap.containsKey(oppOli.OpportunityId)){
                        newOppIdToOliMap.get(oppOli.OpportunityId).add(oppOli);
                    }else{
                        newOppIdToOliMap.put(oppOli.OpportunityId, new List<OpportunityLineItem>{oppOli});                    
                    }//End of else loop
                    
                    opptyLineItems wrapperOLI= new opptyLineItems();
                    maxDBSize=0.0;
                    oliQuantity =0.0;
                    
                    if(ProdCodeToOldOLIMapRenewal.containsKey(CurProdCode)){
                        if(ProdCodeToOldOLIMapRenewal.get(CurProdCode).Quantity!=null){  
                            oliQuantity=ProdCodeToOldOLIMapRenewal.get(CurProdCode).Quantity+oppOli.SBQQ__QuoteLine__r.SBQQ__Quantity__c;
                        }//end of if loop
                        else{
                            oliQuantity=oppOli.SBQQ__QuoteLine__r.SBQQ__Quantity__c;
                        }//end of else loop
                        
                        wrapperOLI.ProductCode=oppOli.ProductCode;
                        wrapperOLI.ProductName=oppOli.PricebookEntry.Product2.Name;
                        wrapperOLI.Quantity=oliQuantity;
                        wrapperOLI.OLIServiceEndDate=oppOli.ServiceEndDate__c;
                        ProdCodeToOldOLIMapRenewal.put(CurProdCode,wrapperOLI);
                                                
                    }//End of if loop                               
                    else{
                        wrapperOLI.ProductCode=oppOli.ProductCode;
                        wrapperOLI.ProductEnggCode=ProductSKUEngineeringCode.get(oppOli.ProductCode).Engineering_Code__c;
                        wrapperOLI.OLIServiceEndDate=oppOli.ServiceEndDate__c;
                        
                        if(oppOli.SBQQ__QuoteLine__r.SBQQ__Quantity__c!=null){
                            wrapperOLI.Quantity=oppOli.SBQQ__QuoteLine__r.SBQQ__Quantity__c;
                        } //end of if loop                                               
                        if(CurProdCode!=null && wrapperOLI!=null)
                            ProdCodeToOldOLIMapRenewal.put(CurProdCode,wrapperOLI);
                        
                    }//End of else loop   
                }//end of OLI for loop
                
                //Comparing the Current(OLIs) and Prior Opportunity Products(Subscriptions)
                if(opportunityId!=null && OppInstance.Type != 'New Business'){  
                    // Calculate Added Products
                    if(newOppIdToOliMap.containsKey(OppInstance.Id)){
                        list<OpportunityLineItem> OptyList=new list<OpportunityLineItem>();
                        
                        for(OpportunityLineItem newOli :OLIList){
                            string newOliProdCode=null;
                            boolean NonAdded=false;
                            if((newOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c > 1.0) || (newOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && priorSolutionQuote==false)){
                                if(newOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c!=null &&  curReqByIdPriorReqIds.containsKey(newOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)){
                                    
                                    id priorReById=curReqByIdPriorReqIds.get(newOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);
                                    if(curReqByIdtoPriorAssetId.containsKey(priorReById)){
                                        newOliProdCode=curReqByIdtoPriorAssetId.get(priorReById)+';'+newOli.ProductCode;
                                    }//End of If
                                }//End of For
                                if(newOli.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c==null){
                                    newOliProdCode=newOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id+';'+newOli.ProductCode;
                                }//End of If
                                if(!PriorReqIdWithChildQLIIds.isempty() && curReqByIdPriorReqIds.containskey(newOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id)){
                                    if(PriorReqIdWithChildQLIIds.containskey(curReqByIdPriorReqIds.get(newOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id))){
                                        set<string> PriorProdCode = PriorReqIdWithChildQLIIds.get(curReqByIdPriorReqIds.get(newOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id));
                                        if(!PriorProdCode.contains(newOli.ProductCode)){
                                            NonAdded =true;
                                        }
                                    }
                                }
                                else if(newOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && !curReqByIdPriorReqIds.containskey(newOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id)){
                                    NonAdded = true;
                                }
                            }else{
                                NonAdded=true;
                                newOliProdCode=newOli.ProductCode;
                            }
                            //Added Products Loop
                            //check Current opp OLI in prior OLI map
                            if(NonAdded==true  && !ProdCodeToPriorSubMap.containsKey(newOliProdCode)){
                                AddedProduct=null;
                                EnggCode=ProductSKUEngineeringCode.get(newOli.ProductCode).Engineering_Code__c;
                                if(newOli.SBQQ__QuoteLine__r.SBQQ__Quantity__c!=0 && newOli.SBQQ__QuoteLine__r.SBQQ__Quantity__c!=null){
                                    AddedProduct=  EnggCode+':'+newOli.SBQQ__QuoteLine__r.SBQQ__Quantity__c * ProductSKUEngineeringCode.get(newOli.ProductCode).Quantity_Multiple__c;
                                }
                                if(newOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c > 1.0 || (newOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && priorSolutionQuote==false)){
                                    munchkinId=null;
                                    if(BundleAndMunchkinMap.containsKey(newOli.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c)){
                                        MunchkinId = BundleAndMunchkinMap.get(newOli.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c);
                                    }
                                    //OLI -> QLI -> Renewed Subscription - Blank
                                    id PrirReqId;
                                    if(curReqByIdPriorReqIds.containsKey(newOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id) ){
                                        
                                        PrirReqId=curReqByIdPriorReqIds.get(newOli.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id);
                                    }
                                    if(MunchkinId==null && curReqByIdtoPriorAssetId.containsKey(PrirReqId)){
                                        id subAssetId=curReqByIdtoPriorAssetId.get(PrirReqId);
                                        if(BundleAndMunchkinMap.containsKey(subAssetId)){
                                            MunchkinId = BundleAndMunchkinMap.get(subAssetId);
                                        }
                                    }
                                    if(MunchkinId!=null){
                                        if(MultiInstAddedProducts.containsKey(MunchkinId)){
                                            MultiInstAddedProducts.get(MunchkinId).add(AddedProduct);
                                        }else{
                                            MultiInstAddedProducts.put(MunchkinId,new list<String>{AddedProduct});
                                        }//End of If
                                    }
                                    // Handle Phoenix  Grouping Scenario
                                    if(MunchkinId==null && newOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c){
                                        AddedProducts.add(AddedProduct);
                                    }
                                }else{
                                    if(AddedProduct!=null){
                                        AddedProducts.add(AddedProduct);
                                    }
                                }
                                
                            }//end of if loop
                            //Quantity Change Loop
                            else if(ProdCodeToOldOLIMapRenewal.containsKey(newOliProdCode) && ProdCodeToPriorSubMap.containsKey(newOliProdCode) ){
                                EnggCode=ProductSKUEngineeringCode.get(newOli.ProductCode).Engineering_Code__c;
                                
                                opptyLineItems WrapperList=ProdCodeToPriorSubMap.get(newOliProdCode);
                                
                                if(ProdCodeToOldOLIMapRenewal.get(newOliProdCode).Quantity!=ProdCodeToPriorSubMap.get(newOliProdCode).Quantity && ProdCodeToOldOLIMapRenewal.get(newOliProdCode).Quantity!=0 && ProdCodeToPriorSubMap.get(newOliProdCode).Quantity!=0){
                                    if(ProdCodeToOldOLIMapRenewal.containsKey(newOliProdCode)){
                                        opptyLineItems wrapOLI=ProdCodeToOldOLIMapRenewal.get(newOliProdCode);
                                        oliQuantity1=WrapperList.Quantity;
                                        difOfOliQty1=0.0;
                                        if(wrapOLI.Quantity!=oliQuantity1){ 
                                            QuantityChangedProduct=  EnggCode+':'+newOli.SBQQ__QuoteLine__r.SBQQ__Quantity__c * ProductSKUEngineeringCode.get(newOli.ProductCode).Quantity_Multiple__c;
                                            if(newOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c > 1.0 || (newOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && priorSolutionQuote==false)){
                                                MunchkinId=null;
                                                if(BundleAndMunchkinMap.containsKey(newOli.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c)){
                                                    MunchkinId = BundleAndMunchkinMap.get(newOli.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c);
                                                }
                                                system.debug('Qty Change munchkinid'+MunchkinId);
                                                // Multi Instance Products
                                                if(MunchkinId!=null){
                                                    if(MultiInstQuantityChangedProducts.containsKey(MunchkinId)){
                                                        MultiInstQuantityChangedProducts.get(MunchkinId).add(QuantityChangedProduct);
                                                    }else{
                                                        MultiInstQuantityChangedProducts.put(MunchkinId,new list<String>{QuantityChangedProduct});
                                                    }
                                                }
                                            }else{
                                                if(QuantityChangedProduct!=''){
                                                    QuantityChangedProducts.add(QuantityChangedProduct);
                                                }
                                            }
                                            
                                        }//end of if loop
                                    }//end of if loop
                                }//End of Quantity Check  
                                //Handle MDQ Scenario + Early renewal
                                else if(ProdCodeToPriorSubMap.get(newOliProdCode).Quantity!=0 && ProdCodeToOldOLIMapRenewal.get(newOliProdCode).Quantity==0 && PriorOptyContractEndDate!=ProdCodeToOldOLIMapRenewal.get(newOliProdCode).OLIServiceEndDate && newOli.SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c==true){
                                    String MDQDroppedProduct=  EnggCode+':'+ProdCodeToPriorSubMap.get(newOliProdCode).Quantity * ProductSKUEngineeringCode.get(newOli.ProductCode).Quantity_Multiple__c;
                                    DroppedProducts.add(MDQDroppedProduct);
                                }//End of If
                                
                            }//End of else loop
                            
                        }//End of OpportunityLineItem for loop
                        
                    }//End of newOppIdToOliMap if loop
                    
                    // Dropped Products
                    for(SBQQ__Subscription__c sub: PriorOppsSubscriptionList){
                        system.debug('################ sub '+ sub);
                        string subProdCode;
                        if(((sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c > 1.0)||(OptyInstanceRollup >1.0 && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c == 1.0)) || (sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && priorSolutionQuote==false)){
                            subProdCode=sub.Production_Asset__c+';'+sub.Subscription_Product_Code__c;
                        }
                        else{
                            subProdCode=sub.Subscription_Product_Code__c;
                        }
                        //Added the [(CurrentOptyContractStartDate > PriorOptyContractEndDate || EarlyRenewal == false)] condition to handle the early renewal scenario if opportunity line not created for 1st segment Product Quantity = 0
                        if(!prodCodeToOliMap.containsKey(subProdCode) && (CurrentOptyContractStartDate > PriorOptyContractEndDate || EarlyRenewal == false)){
                            
                            EnggCode=ProductSKUEngineeringCode.get(sub.Subscription_Product_Code__c).Engineering_Code__c;
                            DroppedProduct       = null;
                            double SubscriptionQuantity = sub.SBQQ__SegmentQuantity__c==null ? sub.SBQQ__Quantity__c: sub.SBQQ__SegmentQuantity__c;
                            if(SubscriptionQuantity!=null){
                                DroppedProduct = EnggCode+':'+SubscriptionQuantity * ProductSKUEngineeringCode.get(sub.Subscription_Product_Code__c).Quantity_Multiple__c; 
                            }
                            if(((sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c > 1.0)||(OptyInstanceRollup >1.0 && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c == 1.0)) || (sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c && priorSolutionQuote==false)){
                                MunchkinId=null;
                                if(BundleAndMunchkinMap.containsKey(sub.Production_Asset__c)){
                                    MunchkinId = BundleAndMunchkinMap.get(sub.Production_Asset__c);
                                }
                                system.debug('MunchkinId********'+MunchkinId); 
                                // Multi Instance Products
                                if(MunchkinId!=null){
                                    if(MultiInstDroppedProducts.containsKey(MunchkinId)){
                                        MultiInstDroppedProducts.get(MunchkinId).add(DroppedProduct);
                                    }else{
                                        MultiInstDroppedProducts.put(MunchkinId,new list<String>{DroppedProduct});
                                    }
                                }
                            }else{
                                if(DroppedProduct!=null){
                                    DroppedProducts.add(DroppedProduct);
                                }
                                system.debug('DroppedProducts********'+DroppedProducts); 
                            }
                        }//End of prodCodeToOliMap
                    }//End of subcription for Dropped product
                } // end of opportunityId if loop  
            }//End of Rubiks if
            
            String AddedProductsWithComaSeperatevalue;
            map<String,String> AddingDroppingQtyChangeMap = new map<String,String>();
            
            //Added Products 
            if(!AddedProducts.IsEmpty() ||((OptyInstanceRollup > 1.0 || PhoenixQuote) && !MultiInstAddedProducts.Keyset().isEmpty())){
                if(!AddedDroppedMap.containsKey('Added Products')){
                    if(OptyInstanceRollup > 1.0 || PhoenixQuote){
                        AddedProducts.clear();
                        if(!MultiInstAddedProducts.Keyset().isEmpty()){
                            for(string addedProductKey:MultiInstAddedProducts.Keyset()){
                                map<String,String> tempMap=new map<String,String>();
                                string munchkinIdKey='\n'+ addedProductKey + '\n';
                                AddedProducts.add(munchkinIdKey);
                                AddedProductsWithComaSeperatevalue='';
                                for(String addedProductVal: MultiInstAddedProducts.get(addedProductKey)){
                                    AddedProducts.add(addedProductVal);
                                    if(AddedProductsWithComaSeperatevalue==''){
                                        AddedProductsWithComaSeperatevalue=addedProductVal;
                                    }else{
                                        AddedProductsWithComaSeperatevalue=AddedProductsWithComaSeperatevalue + ',' + addedProductVal;
                                    } 
                                }
                                system.debug('Inside Added, Coma seperated AddedProductsWithComaSeperatevalue'+AddedProductsWithComaSeperatevalue);
                                if(AddedProductsWithComaSeperatevalue!=''){
                                    tempMap.put('Added Products',AddedProductsWithComaSeperatevalue);
                                }
                                if(!tempMap.values().isEmpty()){
                                    MunchkinAndProducts.put(addedProductKey,tempMap);
                                }
                            }
                        }
                        AddedDroppedMap.put('Added Products',AddedProducts);  
                    }else{
                        AddedDroppedMap.put('Added Products',AddedProducts);  
                    }
                }
            }
            
            //Dropped Products
            if((!DroppedProducts.IsEmpty()|| ((OptyInstanceRollup > 1.0 || PhoenixQuote) && !MultiInstDroppedProducts.Keyset().isEmpty())) && OppInstance.Type!='Upsell/Crossell'){
                if(!AddedDroppedMap.containsKey('Dropped Products')){
                    if(OptyInstanceRollup > 1.0 || PhoenixQuote){
                        DroppedProducts.clear();
                        if(!MultiInstDroppedProducts.Keyset().isEmpty()){
                            for(string addedProductKey:MultiInstDroppedProducts.Keyset()){
                                string munchkinIdKey='\n'+ addedProductKey + '\n';
                                DroppedProducts.add(munchkinIdKey);
                                map<string,string> tempmap=new map<string,string>();
                                if(!MunchkinAndProducts.keyset().isempty()){
                                    if(MunchkinAndProducts.containsKey(addedProductKey)){
                                        if(!MunchkinAndProducts.get(addedProductKey).Keyset().isEmpty()){
                                            for(String key2:MunchkinAndProducts.get(addedProductKey).keySet()) {
                                                tempMap.put(key2,MunchkinAndProducts.get(addedProductKey).get(key2));
                                            }
                                        }//End of If
                                    }//End of If
                                }
                                AddedProductsWithComaSeperatevalue='';
                                
                                for(String addedProductVal: MultiInstDroppedProducts.get(addedProductKey)){
                                    DroppedProducts.add(addedProductVal);
                                    if(AddedProductsWithComaSeperatevalue==''){
                                        AddedProductsWithComaSeperatevalue=addedProductVal;
                                    }else{
                                        AddedProductsWithComaSeperatevalue=AddedProductsWithComaSeperatevalue + ',' + addedProductVal;
                                    } 
                                }
                                if(AddedProductsWithComaSeperatevalue!=''){
                                    tempMap.put('Dropped Products',AddedProductsWithComaSeperatevalue);
                                }
                                if(!tempMap.values().isEmpty()){
                                    MunchkinAndProducts.put(addedProductKey,tempMap);
                                }
                            }
                        }
                        AddedDroppedMap.put('Dropped Products',DroppedProducts);  
                    }else{
                        AddedDroppedMap.put('Dropped Products',DroppedProducts);   
                    } 
                }
            }
            
            //Quantity Change Product
            if(!QuantityChangedProducts.IsEmpty() || ((OptyInstanceRollup > 1.0 || PhoenixQuote) && !MultiInstQuantityChangedProducts.Keyset().isEmpty())){
                if(!AddedDroppedMap.containsKey('QuantityChangedProduct')){
                    if(OptyInstanceRollup > 1.0 || PhoenixQuote){
                        QuantityChangedProducts.clear();
                        if(!MultiInstQuantityChangedProducts.Keyset().isEmpty()){
                            for(string addedProductKey:MultiInstQuantityChangedProducts.Keyset()){
                                string munchkinIdKey='\n'+addedProductKey + '\n';
                                QuantityChangedProducts.add(munchkinIdKey);
                                system.debug('Inside Quantity Change +addedProductKey'+addedProductKey);
                                
                                map<string,string> tempmap=new map<string,string>();
                                
                                if(!MunchkinAndProducts.keyset().isempty()){
                                    if(MunchkinAndProducts.containsKey(addedProductKey)){
                                        if(!MunchkinAndProducts.get(addedProductKey).Keyset().isEmpty()){
                                            for(String key2:MunchkinAndProducts.get(addedProductKey).keySet()) {
                                                tempMap.put(key2,MunchkinAndProducts.get(addedProductKey).get(key2));
                                            }
                                        }//End Of If
                                    }//End of If
                                }//End of If
                                
                                AddedProductsWithComaSeperatevalue='';
                                for(String addedProductVal: MultiInstQuantityChangedProducts.get(addedProductKey)){
                                    QuantityChangedProducts.add(addedProductVal);
                                    if(AddedProductsWithComaSeperatevalue==''){
                                        AddedProductsWithComaSeperatevalue=addedProductVal;
                                    }else{
                                        AddedProductsWithComaSeperatevalue=AddedProductsWithComaSeperatevalue + ',' + addedProductVal;
                                    } 
                                }
                                if(AddedProductsWithComaSeperatevalue!=''){
                                    tempMap.put('QuantityChangedProduct',AddedProductsWithComaSeperatevalue);
                                }
                                
                                if(!tempMap.isEmpty()){
                                    MunchkinAndProducts.put(addedProductKey,tempMap);
                                }
                            }
                        }
                        AddedDroppedMap.put('QuantityChangedProduct',QuantityChangedProducts);  
                    }else{
                        AddedDroppedMap.put('QuantityChangedProduct',QuantityChangedProducts);  
                    } 
                    
                }  
            }
            // JSON For Added and Dropped
            if(!MunchkinAndProducts.keyset().isempty()){
                list<String> tempList = new  list<String>();
                string AddedDroppedQtyChange = JSON.serialize(MunchkinAndProducts);
                tempList.add(AddedDroppedQtyChange);
                AddedDroppedMap.put('AddedDroppedQtyChange',tempList);  
            }
        }
        
        /* ********************************************************************************************************************
        * Last Modified By    : Priyanka Shende, Jade Global Inc on 1st August 2018
        * Purpose             : Change quantity associated with Life Cycle Modeler : APPS-20694 
        * *********************************************************************************************************************/
        map<string,list<string> > AddedDroppedProductsMap =  LCMQuantityCalculation(AddedDroppedMap);
        
        return AddedDroppedProductsMap;
    }// end of AddingDroppingProdController method
    
   /* ********************************************************************************************************************
    * Created By        : Priyanka Shende, Jade Global Inc on 1st August 2018
    * Method(Return Map): LCMQuantityCalculation
    * Purpose           : Change quantity associated with Life Cycle Modeler : APPS-20694 
    * *********************************************************************************************************************/
    public static map<string,list<string>> LCMQuantityCalculation(map<string,list<string>> AddedDroppedQtyChangeProd){
        string AdditionalModelsEnggCode  = 'lifeCycleModeler_AdditionalModels';
        string LifeCycleModelerEnggCode  = 'lifeCycleModeler';
        system.debug('################### AddedDroppedQtyChangeProd'+ AddedDroppedQtyChangeProd);
        map<string,list<string>> AddedDroppedMap = new map<string,list<string>>();
        if(!AddedDroppedQtyChangeProd.isEmpty()){
            if(AddedDroppedQtyChangeProd.containsKey('Added Products')){
                List<string> AddedProducts=AddedDroppedQtyChangeProd.get('Added Products');
                
                Boolean isLCMPresent = false;
                Boolean isAdditionalModelsPresent = false;
                decimal LCMQuantity = null;
                for(String AddedProduct : AddedProducts){
                    if(AddedProduct.contains(AdditionalModelsEnggCode)){
                        List<String> LCMProd = AddedProduct.split(':');
                        LCMQuantity = Decimal.ValueOf(LCMProd.get(1));
                        isAdditionalModelsPresent = true;
                        system.debug('######### LCMQuantity'+LCMQuantity);
                    }else if(AddedProduct.contains(LifeCycleModelerEnggCode)){
                        isLCMPresent = true;
                    }
                }//End of For
                if(isLCMPresent){
                    List<string> AddedProductsWithLCM = new List<string>();
                    for(String AddedProduct : AddedProducts){
                        string AddProductToList;
                        if(AddedProduct.contains(LifeCycleModelerEnggCode) && !AddedProduct.contains(AdditionalModelsEnggCode) && isAdditionalModelsPresent){
                            decimal LCMTotalQty = 1.000 + LCMQuantity;
                            AddProductToList = LifeCycleModelerEnggCode+':'+LCMTotalQty;
                            AddedProductsWithLCM.add(AddProductToList);
                            system.debug('');
                        }else if(AddedProduct.contains(LifeCycleModelerEnggCode) && !AddedProduct.contains(AdditionalModelsEnggCode) && isAdditionalModelsPresent== false){
                            AddProductToList = LifeCycleModelerEnggCode+':1.000';
                            AddedProductsWithLCM.add(AddProductToList);
                        }else{
                            AddedProductsWithLCM.add(AddedProduct); 
                        }
                    }
                    system.debug('############# AddedProductsWithLCM'+AddedProductsWithLCM);
                    AddedDroppedMap.put('Added Products',AddedProductsWithLCM);
                }else{
                    AddedDroppedMap.put('Added Products',AddedProducts);
                    system.debug('Inside Else ############# AddedProducts'+AddedProducts);
                }
            }//End of If
            // Dropped Products
            if(AddedDroppedQtyChangeProd.containsKey('Dropped Products')){
                List<string> DroppedProducts=AddedDroppedQtyChangeProd.get('Dropped Products');
                decimal LCMQuantity = null;
                Boolean isLCMPresent = false;
                Boolean isAdditionalModelsPresent = false;
                for(String DroppedProduct : DroppedProducts){
                    if(DroppedProduct.contains(AdditionalModelsEnggCode)){
                        List<String> LCMProd = DroppedProduct.split(':');
                        LCMQuantity = Decimal.ValueOf(LCMProd.get(1));
                        isAdditionalModelsPresent= true;
                    }else if(DroppedProduct.contains(LifeCycleModelerEnggCode)){
                        isLCMPresent = true;
                    }
                }//End of For
                if(isLCMPresent){
                    List<string> DroppedProductsWithLCM = new List<string>();
                    for(String DroppedProduct : DroppedProducts){
                        string DroppedProductToList;
                        if(DroppedProduct.contains(LifeCycleModelerEnggCode) && !DroppedProduct.contains(AdditionalModelsEnggCode) && isAdditionalModelsPresent){
                            decimal LCMTotalQty = 1.000 + LCMQuantity;
                            DroppedProductToList = LifeCycleModelerEnggCode+':'+LCMTotalQty;
                            DroppedProductsWithLCM.add(DroppedProductToList);
                        }else if(DroppedProduct.contains(LifeCycleModelerEnggCode) && !DroppedProduct.contains(AdditionalModelsEnggCode) && isAdditionalModelsPresent == false){
                            DroppedProductToList = LifeCycleModelerEnggCode+':1.000';
                            DroppedProductsWithLCM.add(DroppedProductToList);
                        }else{
                            DroppedProductsWithLCM.add(DroppedProduct);
                        }
                    }
                    AddedDroppedMap.put('Dropped Products',DroppedProductsWithLCM);
                }else{
                    AddedDroppedMap.put('Dropped Products',DroppedProducts);
                }
            }//End of Dropped
            // QuantityChanged Products
            if(AddedDroppedQtyChangeProd.containsKey('QuantityChangedProduct')){
                List<string> QuantityChangedProducts=AddedDroppedQtyChangeProd.get('QuantityChangedProduct');
                decimal LCMQuantity = null;
                Boolean isLCMPresent = false;
                Boolean isAdditionalModelsPresent = false;
                for(String QuantityChangedProduct : QuantityChangedProducts){
                    if(QuantityChangedProduct.contains(AdditionalModelsEnggCode)){
                        List<String> LCMProd = QuantityChangedProduct.split(':');
                        LCMQuantity = Decimal.ValueOf(LCMProd.get(1));
                        isAdditionalModelsPresent= true;
                    }else if(QuantityChangedProduct.contains(LifeCycleModelerEnggCode)){
                        isLCMPresent = true;
                    }
                }//End of For
                if(isLCMPresent){
                    List<string> QuantityChangedsWithLCM = new List<string>();
                    for(String QuantityChangedProduct : QuantityChangedProducts){
                        string QuantityChangedToList;
                        if(QuantityChangedProduct.contains(LifeCycleModelerEnggCode) && !QuantityChangedProduct.contains(AdditionalModelsEnggCode) && isAdditionalModelsPresent){
                            decimal LCMTotalQty = 1.000 + LCMQuantity;
                            QuantityChangedToList = LifeCycleModelerEnggCode+':'+LCMTotalQty;
                            QuantityChangedsWithLCM.add(QuantityChangedToList);
                        }else if(QuantityChangedProduct.contains(LifeCycleModelerEnggCode) && !QuantityChangedProduct.contains(AdditionalModelsEnggCode) && isAdditionalModelsPresent== false){
                            QuantityChangedToList = LifeCycleModelerEnggCode+':1.000';
                            QuantityChangedsWithLCM.add(QuantityChangedToList);
                        }else{
                            QuantityChangedsWithLCM.add(QuantityChangedProduct);
                        }
                    }
                    AddedDroppedMap.put('QuantityChangedProduct',QuantityChangedsWithLCM);
                }else{
                    AddedDroppedMap.put('QuantityChangedProduct',QuantityChangedProducts);
                }
            }//End of Dropped
        }// End of If 
        return AddedDroppedMap;
    }// End of LCMQuantityCalculation Method
    
    //MDQ NB and Renewal logic for 2nd and onwards segments
    public  static map<string,list<string> > populateAddedDroppedProductsOnMDQ2ndSegmentCase(Opportunity opp){
        Map<string,list<string>> addedDroppedAndQtyChangeProduct                  = new Map<string,list<string>>();
        list<SBQQ__Subscription__c> allSubscriptions                              = new list<SBQQ__Subscription__c>();
        Map<string,SBQQ__Subscription__c> currentSegmentSubscriptions             = new Map<string,SBQQ__Subscription__c>();
        Map<string,SBQQ__Subscription__c> priorSegmentSubscriptions               = new Map<string,SBQQ__Subscription__c>();
        Map<String,Product_SKU_Engineering_Code__c> ProductSKUEngineeringCode     = new Map<String,Product_SKU_Engineering_Code__c>();
        Date currentSegmentStartDate;
        Double currentSegmentIndex;
        Double priorSegmentIndex;
        id OpportunitySegId;
        list<string> AddedSegProducts                                = new  list<string>();
        list<string> DroppedSegProducts                                = new  list<string>();
        list<string> QuantityChangedSegProducts                                = new  list<string>();
        //ProductSKUEngineeringCode populated to consider products from Product_SKU_Engineering_Code__c in Adding Dropping Functionality 
        for(Product_SKU_Engineering_Code__c thisCustSetRec :Product_SKU_Engineering_Code__c.getAll().values()){
            ProductSKUEngineeringCode.put(thisCustSetRec.Product_Code__c, thisCustSetRec);
        }//end of for loop 
        
        // list<OpportunityLineitem> segmentedOLIList = [SELECT Id,SBQQ__QuoteLine__r.SBQQ__StartDate__c,Segment_Start_Date__c,Name,servicedate,Product_Type__c,Instance_ID__c,Contract_Quantity__c, MKTO_Product_Name__c,SBQQ__QuoteLine__r.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c,SBQQ__QuoteLine__r.SBQQ__Existing__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Type__c,SBQQ__QuoteLine__r.SBQQ__SubscriptionPercent__c,SBQQ__QuoteLine__r.SBQQ__EffectiveQuantity__c ,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,SBQQ__QuoteLine__c,Product2.Name,ProductCode,SBQQ__QuoteLine__r.Qty_Diff__c,opportunityId FROM OpportunityLineitem WHERE Id IN:segmentedOLIids order by MKTO_Product_Name__c ASC];
        
        for(OpportunityLineitem OLI: opp.OpportunityLineitems){
            if(OLI.SBQQ__QuoteLine__r.SBQQ__StartDate__c!=null){
                currentSegmentStartDate= OLI.SBQQ__QuoteLine__r.SBQQ__StartDate__c;     
                OpportunitySegId=OLI.OpportunityId;
            }
        }
        
        system.debug('currentSegmentStartDate ###########'+currentSegmentStartDate);
        for(SBQQ__Subscription__c sub :[SELECT id,SBQQ__SegmentStartDate__c,SBQQ__Quantity__c,Subscription_Product_Code__c,SBQQ__SegmentIndex__c,SBQQ__SegmentKey__c,SBQQ__SegmentLabel__c,SBQQ__SegmentQuantity__c FROM SBQQ__Subscription__c WHERE  Subscription_Product_Code__c IN:ProductSKUEngineeringCode.keySet() AND SBQQ__Contract__r.SBQQ__Opportunity__c=:OpportunitySegId]){
            allSubscriptions.add(sub);  
            if(currentSegmentStartDate==sub.SBQQ__SegmentStartDate__c && currentSegmentIndex==null){
                currentSegmentIndex=sub.SBQQ__SegmentIndex__c;
                if(currentSegmentIndex!=null){
                    priorSegmentIndex= currentSegmentIndex - 1.0; 
                }
            }
        }
        
        for(SBQQ__Subscription__c sub :allSubscriptions){
            if(sub.SBQQ__SegmentStartDate__c==currentSegmentStartDate){
                currentSegmentSubscriptions.put(sub.Subscription_Product_Code__c,sub);
            }else if(sub.SBQQ__SegmentIndex__c== priorSegmentIndex){
                priorSegmentSubscriptions.put(sub.Subscription_Product_Code__c,sub);
            }
        }//End of subscriptions
        system.debug('######## currentSegmentSubscriptions'+currentSegmentSubscriptions);
        
        //Iterate current segment subscriptions for Added and Qty change Product
        for(SBQQ__Subscription__c currentSub: currentSegmentSubscriptions.values()){
            if(priorSegmentSubscriptions.containsKey(currentSub.Subscription_Product_Code__c)){
                string QtyChange='';
                if(currentSub.SBQQ__SegmentQuantity__c!=priorSegmentSubscriptions.get(currentSub.Subscription_Product_Code__c).SBQQ__SegmentQuantity__c && currentSub.SBQQ__SegmentQuantity__c!=0.00 && priorSegmentSubscriptions.get(currentSub.Subscription_Product_Code__c).SBQQ__SegmentQuantity__c!=0.00){
                    QtyChange=ProductSKUEngineeringCode.get(currentSub.Subscription_Product_Code__c).Engineering_Code__c+':'+currentSub.SBQQ__SegmentQuantity__c * ProductSKUEngineeringCode.get(currentSub.Subscription_Product_Code__c).Quantity_Multiple__c;
                    if(QtyChange!=''){
                        QuantityChangedSegProducts.add(QtyChange);
                    }
                }
                else if(priorSegmentSubscriptions.get(currentSub.Subscription_Product_Code__c).SBQQ__SegmentQuantity__c==0.00 && currentSub.SBQQ__SegmentQuantity__c!=0.00){
                    String AddedProduct='';
                    AddedProduct= ProductSKUEngineeringCode.get(currentSub.Subscription_Product_Code__c).Engineering_Code__c+':'+currentSub.SBQQ__SegmentQuantity__c * ProductSKUEngineeringCode.get(currentSub.Subscription_Product_Code__c).Quantity_Multiple__c;
                    if(AddedProduct!=''){
                        AddedSegProducts.add(AddedProduct);
                    }
                }
                else if(priorSegmentSubscriptions.get(currentSub.Subscription_Product_Code__c).SBQQ__SegmentQuantity__c!=0.00 && currentSub.SBQQ__SegmentQuantity__c==0.00){
                    string DroppedProduct='';
                    DroppedProduct= ProductSKUEngineeringCode.get(currentSub.Subscription_Product_Code__c).Engineering_Code__c+':'+priorSegmentSubscriptions.get(currentSub.Subscription_Product_Code__c).SBQQ__SegmentQuantity__c * ProductSKUEngineeringCode.get(currentSub.Subscription_Product_Code__c).Quantity_Multiple__c;
                    if(DroppedProduct!=''){
                        DroppedSegProducts.add(DroppedProduct);
                    }
                }
            }else if(!priorSegmentSubscriptions.containsKey(currentSub.Subscription_Product_Code__c)){
                String AddedProduct='';
                AddedProduct= ProductSKUEngineeringCode.get(currentSub.Subscription_Product_Code__c).Engineering_Code__c+':'+currentSub.SBQQ__SegmentQuantity__c * ProductSKUEngineeringCode.get(currentSub.Subscription_Product_Code__c).Quantity_Multiple__c;
                if(AddedProduct!=''){
                    AddedSegProducts.add(AddedProduct);
                }
            }
        }//End of For
        if(!priorSegmentSubscriptions.values().isEmpty()){
            for(SBQQ__Subscription__c priorSub :priorSegmentSubscriptions.values()){
                if(!currentSegmentSubscriptions.containsKey(priorSub.Subscription_Product_Code__c)){
                    string DroppedProduct='';
                    double SubQuantity = priorSub.SBQQ__SegmentQuantity__c==null ? 0 : priorSub.SBQQ__SegmentQuantity__c;
                    if(SubQuantity!=0){
                        DroppedProduct= ProductSKUEngineeringCode.get(priorSub.Subscription_Product_Code__c).Engineering_Code__c+':'+ priorSub.SBQQ__SegmentQuantity__c * ProductSKUEngineeringCode.get(priorSub.Subscription_Product_Code__c).Quantity_Multiple__c;
                        if(DroppedProduct!=''){
                            DroppedSegProducts.add(DroppedProduct);
                        }
                    }
                }
            }//End of for
        }
        
        if(!AddedSegProducts.IsEmpty()){
            addedDroppedAndQtyChangeProduct.put('Added Products',AddedSegProducts);
        }
        if(!DroppedSegProducts.IsEmpty()){
            addedDroppedAndQtyChangeProduct.put('Dropped Products',DroppedSegProducts);
        }
        if(!QuantityChangedSegProducts.IsEmpty()){
            addedDroppedAndQtyChangeProduct.put('QuantityChangedProduct',QuantityChangedSegProducts); 
        }
        system.debug('############# addedDroppedAndQtyChangeProduct'+addedDroppedAndQtyChangeProduct);
        
        /* ********************************************************************************************************************
        * Last Modified By    : Priyanka Shende, Jade Global Inc on 1st August 2018
        * Purpose             : Change quantity associated with Life Cycle Modeler : APPS-20694 
        * *********************************************************************************************************************/
        
        map<string,list<string> > AddedDroppedProductsMap =  LCMQuantityCalculation(addedDroppedAndQtyChangeProduct);
        system.debug('############# AddedDroppedProductsMap'+AddedDroppedProductsMap);
        
        return AddedDroppedProductsMap;
    } 
    
    // Wrapper Class
    public class opptyLineItems{
        public String ProductCode;
        public string BundleName;
        public String ProductName;
        public Decimal instanceRollup;
        public Double Quantity;
        public String ProductEnggCode;
        public id requiredbyId;
        public Date OLIServiceEndDate;
    }//end of opptyLineItems class
    
}// End of Class