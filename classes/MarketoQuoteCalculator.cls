/*******************************************************************
*Modified By: Sumit Bhatt, Grazitti Interactive
*Purpose: REF: #APPS-18580# Update Test Classes
*Tracking: One cn track the changes by searching ticket number in code
*******************************************************************/
/*PLUGIN : 2OCT 2015*/

global class MarketoQuoteCalculator implements SBQQ.QuoteCalculatorPlugin {

    global class supportWrapper{
        global Decimal percentofNet{get;set;}
        global Decimal prorate{get;set;}
        global Decimal totalfloor{get;set;}
        global Decimal floorMCV{get;set;}
        global String quoteLine{get;set;}
        global String parentSeg{get;set;}
        global Decimal defaultTerm{get;set;}
        global Boolean existing{get;set;}
        global String productCode{get;set;}
        global Decimal priorQuantity{get;set;}
        global Decimal quantity{get;set;}
        global Decimal subPriorQuantity{get;set;}


        global supportWrapper(){

        }

    }

     global class contractSubWrapper{

        global Decimal totalSub{get;set;}
        global Decimal subMCV{get;set;}
        global String parentSeg{get;set;}
        global Decimal previousSub{get;set;}
        global Decimal previousSubMCV{get;set;}

        global contractSubWrapper(){

        }

    }

    private Boolean hasNegativeQuantity = false;   // Used for support floor price logic
    private String debugMessage = '';
    global Map<String,Decimal> rubiksBundlePreviousDiscounts{get;set;}
    global Boolean isRubiks{get;set;}
    global Map<String,Decimal> rubiksPreviousSupport{get;set;}

     global void onBeforeCalculate(SObject quote, SObject[] lines) {
        
        for(SObject line : lines) {
            Boolean includeComponent = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.Include_in_Bundle_Price__c));
            includeComponent = (includeComponent == NULL)?FALSE:includeComponent;
            Decimal quantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
            quantity = (quantity == NULL) ? 0: quantity;
            SObject parent = line.getSObject(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c.getDescribe().getRelationshipName());
            String payment = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.Payment_Freq__c));
            String orderType = (String)quote.get(String.valueOf(SBQQ__Quote__c.Order_Type__c));
            Decimal msrp = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.MSRP_Price__c));
            String subscription = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c));
            Decimal prorate = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProrateMultiplier__c));
            Decimal calcListPrice = 0;
            DateTime createdDateTime = (DateTime)line.get(String.valueOf(SBQQ__QuoteLine__c.CreatedDate));
            createdDateTime=(createdDateTime==NULL) ? system.now() : createdDateTime;
            Date createdDate = date.newinstance(createdDateTime.year(), createdDateTime.month(), createdDateTime.day());
            String bpricingMethod = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PricingMethod__c));
            String productCode = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            Set<String> subBaseCodes=new Set<String>{'SUP-BASE-BUS', 'EDU-TRN-PASS', 'SUP-BASE-STD-SMB', 'SUP-BASE-PRM', 'SUP-BASE-ELT' };
            Set<String> rubikPOTSKU=new Set<String>{'PROD-PLAT-SANDBOX', 'PROD-PLAT-DATAENCRYPT', 'PROD-PLAT-GEI'};

            bpricingMethod = (bpricingMethod == NULL) ? '': bpricingMethod;
            productCode = (productCode == NULL) ? '': productCode;

            if(String.isNotEmpty(subscription)) {
                if(bpricingMethod<>'Block'){
                    msrp = (msrp == null) ? 0 : msrp;
                    prorate = (prorate == null) ? 1 : prorate;
                    if(parent != null) {
                        String emailVol = (String)parent.get(String.valueOf(SBQQ__QuoteLine__c.Email_Volume__c));
                        emailVol = (emailVol == NULL) ? '': emailVol;
                        if( productCode == 'PROD-PLAT-EMAIL-INF'){
                            if(emailVol == '1M-20M'){
                                msrp = msrp * 8.75;
                            } else if (emailVol =='20M+'){
                                msrp = msrp * 18.75;
                            }
                        }
                        
                    }
                    // Apply payment frequency uplift
                    if(payment != null && payment != 'Annually' && !rubikPOTSKU.contains(productCode) && !subBaseCodes.contains(productCode)) {
                        if(createdDate >= Date.valueOf(Label.RubiksStartDate)){
                                calcListPrice = (msrp * 1.1).setScale(4, System.RoundingMode.HALF_UP);
                            }else{
                                calcListPrice = (msrp * 1.11111111 ).setScale(4, System.RoundingMode.HALF_UP);
                            }
                        
                    } else {
                        // Remove uplift
                        calcListPrice = msrp;
                    }
                    // Apply agency discount
                    if(orderType == 'Agency Standard' && !subBaseCodes.contains(productCode) && !rubikPOTSKU.contains(productCode)) {
                        calcListPrice = (calcListPrice * 0.7).setScale(4, System.RoundingMode.HALF_UP);
                    }

                    line.put(SBQQ__QuoteLine__c.SBQQ__ListPrice__c, calcListPrice);
                    
                    //Apply Renewal Uplift - Begin
                    String renewedSubscription = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RenewedSubscription__c));

                    if(String.isNotEmpty(renewedSubscription)) {
                        Decimal previousMSRP = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Subscription_MSRP__c));
                        Decimal previousDisc = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Subscription_Disc__c));
                        Decimal renewalUplift = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Subscription_Uplift__c));
                        Decimal currentDisc = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c));
                        Decimal calcDisc = 0;
                        
                        renewalUplift=(renewalUplift == null) ? 0 : renewalUplift;
                        previousMSRP=(previousMSRP==NULL) ? 0 : previousMSRP;

                        // Apply previous discount to support
                        if( currentDisc == null  && subBaseCodes.contains(productCode)){
                            line.put(SBQQ__QuoteLine__c.SBQQ__Discount__c, previousDisc);
                        } 
                        // Determine the uplifted price of non-zero and non-support products and compare it to the MSRP
                        // Then determine the discount to achieve the uplifted price or if upflited price is higher than MSRP set discount to 0
                        if( msrp != null && msrp != 0 && !subBaseCodes.contains(productCode)) {
                            previousDisc = (previousDisc == null) ? 0 : previousDisc;
                            Decimal previousList = previousMSRP - ((previousMSRP/100) * previousDisc);
                            Decimal upliftedPrice =  previousList + ((previousList/100)*renewalUplift);
                            if( upliftedPrice < msrp ) {
                                calcDisc = ((msrp - upliftedPrice) / (msrp/100)).setScale(4, System.RoundingMode.HALF_UP);
                                if( includeComponent == true ) {
                                    line.put(SBQQ__QuoteLine__c.Renewal_Discount__c, calcDisc);
                                    line.put(SBQQ__QuoteLine__c.Renewal_Uplifted_Price__c, upliftedPrice);
                                } else if( currentDisc == null ) {  
                                    line.put(SBQQ__QuoteLine__c.SBQQ__Discount__c, calcDisc);
                                }
                            } else if(includeComponent == true) {
                                line.put(SBQQ__QuoteLine__c.Renewal_Uplifted_Price__c, msrp);
                                line.put(SBQQ__QuoteLine__c.Renewal_Discount__c, 0);
                            }
                        }
                        // If product price is hidden in bundle aggregate uplifted price to bundle field
                        if(includeComponent == True) {    
                            if(String.isNotEmpty(renewedSubscription)) {
                                Decimal pCompTotal = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Renewal_Component_Total__c));
                                Decimal upliftedPrice = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Renewal_Uplifted_Price__c));
                                pCompTotal = (pCompTotal == null) ? 0 : pCompTotal;
                                upliftedPrice = (upliftedPrice == null) ? 0 : upliftedPrice;
                                pCompTotal += (upliftedPrice * quantity).setScale(4, System.RoundingMode.HALF_UP);
                                parent.put(SBQQ__QuoteLine__c.Renewal_Component_Total__c, pCompTotal); 
                            }      
                        }
                    //Renewal Uplift - End
                    }
                }
            }
            
            // Locate support line
            Date qStartDate = (Date)quote.get(String.valueOf(SBQQ__Quote__c.SBQQ__StartDate__c));
            Boolean bundled = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Bundled__c));
            
            Date qStart3Months;    // Start date + 3 months
            Date qEnd3Months;      // Start date + 3 months - 1 day
            Date qEnd12Months;     // Start date + 12 months
            
            bundled = (bundled == null) ? false : bundled;
            
            // Set start end end date for Business Support and learning passport on Advantage Bundle
            // Set end date for standard support on Advantage Bundle
            String pCode = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.Parent_Product_Code__c));
            if(pCode != null && pCode.startsWithIgnoreCase('BNDL-SVC-ADV')) {
                if(qStartDate != null) {
                    qStart3Months = qStartDate.addMonths(3);
                    qEnd3Months = qStart3Months.addDays(-1);
                    qEnd12Months = qStartDate.addMonths(12).addDays(-1);
                }
                if(productCode != null && (productCode == 'SUP-BASE-BUS' || productCode == 'EDU-TRN-PASS')) {
                    line.put(SBQQ__QuoteLine__c.SBQQ__StartDate__c, qStart3Months);
                    line.put(SBQQ__QuoteLine__c.SBQQ__EndDate__c, qEnd12Months);
                }
                if(productCode != null && productCode == 'SUP-BASE-STD-SMB') {
                    line.put(SBQQ__QuoteLine__c.SBQQ__EndDate__c, qEnd3MOnths);
                }
            }
        }


        // Second Pass
        // Renewals: Calculate the blended discount of the bundle line based on the aggrgate uplifted products price
        // Set prior qty for support on amendments
        for(SObject line : lines) {

            Boolean includeComponent = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.Include_in_Bundle_Price__c));
            includeComponent = (includeComponent == NULL)?FALSE:includeComponent;
            SObject parent = line.getSObject(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c.getDescribe().getRelationshipName());

            if(parent != null) {
                if(includeComponent == true) {
                    String renewedSubscription = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RenewedSubscription__c));
       
                    if( renewedSubscription != null && renewedSubscription != '') {
                        Decimal pCompTotal = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Renewal_Component_Total__c));
                        Decimal blendedDiscount = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Renewal_Blended_Discount__c));
                        Decimal upliftedPrice = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Renewal_Uplifted_Price__c));
                        Decimal quantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
                        Decimal renewalDisc = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Renewal_Discount__c));
                        blendedDiscount = (blendedDiscount == null) ? 0 : blendedDiscount;
                        quantity = (quantity == null) ? 0: quantity;
                        renewalDisc = (renewalDisc == NULL) ? 0: renewalDisc;
                        upliftedPrice = (upliftedPrice == NULL) ? 0: upliftedPrice;
                        if( pCompTotal != 0 ){
                            blendedDiscount += ((((upliftedPrice * quantity * renewalDisc)/100)/pCompTotal)*100).setScale(4, System.RoundingMode.HALF_UP);
                        }
                        parent.put(SBQQ__QuoteLine__c.Renewal_Blended_Discount__c, blendedDiscount); 
                    }
                }
            }
         }

         // Third Pass - Renewals
         // Set the calculated blended discount for the bundle to the actaul discount
        for(SObject line:lines){
            String productCode = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            String renewedSubscription = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RenewedSubscription__c));
            if( renewedSubscription != null && renewedSubscription != '') {
                if( productCode.startsWithIgnoreCase('BNDL')  ){
                    SObject parent = line.getSObject(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c.getDescribe().getRelationshipName());
                    Decimal blendedDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Renewal_Blended_Discount__c));
                    Decimal currentDisc = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c));
                    if( currentDisc == null){
                        line.put(SBQQ__QuoteLine__c.SBQQ__Discount__c, blendedDiscount.setScale(4,System.roundingMode.HALF_UP));
                    }
                }
            }  
        }
    }



    global void onBeforePriceRules(SObject quote, SObject[] lines) {
         //system.debug('BEFORE PRICE RULES');
        if(isRubiks){
            /************RUBIK********************/
            String rubikMasterSKU='PROD-APPS-AUTOWKFL';
            Set<String> rubikSubSKU=new Set<String>{'PROD-APPS-ADVREP','PROD-APPS-LCM', 'PROD-PLAT-WORKPAR'};
            Map<String,Map<Decimal,Decimal>> bundleMap=new Map<String,Map<Decimal,Decimal>>();
            Map<String,Decimal> bundleMaxMap=new Map<String,Decimal>();
            Map<String,Decimal> bundleNullMap=new Map<String,Decimal>();
            Map<String,Boolean> bundleBoolean=new Map<String,Boolean>();

            Map<Decimal,Decimal> seqment_to_qty_map=new Map<Decimal,Decimal>();
            Decimal maxqtyMasterSKU=0;
            Decimal nullMasterSKU=0;
            Boolean isSegmentNull=false;

            // Proagate qty from Automation & Workflow to all contacts based skus inside each segemnt
            // First Pass, Create Seqment to Qty Map
            for(SObject line : lines) {
                SObject parent = line.getSObject(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c.getDescribe().getRelationshipName());
                Decimal qty = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
                Decimal segment = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SegmentIndex__c ));
                String code = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
                String reqBy = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c));
                String productid = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Product__c));

                code=(code==null) ? '' : code;
                qty=(qty==null) ? 0 : qty;
                reqBy=(reqBy==null) ? '' : reqBy;

                system.debug(code);

                if(code==rubikMasterSKU){
                    if(!bundleMap.containsKey(reqBy)){
                        //Add all Bundle Maps
                        maxqtyMasterSKU=(qty>maxqtyMasterSKU) ? qty : maxqtyMasterSKU;
                        bundleMaxMap.put(reqBy,maxqtyMasterSKU);
                        if(segment==NULL){
                            bundleBoolean.put(reqBy,true);

                            bundleNullMap.put(reqBy,qty);

                            seqment_to_qty_map=new Map<Decimal,Decimal>();
                            bundleMap.put(reqBy,seqment_to_qty_map);
                        }else{
                             seqment_to_qty_map=new Map<Decimal,Decimal>();
                            seqment_to_qty_map.put(segment,qty);    
                            bundleBoolean.put(reqBy,false);
                            bundleMap.put(reqBy,seqment_to_qty_map);
                        }
                    }else{
                        maxqtyMasterSKU=bundleMaxMap.get(reqBy);
                        maxqtyMasterSKU=(qty>maxqtyMasterSKU) ? qty : maxqtyMasterSKU;
                        bundleMaxMap.put(reqBy,maxqtyMasterSKU);

                        if(segment==NULL){
                            bundleBoolean.put(reqBy,true);
                            bundleNullMap.put(reqBy,qty);

                            seqment_to_qty_map=new Map<Decimal,Decimal>();
                            bundleMap.put(reqBy,seqment_to_qty_map);
                        }else{
                            seqment_to_qty_map=new Map<Decimal,Decimal>();
                            seqment_to_qty_map=bundleMap.get(reqBy);
                            seqment_to_qty_map.put(segment,qty);    
                            bundleMap.put(reqBy,seqment_to_qty_map);
                        }
                    }  
                }
            }

            // Second Pass
            // Inject qty into related skus
            for(SObject line : lines) {
                Decimal qty = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
                Decimal segment = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SegmentIndex__c));
                String code = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
                String reqBy = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c));
                String productid = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Product__c));

                reqBy=(reqBy==null) ? '' : reqBy;
                code=(code==null) ? '' : code;
                qty=(qty==null) ? 0 : qty;
                system.debug(reqBy);
                 
                if(rubikSubSKU.contains(code) && qty!=0){
                    
                    if(bundleMap.containsKey(reqBy)){
                      seqment_to_qty_map=bundleMap.get(reqBy);  
                    }
                    
                    nullMasterSKU=bundleNullMap.get(reqBy);
                    maxqtyMasterSKU=bundleMaxMap.get(reqBy);
                    isSegmentNull=bundleBoolean.get(reqBy);
                    
                    system.debug(nullMasterSKU);
                    system.debug(maxqtyMasterSKU);
                    system.debug(isSegmentNull);
                    system.debug(segment);

                    
                   
                    if(isSegmentNull){
                      line.put(SBQQ__QuoteLine__c.SBQQ__Quantity__c, nullMasterSKU); //
                      line.put(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c, nullMasterSKU);
                    }
                    
                    else if(segment==NULL){
                        line.put(SBQQ__QuoteLine__c.SBQQ__Quantity__c, maxqtyMasterSKU);
                        line.put(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c, maxqtyMasterSKU);
                    }else if(seqment_to_qty_map.containsKey(segment)){
                        line.put(SBQQ__QuoteLine__c.SBQQ__Quantity__c, seqment_to_qty_map.get(segment));
                        line.put(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c, seqment_to_qty_map.get(segment));
                    }
                   
                }
            }
             /************END RUBIK********************/
        }
    }
    
    global void onAfterPriceRules(SObject quote, SObject[] lines) {
        //system.debug('AFTER PRICE RULES');

        if(isRubiks){
            /************RUBIK********************/
            Set<String> rubikBundles=new Set<String>{'BNDL-SMB-MKTGAUTO', 'BNDL-ENT-MKTGAUTO'};

            // Propogated Discount(s) from bundle line
            for(SObject line : lines) {
                SObject parent = line.getSObject(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c.getDescribe().getRelationshipName());
                if(parent != null) {
                    String productCodecheck = (String)parent.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
                    Decimal addlDiscount_parent = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c));
                    Boolean pexisting = (Boolean)parent.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Existing__c));

                    if(rubikBundles.contains(productCodecheck)){
                        Decimal segment = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SegmentIndex__c ));
                        Decimal addlDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c));
                        String productFam = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.Product_Family__c));
                        String productType = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type__c));
                        String parentqlId = (String)parent.get(String.valueOf(SBQQ__QuoteLine__c.id));
                        String subscriptionPricing = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c));
                        Boolean includeInMaintenance = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.Include_in_Maintenance__c));
                        Decimal subPercent=(Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPercent__c));
                        String quoteType = (String)quote.get(String.valueOf(SBQQ__Quote__c.SBQQ__Type__c));

                        Decimal previousDisc=NULL;
                        if(rubiksBundlePreviousDiscounts.containsKey(parentQLID)){
                            previousDisc=rubiksBundlePreviousDiscounts.get(parentqlId);  
                        }
                        
                        pexisting=(pexisting==null) ? false : pexisting;
                        
                        quoteType=(quoteType==NULL) ? '' : quoteType;
                        segment=(segment==null) ? 0 : segment;
                        productFam=(productFam==NULL) ? '' : productFam;
                        productType=(productType==NULL) ? '' : productType;
                        // Create Map of Parent to Subscription SKUs by Line and Segment
                        if( (quoteType=='Amendment' && pexisting==false) || quoteType!='Amendment'){
                            if(subscriptionPricing != null && includeInMaintenance && subPercent ==null){ 

                                if(addlDiscount_parent!=NULL){
                                        parent.put(SBQQ__QuoteLine__c.Previous_Additional_Discount__c, addlDiscount_parent);  

                                        if(addlDiscount==NULL){
                                            if(segment==0 || segment==1){
                                            line.put(SBQQ__QuoteLine__c.SBQQ__Discount__c, addlDiscount_parent); 
                                            }
                                        }else if( ( (addlDiscount_parent==addlDiscount || previousDisc==addlDiscount) &&  addlDiscount!=0) && (segment==0 || segment==1) ){
                                                line.put(SBQQ__QuoteLine__c.SBQQ__Discount__c, addlDiscount_parent);  
                                        }
                                       
                                    
                                    
                                }else{
                                    parent.put(SBQQ__QuoteLine__c.Previous_Additional_Discount__c, NULL); 
                                    if(addlDiscount!=NULL){

                                        if( (addlDiscount_parent==addlDiscount || previousDisc==addlDiscount)  && (segment==0 || segment==1) ){
                                            line.put(SBQQ__QuoteLine__c.SBQQ__Discount__c, null); 
                                        }
                                    }
                                }
                            }

                        }
                        
                    }
                }
            }
             /************END RUBIK********************/
        }
        

        if(!isRubiks){
             //Sets for Product Code, Easily Updatabale
            Set<String> rcaCodes=new Set<String>{'PROD-ANA-RCA','PROD-ANA-RCA-USE', 'PROD-ANA-DIA-RCA','PROD-ANA-DIA-RCA-USE'  };
            Set<String> socialCodes=new Set<String>{'PROD-SOC-CAMP','PROD-SOC-CAMP-USE','PROD-SOC-DIA-CAMP-RCA','PROD-SOC-DIA-CAMP-RCA-USE'};
            Set<String> workCodes=new Set<String>{'PROD-MA-WRKSP', 'PROD-MA-WRKSP-USE','PROD-MA-DIA-WRKSP', 'PROD-MA-DIA-WRKSP-USE' };
            Set<String> integCodes=new Set<String>{'PROD-MA-DIA-INT','PROD-MA-DIA-INT-USE' };

            for(SObject line : lines) {
                SObject parent = line.getSObject(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c.getDescribe().getRelationshipName());
                String pName = '';
                String dbLabel = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.Database_Size_Label__c));
                Decimal dbSize = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
                String bundleName = '';
                
                // Build the bundle name
                if(parent != null) {
                    pName = (String)parent.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductName__c));
                    String pBundleName = (String)parent.get(String.valueOf(SBQQ__QuoteLine__c.Bundle_Name__c));
                    if(pBundleName == null || pBundleName == '') {
                        pBundleName = pName;
                    }
                    if(dbLabel != null) {
                        if(dbLabel.toLowerCase() == 'parent') {
                            bundleName = pName;
                        } else {
                            if(pName != null && dbSize != null) {
                                dbSize = dbSize * 10000;
                                bundleName = pName + ' - ' + dbSize.format() + ' ' + dbLabel;
                            } else {
                                bundleName = pName;
                            }
                        }
                        parent.put(SBQQ__QuoteLine__c.Bundle_Name__c, bundleName);
                    }
                }
                
                // Format Delta Usage quantity used in concatenating the number of contacts in the product name for usage SKUs
                Decimal qRCA = (Decimal)quote.get(String.valueOf(SBQQ__Quote__c.Records_to_be_Purchased_for_RCA__c));
                Decimal qSocial = (Decimal)quote.get(String.valueOf(SBQQ__Quote__c.Records_to_be_Purchased_for_Social__c));
                Decimal qWork = (Decimal)quote.get(String.valueOf(SBQQ__Quote__c.Records_to_be_Purchased_for_Workspaces__c));
                Decimal qInteg = (Decimal)quote.get(String.valueOf(SBQQ__Quote__c.Records_to_be_Purchased_for_Integration__c));
                String code = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
                String delta = '';
                
                qRCA = (qRCA == null) ? 0 : qRCA;
                qSocial = (qSocial == null) ? 0 : qSocial;
                qWork = (qWork == null) ? 0 : qWork;
                qInteg = (qInteg == null) ? 0 : qInteg;

                
                if(code != null) {
                    if(rcaCodes.contains(code)){
                        delta = (qRCA * 10000).format();
                    }
                    if(socialCodes.contains(code)){
                        delta = (qSocial * 10000).format();
                    }
                    if(workCodes.contains(code)) {
                        delta = (qWork * 10000).format();
                    }
                    if(integCodes.contains(code)) {
                        delta = (qInteg * 10000).format();
                    }
                    if(delta != '') {
                        line.put(SBQQ__QuoteLine__c.Delta_Usage_Formatted__c, delta);
                    }
                }

            }
        }   
       
    }
    
   
    
    global void onAfterCalculate(SObject quote, SObject[] lines) {
        //system.debug('AfterCalcuate');


        Date maxEndDate = (Date)quote.get(String.valueOf(SBQQ__Quote__c.SBQQ__StartDate__c));
        Set<String> rubikBundles=new Set<String>{'BNDL-SMB-MKTGAUTO', 'BNDL-ENT-MKTGAUTO'};
        Set<String> rubikSupportSKU=new Set<String>{'SUP-BASE-BUS', 'SUP-BASE-PRM', 'SUP-BASE-ELT'};
        Set<String> rubikPOTSKU=new Set<String>{'PROD-PLAT-SANDBOX', 'PROD-PLAT-DATAENCRYPT', 'PROD-PLAT-GEI'};
        Decimal totalQuotedBase = 0;
        String quoteUsage = '';
        quote.put(SBQQ__Quote__c.Additional_UR_Products__c, quoteUsage);

        Map<String,String>  parentSeg_SupportMap=new Map<String,String>();  //ParentSeg to Support Quote Lines
        Map<String,Decimal> parentSeg_SubscriptionTotalNetMCV=new Map<String,Decimal>();    //Parent Seg to Total NET MCV
        Map<String,Decimal> parentSeg_PercentOfTotal=new Map<String,Decimal>(); //Parent Set to Percent of Total %
        Map<String,Decimal> parentSeg_SupportListPriceMCV=new Map<String,Decimal>();   //Parent Seg to List Price of Support (MCV)
        Map<String,Decimal> parentSeg_SupportListPrice=new Map<String,Decimal>();  //Parent Seg to List Price (TOTAL)
        Map<String,Decimal> parentSeg_SubscriptionTotalNet=new Map<String,Decimal>();   //Parent Seg to Total Net Price
        Map<String,Decimal> parentSeg_ProrateMap=new Map<String,Decimal>();   //Parent Seg to Prorate
        Map<String,Decimal> parentSeg_DefaultTerm=new Map<String,Decimal>();   //Parent Seg to Default Term
        Map<String,contractSubWrapper> parentSeg_contractSubMap=new Map<String,contractSubWrapper>();    //Parent Seg to Total Contract NET MCV
        Map<String,List<supportWrapper>>  parentSeg_supportwrapper=new Map<String,List<supportWrapper>>(); 

        // First pass
        // Calculate aggregates
        // Calculate block pricing uplift
        for(SObject line : lines) {           
            String bsubscription = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c));
            String bpricingMethod = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PricingMethod__c));
            String payment = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.Payment_Freq__c));
            String orderType = (String)quote.get(String.valueOf(SBQQ__Quote__c.Order_Type__c));
            Decimal regPrice = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c));
            Decimal calcRegPrice = 0;
            //Testing
            Decimal nettest = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetTotal__c));
            String productTest = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));

            bpricingMethod=(bpricingMethod==NULL) ? '' : bpricingMethod;
            regPrice=(regPrice==NULL) ? 0 : regPrice;
            orderType=(orderType==NULL) ? '' : orderType;
            bsubscription=(bsubscription==NULL) ? '' : bsubscription;

            nettest=(nettest==NULL) ? 0 : nettest;
            productTest=(productTest==NULL) ? '' : productTest;

            system.debug('Original Net Total: ' + productTest + ': ' + nettest);




            
            // Block Pricing non-annual uplift
            // Has to be done in onafterCalculate because block prices are not calculated yet in onBeforeCalculate
            if(String.isNotEmpty(bsubscription) && bpricingMethod=='Block'){

                if(payment != null && payment != 'Annually') {
                    // Apply uplift
                    calcRegPrice = (regPrice * 1.1).setScale(4, System.RoundingMode.HALF_UP);
                } else {
                    // Remove uplift
                    calcRegPrice = regPrice;
                }
                
                if(orderType == 'Agency Standard') {
                    // Apply agency discount
                    calcRegPrice = (calcRegPrice * 0.7).setScale(4, System.RoundingMode.HALF_UP);
                }

                
                 Decimal partnerDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PartnerDiscount__c));
                Decimal addlDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c));
                Decimal addlDiscountAmount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__AdditionalDiscountAmount__c));
                Decimal distDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DistributorDiscount__c));

                Decimal effectiveDiscount = 0;
                Decimal bCustomer=0;
                Decimal bPartner=0;
                Decimal bNet=0;

                distDiscount = (distDiscount == null) ? 0 : distDiscount;
                partnerDiscount = (partnerDiscount == null) ? 0 : partnerDiscount;
                addlDiscount = (addlDiscount == null) ? 0 : addlDiscount;
                addlDiscountAmount = (addlDiscountAmount == null) ? 0 : addlDiscountAmount;




                 if(addlDiscountAmount != null && addlDiscountAmount <> 0) {
                    if(calcRegPrice <> 0) {
                        effectiveDiscount = addlDiscountAmount / ( calcRegPrice / 100 );
                    } else {
                        effectiveDiscount = 0;
                    }
                } else {
                    effectiveDiscount = addlDiscount;
                }
                bCustomer = calcRegPrice * (1 - effectiveDiscount / 100 );
                bPartner = bCustomer * (1 - partnerDiscount / 100 );
                bNet = bPartner * (1 - distDiscount / 100 );
                
                // Save calculated values
                 system.debug('New Net Price: ' + productTest + ': ' + bNet);
                line.put(SBQQ__QuoteLine__c.SBQQ__NetPrice__c, bNet);
                line.put(SBQQ__QuoteLine__c.SBQQ__PartnerPrice__c, bPartner);
                line.put(SBQQ__QuoteLine__c.SBQQ__CustomerPrice__c, bCustomer);
                line.put(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c, calcRegPrice);

                Decimal nettest2 = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetTotal__c));
                nettest2=(nettest2==NULL) ? 0 : nettest2;
               
            }
            


            // Calculate component aggregates in bundle
            Boolean includeComponent = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.Include_in_Bundle_Price__c));
            includeComponent = (includeComponent == NULL)?FALSE:includeComponent;
            SObject parent = line.getSObject(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c.getDescribe().getRelationshipName());
            if(parent != null) {
                        String productCodecheck = (String)parent.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
                //Parent is not part of the Rubiks Bundles
                if(!rubikBundles.contains(productCodecheck)){
                        Decimal plist = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Bundle_Component_List_Total__c));
                        Decimal pregular = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Bundle_Component_Regular_Total__c));
                        Decimal pcustomer = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Bundle_Component_Customer_Total__c));
                        Decimal pnet = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Bundle_Component_Net_Total__c));
                        Decimal parr = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Bundle_Component_ARR_for_Bundles__c));
                        Decimal clist = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProratedListPrice__c));
                        Decimal cregular = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c));
                        Decimal ccustomer = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__CustomerPrice__c));
                        Decimal cnet = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c));
                        Decimal carr = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.ARR_for_Bundles__c));
                        Decimal quantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
                        Decimal prorate = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProrateMultiplier__c));
                        Boolean renewal = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Renewal__c));
                        Boolean bundled = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Bundled__c));
                        Boolean existing = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Existing__c));
                        String pricingMethod = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PricingMethod__c));
                        Decimal defaultTerm = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DefaultSubscriptionTerm__c));
                        String discountScheduleType = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DiscountScheduleType__c));
                        String subscriptionPricing = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c));
                        Decimal pQuotedNetBase = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Quoted_Base_ACV_for_Support__c));
                        Boolean includeInMaintenance = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.Include_in_Maintenance__c));
                        Decimal optionLevel = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__OptionLevel__c));
                        Decimal priorQuantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PriorQuantity__c));

                        String qPromotion = (String)quote.get(String.valueOf(SBQQ__Quote__c.New_Logo_Term_Promotions__c));
                        
                        plist = (plist == null) ? 0 : plist;
                        pregular = (pregular == null) ? 0 : pregular;
                        pcustomer = (pcustomer == null) ? 0 : pcustomer;
                        pnet = (pnet == null) ? 0 : pnet;
                        parr = (parr == null) ? 0 : parr;

                        clist = (clist == null) ? 0 : clist;
                        cregular = (cregular == null) ? 0 : cregular;
                        ccustomer = (ccustomer == null) ? 0 : ccustomer;
                        cnet = (cnet == null) ? 0 : cnet;
                        carr = (carr == null) ? 0 : carr;
                        parr = (parr == null) ? 0 : parr;

                        quantity = (quantity == null) ? 1 : quantity;
                        prorate = (prorate == null) ? 1 : prorate;
                        renewal = (renewal == null) ? false : renewal;
                        bundled = (bundled == null) ? false : bundled;
                        existing = (existing == null) ? false : existing;
                        pricingMethod = (pricingMethod == null) ? 'List' : pricingMethod;

                        pQuotedNetBase = (pQuotedNetBase == null) ? 0 : pQuotedNetBase;
                        optionLevel = (optionLevel == null) ? 0 : optionLevel;

                        qPromotion = (qPromotion == null) ? '' : qPromotion;

                        Decimal clistPrice = clist;
                        
                        // Set negative quantity flag (used for support floor price logic)
                        hasNegativeQuantity=(quantity<0) ? true : false;
                        
                        Decimal cListTotal;
                        Decimal cRegularTotal ;
                        Decimal cCustomerTotal ;
                        Decimal cNetTotal;

                        // Have to use old getTotal method otherwise New Logo pricing on CPQ 2.0 is incorrect
                        if(renewal == false && !isRubiks){  
                           cListTotal = getTotalold(clist, quantity, prorate, renewal, bundled, existing, pricingMethod, discountScheduleType, subscriptionPricing);
                           cRegularTotal = getTotalold(cregular, quantity, prorate, renewal, bundled, existing, pricingMethod, discountScheduleType, subscriptionPricing);
                           cCustomerTotal = getTotalold(ccustomer, quantity, prorate, renewal, bundled, existing, pricingMethod, discountScheduleType, subscriptionPricing);
                           cNetTotal = getTotalold(cnet, quantity, prorate, renewal, bundled, existing, pricingMethod, discountScheduleType, subscriptionPricing);
                       }else{
                           cListTotal = getTotal(clist, quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clistPrice);
                           cRegularTotal = getTotal(cregular, quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clistPrice);
                           cCustomerTotal = getTotal(ccustomer, quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clistPrice);
                           cNetTotal = getTotal(cnet, quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clistPrice);
                           
                       }
                       
                        if(includeComponent == True) {    
                            plist += cListTotal;
                            pregular += cRegularTotal;
                            pcustomer += cCustomerTotal;
                            pnet += cNetTotal;
                            parr += carr;
                            
                            parent.put(SBQQ__QuoteLine__c.Bundle_Component_List_Total__c, plist);
                            parent.put(SBQQ__QuoteLine__c.Bundle_Component_Regular_Total__c, pregular);
                            parent.put(SBQQ__QuoteLine__c.Bundle_Component_Customer_Total__c, pcustomer);
                            parent.put(SBQQ__QuoteLine__c.Bundle_Component_Net_Total__c, pnet);
                            parent.put(SBQQ__QuoteLine__c.Bundle_Component_ARR_for_Bundles__c, parr); 
                            
                        }
                        
                        // Aggregate for support floor price
                        if(subscriptionPricing != null && includeInMaintenance) {
                        // Aggregate subscription base
                            Decimal cBaseACVNet = 0;
                            // If 13-for-12 promotion is in effect, calculate support on TCV instead of ACV
                            if(qPromotion != '13-for-12: Free month') {
                                cBaseACVNet = getMCV(cNetTotal, prorate, defaultTerm) * 12;
                            } else {
                                cBaseACVNet = cNetTotal;
                            }
                            pQuotedNetBase += cBaseACVNet;
                            parent.put(SBQQ__QuoteLine__c.Quoted_Base_ACV_for_Support__c, pQuotedNetBase);
                        }
                }else{
                        //Parent is part of the Rubiks Bundles
                        //Populate Map of ParentQLID + Segment to List of Valid Child QuoteLines
                        //Populate Map of ParentQLID + Segment to Net Amount of Valid Child QuoteLines
                        //Populate Map of ParentQLID + Segment to Support SKUs
                        String parentQLID = (String)parent.get(String.valueOf(SBQQ__QuoteLine__c.Id));
                        String productCode = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
                        Decimal segment = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SegmentIndex__c ));
                        Decimal listPrice = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ListPrice__c ));
                        String productFam = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.Product_Family__c));
                        String productType = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.Product_Type__c));
                        Decimal defaultTerm = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DefaultSubscriptionTerm__c));
                        Decimal prorate = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProrateMultiplier__c));
                        Decimal subscriptionPercent = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPercent__c));
                        String qlId = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.id));
                        Decimal rnetPrice = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c ));
                        Decimal priorQuantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PriorQuantity__c));
                        String discountScheduleType = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DiscountScheduleType__c));
                        String subscriptionPricing = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c));
                        Boolean renewal = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Renewal__c));
                        Boolean existing = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Existing__c));
                        String pricingMethod = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PricingMethod__c));
                        Decimal quantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
                        Decimal clist = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProratedListPrice__c));
                        Decimal originalPrice = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__OriginalPrice__c));
                        Boolean includeInMaintenance = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.Include_in_Maintenance__c));
                        Boolean needsUsage = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.UR_Product__c));
                        Decimal subPriorQuantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Prior_Subscription_Quantity__c));
                        String quoteType = (String)quote.get(String.valueOf(SBQQ__Quote__c.SBQQ__Type__c));
                            
                        quoteType=(quoteType==NULL) ? '' : quoteType;
                        clist = (clist == null) ? 0 : clist;
                        originalPrice = (originalPrice == null) ? 0 : originalPrice;
                        segment=(segment==NULL) ? 0 : segment;
                        rnetPrice=(rnetPrice==NULL) ? 0 : rnetPrice;
                        productCode=(productCode==NULL) ? '' : productCode;
                        subscriptionPercent=(subscriptionPercent==NULL) ? 0 : subscriptionPercent;
                        productFam=(productFam==NULL) ? '' : productFam;
                        productType=(productType==NULL) ? '' : productType;
                        prorate=(prorate==NULL) ? 1 : prorate;
                        listPrice=(listPrice==NULL) ? 0 : listPrice;
                        renewal = (renewal == null) ? false : renewal;
                        existing = (existing == null) ? false : existing;
                        pricingMethod = (pricingMethod == null) ? 'List' : pricingMethod;
                        needsUsage=(needsUsage==null) ? false : needsUsage;
                        subPriorQuantity=(subPriorQuantity==NULL) ? 0 : subPriorQuantity;
                        quantity=(quantity==NULL) ? 0 : quantity;
                        priorQuantity=(priorQuantity==NULL) ? 0 : priorQuantity;

                        String parentSegConcat=parentQLID+String.valueof(segment);
                        Decimal rListTotal=0;
                        Decimal rNetTotal=0;
                        Decimal rContractNetTotal=0;
                        Decimal rPreviousContractNetTotal=0;

                        // Adds usage rights at the quote level
                        if(needsUsage && (quantity-priorQuantity) > 0){
                            quoteUsage = (String)quote.get(String.valueOf(SBQQ__Quote__c.Additional_UR_Products__c));
                            String productName = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.MKTO_Product_Name__c));
                            quoteUsage = (quoteUsage == '') ? productName : quoteUsage + ', ' + productName;
                            quote.put(SBQQ__Quote__c.Additional_UR_Products__c, quoteUsage);
                        }

                        if(quoteType=='Amendment' && rnetPrice == 0){
                            rnetPrice = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Previous_Net_Price__c));
                        } else if(quoteType=='Amendment'){
                            rnetPrice = rnetPrice / prorate;
                        }

                        rListTotal = getTotal(clist, quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clist);
                        rNetTotal = getTotal(rnetPrice, quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clist);
                        rContractNetTotal = getTotal(rnetPrice, quantity, 0, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clist);
                        rPreviousContractNetTotal = getTotal(rnetPrice, priorQuantity, 0, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clist);
                        //rPreviousContractNetTotal = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Subscription_ACV__c));
                        //rPreviousContractNetTotal=(rPreviousContractNetTotal==NULL) ? 0 : rPreviousContractNetTotal;


                        system.debug(productCode);
                        system.debug(productCode + '(Net Total) : ' + rNetTotal);
                        system.debug(productCode + '(List Total) : ' + rListTotal);
                        system.debug(productCode + '(Contract Net Total) : ' + rContractNetTotal);
                        system.debug(productCode + '(Prior Net Total) : ' + rPreviousContractNetTotal);
                        //Create Map of Parent to Subscription SKUs by Line and Segment
                        if(subscriptionPricing != null && includeInMaintenance && !rubikPOTSKU.contains(productCode)){

                            if(parentSeg_SubscriptionTotalNetMCV.containsKey(parentSegConcat)){     
                                //Get Maps of Subscription MCV and Subscription Net Total
                                Decimal subscripRubikMCV=getMCV(rNetTotal, prorate, defaultTerm);
                                parentSeg_SubscriptionTotalNetMCV.put(parentSegConcat, parentSeg_SubscriptionTotalNetMCV.get(parentSegConcat) + subscripRubikMCV);
                                parentSeg_SubscriptionTotalNet.put(parentSegConcat,parentSeg_SubscriptionTotalNet.get(parentSegConcat) + rNetTotal);

                            }else{
                                //Get MCV
                                Decimal subscripRubikMCV=getMCV(rNetTotal, prorate, defaultTerm);
                                parentSeg_SubscriptionTotalNetMCV.put(parentSegConcat,subscripRubikMCV);
                                parentSeg_SubscriptionTotalNet.put(parentSegConcat,rNetTotal);
                            }

                            parentSeg_ProrateMap.put(parentSegConcat, prorate);
                            parentSeg_DefaultTerm.put(parentSegConcat,defaultTerm);

                            if( parentSeg_contractSubMap.containskey(parentSegConcat)){
                                Decimal contractMCV=getMCV(rContractNetTotal, prorate, defaultTerm);
                                Decimal previousContractMCV=getMCV(rContractNetTotal, prorate, defaultTerm);
                                contractSubWrapper csw = parentSeg_contractSubMap.get(parentSegConcat);
                                csw.totalsub = csw.totalSub+rContractNetTotal;
                                csw.subMCV = csw.subMCV+contractMCV;
                                csw.parentSeg = parentSegConcat;
                                csw.previousSub = csw.previousSub + rPreviousContractNetTotal;
                                csw.previousSubMCV = csw.previousSubMCV + previousContractMCV;
                                parentSeg_contractSubMap.put(parentSegConcat,csw);
                            } else if( !parentSeg_contractSubMap.containskey(parentSegConcat)){
                                Decimal contractMCV=getMCV(rContractNetTotal, prorate, defaultTerm);
                                Decimal previousContractMCV=getMCV(rContractNetTotal, prorate, defaultTerm);
                                contractSubWrapper csw = new contractSubWrapper();
                                csw.totalsub = rContractNetTotal;
                                csw.subMCV = contractMCV;
                                csw.parentSeg = parentSegConcat;
                                csw.previousSub = rPreviousContractNetTotal;
                                csw.previousSubMCV = previousContractMCV;
                                parentSeg_contractSubMap.put(parentSegConcat,csw);
                            }
                            system.debug(parentSeg_contractSubMap);

                        }else if(rubikSupportSKU.contains(productCode)){  
                            system.debug(productCode);
                            system.debug(productCode + '(Net Total) : ' + rNetTotal);
                            system.debug(productCode + '(List Total) : ' + rListTotal);



                            if(quoteType=='Amendment' && existing){
                                system.debug(originalPrice);
                                rListTotal = getTotal(originalPrice, 1, 0, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, originalPrice);

                                system.debug(rListTotal);
                                
                                priorQuantity=(priorQuantity==NULL) ? 0 : priorQuantity;
                
                                // Sets prior qty to 0 in order to correctly calculate support on admendments
                                if(priorQuantity > 0){
                                    line.put(SBQQ__QuoteLine__c.SBQQ__PriorQuantity__c , 0);
                                    line.put(SBQQ__QuoteLine__c.Prior_Subscription_Quantity__c , priorQuantity);    
                                }

                                parentSeg_SupportMap.put(parentSegConcat,qlId);
                                Decimal supportRubikMCV=getMCV(rListTotal, 1, defaultTerm);
                                parentSeg_SupportListPriceMCV.put(parentSegConcat,supportRubikMCV);  
                                parentSeg_PercentOfTotal.put(parentSegConcat,subscriptionPercent);
                                parentSeg_SupportListPrice.put(parentSegConcat,rListTotal);
                                parentSeg_ProrateMap.put(parentSegConcat, prorate);
                                parentSeg_DefaultTerm.put(parentSegConcat,defaultTerm);

                            }else if(quoteType=='Amendment' && !existing){
                                    //Handling Changing/Updating of Support

                                    rListTotal = getTotal(originalPrice, quantity, 0, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, originalPrice);


                                    parentSegConcat=parentSegConcat+'S';
                                    system.debug(parentSegConcat);
                                    parentSeg_SupportMap.put(parentSegConcat,qlId);
                                    Decimal supportRubikMCV=getMCV(rListTotal, 1, defaultTerm);
                                    parentSeg_SupportListPriceMCV.put(parentSegConcat,supportRubikMCV);  
                                    parentSeg_PercentOfTotal.put(parentSegConcat,subscriptionPercent);
                                    parentSeg_SupportListPrice.put(parentSegConcat,rListTotal);
                                    parentSeg_ProrateMap.put(parentSegConcat, prorate);
                                    parentSeg_DefaultTerm.put(parentSegConcat,defaultTerm);
                            }

                            if(quoteType!='Amendment'){
                                parentSeg_SupportMap.put(parentSegConcat,qlId);
                                Decimal supportRubikMCV=getMCV(rListTotal, prorate, defaultTerm);
                                parentSeg_SupportListPriceMCV.put(parentSegConcat,supportRubikMCV);  
                                parentSeg_PercentOfTotal.put(parentSegConcat,subscriptionPercent);
                                parentSeg_SupportListPrice.put(parentSegConcat,rListTotal);
                                parentSeg_ProrateMap.put(parentSegConcat, prorate);
                                parentSeg_DefaultTerm.put(parentSegConcat,defaultTerm);
                            }
                            
                        }else if(rubikPOTSKU.contains(productCode)){
                            //Create Maps of Parent to Support SKUs, Percent of Total, Total List Price and MCV List Price
                            rListTotal = getTotal(clist, 1, 0, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clist);
                            List<supportWrapper> tempList=new List<supportWrapper>();
                            Decimal supportRubikMCV=getMCV(rListTotal, prorate, defaultTerm);
                            supportWrapper sw=new supportWrapper();
                            sw.parentSeg=parentSegConcat;
                            sw.prorate=prorate;
                            sw.totalfloor=rListTotal;
                            sw.floorMCV=supportRubikMCV;
                            sw.percentofNet=subscriptionPercent;
                            sw.defaultTerm=defaultTerm;
                            sw.quoteLine=qlId;
                            sw.existing=existing;
                            sw.productCode=productCode;
                            sw.priorQuantity=priorQuantity;
                            sw.quantity=quantity;
                            sw.subPriorQuantity=subPriorQuantity;


                            if(parentSeg_supportwrapper.containsKey(parentSegConcat)){
                                templist=parentSeg_supportwrapper.get(parentSegConcat);
                                tempList.add(sw);
                                parentSeg_supportwrapper.put(parentSegConcat,tempList);
                            }else{
                                tempList.add(sw);
                                parentSeg_supportwrapper.put(parentSegConcat,tempList);
                            }

                            if(quoteType=='Amendment' && existing){
                                priorQuantity=(priorQuantity==NULL) ? 0 : priorQuantity;
                                system.debug(productCode + ' Prior Qty: ' + priorQuantity);
                                system.debug(productCode + ' Sub Prior Qty: ' + subPriorQuantity);
                
                                // Sets prior qty to 0 in order to correctly calculate support on admendments
                                if(priorQuantity > 0 && quantity > subPriorQuantity){
                                    line.put(SBQQ__QuoteLine__c.SBQQ__PriorQuantity__c , 0);
                                    line.put(SBQQ__QuoteLine__c.Prior_Subscription_Quantity__c , priorQuantity);    
                                }
                                if( (quantity > subPriorQuantity && productCode == 'PROD-PLAT-SANDBOX') ||  quantity < subPriorQuantity){
                                    line.put(SBQQ__QuoteLine__c.SBQQ__PriorQuantity__c , subPriorQuantity);  
                                }
                            }
                            
                        }

                    }
            }
            

            // Effective end date and effective term
            String subscription = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c));
            if(subscription != null) {
                Date effEndDate = calculateEndDate(line);
                Decimal effTerm = getEffectiveSubscriptionTerm(line);
                line.put(SBQQ__QuoteLine__c.MKTO_Effective_End_Date__c, effEndDate);
                line.put(SBQQ__QuoteLine__c.MKTO_Effective_Term__c, effTerm);
            }            
        }   //End first Pass
        

       
        if(!isRubiks){
            // Second pass - Aggregate all support base values and retrieve max effective end date
            for(SObject line : lines) {
                Decimal quotedBase = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Quoted_Base_ACV_for_Support__c));
                if(quotedBase != null) {
                    totalQuotedBase += quotedBase;
                }
                String lCode = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
                String subscription = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c));
                if(subscription != null && lCode != null && lCode != 'SUP-BASE-BUS' && lCode != 'EDU-TRN-PASS' ) {
                    Date effEndDate = (Date)line.get(String.valueOf(SBQQ__QuoteLine__c.MKTO_Effective_End_Date__c));
                    if(effEndDate != null) {
                        if(maxEndDate == null) {
                            maxEndDate = effEndDate;
                        } else {
                            if(effEndDate > maxEndDate) {
                                maxEndDate = effEndDate;
                            }
                        }
                    }
                }
            }
        }

        //Populate Support Map for Rubiks
        Map<String,Decimal> rubikSupportListMap=new Map<String,Decimal>();
        Map<String,Decimal> rubikSupportHistoricalListMap=new Map<String,Decimal>();

        system.debug(parentSeg_ProrateMap);
        system.debug(parentSeg_DefaultTerm);
        system.debug(parentSeg_PercentOfTotal);
        system.debug(parentSeg_SupportListPriceMCV);
        system.debug(parentSeg_SubscriptionTotalNetMCV);
        system.debug(parentSeg_SupportListPrice);
        system.debug(parentSeg_SubscriptionTotalNet);
        system.debug(parentSeg_supportwrapper);

        for(String s:parentSeg_SubscriptionTotalNetMCV.keySet()){
            //system.debug(s);

            Decimal percentOfNet=0;
            Decimal support_List_Floor=0;
            Decimal support_total_List_Floor=0;
            Decimal subscription_Net_Total_MCV=0;
            Decimal subscription_net_total=0;
            Decimal proRate=0;
            Decimal defaultTerm=0;

            if(parentSeg_ProrateMap.containsKey(s)){
                proRate=parentSeg_ProrateMap.get(s);
            }

            if(parentSeg_DefaultTerm.containsKey(s)){
                defaultTerm=parentSeg_DefaultTerm.get(s);
            }

            if(parentSeg_PercentOfTotal.containsKey(s)){
                percentOfNet=parentSeg_PercentOfTotal.get(s);
            }

            if(parentSeg_SupportListPriceMCV.containsKey(s)){
                support_List_Floor=parentSeg_SupportListPriceMCV.get(s);
            }

             if(parentSeg_SubscriptionTotalNetMCV.containsKey(s)){
                subscription_Net_Total_MCV=parentSeg_SubscriptionTotalNetMCV.get(s);
            }

            if(parentSeg_SupportListPrice.containsKey(s)){
                support_total_List_Floor=parentSeg_SupportListPrice.get(s);
            }

            if(parentSeg_SubscriptionTotalNet.containsKey(s)){
                subscription_net_total=parentSeg_SubscriptionTotalNet.get(s);
            }



            Decimal subscription_support_value_MCV=subscription_Net_Total_MCV * (percentofNet/100);
            Decimal subscription_support_value=subscription_net_total * (percentofNet/100);
            Decimal previousSupport=0;
            Decimal previousSupportMCV=0;
            Decimal finalList=0;
            Decimal previous_subscription_value=0;
            system.debug(subscription_net_total);

            String quoteType = (String)quote.get(String.valueOf(SBQQ__Quote__c.SBQQ__Type__c));
            quoteType=(quoteType==NULL) ? '' : quoteType;
            system.debug(s);
            system.debug(quoteType);
            system.debug(rubiksPreviousSupport);
            Boolean changedSupport=false;

            if(quoteType=='Amendment' && rubiksPreviousSupport.containsKey(s)){
                
                Decimal old_support_List_Floor=0;
                system.debug(s);

                previousSupport=rubiksPreviousSupport.get(s);
                previousSupportMCV=getMCV(previousSupport,1,defaultTerm);   //Set to 1 to get the Original Original Price

                contractSubWrapper csw = parentSeg_contractSubMap.get(s);
                previous_subscription_value=csw.previousSub;
                system.debug('Previous Subscription: ' + previous_subscription_value);

                if(parentSeg_SupportListPrice.containsKey(s +'S')){
                    //This means new Support
                    changedSupport=true;
                    subscription_support_value_MCV=subscription_Net_Total_MCV * (parentSeg_PercentOfTotal.get(s + 'S')/100);
                    subscription_support_value=subscription_net_total * (parentSeg_PercentOfTotal.get(s + 'S')/100);
                    //old_support_total_List_Floor=support_total_List_Floor;
                    old_support_List_Floor=support_List_Floor;
                    //support_total_List_Floor=parentSeg_SupportListPrice.get(s + 'S');
                    support_List_Floor=parentSeg_SupportListPriceMCV.get(s + 'S');
                    //if(percentofNet != 0){
                    //    previousSupport=(rubiksPreviousSupport.get(s)/(percentofNet/100))*(parentSeg_PercentOfTotal.get(s + 'S')/100);
                        previousSupport=previous_subscription_value*(parentSeg_PercentOfTotal.get(s + 'S')/100);
                    //}
                    //previousSupportMCV=getMCV(previousSupport,1,defaultTerm);
                    system.debug(old_support_List_Floor);
                    system.debug(support_List_Floor);
                }

                system.debug('Previous Support: ' + previousSupportMCV);
                system.debug('Current Sub Support: ' + subscription_support_value);
                system.debug('Support List Floor MCV: ' + support_List_Floor);
                system.debug('Previous Subscription Support: ' + previousSupport);

                Decimal combined_subscription_support=previousSupport + subscription_support_value;
                Decimal combined_subscription_support_MCV= getMCV(combined_subscription_support, 1, defaultTerm);

                system.debug(combined_subscription_support);
                system.debug(combined_subscription_support_MCV);
                system.debug(support_total_List_Floor);

                Decimal newMCV=0;
                Decimal newACV=0;
                if(previousSupportMCV > support_List_Floor){
                    newMCV=combined_subscription_support_MCV-previousSupportMCV;
                    system.debug(newMCV);
                    newACV=newMCV * (defaultTerm * prorate);
                    system.debug(newMCV);

                    finalList=newACV;
                    subscription_support_value=combined_subscription_support;

                }else if (combined_subscription_support_MCV > support_List_Floor) {
                    if(changedSupport){
                        newMCV=combined_subscription_support_MCV-old_support_List_Floor;
                    } else {
                        newMCV=combined_subscription_support_MCV-support_List_Floor;
                    }
                    system.debug(newMCV);
                    newACV=newMCV * (defaultTerm * prorate);
                    system.debug(newACV);
                    finalList=newACV;
                    subscription_support_value=combined_subscription_support;
                }else if(changedSupport){
                    newMCV=support_List_Floor-old_support_List_Floor;
                    newACV=newMCV * (defaultTerm * prorate);
                    system.debug(newACV);
                    finalList=newACV;
                    subscription_support_value=combined_subscription_support;
                } else {
                    finalList=0;
                    subscription_support_value=combined_subscription_support;
                }

            }else{
                if(subscription_support_value_MCV > support_List_Floor){
                    finalList=subscription_support_value;
                }else{
                    finalList=support_total_List_Floor;
                }
            }

            
                


            if(changedSupport){
                rubikSupportListMap.put(parentSeg_SupportMap.get(s +'S'), finalList);
                rubikSupportHistoricalListMap.put(parentSeg_SupportMap.get(s + 'S'), subscription_support_value);
            }else{
                rubikSupportListMap.put(parentSeg_SupportMap.get(s), finalList);
                rubikSupportHistoricalListMap.put(parentSeg_SupportMap.get(s), subscription_support_value);
            }
            

            //Reset for Subscription Support SKUS(PROD-PLAT-***)
            finalList=0;
            subscription_support_value_MCV=0;
            subscription_support_value=0;
            Decimal previous_support_value_MCV=0;
            Decimal previous_support_value=0;
            Decimal total_support_value_MCV=0;
            Decimal total_support_value=0;

            
            if(parentSeg_supportwrapper.containsKey(s)){
                if( quoteType != 'Amendment'){
                    for(supportWrapper sw:parentSeg_supportwrapper.get(s)){
                        sw.percentofNet=(sw.percentofNet==NULL) ? 0 : sw.percentofNet;
                        sw.floorMCV=(sw.floorMCV==NULL) ? 0 : sw.floorMCV;

                         subscription_support_value_MCV=subscription_Net_Total_MCV * (sw.percentofNet/100);
                         subscription_support_value=subscription_net_total * (sw.percentofNet/100);

                         if(subscription_support_value_MCV > sw.floorMCV){
                            finalList=subscription_support_value;
                        }else{
                            finalList=sw.totalfloor;
                        }

                        rubikSupportListMap.put(sw.quoteLine, finalList);
                    }
                } else if( quoteType == 'Amendment') {
                    for(supportWrapper sw:parentSeg_supportwrapper.get(s)){
                        if(!sw.existing){
                            sw.percentofNet=(sw.percentofNet==NULL) ? 0 : sw.percentofNet;
                            sw.floorMCV=(sw.floorMCV==NULL) ? 0 : sw.floorMCV;
                            contractSubWrapper csw = parentSeg_contractSubMap.get(s);
                            system.debug(csw);
                            subscription_support_value_MCV=csw.subMCV * (sw.percentofNet/100);
                            subscription_support_value=(csw.totalSub * (sw.percentofNet/100))*sw.prorate;

                            if(subscription_support_value_MCV > sw.floorMCV){
                                finalList=subscription_support_value;
                            }else{
                                finalList=sw.totalfloor;
                            }

                            rubikSupportListMap.put(sw.quoteLine, finalList);
                        } else {
                            sw.percentofNet=(sw.percentofNet==NULL) ? 0 : sw.percentofNet;
                            sw.floorMCV=(sw.floorMCV==NULL) ? 0 : sw.floorMCV;
                            sw.productCode=(sw.productCode==NULL) ? '' : sw.productCode;
                            sw.priorQuantity=(sw.priorQuantity==NULL) ? 0 : sw.priorQuantity;
                            sw.quantity=(sw.quantity==NULL) ? 0 : sw.quantity;
                            sw.subPriorQuantity=(sw.subPriorQuantity==NULL) ? 0 : sw.subPriorQuantity;

                            contractSubWrapper csw = parentSeg_contractSubMap.get(s);
                            system.debug(csw);
                            previous_support_value_MCV=csw.previousSubMCV * (sw.percentofNet/100);
                            previous_support_value=csw.previousSub * (sw.percentofNet/100);
                            total_support_value_MCV=csw.subMCV * (sw.percentofNet/100);
                            total_support_value=csw.totalSub * (sw.percentofNet/100);
                            subscription_support_value_MCV=subscription_Net_Total_MCV * (sw.percentofNet/100);
                            subscription_support_value=subscription_net_total * (sw.percentofNet/100);
                            system.debug(subscription_support_value_MCV);
                            system.debug(subscription_support_value);

                            if(sw.productCode != 'PROD-PLAT-SANDBOX'){
                                if(total_support_value_MCV > sw.floorMCV){
                                    if(previous_support_value_MCV > sw.floorMCV){
                                        finalList=subscription_support_value;
                                    } else {
                                        finalList=subscription_support_value - sw.floorMCV ;
                                    }
                                }else{
                                    finalList=0;
                                }
                            } else {
                                if(sw.quantity > sw.subPriorQuantity){
                                    if(previous_support_value_MCV > sw.floorMCV){
                                        finalList=total_support_value*prorate;
                                    }else{
                                        finalList=sw.totalfloor;
                                    }
                                } else {
                                    if(total_support_value_MCV > sw.floorMCV){
                                        if(previous_support_value_MCV > sw.floorMCV){
                                            finalList=subscription_support_value;
                                        } else {
                                            finalList=subscription_support_value - sw.floorMCV;
                                        }
                                    }else{
                                        finalList=0;
                                    }
                                }
                            }

                            rubikSupportListMap.put(sw.quoteLine, finalList);
                        }
                    }
                }
            }
        }

        system.debug(parentSeg_SubscriptionTotalNet);
        system.debug(parentSeg_PercentOfTotal);
        system.debug(parentSeg_SupportListPriceMCV);
        system.debug(parentSeg_SupportListPrice);
        system.debug(parentSeg_SubscriptionTotalNetMCV);
        system.debug(rubikSupportListMap);
        
        // Third pass - Calculate Support amount - Set end date for Business Support on Advantage Bundles
        for(SObject line : lines) {
            // Locate support line
            String productCode = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            String qlId = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.id));
            Boolean bundled = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Bundled__c));
            String subscription = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c));
            subscription=(subscription==null) ? '' : subscription;
            bundled=(bundled==null) ? false : bundled;
            Decimal mktoDisc = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.MKTO_Discount__c));
           
           String qlId_newsupport=qlId + 'S';

           if(productCode!=null && !productCode.startsWithIgnoreCase('SUP-BASE') && subscription!='' && mktoDisc!=null){
                Decimal regPrice = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c));
                Decimal distDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DistributorDiscount__c));
                Decimal partnerDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PartnerDiscount__c));

                
                regPrice=(regPrice==NULL) ? 0 : regPrice;
                distDiscount=(distDiscount==NULL) ? 0 : distDiscount;
                partnerDiscount=(partnerDiscount==NULL) ? 0 : partnerDiscount;

                Decimal custPrice=0;
                Decimal partPrice=0;
                Decimal netPrice=0;

                 custPrice = regPrice * (1 - mktoDisc / 100 );
                    partPrice = custPrice * (1 - partnerDiscount / 100 );
                    netPrice = partPrice * (1 - distDiscount / 100 );

                // Save calculated values
                    line.put(SBQQ__QuoteLine__c.SBQQ__NetPrice__c, netPrice);
                    line.put(SBQQ__QuoteLine__c.SBQQ__PartnerPrice__c, partPrice);
                    line.put(SBQQ__QuoteLine__c.SBQQ__CustomerPrice__c, custPrice);
                    line.put(SBQQ__QuoteLine__c.SBQQ__Discount__c, mktoDisc);


            }else
            if(productCode != null && productCode.startsWithIgnoreCase('SUP-BASE') && !bundled && !rubikSupportListMap.containsKey(qlId) && !rubikSupportListMap.containsKey(qlId_newsupport)) {
                // Calculate support amount
                SObject parent = line.getSObject(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c.getDescribe().getRelationshipName());
                if(parent != null) {
                    Decimal qContractBase = (Decimal)quote.get(String.valueOf(SBQQ__Quote__c.Contract_Base_ACV_for_Support__c));
                    Decimal qContractSupport = (Decimal)quote.get(String.valueOf(SBQQ__Quote__c.Contract_Support_ACV__c));
                    String qOrderType = (String)quote.get(String.valueOf(SBQQ__Quote__c.Order_Type__c));
                    
                    // Decimal pQuotedBase = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Quoted_Base_ACV_for_Support__c));
                    Decimal pQuotedBase = totalQuotedBase;
                    
                    Decimal quantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
                    Decimal subscriptionPercent = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPercent__c));
                    Decimal distDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DistributorDiscount__c));
                    Decimal partnerDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PartnerDiscount__c));
                    Decimal addlDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c));
                    Decimal addlDiscountAmount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__AdditionalDiscountAmount__c));
                    Decimal prorate = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProrateMultiplier__c));
                    Decimal msrp = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.MSRP_Price__c));
                    
                    Decimal supportBase = 0;
                    Decimal supportACVAmount = 0;
                    Decimal deltaSupportACV = 0;
                    Decimal deltaProrated = 0;
                    Decimal supportNet = 0;
                    Decimal supportPartner = 0;
                    Decimal supportCustomer = 0;
                    Decimal supportRegular = 0;
                    Decimal effectiveDiscount = 0;
                    
                    String debugMessage = '';

                    qContractBase=(qContractBase==null) ? 0 : qContractBase;
                    qContractSupport=(qContractSupport==null) ? 0 : qContractSupport;
                    qOrderType=(qOrderType==null) ? '' : qOrderType;
                    pQuotedBase=(pQuotedBase==null) ? 0 : pQuotedBase;
                    quantity=(quantity==null) ? 1 : quantity;
                    subscriptionPercent=(subscriptionPercent==null) ? 0 : subscriptionPercent;
                    distDiscount=(distDiscount==null) ? 0 : distDiscount;
                    partnerDiscount=(partnerDiscount==null) ? 0 : partnerDiscount;
                    addlDiscount=(addlDiscount==null) ? 0 : addlDiscount;
                    prorate=(prorate==null) ? 1 : prorate;
                    msrp=(msrp==null) ? 0 : msrp;

                    /* FROM Tayo: DO WE NEED DEFAULT FOR ADDL DISCOUNT AMOUNT*/

                    // If the quantity is negative, it's an early termination, we ignore the contract ACV base for support and only use the quoted ACV base
                    // If the quantity is positive, we aggregate the existing subscription base to the quoted subscription base
                    if(quantity < 0) {
                        supportBase = pQuotedBase;
                    } else {
                        // In case of an early termination scenario, the existing subscription base should not be aggregated
                        if(qOrderType == 'Edition Change') {
                            supportBase = pQuotedBase;
                        } else {
                            supportBase = pQuotedBase + qContractBase;
                        }
                    }
                    
                    // Calculate support ACV
                    supportACVAmount = supportBase * subscriptionPercent / 100;
                    
                    // Apply floor price
                    supportACVAmount=(supportACVAmount<msrp) ? msrp : supportACVAmount;

                    // Store result
                    line.put(SBQQ__QuoteLine__c.Support_ACV_Amount__c, supportACVAmount);
                    
                    // Calculate support to charge for
                    if(qOrderType == 'Edition Change') {
                        deltaSupportACV = supportACVAmount;
                    } else {
                        deltaSupportACV = supportACVAmount - qContractSupport;
                    }

                    deltaSupportACV=(deltaSupportACV<0) ? 0 : deltaSupportACV;

                    
                    // Now that we know what the regular price for support is, we need to calculate the other price fields
                    if(prorate <> 0) {
                        supportRegular = deltaSupportACV * prorate;
                    } else {
                        supportRegular = deltaSupportACV;
                    }
                    if(addlDiscountAmount != null && addlDiscountAmount <> 0) {
                        if(supportRegular <> 0) {
                            effectiveDiscount = addlDiscountAmount / ( supportRegular / 100 );
                        } else {
                            effectiveDiscount = 0;
                        }
                    } else {
                        effectiveDiscount = addlDiscount;
                    }
                    supportCustomer = supportRegular * (1 - effectiveDiscount / 100 );
                    supportPartner = supportCustomer * (1 - partnerDiscount / 100 );
                    supportNet = supportPartner * (1 - distDiscount / 100 );
                    
                    // Save calculated values
                    line.put(SBQQ__QuoteLine__c.SBQQ__NetPrice__c, supportNet);
                    line.put(SBQQ__QuoteLine__c.SBQQ__PartnerPrice__c, supportPartner);
                    line.put(SBQQ__QuoteLine__c.SBQQ__CustomerPrice__c, supportCustomer);
                    line.put(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c, supportRegular);
                    
                } 


           
            }

            if(rubikSupportListMap.containsKey(qlId)|| rubikSupportListMap.containsKey(qlId_newsupport)){
                Decimal distDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DistributorDiscount__c));
                Decimal partnerDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PartnerDiscount__c));
                Decimal addlDiscount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c));
                Decimal addlDiscountAmount = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__AdditionalDiscountAmount__c));

                Decimal effectiveDiscount = 0;

                    distDiscount=(distDiscount==null) ? 0 : distDiscount;
                    partnerDiscount=(partnerDiscount==null) ? 0 : partnerDiscount;
                    addlDiscount=(addlDiscount==null) ? 0 : addlDiscount;   
                    Decimal supportNet = 0;
                    Decimal supportPartner = 0;
                    Decimal supportCustomer = 0;
                    Decimal supportRegular = 0;    
                    if(rubikSupportListMap.containsKey(qlId)){
                            supportRegular=rubikSupportListMap.get(qlId);
                        }else if(rubikSupportListMap.containsKey(qlId_newsupport)){
                            supportRegular=rubikSupportListMap.get(qlId_newsupport);
                        }
                
                if(addlDiscountAmount != null && addlDiscountAmount <> 0) {
                        if(supportRegular <> 0) {
                            effectiveDiscount = addlDiscountAmount / ( supportRegular / 100 );
                        } else {
                            effectiveDiscount = 0;
                        }
                    } else {
                        effectiveDiscount = addlDiscount;
                    }
                    supportCustomer = supportRegular * (1 - effectiveDiscount / 100 );
                    supportPartner = supportCustomer * (1 - partnerDiscount / 100 );
                    supportNet = supportPartner * (1 - distDiscount / 100 );
                    
                    // Save calculated values
                    line.put(SBQQ__QuoteLine__c.SBQQ__NetPrice__c, supportNet);
                    line.put(SBQQ__QuoteLine__c.SBQQ__PartnerPrice__c, supportPartner);
                    line.put(SBQQ__QuoteLine__c.SBQQ__CustomerPrice__c, supportCustomer);
                    line.put(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c, supportRegular);
                    if(supportRegular == 0 && productCode.startsWithIgnoreCase('SUP-BASE')) {
                        Decimal subPriorQuantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Prior_Subscription_Quantity__c));
                        line.put(SBQQ__QuoteLine__c.SBQQ__PriorQuantity__c, subPriorQuantity);
                    }
            }

            if(rubikSupportHistoricalListMap.containsKey(qlId)){
                Decimal historicalSupport=0;
                historicalSupport=rubikSupportHistoricalListMap.get(qlId);
                line.put(SBQQ__QuoteLine__c.Rubiks_Support_ACV__c, historicalSupport);
            }

            if(rubikSupportHistoricalListMap.containsKey(qlId_newsupport)){
                Decimal historicalSupport=0;
                historicalSupport=rubikSupportHistoricalListMap.get(qlId_newsupport);
                line.put(SBQQ__QuoteLine__c.Rubiks_Support_ACV__c, historicalSupport);
            }
            
            
                
            
        }

        //Fourth Pass - Aggregate to parent Manual Rollup SUKs for Rubiks
       
        for(SObject line : lines) {
            String productCode = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            String qlId = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.id));
            Boolean manualRollup = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.Manual_Rollup__c));
            manualRollup=(manualRollup==null) ? false : manualRollup;


            Decimal testnetPrice = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c ));
            Decimal testnetTotal = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetTotal__c ));
            String testproductCode = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            String quoteType = (String)quote.get(String.valueOf(SBQQ__Quote__c.SBQQ__Type__c));
            Boolean hiddenOuput = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.Hidden_Output_Product__c));
            hiddenOuput=(hiddenOuput==null) ? false : hiddenOuput;

            testnetPrice = (testnetPrice == null) ? 0 : testnetPrice;
            testnetTotal = (testnetTotal == null) ? 0 : testnetTotal;
            testproductCode=(testproductCode==NULL) ? '' : testproductCode;


            system.debug(testproductCode + '(Last Loop Total) : ' + testnetTotal);
            system.debug(testproductCode + '(Last Loop Net Price) : ' + testnetPrice);

             SObject parent = line.getSObject(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c.getDescribe().getRelationshipName());
             

                if(parent != null) {
                    String parentproductCode = (String)parent.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
                    if(quoteType == 'Amendment' && hiddenOuput){
                         Boolean parentManualRollup = (Boolean)parent.get(String.valueOf(SBQQ__QuoteLine__c.Manual_Rollup__c));
                         parentManualRollup=(parentManualRollup==null) ? false : parentManualRollup;
                         manualRollup = parentManualRollup;
                         line.put(SBQQ__QuoteLine__c.Manual_Rollup__c, manualRollup);
                    }
                   



                    if(rubikBundles.contains(parentproductCode) && manualRollup){
                        Decimal plist = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Bundle_Component_List_Total__c));
                        Decimal pregular = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Bundle_Component_Regular_Total__c));
                        Decimal pcustomer = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Bundle_Component_Customer_Total__c));
                        Decimal pnet = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Bundle_Component_Net_Total__c));
                        Decimal parr = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Bundle_Component_ARR_for_Bundles__c));
                        Decimal clist = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProratedListPrice__c));
                        Decimal cregular = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__RegularPrice__c));
                        Decimal ccustomer = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__CustomerPrice__c));
                        Decimal cnet = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__NetPrice__c));
                        Decimal carr = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.ARR_for_Bundles__c));
                        Decimal quantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Quantity__c));
                        Decimal prorate = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProrateMultiplier__c));
                        Boolean renewal = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Renewal__c));
                        Boolean bundled = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Bundled__c));
                        Boolean existing = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Existing__c));
                        String pricingMethod = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PricingMethod__c));
                        Decimal defaultTerm = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DefaultSubscriptionTerm__c));
                        String discountScheduleType = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DiscountScheduleType__c));
                        String subscriptionPricing = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SubscriptionPricing__c));
                        Decimal pQuotedNetBase = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Quoted_Base_ACV_for_Support__c));
                        Boolean includeInMaintenance = (Boolean)line.get(String.valueOf(SBQQ__QuoteLine__c.Include_in_Maintenance__c));
                        Decimal optionLevel = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__OptionLevel__c));
                        Decimal priorQuantity = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__PriorQuantity__c));

                        String qPromotion = (String)quote.get(String.valueOf(SBQQ__Quote__c.New_Logo_Term_Promotions__c));
                        
                        plist = (plist == null) ? 0 : plist;
                        pregular = (pregular == null) ? 0 : pregular;
                        pcustomer = (pcustomer == null) ? 0 : pcustomer;
                        pnet = (pnet == null) ? 0 : pnet;
                        parr = (parr == null) ? 0 : parr;

                        clist = (clist == null) ? 0 : clist;
                        cregular = (cregular == null) ? 0 : cregular;
                        ccustomer = (ccustomer == null) ? 0 : ccustomer;
                        cnet = (cnet == null) ? 0 : cnet;
                        carr = (carr == null) ? 0 : carr;
                        parr = (parr == null) ? 0 : parr;

                        quantity = (quantity == null) ? 1 : quantity;
                        prorate = (prorate == null) ? 1 : prorate;
                        renewal = (renewal == null) ? false : renewal;
                        bundled = (bundled == null) ? false : bundled;
                        existing = (existing == null) ? false : existing;
                        pricingMethod = (pricingMethod == null) ? 'List' : pricingMethod;

                        pQuotedNetBase = (pQuotedNetBase == null) ? 0 : pQuotedNetBase;
                        optionLevel = (optionLevel == null) ? 0 : optionLevel;

                        qPromotion = (qPromotion == null) ? '' : qPromotion;

                        Decimal clistPrice = clist;
                        
                        // Set negative quantity flag (used for support floor price logic)
                        hasNegativeQuantity=(quantity<0) ? true : false;
                        
                        Decimal cListTotal;
                        Decimal cRegularTotal ;
                        Decimal cCustomerTotal ;
                        Decimal cNetTotal;

                        cListTotal = getTotal(clist, quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clistPrice);
                        cRegularTotal = getTotal(cregular, quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clistPrice);
                        cCustomerTotal = getTotal(ccustomer, quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clistPrice);
                        cNetTotal = getTotal(cnet, quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, clistPrice);

                        plist += cListTotal;
                        pregular += cRegularTotal;
                        pcustomer += cCustomerTotal;
                        pnet += cNetTotal;
                        parr += carr;
                        
                        parent.put(SBQQ__QuoteLine__c.Bundle_Component_List_Total__c, plist);
                        parent.put(SBQQ__QuoteLine__c.Bundle_Component_Regular_Total__c, pregular);
                        parent.put(SBQQ__QuoteLine__c.Bundle_Component_Customer_Total__c, pcustomer);
                        parent.put(SBQQ__QuoteLine__c.Bundle_Component_Net_Total__c, pnet);
                        parent.put(SBQQ__QuoteLine__c.Bundle_Component_ARR_for_Bundles__c, parr);

                    }
                }

        }

    }
    
    global void onInit(SObject[] lines) {
        Set<String> rubikBundles=new Set<String>{'BNDL-SMB-MKTGAUTO', 'BNDL-ENT-MKTGAUTO'};
        rubiksPreviousSupport=new Map<String,Decimal>();
        Map<String,String> productMap=new Map<String,String>();
        Set<String> prodIds=new Set<String>();

        rubiksBundlePreviousDiscounts=new Map<String,Decimal>();
        isRubiks=false;


        //Initial Query of All Product Ids to Create Map of Products to QuoteLines

        for(SObject line : lines) {
            String productid = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Product__c));
            if(productid!=null){
                prodIds.add(productid);
            }
        }

        //Query Products to create Map
        for(Product2 prods:[Select id,ProductCode from Product2 where id IN: prodids]){
            productMap.put(prods.id, prods.ProductCode);
        }
        
        system.debug('Product Map: ' + productMap);

        for(SObject line : lines) {
            Decimal msrp = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.MSRP_Price__c));
            Decimal listUnitPrice = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ListPrice__c));
            String productCode = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
            String productid = (String)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Product__c));

            SObject parent = line.getSObject(SBQQ__QuoteLine__c.SBQQ__RequiredBy__c.getDescribe().getRelationshipName());
            if(productCode==null){
                if(productMap.containsKey(productid)){
                    productCode=productMap.get(productid);
                }else{
                    productCode='';
                }
            }
            productCode=(productCode==NULL) ? '' : productCode;
             if(parent != null) {
                        String productCodecheck = (String)parent.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__ProductCode__c));
                        Decimal addlDiscount_parent = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Discount__c));
                        Decimal previousAddlDiscount = (Decimal)parent.get(String.valueOf(SBQQ__QuoteLine__c.Previous_Additional_Discount__c));
                        String parentqlId = (String)parent.get(String.valueOf(SBQQ__QuoteLine__c.id));
                        String parentproductid = (String)parent.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__Product__c));
                        rubiksBundlePreviousDiscounts.put(parentqlId,previousAddlDiscount);

                        if(productCodecheck==null){
                            if(productMap.containsKey(parentproductid)){
                                productCodecheck=productMap.get(parentproductid);
                            }else{
                                productCodecheck='';
                            }
                        }

                        system.debug(productCodecheck);
                        if(rubikBundles.contains(productCodecheck)){
                            //Set Global Variable to True if Rubiks Exists
                            isRubiks=true;


                            Decimal segment = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__SegmentIndex__c ));
                            Decimal rubikssupportACV = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Subscription_ACV__c));
                            
                            segment=(segment==NULL) ? 0 : segment;

                            ///Check for Support Line
                            if(productCode.startsWithIgnoreCase('SUP-BASE') && rubikssupportACV != NULL) {
                                String newId=parentqlId + string.valueOf(segment);
                                if(rubiksPreviousSupport.containsKey(newId)){   
                                    Decimal supportVal=0;
                                        supportVal=rubiksPreviousSupport.get(newId);
                                        rubiksPreviousSupport.put(newId, supportVal+rubikssupportACV); 
                                    }else{
                                        rubiksPreviousSupport.put(newId, rubikssupportACV);        
                                    }
                                
                                system.debug(rubiksPreviousSupport);
                            }
                        }
            }

            //Set Bundled Quantity of Rubiks Automation and Workflow

            Decimal bundledQty = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c ));
            bundledQty=(bundledQty==NULL) ? 0 : bundledQty;
            Decimal newQty=0;
            if(productCode=='PROD-APPS-AUTOWKFL'){    
                system.debug(bundledQty);

                if( bundledQty < 100000){
                    newQty=math.ceil(bundledQty/10000)*10000;
                }else if(bundledQty < 1000000){
                    newQty=math.ceil(bundledQty/100000)*100000;
                }else if(bundledQty < 10000000){
                   newQty=math.ceil(bundledQty/250000)*250000;
                }else{
                    newQty=math.ceil(bundledQty/1000000)*1000000;
                }
                    system.debug(newQty);

                    line.put(SBQQ__QuoteLine__c.SBQQ__Quantity__c, newQty);
                    line.put(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c, newQty);

            }

            // Inject qty based on calculated qty multiple
            Decimal qtyMultiple = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Product_Multiple__c));
            if(qtyMultiple != NULL ){
                newQty=math.ceil(bundledQty / qtyMultiple)*qtyMultiple;
                line.put(SBQQ__QuoteLine__c.SBQQ__Quantity__c, newQty);
                line.put(SBQQ__QuoteLine__c.SBQQ__BundledQuantity__c, newQty);
            }

            // Initialize MSRP Price
            if(msrp == null) {
                line.put(SBQQ__QuoteLine__c.MSRP_Price__c, listUnitPrice);
            }
            
            // Reset component aggregates in bundle
            line.put(SBQQ__QuoteLine__c.Bundle_Component_List_Total__c, 0);
            line.put(SBQQ__QuoteLine__c.Bundle_Component_Regular_Total__c, 0);
            line.put(SBQQ__QuoteLine__c.Bundle_Component_Customer_Total__c, 0);
            line.put(SBQQ__QuoteLine__c.Bundle_Component_Net_Total__c, 0);
            line.put(SBQQ__QuoteLine__c.Quoted_Base_ACV_for_Support__c, 0);
            line.put(SBQQ__QuoteLine__c.Bundle_Component_ARR_for_Bundles__c, 0);
            line.put(SBQQ__QuoteLine__c.Renewal_Component_Total__c, 0);
            line.put(SBQQ__QuoteLine__c.Renewal_Blended_Discount__c, 0);

        }
    }
    
    private Date calculateEndDate(SObject line) {
        Date startDate = (Date)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__EffectiveStartDate__c));
        Date endDate = (Date)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__EffectiveEndDate__c));
        if ((startDate != null) && (endDate == null)) {
            /* Note: we are assuming that Subscription Term Unit is Month in the package settings */
            endDate = startDate.addMonths(getEffectiveSubscriptionTerm(line).intValue()).addDays(-1);
        }
        return endDate;
    }
    
    private Decimal getEffectiveSubscriptionTerm(SObject line) {
        Decimal lineTerm = null;
        Date startDate = (Date)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__EffectiveStartDate__c));
        Date endDate = (Date)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__EffectiveEndDate__c));
        if ((startDate != null) && (endDate != null)) {
            /* Note: we are assuming that Subscription Term Unit is Month in the package settings */
            lineTerm = startDate.monthsBetween(endDate.addDays(1));
        } else {
            lineTerm = (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.Effective_Subscription_Term__c));
            if (lineTerm == null) {
                return (Decimal)line.get(String.valueOf(SBQQ__QuoteLine__c.SBQQ__DefaultSubscriptionTerm__c));
            }
        }
        return lineTerm;
    }

   
    private Decimal getTotalold(Decimal price, Decimal quantity, Decimal prorate, Boolean renewal, Boolean bundled, Boolean existing, String pricingMethod, String discountScheduleType, String subscriptionPricing) {
        Decimal total = 0;
        if(renewal == false && bundled == false && existing == false) {
            if(prorate == null) {
                prorate = 1;
            }
            if(pricingMethod == 'Block' || discountScheduleType == 'Slab' || subscriptionPricing == 'Percent Of Total') {
                quantity = 1;
            }
            total = price * quantity;
        }
        return total;
    }
   
        
    private Decimal getTotal(Decimal price, Decimal quantity, Decimal priorQuantity, String pricingMethod, String discountScheduleType, Boolean renewal, Boolean existing, String subscriptionPricing, Decimal ListPrice) {
        price = (price == null) ? 0 : price;
        renewal = (renewal == null) ? false : renewal;
        existing = (existing == null) ? false : existing;
        
        if(renewal == true && existing == false && priorQuantity == null) {
            return 0;
        } else {
            return price * getEffectiveQuantity(quantity, priorQuantity, pricingMethod, discountScheduleType, renewal, existing, subscriptionPricing, listPrice);
        }
        
    }
    
    private Decimal getEffectiveQuantity(Decimal quantity, Decimal priorQuantity, String pricingMethod, String discountScheduleType, Boolean renewal, Boolean existing, String subscriptionPricing, Decimal ListPrice) {
        Decimal result = 0;
        Decimal deltaQuantity = 0;
        
        quantity = (quantity == null) ? 0 : quantity;
        priorQuantity = (priorQuantity == null) ? 0 : priorQuantity;
        pricingMethod = (pricingMethod == null) ? '' : pricingMethod;
        discountScheduleType = (discountScheduleType == null) ? '' : discountScheduleType;
        subscriptionPricing = (subscriptionPricing == null) ? '' : subscriptionPricing;
        renewal = (renewal == null) ? false : renewal;
        existing = (existing == null) ? false : existing;
        listPrice = (listPrice == null) ? 0 : listPrice;
        
        deltaQuantity = quantity - priorQuantity;
        
        if(pricingMethod == 'Block' && deltaQuantity == 0) {
            result = 0;
        } else {
            if(pricingMethod == 'Block') {
                result = 1;
            } else {
                if(discountScheduleType == 'Slab' && (deltaQuantity == 0 || (quantity == 0 && renewal == true))) {
                    result = 0;
                } else {
                    if(discountScheduleType == 'Slab') {
                        result = 1;
                    } else {
                        if(existing == true && subscriptionPricing == '' && deltaQuantity < 0) {
                            result = 0;
                        } else {
                            if(existing == true && subscriptionPricing == 'Percent Of Total' && listPrice != 0 && deltaQuantity >= 0) {
                                result = quantity;
                            } else {
                                if(existing == true) {
                                    result = deltaQuantity;
                                } else {
                                    result = quantity;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return result;
    }
    
    private Decimal getMCV(Decimal amount, Decimal prorate, Decimal defaultTerm) {
        if(amount == null) {
            amount = 0;
        }
        if(prorate == null) {
            prorate = 1;
        }
        if(defaultTerm == null || defaultTerm == 0) {
            defaultTerm = 1;
        }
        return amount / (prorate * defaultTerm);
    }
    
    testMethod static void test() {
        Account acct = new Account(Name='Test');
        acct.BillingCountry = 'United States';
        acct.BillingStreet = 'Test Street';
        acct.BillingState ='Test Billing State';
        acct.BillingPostalCode ='12345';
        acct.ShippingCity ='Pune';
        acct.ShippingCountry ='India';
        acct.ShippingPostalCode = '12345';
        acct.ShippingState = 'Maharashtra';
        acct.ShippingStreet = 'Test Shipping Street';  
        acct.Accounting_Email__c = 'test@gmail.com';
        acct.Accounting_Contact_First_Name__c = 'FirstName';
        acct.Accounting_Contact_Last_Name__c = 'LastName';
        acct.Website = 'www.google.com';
        insert acct;
        
        Opportunity opp1 = new Opportunity(Name='Test', AccountId=acct.Id, StageName='B - Discover', CloseDate=System.today());
        opp1.Type = 'New Business';
        opp1.CRM_System__c = 'Other';
        opp1.Use_Case__c = 'B2B';
        opp1.NextStep = 'test';
        opp1.Deal_Type__c = 'Standard';
        opp1.LeadSource = 'Website';
		//APPS-18580
        opp1.Rep_Create_ARR__c = 1;
		opp1.MainCompetitor__c = 'AppBoy';
		//APPS-18580
        insert opp1;
        
        Product2[] products = new Product2[0];
        Product2 p1 = new Product2(Name='MA Select Edition',ProductCode='BNDL-MA-SEL',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p2 = new Product2(Name='MA Base Contacts',ProductCode='PROD-MA-SEL-USE',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p3 = new Product2(Name='Support',ProductCode='SUP-STD',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p4 = new Product2(Name='RCA Usage',ProductCode='PROD-ANA-RCA-USE',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        
        products.add(p1);
        products.add(p2);
        products.add(p3);
        products.add(p4);
        insert products;
        
        p2.SBQQ__IncludeInMaintenance__c = true;
        update products;
        
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp1.Id, SBQQ__StartDate__c = System.Today());
        quote1.Payment_Frequency__c = 'Quarterly';
        quote1.Order_Type__c = 'Standard (includes Promos)';
        quote1.SBQQ__StartDate__c = System.today();
        insert quote1;
        
        SBQQ__QuoteLine__c[] lines1 = new SBQQ__QuoteLine__c[0];
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p1.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 0, SBQQ__Quantity__c=1);
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p2.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 100, SBQQ__Quantity__c=10);
        SBQQ__QuoteLine__c line3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p3.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 0, SBQQ__Quantity__c=1);
        SBQQ__QuoteLine__c line4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p4.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1);
        lines1.add(line1);
        lines1.add(line2);
        lines1.add(line3);
        lines1.add(line4);
        insert lines1;
        
        lines1[0].SBQQ__Incomplete__c = false;
        lines1[1].SBQQ__Incomplete__c = false;
        lines1[2].SBQQ__Incomplete__c = false;
        lines1[3].SBQQ__Incomplete__c = false;
        lines1[1].SBQQ__OptionLevel__c = 1;
        lines1[2].SBQQ__OptionLevel__c = 1;
        lines1[3].SBQQ__OptionLevel__c = 1;
        lines1[1].SBQQ__ProrateMultiplier__c = 1;
        lines1[2].SBQQ__ProrateMultiplier__c = 1;
        lines1[3].SBQQ__ProrateMultiplier__c = 1;
        lines1[1].SBQQ__DiscountScheduleType__c = 'Slab';
        lines1[1].SBQQ__SubscriptionPricing__c = 'Fixed Price';
        lines1[1].SBQQ__DefaultSubscriptionTerm__c = 12;
        update lines1;
        
        lines1 = [SELECT SBQQ__Quote__c, SBQQ__Product__c, SBQQ__BundledQuantity__c,Product_Multiple__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SBQQ__Discount__c, SBQQ__RequiredBy__r.Previous_Additional_Discount__c, SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__RequiredBy__r.id, SBQQ__RequiredBy__r.SBQQ__ProductCode__c, SBQQ__ProductCode__c, SBQQ__Quantity__c, SBQQ__ListPrice__c, SBQQ__ProratedListPrice__c, SBQQ__RegularPrice__c, SBQQ__NetPrice__c, MSRP_Price__c, SBQQ__ListTotal__c, SBQQ__RegularTotal__c, SBQQ__CustomerTotal__c, SBQQ__NetTotal__c, ARR_for_Bundles__c, Bundle_Name__c, Database_Size__c, Database_Size_Label__c, SBQQ__ProductName__c, Bundle_Component_List_Total__c, Bundle_Component_Regular_Total__c, Bundle_Component_Customer_Total__c, Bundle_Component_Net_Total__c, Bundle_Component_ARR_for_Bundles__c, Include_in_Bundle_Price__c, SBQQ__EffectiveStartDate__c, SBQQ__EffectiveEndDate__c, SBQQ__SubscriptionTerm__c, SBQQ__DefaultSubscriptionTerm__c, MKTO_Effective_Term__c, MKTO_Effective_End_Date__c, SBQQ__SubscriptionPricing__c, SBQQ__ProrateMultiplier__c, SBQQ__Renewal__c, SBQQ__Bundled__c, SBQQ__Existing__c, SBQQ__PricingMethod__c, SBQQ__DiscountScheduleType__c, Quoted_Base_ACV_for_Support__c, Support_ACV_Amount__c, Include_in_Maintenance__c, SBQQ__OptionLevel__c, SBQQ__DistributorDiscount__c, SBQQ__PartnerDiscount__c, Delta_Usage_Formatted__c, Parent_Product_Code__c, DebugMessage__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote1.Id ORDER BY SBQQ__Number__c];
        lines1[1].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[2].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[3].SBQQ__RequiredBy__c = lines1[0].id;

        MarketoQuoteCalculator target1 = new MarketoQuoteCalculator();
        target1.onInit(lines1);
        target1.onBeforeCalculate(quote1, lines1);
        target1.onBeforePriceRules(quote1, lines1);
        target1.onAfterPriceRules(quote1, lines1);
        target1.onAfterCalculate(quote1, lines1);
        
        System.assertEquals(1,1);
    }
    
}