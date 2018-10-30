/**********************************************************
Created By:   Tushar Misri, Grazitti Interactive
Created Date: 5th August, 2018
Purpose : Created to check the following:
          - Rubiks to Phoenix Converstion
          - Rubiks to Rubiks Converstion
          - Phoenix to Phoenix Converstion

**********************************************************/

public class phoenixRenewalARR{
    
    static Map<Id, Decimal> SubscripToTotal =new Map<Id, Decimal>();
    static Map<Id, Decimal> SubscripToMaxQty =new Map<Id, Decimal>();
    static Map<Id, Decimal> ProductToTotal =new Map<Id, Decimal>();
    static Map<Id, Decimal> ProductToMaxQty =new Map<Id, Decimal>();
    static Map<id,id> pheonixToRubiks = new Map<id,id>();
    static Set<String> subFamlies = new Set<String>(); 
    static Map<id,id> rubiksToPhoenix = new Map<id,id>();
    

    public static void calculateARRFields(string OppID, String RenewedContractId, String Event){
        
  
        List<SBQQ__Subscription__c> subs = [SELECT Id, SBQQ__Contract__c,  SBQQ__Contract__r.ContractTerm, Subscription_ACV__c,
                                            SBQQ__Account__c, SBQQ__Product__c, SBQQ__Product__r.Product_SubFamily__c, SBQQ__Product__r.Phoenix_Product__c, SBQQ__ProductId__c, 
                                            SBQQ__Quantity__c, SBQQ__NetPrice__c, SBQQ__Product__r.Product_type__c from SBQQ__Subscription__c 
                                            where SBQQ__Contract__c =: RenewedContractId and SBQQ__Product__r.Product_type__c = 'Subscription' ];
        // SUB ProductId with Total Price 
         SubscripToTotal = subscriptionLinesTotals(subs);
        
        //Get the max Subs Quantity
         SubscripToMaxQty = subscriptionLinesMaxQTY(subs);
         subFamlies = subscriptionProductFamilies(subs);
        
        List<OpportunityLineItem> olis = [SELECT Id, TotalPrice,Product2Id,Product2.Product_SubFamily__c,
                                          Months__c, Product_Type__c, Product2.Name, Contract_Quantity__c,Total_Price_Subscription__c from 
                                          OpportunityLineItem where OpportunityId =:  OppID and Product_Type__c = 'Subscription'];
        
        // OLI ProductId with Total Price- set by method
         ProductToTotal = oppLinesTotals(olis);
        
        //Get the max OLI Quantity - set by method
         ProductToMaxQty = oppLinesMaxQTY(olis);
         
        
    }
    
    //Method to populate map of pheonix products to rubiks product
    public static void pheonixToRubiks(){
        for(product2 prod:[select id,phoenix_product__c from product2 where phoenix_product__c!=null]){
            pheonixToRubiks.put(prod.phoenix_product__c,prod.id);
        } 
    }
    
        public static void RubiksToPhoenix(){
        for(product2 prod:[select id,phoenix_product__c from product2 where phoenix_product__c!=null]){
            RubiksToPhoenix.put(prod.id, prod.phoenix_product__c);
        } 
    }
    /******* 
    This method recieves List Of Subs related to RenewedContractId and Totals the Net and then we divide them by Term Multiply by 12 
    ***********/
    public static Map<id, Decimal> subscriptionLinesTotals (List<SBQQ__Subscription__c> subss){
        Map<Id, Decimal>  SubscripToTotal = new Map<Id, Decimal>();
        Integer term;
        
        for( SBQQ__Subscription__c sline: subss){
       
                term = sline.SBQQ__Contract__r.ContractTerm;
            
            //Check to see map has key, get values, and sum together.
            if(SubscripToTotal.containsKey(sline.SBQQ__ProductId__c)){
                Decimal total =  0.0;
                total = SubscripToTotal.get(sline.SBQQ__ProductId__c) +  sline.Subscription_ACV__c;
                SubscripToTotal.put(sline.SBQQ__ProductId__c,total);
            }
            else{
                SubscripToTotal.put(sline.SBQQ__ProductId__c, sline.Subscription_ACV__c);
            }
        }
        
        
        return SubscripToTotal;
        
    }
    
    
    //Find the max quantity for subscription lines
    
    public static Map<id, Decimal> subscriptionLinesMaxQTY(List<SBQQ__Subscription__c> subss){
        Map<Id, Decimal>  SubscripToMaxQty = new Map<Id, Decimal>();
        
        for(SBQQ__Subscription__c sub :subss ){
            if(SubscripToMaxQty.containsKey(sub.SBQQ__ProductId__c)){
                if(SubscripToMaxQty.get(sub.SBQQ__ProductId__c) < sub.SBQQ__Quantity__c){
                    SubscripToMaxQty.put(sub.SBQQ__ProductId__c,sub.SBQQ__Quantity__c);
                }
            }else{
                SubscripToMaxQty.put(sub.SBQQ__ProductId__c, sub.SBQQ__Quantity__c);
            }
        }
        
        return SubscripToMaxQty;
    
    }
    
    /********
    This method sets the product family set for xSell 
    *****/
    
    public static set<string> subscriptionProductFamilies(List<SBQQ__Subscription__c> subss)
    {
    Set<String> subFamilies = new set<string>();
        for(SBQQ__Subscription__c s :subss)
        {
        subfamilies.add(s.SBQQ__Product__r.Product_SubFamily__c);    
        }
        return subFamilies;
    }
    
    /******* 
    This method recieves List Of OLI related to Quote which is edited and Totals the Net and then we divide them by Term Multiply by 12 
    ***********/
   public static Map<id, Decimal> oppLinesTotals(List<OpportunityLineItem> oliss){
        Map<Id, Decimal>  ProductToTotal = new Map<Id, Decimal>();
        Map<Id, integer>  producttoterm= new Map<Id, integer>();
        //Integer term;
        
        for(OpportunityLineItem olis :oliss ){
            if(producttoterm.containskey(olis.Product2Id)){
                //term = (Integer) olis.Months__c;
                Integer term = producttoterm.get(olis.Product2Id);
                term = term + Integer.valueOf(olis.Months__c);
                producttoterm.put(olis.Product2Id, term);
                
            }else{
                producttoterm.put(olis.Product2Id, Integer.valueOf(olis.Months__c));
            }
            if(ProductToTotal.containsKey(olis.Product2Id)){
                Decimal total =  0.0;
                total = ProductToTotal.get(olis.Product2Id) +  olis.totalprice;
                ProductToTotal.put(olis.Product2Id,total);
            }else{
                system.debug('OLIIII ID===>'+ olis.Product2Id);
                ProductToTotal.put(olis.Product2Id, olis.totalprice);
            }
        }
        
        for(Id idd : ProductToTotal.keyset()){
            Decimal Net = ProductToTotal.get(idd);
            //Decimal tots =  (Net/term)* 12;
            system.debug('OLIIII ID Going IN===>'+ idd);
            Decimal tots =  (Net/producttoterm.get(idd))* 12;
            ProductToTotal.put(idd,tots);
        }
        
        return ProductToTotal;
    
    }
        
    public static Map<id, Decimal> oppLinesMaxQTY(List<OpportunityLineItem> oliss){
        Map<Id, Decimal>  ProductToMaxQty = new Map<Id, Decimal>();
        
        for(OpportunityLineItem olis :oliss ){
            if(ProductToMaxQty.containsKey(olis.Product2Id)){
                if(ProductToMaxQty.get(olis.Product2Id) < olis.Contract_Quantity__c){
                    ProductToMaxQty.put(olis.Product2Id,olis.Contract_Quantity__c);
                }
            }else{
                ProductToMaxQty.put(olis.Product2Id, olis.Contract_Quantity__c);
            }
        }
        
        return ProductToMaxQty;
    }
    // Method to Populate the Renewal Retention,Deduction and upsell Renewal
    public static void phoenixRenewalARRcalc(string opportunityid){
        Set<string> MDQdoublePrevention = new Set<String>();
        decimal renewalRetentionRollup=0;
        decimal renewalUpsellRollup=0;
        decimal renewalDeductioRollup=0;
        decimal renewalXsellRollup=0;
        opportunity opp;
        list<opportunitylineitem> olis=new list<opportunitylineitem>();
        if(opportunityid!=null && opportunityid!=''){
            list<opportunity> opplist=[select id,SBQQ__RenewedContract__c, type,Prior_Opportunity__r.pricebook2.name,pricebook2.name,(select id,product2id, Product2.Name, Product2.Product_SubFamily__c, Product2.Product_Type__c, SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c from opportunitylineitems where product2.Product_Type__c = 'Subscription' OR product2.Name = 'Production Instance' )  from opportunity where id=:opportunityid];
            
            if(opplist!=null && !opplist.isempty()){
                opp =opplist[0];
                calculateARRFields(opp.id,opp.SBQQ__RenewedContract__c,null);
                pheonixToRubiks();
                rubiksToPhoenix();
                for(opportunitylineitem oli:opp.opportunitylineitems){
                    if((opp.pricebook2.name=='Enterprise Price Book v2018' || opp.pricebook2.name=='SMB Price Book v2018') && opp.Prior_Opportunity__r.pricebook2.name =='MKTO Standard Price Book'){
                        oli.Renewal_Retention__c= renewalRentention(oli,'Rubiks To Phoenix');
                        oli.Renewal_Deduction__c = renewalDeduction(oli,'Rubiks To Phoenix');
                        oli.Renewal_Upsell__c = renewalUpsell(oli,'Rubiks To Phoenix');
                        if(subFamlies.contains(oli.Product2.Product_SubFamily__c) == true && oli.Renewal_Upsell__c < = 0)
                        {
                        system.debug(oli.Product2Id + ' Renewal Upsell is being set by xSell');    
                        oli.Renewal_Upsell__c = renewalXSell(oli, 'Rubiks to Phoenix');
                         }
                        else
                        {
                         oli.RenewalCrosssell__c = renewalXSell(oli, 'Rubiks to Phoenix');
                        }   
                        
                        if(MDQdoublePrevention.contains(oli.Product2Id) == false)
                        {
                        olis.add(oli);
                        MDQdoublePrevention.add(oli.Product2Id);
                        
                        
                        renewalRetentionRollup+=oli.Renewal_Retention__c;
                        if(oli.Renewal_Upsell__c != NULL)
                        {
                        renewalUpsellRollup+=oli.Renewal_Upsell__c;
                        }
                        renewalDeductioRollup+=oli.Renewal_Deduction__c;
                        if(oli.RenewalCrosssell__c != NULL)
                        {
                        renewalXsellRollup += oli.RenewalCrosssell__c;
                        }
                        }
                    }
                    else{
                        oli.Renewal_Retention__c= renewalRentention(oli,'Other');
                        oli.Renewal_Upsell__c = renewalUpsell(oli,'Other');
                        oli.Renewal_Deduction__c = renewalDeduction(oli,'Other');
                       if(subFamlies.contains(oli.Product2.Product_SubFamily__c) == true && oli.Renewal_Upsell__c < = 0)
                        {
                         system.debug(oli.Product2Id + ' Renewal Upsell is being set by xSell' );     
                        oli.Renewal_Upsell__c = renewalXSell(oli, 'Other');
                        }
                        else
                        { 
                         oli.RenewalCrosssell__c = renewalXSell(oli, 'Other');
                        }   
                           if(MDQdoublePrevention.contains(oli.Product2Id) == false)
                        {
                        olis.add(oli);
                        MDQdoublePrevention.add(oli.Product2Id);
                        
                        renewalRetentionRollup+=oli.Renewal_Retention__c;
                        if(oli.Renewal_Upsell__c != NULL)
                        {
                        renewalUpsellRollup+=oli.Renewal_Upsell__c;
                        }
                        renewalDeductioRollup+=oli.Renewal_Deduction__c;
                        if(oli.RenewalCrosssell__c != NULL)
                        {
                        renewalXsellRollup += oli.RenewalCrosssell__c;
                        }
                    }
                    }
                    if(oli.Product2.Name == 'Production Instance')
                    {
                     oli.Renewal_Deduction__c = droppedProducts(ProductToTotal, SubscriptoTotal); 
                     if(oli.Renewal_Deduction__c != NULL)
                     {
                     renewalDeductioRollup+=oli.Renewal_Deduction__c;   
                     }
                     }
                }
                
            }
        }
        if(!olis.isempty()){
           update olis; 
        }
        if(opp!=null && (renewalRetentionRollup!=0 || renewalUpsellRollup!=0 || renewalDeductioRollup!=0)){
            opp.Renewal_Retention__c=renewalRetentionRollup;
            opp.Renewal_Upsell__c =renewalUpsellRollup;
            opp.Renewal_Deduction__c =renewalDeductioRollup;
            opp.RenewalCrosssell__c = renewalXsellRollup; 
            update opp;
        }
    }
    
    //calculate renewal retention
 public static decimal renewalRentention(opportunitylineitem oli, string event){
        Decimal RenewalRetention=0;
        if(event=='Rubiks To Phoenix' && pheonixToRubiks.containskey(oli.product2id) && ProductToTotal.containskey(oli.product2id) && ProductToMaxQty.containskey(oli.product2id) && SubscripToMaxQty.containskey(pheonixToRubiks.get(oli.product2id)))
        {
        system.debug('Rubiks to Phoenix Retention');
            if(SubscripToMaxQty.get(pheonixToRubiks.get(oli.product2id)) >= ProductToMaxQty.get(oli.product2id) ){
                system.debug(oli.Product2.Name); 
                system.debug('SUB >= OLI');
                RenewalRetention =  ProductToTotal.get(oli.product2id);
            }
             if(SubscripToMaxQty.get(pheonixToRubiks.get(oli.product2id)) < ProductToMaxQty.get(oli.product2id) ){
                 system.debug(oli.Product2.Name);
              system.debug('SUB < OLI');
               system.debug('Product Total:');
               system.debug(ProductToTotal.get(oli.product2id));
               system.debug('Subscription Total');
               system.debug(SubscripToTotal.get(pheonixToRubiks.get(oli.product2id)));
               system.debug('Rentention');
                 RenewalRetention = SubscripToTotal.get(pheonixToRubiks.get(oli.product2id));
               system.debug(RenewalRetention); 
             }
        }
        else if(ProductToTotal.containskey(oli.product2id) && ProductToMaxQty.containskey(oli.product2id) && SubscripToMaxQty.containskey(oli.product2id)){
        system.debug('Standard Retention');
            if(SubscripToMaxQty.get(oli.product2id) >= ProductToMaxQty.get(oli.product2id) ){
         system.debug(oli.Product2.Name);
                system.debug('SUB >= OLI');
                RenewalRetention =  ProductToTotal.get(oli.product2id);
            }
           if(SubscripToMaxQty.get(oli.product2id) < ProductToMaxQty.get(oli.product2id) ){
               system.debug(oli.Product2.Name);        
               system.debug('SUB < OLI');
               system.debug('Product Total:');
               system.debug(ProductToTotal.get(oli.product2id));
               system.debug('Subscription Total');
               system.debug(SubscripToTotal.get(oli.product2id));
               RenewalRetention = SubscripToTotal.get(oli.product2id);
               system.debug('Rentention');
               system.debug(RenewalRetention);
            }
          
        }
        return RenewalRetention;
    }
    // calculate renewal upsell
        public static decimal renewalUpsell(opportunitylineitem oli, string event){
        Decimal RenewalUpsell = 0;
        if(event=='Rubiks To Phoenix' && pheonixToRubiks.containskey(oli.product2id) && ProductToTotal.containskey(oli.product2id) && ProductToMaxQty.containskey(oli.product2id) && SubscripToMaxQty.containskey(pheonixToRubiks.get(oli.product2id))){
            if(ProductToMaxQty.get(oli.product2id) > SubscripToMaxQty.get(pheonixToRubiks.get(oli.product2id)))
            {
                RenewalUpsell = ProductToTotal.get(oli.product2id) - SubscripToTotal.get(pheonixToRubiks.get(oli.product2id));    
            }
        }
        else if(/*event=='Other' &&*/ ProductToTotal.containskey(oli.product2id) && ProductToMaxQty.containskey(oli.product2id) && SubscripToMaxQty.containskey(oli.product2id)){
            if(ProductToMaxQty.get(oli.product2id) > SubscripToMaxQty.get(oli.product2id)){
                RenewalUpsell = ProductToTotal.get(oli.product2id) - SubscripToTotal.get(oli.product2id);
        }
       }
        return RenewalUpsell;
    }
    //Calculate renewalDeduction
    public static decimal renewalDeduction(opportunitylineitem oli, string event){
        Decimal RenewalDeduction = 0;
        if(event=='Rubiks To Phoenix' && pheonixToRubiks.containskey(oli.product2id) && ProductToTotal.containskey(oli.product2id) && SubscripToTotal.containskey(pheonixToRubiks.get(oli.product2id))){
            if(SubscripToTotal.get(pheonixToRubiks.get(oli.product2id))- ProductToTotal.get(oli.product2id) > 0 ){
                //renewalDeduction = SubscripToTotal.get(pheonixToRubiks.get(oli.product2id))- ProductToTotal.get(oli.product2id);
                renewalDeduction = ProductToTotal.get(oli.product2id) - SubscripToTotal.get(pheonixToRubiks.get(oli.product2id)) ;
            }
        }
        else if(/*event=='Other' &&*/ SubscripToTotal.containskey(oli.product2id) && ProductToTotal.containskey(oli.product2id)){
            if(SubscripToTotal.get(oli.product2id)- ProductToTotal.get(oli.product2id) > 0){  
            //renewalDeduction = SubscripToTotal.get(oli.product2id)- ProductToTotal.get(oli.product2id);
            //if(ProductToTotal.get(oli.product2id) != NULl &&  SubscripToTotal.get(pheonixToRubiks.get(oli.product2id)) != NULL)
                if(ProductToTotal.get(oli.product2id) != NULl &&  SubscripToTotal.get(oli.product2id) != NULL)
                {
                    renewalDeduction = ProductToTotal.get(oli.product2id) - SubscripToTotal.get(oli.product2id) ;
                }
            }
        }
        return RenewalDeduction;
    }
    
    public static decimal renewalXSell(opportunitylineitem oli, string event)
    {
        decimal renewalXSell = 0;
        if(SubscripToTotal.containskey(oli.product2id) == false && subscripToTotal.containskey(pheonixToRubiks.get(oli.product2id)) == false)
        {
            renewalXSell = ProductToTotal.get(oli.product2id);     
        }
       return renewalXSell;
    }
    
    public static decimal droppedProducts(Map<Id, Decimal> productTotal, Map<Id, Decimal> subTotal)
    {
        system.debug('The Subscriptions are');
        system.debug(subtotal);
        system.debug('Phoenix to Rubiks');
        system.debug(pheonixToRubiks);
        decimal droppedProducts = 0;
        for(ID keyId: subTotal.Keyset())
            {
            system.debug(productTotal.keyset().contains(pheonixToRubiks.get(keyId)));    
            if(productTotal.keyset().contains(keyid) == false  & productTotal.keyset().contains(RubikstoPhoenix.get(keyId)) == false) 
            {
            droppedProducts = droppedProducts + subtotal.get(keyid);    
            }
            }
        
        return droppedProducts * -1;
        
    }
}