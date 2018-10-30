/* ------------------------------
Created By - Shridhar Patankar
Date       - 19/01/2015
Description - For CPQ-22 calling this class method 'createFromEmail' from 'emailAssetsAndEntitlements' messaging inbound handler class
--------------------------------- */

public class AEEmailHandlerWithAssetIdController
{
    public static List<Authorized_Contact__c> ListOfAuthorizedContact;
    public static Map<Id,Authorized_Contact__c> AuthMap;
    public static void createFromEmailWithAssetId(string OppID,string Munchkin , string PO,string ProductC,string InstanceNum,string Asse,string AccountPre)
    {

    String OpID = OppID; 
    String MunchkinID =Munchkin;
    String POD=PO;
    String ProductCode = ProductC;
    List<Id> AssetsIds = new List<Id>();
    ListOfAuthorizedContact = new list<Authorized_Contact__c>();
    AuthMap = new Map<Id,Authorized_Contact__c>();
    Decimal InstanceNumber;
    if(InstanceNum != '' && InstanceNum != null)
    InstanceNumber = Decimal.valueOf(InstanceNum);
    String Asset =  Asse;
    
    String AccountPrefix = AccountPre;
    
    list<asset> ListOfAssetss = new list<asset>();
    list<asset> AssetsToUpdate = new list<asset>();
    
    list<opportunitylineitem> OLI = [select pricebookentry.product2.ConvertTo__c ,
                                        Opportunity.Primary_Marketo_User_Lookup__c,
                                        Opportunity.Primary_Marketo_User_Lookup__r.Account.Id, 
                                        pricebookentry.product2.ProductCode,
                                        pricebookentry.product2.Family,
                                        pricebookentry.product2.Record_Limitation__c,
                                        pricebookentry.product2.id,
                                        opportunity.account.id,
                                        opportunity.account.name,
                                        opportunity.account.type,
                                        opportunity.account.Partner_Type__c,
                                        opportunity.account.Sales_Region__c,
                                        opportunity.CRM_System__c,
                                        opportunity.Sub_Start_Date__c,
                                        opportunity.Sub_End_Date__c,
                                        Quantity,Instance_Number__c
                                        from opportunitylineitem where OpportunityId =: OpID 
                                        AND Instance_Number__c=:InstanceNumber 
                                        AND 
                                        pricebookentry.product2.ProductCode =:ProductCode limit 1
                                        ];
   // if(OLI.size()>0)
   // {
        system.debug('yes found');
        ListOfAssetss = [select id,product2.id,UsageEndDate,Munchkin_ID__c,POD__c,Acct_Prefix__c,Provision_Status__c,Purpose__c,Provisioning_Complete__c from asset where Id =:Asset limit 100];
        if(ListOfAssetss.size()>0)
        {
            for(asset LOA : ListOfAssetss)
            {
                //if(LOA.product2.id == OLI[0].pricebookentry.product2.id)
               // {
                    system.debug('POD======Value'+POD);
                    LOA.Munchkin_ID__c = MunchkinID;
                    LOA.POD__c = POD;
                    LOA.Acct_Prefix__c = AccountPrefix;
                    LOA.Provision_Status__c = 'Completed';
                  
                                       
                    if(LOA.Provision_Status__c == 'Completed' && (LOA.Munchkin_ID__c!='' || LOA.Munchkin_ID__c!=null) && (LOA.POD__c!=null || LOA.POD__c!='') && (LOA.Acct_Prefix__c!=null || LOA.Acct_Prefix__c!='')){
                        LOA.Provisioning_Complete__c = System.today();
                        LOA.Status = 'Active';   
                    }
                    
                    if((LOA.Acct_Prefix__c!='' || LOA.Acct_Prefix__c!=null) && (LOA.Purpose__c!='' || LOA.Purpose__c!=null)){
                        LOA.Name = LOA.Acct_Prefix__c + ' '+ String.ValueOf(LOA.Purpose__c);
                    }
                    AssetsToUpdate.add(LOA);
                    AssetsIds.add(LOA.id);
                //}
            }
        }
    //}
               List<Entitlement> ExtEntList = [SELECT id,StartDate,EndDate,BusinessHoursId,
               SlaProcessId,Product_ID__c,name,AccountId,AssetId,Type,Support_Region__c from Entitlement where AssetId =: AssetsIds  limit 100];
             
               
              /* CurrentOpp = [select id,accountid,Primary_Marketo_User_Lookup__c,
                                Primary_Marketo_User_Lookup__r.Account.Id 
                               from opportunity where id =: OpID  limit 1];*/
                
               List<Authorized_Contact__c> ExistingAC = [SELECT id,
                                                                   Entitlement__c
                                                              FROM Authorized_Contact__c
                                                              WHERE Entitlement__c in :ExtEntList 
                                                              and Customer_Admin__c = true limit 200]; 
               
                  for(Authorized_Contact__c c: ExistingAC )
                  {
                      AuthMap.put(c.Entitlement__c,c);
                  } 
                 
    // Calling this method for creating Authorized Contacts
    CreateAuthorizedContact(ExtEntList,OLI);  
    if(AssetsToUpdate.size()>0)
    {
        update AssetsToUpdate;
    }
}

  private static void CreateAuthorizedContact(List<Entitlement> ListOfEntitlement,List<OpportunityLineItem> Opt)
    {
        Authorized_Contact__c ac ;
            if(ListOfEntitlement.size()>0)
            {
                for(Entitlement ent : ListOfEntitlement)
                {
                        if(AuthMap.keyset().contains(ent.id)){
                            ac = AuthMap.get(ent.id);
                        }
                        else{
                            ac = new Authorized_Contact__c();
                        
                           /* if(CurrentOpp.size()>0)
                            {
                                ac.Contact__c= CurrentOpp[0].Primary_Marketo_User_Lookup__c ;
                            }*/
                            if(Opt.size()>0 && Opt[0].Opportunity.Primary_Marketo_User_Lookup__c != null)
                            {
                                ac.Contact__c= Opt[0].Opportunity.Primary_Marketo_User_Lookup__c ;
                            }
                            ac.Entitlement__c= ent.id;
                            ac.Customer_Admin__c=true;  
                                
                          /*  if(ac.Contact__c !=null && CurrentOpp[0].Primary_Marketo_User_Lookup__r.Account.Id == ent.AccountId)
                            {
                                ListOfAuthorizedContact.add(ac);
                                system.debug('ooo2'); 
                                
                            }*/
                            if(ac.Contact__c !=null && Opt[0].Opportunity.Primary_Marketo_User_Lookup__r.Account.Id == ent.AccountId)
                            {
                                ListOfAuthorizedContact.add(ac);
                                system.debug('ooo2'); 
                                
                            }
                        }
                }
            }
             system.debug('This is size of ac '+ListOfAuthorizedContact.size());  
            if(ListOfAuthorizedContact.size()>0)
            {
                upsert ListOfAuthorizedContact ;
            }
    }

}