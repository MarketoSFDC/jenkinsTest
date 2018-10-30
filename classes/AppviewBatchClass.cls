/*************************************************************************************************
This Class is Written to populate the fields of App view Data in Salesforce.
Created By - Grazitti Support Team
*************************************************************************************************/
global class AppviewBatchClass implements Database.Batchable<sObject> {
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = Label.AppViewBatchQuery;
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Appview_Data__c > scope){
        List<Appview_Data__c> listToUpdate = new List<Appview_Data__c >();
        List<sObject> lisToInsert = new List<sObject>();
        for(Appview_Data__c JSONContent: scope){
            AppViewWrapper appObj = (AppViewWrapper) AppViewWrapper.parse(String.valueOf(JSONContent.Json__c));
    
            /*** Below code is written to fetch App view Subscription details **/
            Appview_Data__c app = new Appview_Data__c(id=JSONContent.id);
            if(appObj.Subscription.pod != null && appObj.Subscription.pod != '')                          app.Pod__c = appObj.Subscription.pod;
            if(appObj.Subscription.blackcat!= null && appObj.Subscription.blackcat!= '')                  app.Blackcat_Mode__c = appObj.Subscription.blackcat;
            if(appObj.Subscription.created_on != null && appObj.Subscription.created_on != '')            app.Created_On__c = appObj.Subscription.created_on;
            if(appObj.Subscription.customer_db!= null && appObj.Subscription.customer_db!= '')            app.Customer_DB__c= appObj.Subscription.customer_db;
            if(appObj.Subscription.customer_prefix!= null && appObj.Subscription.customer_prefix!= '')    app.Customer_Prefix__c = appObj.Subscription.customer_prefix;
            if(appObj.Subscription.friendly_name!= null && appObj.Subscription.friendly_name!= '')        app.Friendly_Name__c= appObj.Subscription.friendly_name;
            if(appObj.Subscription.lp_domain!= null && appObj.Subscription.lp_domain!= '')                app.LP_Domain__c= appObj.Subscription.lp_domain;
            if(appObj.Subscription.multi_ip!= null && appObj.Subscription.multi_ip!= '')                  app.Mult_IP__c= appObj.Subscription.multi_ip;
            if(appObj.Subscription.munchkin_id!= null && appObj.Subscription.munchkin_id!= '')            app.Munchkin_ID__c= appObj.Subscription.munchkin_id;
            if(appObj.Subscription.purpose!= null && appObj.Subscription.purpose!= '')                    app.Purpose__c= appObj.Subscription.purpose;
            if(appObj.Subscription.rca!= null && appObj.Subscription.rca!= '')                            app.RCA__c = appObj.Subscription.rca;
            if(appObj.Subscription.rca_pod!= null && appObj.Subscription.rca_pod!= '')                    app.RCA_Pod__c= appObj.Subscription.rca_pod;
            if(appObj.Subscription.rtp!= null && appObj.Subscription.rtp!= '')                            app.RTP__c= appObj.Subscription.rtp;
            if(appObj.Subscription.seo!= null && appObj.Subscription.seo!= '')                            app.SEO__c= appObj.Subscription.seo;
            if(appObj.Subscription.social_enabled!= null && appObj.Subscription.social_enabled!= '')      app.Social_Enabled__c= appObj.Subscription.social_enabled;
            if(appObj.Subscription.status!= null && appObj.Subscription.status!= '')                      app.Status__c= appObj.Subscription.status;
            if(appObj.Subscription.sub_id!= null && appObj.Subscription.sub_id!= '')                      app.Sub_ID__c= appObj.Subscription.sub_id;
            if(appObj.Subscription.sub_type!= null && appObj.Subscription.sub_type!= '')                  app.Subscription_Type__c= appObj.Subscription.pod;
            if(appObj.Subscription.total_users!= null && appObj.Subscription.total_users!= '')            app.Total_Users__c= appObj.Subscription.total_users;
            if(appObj.Subscription.tracking_url!= null && appObj.Subscription.tracking_url!= '')          app.Tracking_URL__c= appObj.Subscription.tracking_url;
            if(appObj.Subscription.updated_on!= null && appObj.Subscription.updated_on!= '')              app.Updated_On__c = appObj.Subscription.updated_on;
            if(appObj.Subscription.batch_vsg!= null && appObj.Subscription.batch_vsg!= '')                app.Binding_Group__c = appObj.Subscription.batch_vsg;
            if(appObj.Subscription.active_cal_seats!= null && appObj.Subscription.active_cal_seats!= '')  app.Calendar_Se__c = appObj.Subscription.active_cal_seats;
            if(appObj.Subscription.msiSeats!= null && appObj.Subscription.msiSeats!= '')                  app.MSI_Seatsats__c = appObj.Subscription.msiSeats;
            if(appObj.Subscription.cal_users!= null && appObj.Subscription.cal_users!= '')                app.Activated_Seats__c = appObj.Subscription.cal_users;
            if(appObj.Subscription.dailyquota!= null && appObj.Subscription.dailyquota!= '')              app.Rest_API_Daily_Quota__c = appObj.Subscription.dailyquota;
            if(appObj.Subscription.ratelimit!= null && appObj.Subscription.ratelimit!= '')                app.Rest_API_Rate_Limit__c = appObj.Subscription.ratelimit;
            if(appObj.Subscription.tracking_link!= null && appObj.Subscription.tracking_link!= '')        app.Tracking_Links__c= appObj.Subscription.tracking_link;
            if(appObj.Subscription.pod != null && appObj.Subscription.pod != '')                          app.Orion_Pod__c = appObj.Subscription.pod;
            if(appObj.Subscription.prefixMunchkin != null && appObj.Subscription.prefixMunchkin != '')    app.Customer_Prefix_MunchkinID__c = appObj.Subscription.prefixMunchkin;
            if(appObj.Subscription.rca != null && appObj.Subscription.rca != '')                          app.RCA__c = appObj.Subscription.rca;
            if(appObj.Subscription.activityService != null && appObj.Subscription.activityService != '')  app.ActivityService__c = appObj.Subscription.activityService;
            if(appObj.Subscription.cv2 != null && appObj.Subscription.cv2 != '')                          app.CV2__c = appObj.Subscription.cv2;
            if(appObj.Subscription.crm != null && appObj.Subscription.crm != '')                          app.CRM__c = appObj.Subscription.crm;
            if(appObj.Subscription.tigger != null && appObj.Subscription.tigger != '')                    app.Tigger__c = appObj.Subscription.tigger;
            if(appObj.Subscription.abm != null && appObj.Subscription.abm != '')                          app.ABM__c = appObj.Subscription.abm;
            if(appObj.Subscription.msiStars != null && appObj.Subscription.msiStars != '')                app.MSIStarsAndFlames__c = appObj.Subscription.msiStars;
            if(appObj.Subscription.msdSpark != null && appObj.Subscription.msdSpark != '')                app.MSDSpark__c= appObj.Subscription.msdSpark;
            if(appObj.Subscription.leadRestApi != null && appObj.Subscription.leadRestApi != '')          app.LeadRESTAPI__c = appObj.Subscription.leadRestApi;
            if(appObj.Subscription.soapApi != null && appObj.Subscription.soapApi != '')                  app.SOAPAPI__c = appObj.Subscription.soapApi;
            if(appObj.Subscription.activityLogUI != null && appObj.Subscription.activityLogUI != '')      app.ActivityLogUI__c = appObj.Subscription.activityLogUI;
            if(appObj.Subscription.anonLeadStore != null && appObj.Subscription.anonLeadStore != '')      app.AnonymousLeadStore__c = appObj.Subscription.anonLeadStore;
            if(appObj.Subscription.logUploader != null && appObj.Subscription.logUploader != '')          app.LogUploader__c = appObj.Subscription.logUploader;
            if(appObj.Subscription.sparkIndexer != null && appObj.Subscription.sparkIndexer != '')        app.SparkIndexer__c = appObj.Subscription.sparkIndexer;
            if(appObj.Subscription.emailReports != null && appObj.Subscription.emailReports != '')        app.EmailReports__c = appObj.Subscription.emailReports;
            if(appObj.Subscription.supporttools != null && appObj.Subscription.supporttools != '')        app.SupportTools__c = appObj.Subscription.supporttools;
            if(appObj.Subscription.googleadwords != null && appObj.Subscription.googleadwords != '')      app.GoogleAdWords__c = appObj.Subscription.googleadwords;
            if(appObj.Subscription.emailinsights != null && appObj.Subscription.emailinsights != '')      app.EmailInsights__c = appObj.Subscription.emailinsights;
            if(appObj.Subscription.webTrackingServiceReport != null && appObj.Subscription.webTrackingServiceReport != '')   app.WebTrackingServiceReport__c = appObj.Subscription.webTrackingServiceReport;


           /*** Below code is written to fetch App view RTP details **/
            if(appObj.rtpDetails != null){
                if(appObj.rtpDetails.munchkin_id!= null && appObj.rtpDetails.munchkin_id!= '')                       app.RTP_Munchkin_ID__c = appObj.rtpDetails.munchkin_id;
                if(appObj.rtpDetails.name!= null && appObj.rtpDetails.name!= '')                                     app.RTP_Name__c= appObj.rtpDetails.name;
                if(appObj.rtpDetails.number_of_reactions!= null && appObj.rtpDetails.number_of_reactions!= '')       app.Number_Of_Reactions__c = appObj.rtpDetails.number_of_reactions;
                if(appObj.rtpDetails.default_time_zone!= null && appObj.rtpDetails.default_time_zone!= '')           app.Default_Time_Zone__c = appObj.rtpDetails.default_time_zone;
                if(appObj.rtpDetails.max_abm_records!= null && appObj.rtpDetails.max_abm_records!= '')               app.Max_ABM_Records__c = appObj.rtpDetails.max_abm_records;
                if(appObj.rtpDetails.max_audiences!= null && appObj.rtpDetails.max_audiences!= '')                   app.Max_Audiences__c = appObj.rtpDetails.max_audiences;
                if(appObj.rtpDetails.custom_fields_limit!= null && appObj.rtpDetails.custom_fields_limit!= '')       app.Custom_Fields_Limit__c = appObj.rtpDetails.custom_fields_limit;
                if(appObj.rtpDetails.create_date!= null && appObj.rtpDetails.create_date!= '')                       app.RTP_Created_Date__c= appObj.rtpDetails.create_date;
                if(appObj.rtpDetails.last_update_date!= null && appObj.rtpDetails.last_update_date!= '')             app.RTP_Last_Updated_Date__c= appObj.rtpDetails.last_update_date;         
            }
            listToUpdate.add(app);
            
            /*** Below code is written to fetch App view Bundle details **/
            if(appObj.rubiks_details!= null){
                for(AppViewWrapper.rubiks_details app1: appObj.rubiks_details){
                    Appview_Bundles__c abb = new Appview_Bundles__c(Appview_Data__c = JSONContent.Id,recordtypeId= Label.Rubiks);
                    if(app1.bundle != null && app1.bundle != '')                                               abb.Bundle__c = app1.bundle;
                    if(app1.feature_names!= null && app1.feature_names!= '')                                   abb.Feature_Details__c= app1.feature_names;
                    if(app1.feature_details!= null && app1.feature_details!= '')                               abb.Feature_Names__c= app1.feature_details;
                    lisToInsert.add(abb);
                }
            }
            if(appObj.legacy_details != null){
            for(List<String> leg: appObj.legacy_details){
                    Appview_Bundles__c abb = new Appview_Bundles__c(Appview_Data__c = JSONContent.Id,recordtypeId= Label.Legacy);
                    abb.Feature__c= String.valueOf(leg[0]);
                    abb.Feature_values__c = String.valueOf(leg[1]);
                    lisToInsert.add(abb);
                }
            }
        }
        if(!listToUpdate.isEmpty()) Update listToUpdate;
        if(!lisToInsert.isEmpty()) Database.Insert(lisToInsert,false);
     }   
    global void finish(Database.BatchableContext BC) {
        
  }
}