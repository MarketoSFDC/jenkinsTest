/*
    ********************************************************
    Class Name : createSandboxAssetForMDQ
    Author : JadeGlobal
    This class Added by Jade for Sandbox in MDQ - JIRA Ticket APPS-9571
    In this class we are creating segmented OLIs 'Sandbox' product - asset(Sandbox Instance) according to the subscription quantity.
    ********************************************************
*/

public class createSandboxAssetForMDQ{
    
        //AssetStatus is used at the time of asset creation (For setting asset Status as 'Active') 
        public static String AssetStatus='Active';
    
        //This is used to store Asset Type as 'instance' 
        public static String AssetType='Instance';
    
        //Start Create Asset Method - called from OLI trigger - After Update
        public static void createAsset(List<Opportunitylineitem> newlist,  map<id,OpportunityLineItem> oldMap){
        
        // This is used to find segmented OLIs 
        Set<ID> opportunityIdSet = new Set<ID>();
        
        //Store segment date - populated on OLI using batch
        Set<Date> segmentStartdate = new Set<Date>();
        
        //Store sandbox product code - PROD-PLAT-SANDBOX this is used in query
        string SandboxProductName=Label.SANDBOX_PRODUCT_NAME;
        
        //Store sandbox product code - PROD-PLAT-SANDBOX-INST this is used in query
        string SandboxInstanceProductName=Label.SANDBOX_INSTANCE_PRODUCT_NAME;
            
        //Quote line Id set for segmented product
        Set<Id> QLIIds= new Set<id>();
        
        //Segmented subscription list
        list<SBQQ__Subscription__c> showSegSubscription= new list<SBQQ__Subscription__c>();
        
        //This is used to store asset - asset create according to subscription quantity
        list<Asset> assetList=new list<Asset>();
        
        //segmented OLI list according to the segmentDate
        list<Opportunitylineitem> SegOLIList =new list<Opportunitylineitem>();
        
        //Product code and product details map from custom setting 
        Map<String,ProductDetails__c> ProductDetailsMap;
        
        //Product code and product details map from custom setting 
        ProductDetailsMap =   new Map<String,ProductDetails__c>();
        for(ProductDetails__c product : ProductDetails__c.getAll().values()){
            ProductDetailsMap.put(product.Name, product);
        }
        
        // Get Sandbox Instance Product details
        //Product2 product=[SELECT id, ProductCode,name FROM Product2 WHERE ProductCode=:SandboxInstanceProductName];
       
        // This is used to store Id of sandbox instance product
        //Id SandboxInstanceProductId=product.id;
        
        for(Opportunitylineitem oli: newlist){
            if(oli.Create_Asset__c==true && oli.Create_Asset__c!=oldMap.get(oli.id).Create_Asset__c && oli.Segment_Start_Date__c!=null){
               segmentStartdate.add(oli.Segment_Start_Date__c); 
                if(oli.opportunityId!=null){
                    opportunityIdSet.add(oli.opportunityId);
                }//End If 
             }//End If 
        }//End For 
        system.debug('segmentStartdate##################'+segmentStartdate);
        
        if(segmentStartDate!=null && !opportunityIdSet.isEmpty()){
            //Get segmented OLIs related to Opportunity and with Segment_Start_Date__c same as segmentStartDate
            //SegOLIList = [SELECT  id, Segment_Start_Date__c, OpportunityId,PricebookEntry.Product2.Name,Product_Family__c,Users__c,Contract_Quantity__c,ServiceDate,ServiceEndDate__c,Months__c,Product_Start_Date__c,SBQQ__QuoteLine__r.SBQQ__Quantity__c FROM OpportunityLineItem WHERE OpportunityId IN :opportunityIdSet AND Product_Start_Date__c=:segmentStartDate];
            //system.debug('SegOLIList=================='+SegOLIList);
            
            showSegSubscription=[SELECT id,SBQQ__QuoteLine__r.SBQQ__Product__r.id,Subscription_Product_Code__c,SBQQ__QuoteLine__r.SBQQ__ProductCode__c,SBQQ__QuoteLine__r.MKTO_Product_Name__c,SBQQ__Product__r.Name,SBQQ__Product__c,SBQQ__ProductName__c,SBQQ__Contract__c,SBQQ__Contract__r.SBQQ__Opportunity__c,SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,SBQQ__Contract__r.Primary_Asset__c,SBQQ__Contract__r.StartDate,SBQQ__Product__r.ProductCode,SBQQ__QuoteLine__r.SBQQ__Quote__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.id,SBQQ__QuoteLine__r.SBQQ__ProductFamily__c,SBQQ__Quantity__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.MKTO_Effective_Term__c,SBQQ__Account__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__r.SBQQ__Opportunity__c IN :opportunityIdSet AND Subscription_Product_Code__c=:ProductDetailsMap.get(SandboxProductName).Product_Code__c AND SBQQ__StartDate__c IN :segmentStartDate];
        }//End If 
        
       /* if(!SegOLIList.isEmpty()){
            //Get segmented OLIs opp Ids
            for(Opportunitylineitem OLI:SegOLIList){
                if(OLI.SBQQ__QuoteLine__c!=null){
                    QLIIds.add(OLI.SBQQ__QuoteLine__c);
                }//End If
            }//End For
        }//End If
        system.debug('QLIIds=================='+QLIIds);
        
        //Get segmented OLIs-> subscription related to Opportunity and with Segment_Start_Date__c same as segmentStartDate
        if(!QLIIds.isEmpty()){
            showSegSubscription=[SELECT id,SBQQ__QuoteLine__r.SBQQ__Product__r.id,Subscription_Product_Code__c,SBQQ__QuoteLine__r.SBQQ__ProductCode__c,SBQQ__QuoteLine__r.MKTO_Product_Name__c,SBQQ__Product__r.Name,SBQQ__Product__c,SBQQ__ProductName__c,SBQQ__Contract__c,SBQQ__Contract__r.SBQQ__Opportunity__c,SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,SBQQ__Contract__r.Primary_Asset__c,SBQQ__Contract__r.StartDate,SBQQ__Product__r.ProductCode,SBQQ__QuoteLine__r.SBQQ__Quote__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.id,SBQQ__QuoteLine__r.SBQQ__ProductFamily__c,SBQQ__Quantity__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.MKTO_Effective_Term__c,SBQQ__Account__c FROM SBQQ__Subscription__c WHERE SBQQ__QuoteLine__c IN :QLIIds AND Subscription_Product_Code__c=:SandboxProductName]; 
        }//End If
        system.debug('#########showSegSubscription'+showSegSubscription);
        */
        if(!showSegSubscription.isEmpty()){
            for(SBQQ__Subscription__c sub :showSegSubscription){  
                system.debug('###########Sub'+sub);  
                if(sub.Subscription_Product_Code__c==ProductDetailsMap.get(SandboxProductName).Product_Code__c && sub.SBQQ__Quantity__c>=1){
                    for(Integer i=0;i<sub.SBQQ__Quantity__c;i++){
                        //asset object store asset detail according to subscription
                        Asset asst                          =   new     Asset();
                        asst.Product2Id                     =   ProductDetailsMap.get(SandboxInstanceProductName).ID__c;
                        asst.Name                           =   ProductDetailsMap.get(SandboxInstanceProductName).Name;
                        asst.Asset_Type__c                  =   AssetType;
                        asst.Status                         =   AssetStatus;
                        asst.SBQQ__QuoteLine__c             =   sub.SBQQ__QuoteLine__c;
                        asst.SBQQ__LatestQuoteLine__c       =   sub.SBQQ__QuoteLine__c;
                        asst.SBQQ__CurrentSubscription__c   =   sub.id;
                        asst.Production_Asset__c            =   sub.SBQQ__Contract__r.Primary_Asset__c;
                        asst.AccountId                      =   sub.SBQQ__Account__c;
                        asst.InstallDate                    =   sub.SBQQ__Contract__r.StartDate;
                        asst.Latest_Opportunity__c          =   sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c;
                        asst.Opportunity__c                 =   sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Id;
                        
                        system.debug('############ass'+asst);
                        assetList.add(asst);
                    }//End of sub quantity for
                }//End of If
            }//End of subscription for
            
        }//End of not null If
        
        //Insert sandbox asset
        if(!assetList.isEmpty()){
            system.debug('###########3insert asset'+assetList);
            insert assetList;
        }//End If  
          
    }

}