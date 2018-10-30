/***************************************************************************
Created By : Aman Bisht (amanb@grazitti.com)
Purpose: To fetch details of APP View details
***************************************************************************/

@RestResource(urlMapping='/AppviewApi/*')
global class AppviewApiClass{

    @HttpPost
    global static void post(){
         if(RestContext.request.requestBody.tostring() != null && RestContext.request.requestBody.tostring() != ''){
             List<Appview_Data__c> appviewList = new List<Appview_Data__c>();
             List<Appview_Data__c> appviewListToUpdate = new List<Appview_Data__c>();
             AppViewWrapper wrap = (AppViewWrapper) AppViewWrapper.parse(RestContext.request.requestBody.tostring());
             if(wrap.Subscription.pod != null && wrap.Subscription.pod != '' && wrap.Subscription.customer_prefix != null && wrap.Subscription.customer_prefix != ''){
                 appviewList = new List<Appview_Data__c>([Select Id from Appview_Data__c  where pod__c =:wrap.Subscription.pod and Customer_Prefix__c =:wrap.Subscription.customer_prefix]);
                 for(Appview_Data__c app :appviewList){
                     app.Json__c = RestContext.request.requestBody.tostring();
                     Appview_Data__c apd = new Appview_Data__c(id=app.Id);
                     appviewListToUpdate.add(apd);
                 }
                if(appviewList.Size() > 0){
                    Database.Delete(appviewListToUpdate,false);
                }
                Appview_Data__c app = new Appview_Data__c();
                app.Json__c = RestContext.request.requestBody.tostring();
                Database.Insert(app);  
             } 
         }           
    }
}