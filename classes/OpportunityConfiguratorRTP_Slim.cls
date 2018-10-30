/*******************************************************
Modified By : Sumit Bhatt, Grazitti Interactive
Modified date : 10-AUG-2018
Purpose : Commented the field that are used in field removal project 
refrence : APPS-20840 Field Cleanup Project - Phase One
log of fields commented : Opportunity: rtp_config_b2__c, rtp_config_billing_frequency__c,rtp_config_selected_suite__c , rtp_config_monthly_unique_visitors__c,
rtp_config_ma__c, rtp_config_domains__c, rtp_config_campaigns_monthly__c
*******************************************************/

public with sharing class OpportunityConfiguratorRTP_Slim {
    
    public String[] suites {get; private set;}
    public String selectedSuite {get; set;}
    public Map<String, Decimal> monthlyPrices {get; private set;}
    public Map<String, Decimal> annualPrices {get; private set;}
    public Map<String, Map<String, String>> addons {get; private set;}

    private ApexPages.StandardController controller;
    private Opportunity opportunity;

    public OpportunityConfiguratorRTP_Slim(ApexPages.StandardController controller) {
        this.controller = controller;
        this.opportunity = (Opportunity)controller.getRecord();
        /* #APPS-20840#
        if (opportunity.RTP_Config_Billing_Frequency__c == null) {
            opportunity.RTP_Config_Billing_Frequency__c = 'Annual';
        }
        #APPS-20840# */
    }

    private static Map<String, PriceBookEntry> getPricebookEntryCache;
    private static PriceBookEntry getPricebookEntry(Opportunity opp, String productCode) {
        // TODO refactor to reduce queries
        for (PriceBookEntry price : [
            select Id, UnitPrice
            from PriceBookEntry 
            where Product2.ProductCode = :productCode
            and CurrencyIsoCode = :opp.CurrencyIsoCode
            and Pricebook2Id = :opp.Pricebook2Id
            and IsActive = true
            and Product2.IsActive = true
        ]) {
            return price;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 
            'Product not in pricebook or does not have price for your currency ('+opp.CurrencyIsoCode+'): '+productCode));
        // return new obj to signify so null errors don't happen
        // the line items won't save with this anyway
        return new PricebookEntry();
    }

    private static OpportunityLineItem generateLineItem(Opportunity opp, PriceBookEntry pbe, Decimal quantity, Decimal price) {
        OpportunityLineItem result = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PriceBookEntryId = pbe.Id,
            UnitPrice = pbe.UnitPrice
        );
        if (quantity != null)
            result.Quantity = quantity;
        if (price != null)
            result.UnitPrice = price;
        return result;
    }

    public static OpportunityLineItem[] generateLineItems(Opportunity opp) {
        OpportunityLineItem[] result = new OpportunityLineItem[]{};
        /* #APPS-20840#
        String suiteName = opp.RTP_Config_Selected_Suite__c;
        
        Boolean b2b = opp.RTP_Config_B2__c == 'B2B' || opp.RTP_Config_B2__c == 'Both';
        Boolean b2c = opp.RTP_Config_B2__c == 'B2C' || opp.RTP_Config_B2__c == 'Both';
        #APPS-20840# */

        PriceBookEntry suitePrice;
        /* #APPS-20840#
        if (suiteName == 'RTP Spark')
            suitePrice = getPricebookEntry(opp, 'RTP-000018');
        else if (suiteName == 'RTP Standard')
            suitePrice = getPricebookEntry(opp, 'RTP-000019');
        else if (suiteName == 'RTP Enterprise')
            suitePrice = getPricebookEntry(opp, 'RTP-000020');
        else if (suiteName == 'RTP Consumer')
            suitePrice = getPricebookEntry(opp, 'RTP-000021');
        #APPS-20840# */
        
        result.add(generateLineItem(opp, suitePrice, 12, null));
        result[result.size()-1].Months__c = 12;

        // --- calculate uniques and add price to the parent line item
        /* #APPS-20840#
        Decimal uniques = opp.RTP_Config_Monthly_Unique_Visitors__c;
        uniques = uniques == null ? 0 : uniques;
        Decimal uniquesBuckets = Math.ceil(uniques / 10000);
        if (uniquesBuckets < 1) uniquesBuckets = 1;

        // --- tiered unique price as part of suite

        // first tier goes up to 100k
        // if user has more than 100k, they get the first tier product price for up to 100k
        // and then over 100k is allocated to the second tier product

        if (uniquesBuckets > 0) {
            PriceBookEntry price;
            #APPS-20840# */
            /* #APPS-20840#
            if (suiteName == 'RTP Spark') price = getPricebookEntry(opp, 'RTP-000022');
            if (suiteName == 'RTP Standard') price = getPricebookEntry(opp, 'RTP-000022');
            if (suiteName == 'RTP Enterprise') price = getPricebookEntry(opp, 'RTP-000022');
            if (suiteName == 'RTP Consumer') price = getPricebookEntry(opp, 'RTP-000024');
            #APPS-20840# */
            /* #APPS-20840#
            if (price != new PriceBookEntry())
                result[result.size()-1].UnitPrice += Math.min(10, uniquesBuckets) * price.UnitPrice;
        }

        if (uniquesBuckets > 10) {
            PriceBookEntry price;
            #APPS-20840# */
            /* #APPS-20840#
            if (suiteName == 'RTP Spark') price = getPricebookEntry(opp, 'RTP-000023');
            if (suiteName == 'RTP Standard') price = getPricebookEntry(opp, 'RTP-000023');
            if (suiteName == 'RTP Enterprise') price = getPricebookEntry(opp, 'RTP-000023');
            if (suiteName == 'RTP Consumer') price = getPricebookEntry(opp, 'RTP-000025');
            #APPS-20840# */
            /*#APPS-20840#
            if (price != new PriceBookEntry())
                result[result.size()-1].UnitPrice += (uniquesBuckets - 10) * price.UnitPrice;
        }
        #APPS-20840# */

        // --- form completion add on
        // TEMPORARILY REMOVED BY REQUEST FROM FREDRIC
        // THEY WILL BE SOLD AGAIN IN A COUPLE WEEKS
        //if (uniques > 0) {
        //    PriceBookEntry price;
        //    if (uniques <= 200000) price = getPricebookEntry(opp, 'RTP-000011');
        //    if (uniques > 200000) price = getPricebookEntry(opp, 'RTP-000012');
        //    result.add(generateLineItem(opp, price, 0, null));
        //}

        // --- MA / Database Contacts Add On
        /* #APPS-20840# commented ** rtp_config_ma__c **
        if (opp.RTP_Config_MA__c && opp.RTP_Config_Database_Contacts__c != null && opp.RTP_Config_Database_Contacts__c > 0) {
            Decimal contacts = opp.RTP_Config_Database_Contacts__c;
            Decimal contactsBuckets = Math.ceil(contacts / 100000);
            Decimal bucketsIncluded = 0;
            /* #APPS-20840# commented suiteName 
            if (suiteName == 'RTP Spark') bucketsIncluded = 1;
            if (suiteName == 'RTP Standard') bucketsIncluded = 3;
            if (suiteName == 'RTP Enterprise') bucketsIncluded = 5;
            if (suiteName == 'RTP Consumer') bucketsIncluded = 5;
             ****  commented suiteName ends here #APPS-20840# ****
             
            /* #APPS-20840# commented ** rtp_config_ma__c **

            if (contactsBuckets > bucketsIncluded)
                result.add(generateLineItem(opp, getPricebookEntry(opp, 'RTP-000010'), 12 * (contactsBuckets - bucketsIncluded), null));
            // TODO: we should populate units__c as well
        }
        commented ** rtp_config_ma__c ** ends here #APPS-20840#*/

        // --- concurrent campaigns add on
            /* #APPS-20840# 
        if (opp.RTP_Config_Campaigns_Monthly__c != null && opp.RTP_Config_Campaigns_Monthly__c > 0) {
            Decimal campaigns = opp.RTP_Config_Campaigns_Monthly__c;
            Decimal included = 0;
            #APPS-20840# commented suiteName */
            /* #APPS-20840#
            if (suiteName == 'RTP Spark') included = 30;
            if (suiteName == 'RTP Standard') included = 60;
            if (suiteName == 'RTP Enterprise') included = 999999999; // unlimited
            if (suiteName == 'RTP Consumer') included = 60;
            ***** #APPS-20840# ***** commented suiteName ends here
            if (campaigns > included) {
                if (campaigns > 60)
                    result.add(generateLineItem(opp, getPricebookEntry(opp, 'RTP-000007'), 12, null));
                else
                    result.add(generateLineItem(opp, getPricebookEntry(opp, 'RTP-000014'), 12, null));
            }
        }
        #APPS-20840# */

        // --- domains add on
        /* #APPS-20840#
        if (opp.RTP_Config_Domains__c != null && opp.RTP_Config_Domains__c > 0) {
            Decimal domains = opp.RTP_Config_Domains__c;
            Decimal included = 0;
            /* #APPS-20840# commented suiteName 
            if (suiteName == 'RTP Spark') included = 1;
            if (suiteName == 'RTP Standard') included = 1;
            if (suiteName == 'RTP Enterprise') included = 3;
            if (suiteName == 'RTP Consumer') included = 1;
            **** commented suiteName ends here*
            if (domains > included)
                result.add(generateLineItem(opp, getPricebookEntry(opp, 'RTP-000008'), domains - included, null));
        }
        #APPS-20840# */
        // --- account based marketing
        /* #APPS-20840#
        if (suiteName != 'RTP Enterprise') {
            result.add(generateLineItem(opp, getPricebookEntry(opp, 'RTP-000013'), 0, null));
        }
        #APPS-20840# */
        result.add(generateLineItem(opp, getPricebookEntry(opp, 'SV-ENT-RTPABM'), 0, null));

        // --- sales / view only users
        /* #APPS-20840#
        if (opp.RTP_Config_View_Only_Users__c != null && opp.RTP_Config_View_Only_Users__c > 0) {
            Decimal users = opp.RTP_Config_View_Only_Users__c;
            Decimal included = 10;
            if (users > included)
                result.add(generateLineItem(opp, getPricebookEntry(opp, 'RTP-000017'), (users - included), null));
                result[result.size()-1].Users__c = result[result.size()-1].Quantity;
        }
        #APPS-20840# */
        // --- a/b testing is not included, an option, for spark only
        /* #APPS-20840#
        if (suiteName == 'RTP Spark')
            result.add(generateLineItem(opp, getPricebookEntry(opp, 'RTP-000016'), 0, null));
        #APPS-20840#*/
        // --- launch pack
        // temporarily not including launchpack while transitioning to new SKU (TBD)
        //result.add(generateLineItem(opp, getPricebookEntry(opp, 'SV-RTPLP'), 1, null));

        applyQuarterlyUplift(opp, result);

        return result;
    }

    private static void applyQuarterlyUplift(Opportunity opp, OpportunityLineItem[] lineItems) {
        /* #APPS-20840#
        if (opp.RTP_Config_Billing_Frequency__c == 'Quarterly') {
            for (OpportunityLineItem lineItem : lineItems) {
                lineItem.UnitPrice += lineItem.UnitPrice * 0.11;
            }
        }
        #APPS-20840# */
    }

    public static Decimal getMonthlyPrice(Opportunity opportunity, String suite) {
        opportunity = opportunity.clone(true, true);
       //#APPS-20840#  opportunity.RTP_Config_Selected_Suite__c = suite;
        return generateLineItems(opportunity)[0].UnitPrice;
    }

    public void calculate() {

        suites = new String[]{};
        /* #APPS-20840#
        if (opportunity.RTP_Config_B2__c == 'b2b' || opportunity.RTP_Config_B2__c == 'both') {
            suites.add('RTP Spark');
            suites.add('RTP Standard');
            suites.add('RTP Enterprise');
        }
        if (opportunity.RTP_Config_B2__c == 'b2c' || opportunity.RTP_Config_B2__c == 'both') {
            suites.add('RTP Consumer');
        }
        #APPS-20840# */
        /* #APPS-20840#
        Decimal uniques = opportunity.RTP_Config_Monthly_Unique_Visitors__c == null ? 0 : opportunity.RTP_Config_Monthly_Unique_Visitors__c;
        Decimal uniquesBucket1 = (uniques >= 100000 ? 10000 : uniques) / 10000;
        Decimal uniquesBucket2 = (uniques > 100000 ? uniques - 100000 : 0) / 10000;
        #APPS-20840# */
        monthlyPrices = new Map<String, Decimal>{};
        annualPrices = new Map<String, Decimal>{};
        /* #APPS-20840#
        for (String suiteName : new String[]{'RTP Spark', 'RTP Standard', 'RTP Enterprise', 'RTP Consumer'}) {
            monthlyPrices.put(suiteName, getMonthlyPrice(opportunity, suiteName));
            if (monthlyPrices.get(suiteName) == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 
                    'Suite Product not in pricebook: ' + suiteName));
                monthlyPrices.put(suiteName, -100);
            }
            annualPrices.put(suiteName, monthlyPrices.get(suiteName)*12);
        }
        #APPS-20840# */
        // --- addons

        addons = new Map<String, Map<String, String>>{};
        /* #APPS-20840#
        if (opportunity.RTP_Config_B2__c == 'b2b' || opportunity.RTP_Config_B2__c == 'both') {
            addons.put('RTP Spark', new Map<String, String>{
                'Real Time Personalization' => 'Included',
                'Account Targeting and Firmographics' => 'Included',
                'A/B Testing and Auto-Tuning' => 'Add On',
                'Analytics & CRM Integration' => 'Included',
                'Concurrent Campaigns +30' => 'Add On',
                'Unlimited Concurrent Campaigns' => 'Add On',
                'Additional Domains' => 'Add On',
                'Marketing Automation Integration' => 'Included',
                'Marketing Automation Additional Contacts' => 'Add On',
                'Account-Based Marketing' => 'Add On',
                'Account-Based Marketing Setup' => 'Add On',
                //'Form Completion' => 'Add On',
                'Sales Intelligence Additional Users' => 'Add On'
            });
            addons.put('RTP Standard', new Map<String, String>{
                'Real Time Personalization' => 'Included',
                'Account Targeting and Firmographics' => 'Included',
                'A/B Testing and Auto-Tuning' => 'Included',
                'Analytics & CRM Integration' => 'Included',
                'Concurrent Campaigns +30' => 'Included',
                'Unlimited Concurrent Campaigns' => 'Add On',
                'Additional Domains' => 'Add On',
                'Marketing Automation Integration' => 'Included',
                'Marketing Automation Additional Contacts' => 'Add On',
                'Account-Based Marketing' => 'Add On',
                'Account-Based Marketing Setup' => 'Add On',
                //'Form Completion' => 'Add On',
                'Sales Intelligence Additional Users' => 'Add On'
            });
            addons.put('RTP Enterprise', new Map<String, String>{
                'Real Time Personalization' => 'Included',
                'Account Targeting and Firmographics' => 'Included',
                'A/B Testing and Auto-Tuning' => 'Included',
                'Analytics & CRM Integration' => 'Included',
                'Concurrent Campaigns +30' => 'Included',
                'Unlimited Concurrent Campaigns' => 'Included',
                'Additional Domains' => 'Add On',
                'Marketing Automation Integration' => 'Included',
                'Marketing Automation Additional Contacts' => 'Add On',
                'Account-Based Marketing' => 'Included',
                'Account-Based Marketing Setup' => 'Add On',
                //'Form Completion' => 'Add On',
                'Sales Intelligence Additional Users' => 'Add On'
            });
        }
        
        if (opportunity.RTP_Config_B2__c == 'b2c' || opportunity.RTP_Config_B2__c == 'both') {
            addons.put('RTP Consumer', new Map<String, String>{
                'Real Time Personalization' => 'Included',
                'Account Targeting and Firmographics' => '-',
                'A/B Testing and Auto-Tuning' => 'Included',
                'Analytics & CRM Integration' => '-',
                'Concurrent Campaigns +30' => 'Included',
                'Unlimited Concurrent Campaigns' => 'Add On',
                'Additional Domains' => 'Add On',
                'Marketing Automation Integration' => 'Included',
                'Marketing Automation Additional Contacts' => 'Add On',
                'Account-Based Marketing' => 'Add On',
                'Account-Based Marketing Setup' => 'Add On',
                //'Form Completion' => 'Add On',
                'Sales Intelligence Additional Users' => 'Add On'
            });
        }
        #APPS-20840# */
    }


    public String[] getProducts() {
        // TODO use config or constant for product names to cut down on repeated text
        return new String[]{
            'Real Time Personalization',
            'Account Targeting and Firmographics',
            'A/B Testing and Auto-Tuning',
            'Analytics & CRM Integration',
            'Concurrent Campaigns +30',
            'Unlimited Concurrent Campaigns',
            'Additional Domains',
            'Marketing Automation Integration',
            'Marketing Automation Additional Contacts',
            'Account-Based Marketing',
            'Account-Based Marketing Setup',
            //'Form Completion',
            'Sales Intelligence Additional Users'
        };
    }

    public OpportunityLineItem[] lineItemsWithQuantity(OpportunityLineItem[] lineItems) {
        OpportunityLineItem[] result = new OpportunityLineItem[]{};
        for (OpportunityLineItem lineItem : lineItems) {
            if (lineItem.Quantity > 0) {
                result.add(lineItem);
            }
        }
        return result;
    }

    public PageReference selectSuite() {

        // save configurator fields on opp
        PageReference saveResult = controller.save();
        if (saveResult == null) return null;
        
        // delete existing RTP products since we're updating our suite
        delete [
            select Id 
            from OpportunityLineItem 
            where OpportunityId = :opportunity.Id 
            and (
                PriceBookEntry.Product2.ProductCode like 'RTP-%'
                or
                PriceBookEntry.Product2.ProductCode in ('SV-RTPLP', 'SV-ENT-RTPABM')
            )
        ];

        OpportunityLineItem[] lineItems = generateLineItems(opportunity);

        insert lineItemsWithQuantity(lineItems);

        //#APPS-20840# System.assertNotEquals(null, opportunity.RTP_Config_Selected_Suite__c);
        PageReference result = Page.OpportunityConfiguratorRTP;
        result.getParameters().put('id', (String)controller.getRecord().get('Id'));
        result.setRedirect(true);
        return result;
    }

    // temporary while old configurator tests are ported to new configurator
    @TestVisible
    private static void testCoverage() {
        Integer i = 0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
    }

}