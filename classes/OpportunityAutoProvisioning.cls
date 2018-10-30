public without sharing class OpportunityAutoProvisioning 
{
    public static boolean isFirstRun = true;
    public static String changed_state_value = 'Closed Won';
    public static String prerequisite_record_type_value = 'Closed Won';
    //testing 
    //public static String changed_state_value = 'Selling';
    //public static String prerequisite_record_type_value = 'Channel';
    
    // Process list of opportunities for auto-provisioning
    public static void processOpportunities(List<Opportunity> opps)
    {
        // Limits
        final Integer maxRecords = 100; //Total
        final Integer maxBatchSize = 10; //Per batch callout
        
        // Future methods only accept primitives, so gather Opportunity ids for future retrieval
        List<Id> oppIds = new List<Id>();
        for(Opportunity o : opps)
        {
            oppIds.add(o.Id);
        }

        // Counter
        Integer recordsProcessed = 0;
        
        // In batches of maxBatchSize, processAutoProvisioning while items remain
        while(recordsProcessed < maxRecords && oppIds.size() > 0)
        {
            // Batch id list
            List<Id> batchOppIds = new List<Id>();
            
            // Batches of maxBatchSize (or less, if less exist)
            Integer batchSize = maxBatchSize;
            if(batchSize > (maxRecords - recordsProcessed))
            {
                batchSize = (maxRecords - recordsProcessed);
            }
            
            for(Integer j = 0; j < batchSize; j++)
            {
                if(oppIds.size() > 0)
                {
                    batchOppIds.add(oppIds[0]);
                    oppIds.remove(0);
                    recordsProcessed += 1;
                }
            }
            
            if(batchOppIds.size() > 0)
            {
                // Send batch to @Future method
                processAutoProvisioningBatch(batchOppIds);
            }
            else
            {
                break;
            }
        }
    }
    
    @Future(callout=true)
    private static void processAutoProvisioningBatch(List<Id> oppIds)
    {

        
        // only consider oppies that have oppy line itmes that require a provisioning action
        //Added 6 new fields in below soql 3 for Opp and 3 for Oplineitems by SP
        List<Opportunity> mlmOps = [
        SELECT  o.Id, o.Name, o.Account.Name, o.Account.Website, o.Primary_Marketo_User_Email__c, o.Primary_Marketo_User_Lookup__r.FirstName, 
            o.Primary_Marketo_User_Lookup__r.LastName, o.MP_Purpose__c, o.MP_Reseller_Partner__c,o.Subscription_Language__c,o.Subscription_Locale__c,Subscription_Time_Zone__c,
            (SELECT ol.Id, ol.Product_Type__c, ol.Users__c, ol.MLM_Edition__c, ol.Instance_Number__c, ol.Related_Asset__c,Subscription_Language__c,Subscription_Locale__c,Subscription_Time_Zone__c,   
            ol.PricebookEntry.Product2.Name, ol.PricebookEntry.Product2.Family, ol.PricebookEntry.Product2.ProductCode
            FROM o.OpportunityLineItems ol 
            WHERE 
                ol.PricebookEntry.Product2.Family = 'Lead Management' 
                OR ol.PricebookEntry.Product2.Family = 'Sales Insight'
                OR ol.PricebookEntry.Product2.Family = 'Select Edition' 
                OR ol.PricebookEntry.Product2.Family = 'Spark Edition' 
                OR ol.PricebookEntry.Product2.Family = 'Standard Edition'
                OR ol.PricebookEntry.Product2.Family = 'Real Time Personalization'
                
            )
             FROM Opportunity o WHERE o.Id IN :oppIds and o.Type = 'New Business' ];
        //Declaring varibales for subscription fields by SP
        string Lang = '';string Locale = '';string Time_Zone = '';
        // iterate through oppies and call api if needed
        for(Opportunity o: mlmOps){
            
            System.debug('Processing oppy [' + o.Id + ']');
            
            Map<String,String> params =  new Map<String, String>();
            
            // Assign non-null Opportunity values to placeholder vars
            params.put('argName', o.Account.Name == null ? '' : o.Account.Name);
            params.put('argHomePage', o.Account.Website == null ? '' : o.Account.Website);
            params.put('argUserName', o.Primary_Marketo_User_Email__c == null ? '' : o.Primary_Marketo_User_Email__c);
            if(o.Primary_Marketo_User_Lookup__r != null)
            {
                params.put('argFirstName', o.Primary_Marketo_User_Lookup__r.FirstName);
                params.put('argLastName',  o.Primary_Marketo_User_Lookup__r.LastName);
            }else{
                params.put('argFirstName', '');
                params.put('argLastName',  '');
            }
            params.put('argPurpose', o.MP_Purpose__c == null ? '' : o.MP_Purpose__c);

            params.put('argChanelPartner', o.MP_Reseller_Partner__c == null ? '' : o.MP_Reseller_Partner__c);
        
            params.put('argLevel','Marketo - Lite');
            
            params.put('argProdCode', '');
            params.put('argOppyId', '');
            params.put('argInstanceNumber', String.valueOf(0.0));
            params.put('argAsset', '');
            params.put('argSessionId', String.valueOf(Crypto.getRandomInteger()));
            
            
            // oppy has sandbox?
            // if it has, call the api explcitely for this sandbox, we however need additional details on the sub type, etc. 
            AggregateResult result = [
                SELECT count(ol.Id) cnt FROM OpportunityLineItem ol WHERE ol.PricebookEntry.Product2.ProductCode = 'LM-SAND' 
                AND ol.Opportunity.Id = :o.Id
            ];
            params.put('argSandbox', '0');
            if ( Integer.valueOf(result.get('cnt')) > 0){
                System.debug('oppy [' + o.Id + '] has a sandbox line item');
                params.put('argSandbox', '1');
            }else{
                System.debug('oppy [' + o.Id + '] has a no sandbox line item');
            }
            
            
            params.put('argOutlookSeats', '0');
            params.put('argSalesforceSeats', '0');
            // oppy has sales insight?
            // if yes, look for the Users__c custom field and assign its value to argSalesforceSeats and argOutlookSeats
            List<OpportunityLineItem> salesinsight_ols = [
                SELECT ol.Users__c FROM OpportunityLineItem ol WHERE ol.PricebookEntry.Product2.Family = 'Sales Insight'
                AND ol.Opportunity.Id = :o.Id
            ];
            // there should be no more then one sales isight, so pick up the first one if thats the case.
            // if the list is empty, fall back to the default value.
            if (salesinsight_ols.size() > 0){
                System.debug('oppy [' + o.Id + '] has a salesinsight line item');
                params.put('argSalesforceSeats', String.valueOf(salesinsight_ols.get(0).Users__c));
                params.put('argOutlookSeats', String.valueOf(salesinsight_ols.get(0).Users__c));
            }else{
                System.debug('oppy [' + o.Id + '] has a no salesinsight line item');
            }

            // oppy has outlook plug in?
            List<OpportunityLineItem> outlook_ols = [
                SELECT ol.Users__c FROM OpportunityLineItem ol WHERE ol.PricebookEntry.Product2.Name LIKE '%Outlook Plug In%'
                AND ol.Opportunity.Id = :o.Id
            ];
            // should be only one oppy line item, pick the first
            if (outlook_ols.size() > 0){
                System.debug('oppy [' + o.Id + '] has a outlook seat line item');
                params.put('argOutlookSeats',  String.valueOf(outlook_ols.get(0).Users__c));
            }else{
                System.debug('oppy [' + o.Id + '] has a no outlook seat line item');
            }
            Lang = o.Subscription_Language__c!=null ? o.Subscription_Language__c : '';
            Locale = o.Subscription_Locale__c!=null ? o.Subscription_Locale__c : '';
            Time_Zone = o.Subscription_Time_Zone__c!=null ? o.Subscription_Time_Zone__c : '';
            
            // Prepare line items 
            for(OpportunityLineItem ol : o.OpportunityLineItems)
            {
                // if the oppy line item is a professional or enterprise
                // discard sandbox line items
                    if(ol.PricebookEntry.Product2.Family == 'Lead Management'
                         && (ol.MLM_Edition__c == 'Enterprise' ||  ol.MLM_Edition__c == 'Professional')
                         && ol.PricebookEntry.Product2.ProductCode != 'LM-SAND'
                    ){
                        System.debug('oppy [' + o.Id + '] line item [' + ol.Id + '] is of type Lead Management');
                        params.put('argLevel', ol.MLM_Edition__c == null ? params.get('argLevel') : ol.MLM_Edition__c);
                       //Adding Params for Subscription Lang,Locale and Time zone  values
                        params.put('argSubLang',ol.Subscription_Language__c != null ?  ol.Subscription_Language__c : Lang);
                        params.put('argSubLocale',ol.Subscription_Locale__c != null ? ol.Subscription_Locale__c : Locale );
                        params.put('argSubTZone',ol.Subscription_Time_Zone__c != null ? ol.Subscription_Time_Zone__c : Time_Zone);
                        provision(o, ol,  params);
                   }                        
                    else if (ol.PricebookEntry.Product2.Family == 'Spark Edition'){
                        System.debug('oppy [' + o.Id + '] line item [' + ol.Id + '] is of type Spark Edition');
                        params.put('argLevel', 'SMB - Spark');
                        //Adding Params for Subscription Lang,Locale and Time zone  values
                        params.put('argSubLang',ol.Subscription_Language__c != null ?  ol.Subscription_Language__c : Lang);
                        params.put('argSubLocale',ol.Subscription_Locale__c != null ? ol.Subscription_Locale__c : Locale );
                        params.put('argSubTZone',ol.Subscription_Time_Zone__c != null ? ol.Subscription_Time_Zone__c : Time_Zone);
                        provision(o, ol, params);
                    }   
                    else if(ol.PricebookEntry.Product2.Family == 'Select Edition'){
                        System.debug('oppy [' + o.Id + '] line item [' + ol.Id + '] is of type Select Edition');
                        params.put('argLevel','SMB - Select');
                        //Adding Params for Subscription Lang,Locale and Time zone  values
                        params.put('argSubLang',ol.Subscription_Language__c != null ?  ol.Subscription_Language__c : Lang);
                        params.put('argSubLocale',ol.Subscription_Locale__c != null ? ol.Subscription_Locale__c : Locale );
                        params.put('argSubTZone',ol.Subscription_Time_Zone__c != null ? ol.Subscription_Time_Zone__c : Time_Zone);
                        provision(o, ol, params);
                    }
                    else if(ol.PricebookEntry.Product2.Family == 'Standard Edition'){
                        System.debug('oppy [' + o.Id + '] line item [' + ol.Id + '] is of type Standard Edition');
                        params.put('argLevel', 'SMB - Standard');
                        //Adding Params for Subscription Lang,Locale and Time zone  values
                        params.put('argSubLang',ol.Subscription_Language__c != null ?  ol.Subscription_Language__c : Lang);
                        params.put('argSubLocale',ol.Subscription_Locale__c != null ? ol.Subscription_Locale__c : Locale );
                        params.put('argSubTZone',ol.Subscription_Time_Zone__c != null ? ol.Subscription_Time_Zone__c : Time_Zone);
                       
                        provision(o, ol, params);
                    }
                    else if(ol.PricebookEntry.Product2.Family == 'Real Time Personalization'){
                        System.debug('oppy [' + o.Id + '] line item [' + ol.Id + '] is of type Real Time Personalization');
                        params.put('argLevel', 'Marketo - Lite');
                        //Adding Params for Subscription Lang,Locale and Time zone  values
                        params.put('argSubLang',ol.Subscription_Language__c != null ?  ol.Subscription_Language__c : Lang);
                        params.put('argSubLocale',ol.Subscription_Locale__c != null ? ol.Subscription_Locale__c : Locale );
                        params.put('argSubTZone',ol.Subscription_Time_Zone__c != null ? ol.Subscription_Time_Zone__c : Time_Zone);
                       
                        provision(o, ol, params);
                    }
                    
                    
                }
            }
    }

   
    
    public static boolean provision( Opportunity o, OpportunityLineItem ol, Map<String,String> args){
        args.put('argProdCode', String.valueOf(ol.PricebookEntry.Product2.ProductCode));
        args.put('argInstanceNumber', ol.Instance_Number__c == null? '': String.valueOf(ol.Instance_Number__c));
        args.put('argAsset', ol.Related_Asset__c == null? '' : String.valueOf(ol.Related_Asset__c));
        args.put('argOppyId', String.valueOf(o.Id));
        try{
            boolean ret =  callApi(o, ol, args);
            // reset the sandbox flag, so if there is another subscription prov related line item
            // it doesnt end up creating another sandbox.
            args.put('argSandbox', '0');
            return ret;
        }catch(Exception e){
            /***CODE IS COMMENTED--APPS-386===
            sendEmail('Auto-Provisioning Error', 'Opportunity ' + o.Id + ' and OpportunityLineItem ' + ol.Id + ' (' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + o.Id + 
                ') Error: ' + e.getMessage() + '\n ' + e.getStackTraceString() + '\npayload:\n' + args);***/
            return false;
        }
    }
    
    // use cert to communicate with mmcweb:
    public static final String certName = Label.OAP_certName;
    //public static final String certName = null;
    public static final String endpoint = Label.OAP_endpoint;
    // Token to acces REST service
    public static final String endpoint_token = Label.OAP_endpoint_token;  
    
    private static boolean callApi(Opportunity o, OpportunityLineItem ol, Map<String, String> args){
            // Set parameters
            Map<String, String> params = new Map<String, String>();

            //
            // Time for the callout
            //
            
            // Catch callout errors
            HTTPRequest req = new HttpRequest();
            
                // Prepare response/request
                HTTPResponse hTTPRes;
                req.setTimeout(120000);
        
                params.put('marketo_charonbundle_subposttype[token]', OpportunityAutoProvisioning.endpoint_token);
                params.put('marketo_charonbundle_subposttype[name]', args.get('argName'));
                params.put('marketo_charonbundle_subposttype[homepage]', args.get('argHomePage'));
                params.put('marketo_charonbundle_subposttype[username]', args.get('argUserName'));
                params.put('marketo_charonbundle_subposttype[firstname]', args.get('argFirstName'));
                params.put('marketo_charonbundle_subposttype[lastname]', args.get('argLastName'));
                params.put('marketo_charonbundle_subposttype[level]', args.get('argLevel'));
                params.put('marketo_charonbundle_subposttype[purpose]', args.get('argPurpose'));
                params.put('marketo_charonbundle_subposttype[sandbox]', args.get('argSandbox'));
                params.put('marketo_charonbundle_subposttype[channel_partner]', args.get('argChanelPartner'));
                params.put('marketo_charonbundle_subposttype[outlook_seats]', args.get('argOutlookSeats'));
                params.put('marketo_charonbundle_subposttype[salesforce_seats]', args.get('argSalesforceSeats'));
                params.put('marketo_charonbundle_subposttype[session_token]', args.get('argSessionId'));
                params.put('marketo_charonbundle_subposttype[product_code]', args.get('argProdCode'));
                params.put('marketo_charonbundle_subposttype[instance_number]', args.get('argInstanceNumber'));
                params.put('marketo_charonbundle_subposttype[opp_id]', args.get('argOppyId'));
                params.put('marketo_charonbundle_subposttype[asset]', args.get('argAsset'));
                //Adding 3 new params Subscription Local,Timezone and Lang
                params.put('marketo_charonbundle_subposttype[language]', CommonUtils.getLangCode(args.get('argSubLang')));
                params.put('marketo_charonbundle_subposttype[locale]', CommonUtils.getLocCode(args.get('argSubLocale')));
                params.put('marketo_charonbundle_subposttype[timezone]', CommonUtils.getTzoneCode(args.get('argSubTZone')));
                System.debug ('param list to be posted : ' + params);
                
                req.setBody(paramStringFromMap(params));
                
                if( OpportunityAutoProvisioning.certName != null) {
                  req.setClientCertificateName(OpportunityAutoProvisioning.certName);
                }

                // Set endpoint
                req.setEndpoint(OpportunityAutoProvisioning.endpoint);
                        
                // Set method to POST
                req.setMethod('POST');
            
                // Make the 1st-10th callout
                HTTP http = new HTTP();
                                
                // Only process if not testing
                if(system.Test.isRunningTest() == false)
                {
                    hTTPRes = http.send(req);
                    integer status_code = hTTPRes.getStatusCode();                    
                    if (status_code != 200){
                       /***CODE IS COMMENTED--APPS-386===
                        sendEmail('Auto-Provisioning Failure', 
                            'Opportunity ' + o.Name + ' (' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + o.Id + 
                            ') successfully called mmcweb\n' + 'payload:\n' + req.getBody().replace('&', '\n'));
                        **/
                        return false;
                    }else{
                        /***CODE IS COMMENTED--APPS-386===
                        sendEmail('Auto-Provisioning Success', 
                            'Opportunity ' + o.Name + ' (' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + o.Id + 
                            ') successfully called mmcweb\n' + 'payload:\n' + req.getBody().replace('&', '\n'));
                        ***/
                        System.debug('Successfull post to mmcweb===>');
                    }
                }
                return true;
            
    }
    
    
    // Parse parameters for POST
    private static String paramStringFromMap(Map<String,String> params)
    {
        String returned = '';
        for(String key : params.keySet())
        {
            if(returned == '')
            {
            }
            else 
            {
                returned += '&';
            }
            System.debug('processing key: ' + key + ' on Map ' + params.get(key));
            returned += key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
        }
        return returned;
    } 

    // Never Used---
    public static void sendEmail(String subject, String body)
    {
        /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { 'jacques@marketo.com.fullcopy' };
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject == null ? '' : subject);
        mail.setPlainTextBody(body == null ? '' : body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        */
    }
}