/**@@
    ISSUE:-
    THE CODE WAS WRITTEN BY VIJAY NAIK TO SET THE APPROVAL INFORMATION. BUT RECORD WAS BEING UPDATED MULTIPLE TIMES IN TWO 
    METHODS- "setApprovalRequestStatus()", "resetApprovalRequestStatus()". CONSEQUENTLY, TWO DML OPERATION AND TWO EXTRA SOQL WAS BEING ADDED.
    
    FIX:-
    NOW WE HAVE MOVED THE CODE OF METHOD "resetApprovalRequestStatus()" TO "setApprovalRequestStatus()". SO NOW, TWO DMLS HAVE BEEN MERGED INTO ONE 
    AND TWO SOQLS TO ONE.
    
    MANAGED BY: GRAZITTI
@@**/

public class SetApprovalRequestStatusController{
    
    public SetApprovalRequestStatusController(){}
    
    //Set Approval Request Status
    /*public void setApprovalRequestStatus(List<Quote> quoteNewList, Map<Id, Quote> quoteNewMap, Map<Id,Quote> quoteOldMap){
        Id currentUserId = userInfo.getUserId();
        DateTime currentDateTime = System.Now();
        
        Map<id,List<Apttus_Approval__Approval_Request__c>> requestMap = new Map<id,List<Apttus_Approval__Approval_Request__c>>();
        List<Apttus_Approval__Approval_Request__c> requestList = new List<Apttus_Approval__Approval_Request__c>();
        
        //Get all approval request related to quotes updated
        requestList = [select id, Apttus_Approval__Approval_Status__c, Apttus_Approval__Actual_Approver__c, 
                       Related_Quote__c, Apttus_Approval__Step_Name__c, 
                       Apttus_Approval__Approver_Comments__c, Apttus_Approval__DateApproved__c from Apttus_Approval__Approval_Request__c 
                       WHERE Related_Quote__c in :quoteNewMap.keySet()];
        
        //create a map of quote id and approval request
        for(Id qId :quoteNewMap.keySet()){
            List<Apttus_Approval__Approval_Request__c> relatedReqs = new List<Apttus_Approval__Approval_Request__c>();
            for(Apttus_Approval__Approval_Request__c req :requestList){
                if(qId == req.Related_Quote__c){
                    relatedReqs.add(req);
                }
            }
            requestMap.put(qId, relatedReqs);
        }
        
    
        List<Apttus_Approval__Approval_Request__c> requestToUpdate = new List<Apttus_Approval__Approval_Request__c>();
        
        //Get the approval requests for which approval status is to set as approved
        for(Quote qt :quoteNewList){
            List<Apttus_Approval__Approval_Request__c> relatedRequests = new List<Apttus_Approval__Approval_Request__c>();
            relatedRequests = requestMap.get(qt.id);
            
            /**@@-- Finance Approval --@@**/
            //SET
            /*if((qt.Redirect_Finance_Approval__c != quoteOldMap.get(qt.id).Redirect_Finance_Approval__c)&&qt.Redirect_Finance_Approval__c==TRUE){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Finance Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Redirected';
                        req.Apttus_Approval__Approver_Comments__c = 'Redirected per previously approved terms';
                        req.Apttus_Approval__Actual_Approver__c = currentUserId;
                        req.Apttus_Approval__DateApproved__c = currentDateTime;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            //RESET
            if(quoteOldMap.get(qt.id).Approval_Status_Finance__c == 'Auto-Approved' && qt.Approval_Status_Finance__c == 'Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Finance Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
            /**@@-- Legal Approval--@@**/
            //SET
            /*if((qt.Redirect_Legal_Approval__c != quoteOldMap.get(qt.id).Redirect_Legal_Approval__c)&&qt.Redirect_Legal_Approval__c==TRUE){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Legal Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Redirected';
                        req.Apttus_Approval__Approver_Comments__c = 'Redirected per previously approved terms';
                        req.Apttus_Approval__Actual_Approver__c = currentUserId;
                        req.Apttus_Approval__DateApproved__c = currentDateTime;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            //RESET
            if(quoteOldMap.get(qt.id).Approval_Status_Legal__c == 'Auto-Approved' && qt.Approval_Status_Legal__c == 'Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Legal Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
            /**@@--Operations Approval --@@**/
            //SET
            /*if((qt.Redirect_Operations_Approval__c != quoteOldMap.get(qt.id).Redirect_Operations_Approval__c)&&qt.Redirect_Operations_Approval__c==TRUE){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Operations Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Redirected';
                        req.Apttus_Approval__Approver_Comments__c = 'Redirected per previously approved terms';
                        req.Apttus_Approval__Actual_Approver__c = currentUserId;
                        req.Apttus_Approval__DateApproved__c = currentDateTime;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            //RESET
            if(quoteOldMap.get(qt.id).Approval_Status_Operations__c == 'Auto-Approved' && qt.Approval_Status_Operations__c=='Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Operations Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
            /**@@ -- Sales Discount Approval --@@**/
            //SET
            /*if((qt.Redirect_Sales_Discount_Approval__c != quoteOldMap.get(qt.id).Redirect_Sales_Discount_Approval__c)&&qt.Redirect_Sales_Discount_Approval__c==TRUE){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Sales Discount Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Redirected';
                        req.Apttus_Approval__Approver_Comments__c = 'Redirected per previously approved terms';
                        req.Apttus_Approval__Actual_Approver__c = currentUserId;
                        req.Apttus_Approval__DateApproved__c = currentDateTime;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            //RESET
            if(quoteOldMap.get(qt.id).Approval_Status_Sales_Discount__c == 'Auto-Approved' && qt.Approval_Status_Sales_Discount__c=='Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Sales Discount Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
            /**@@ -- Sales Terms Approval --@@**/
            //SET
            /*if((qt.Redirect_Sales_Terms_Approval__c != quoteOldMap.get(qt.id).Redirect_Sales_Terms_Approval__c)&&qt.Redirect_Sales_Terms_Approval__c==TRUE){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Sales Terms Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Redirected';
                        req.Apttus_Approval__Approver_Comments__c = 'Redirected per previously approved terms';
                        req.Apttus_Approval__Actual_Approver__c = currentUserId;
                        req.Apttus_Approval__DateApproved__c = currentDateTime;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            //RESET
            if(quoteOldMap.get(qt.id).Approval_Status_Sales_Terms__c == 'Auto-Approved' && qt.Approval_Status_Sales_Terms__c=='Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Sales Terms Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
            /**@@-- Support Approval --@@**/
            //SET
            /*if((qt.Redirect_Support_Approval__c != quoteOldMap.get(qt.id).Redirect_Support_Approval__c)&&qt.Redirect_Support_Approval__c==TRUE){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Support Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Redirected';
                        req.Apttus_Approval__Approver_Comments__c = 'Redirected per previously approved terms';
                        req.Apttus_Approval__Actual_Approver__c = currentUserId;
                        req.Apttus_Approval__DateApproved__c = currentDateTime;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            //RESET
            if(quoteOldMap.get(qt.id).Approval_Status_Support__c == 'Auto-Approved' && qt.Approval_Status_Support__c=='Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Support Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
            
        }
        
        if(requestToUpdate.size()>0){
            update requestToUpdate;
        }
    }*/
    
    
    
    //Reset Approval Request Status
    /*public void reSetApprovalRequestStatus(List<Quote> quoteNewList, Map<Id, Quote> quoteNewMap, Map<Id,Quote> quoteOldMap){
       /***@@@----------------REASON TO COMMENT THE CODE IS EXPLAINED-------------------------------------------------------
        Id currentUserId = userInfo.getUserId();
        DateTime currentDateTime = System.Now();
        
        Map<id,List<Apttus_Approval__Approval_Request__c>> requestMap = new Map<id,List<Apttus_Approval__Approval_Request__c>>();
        List<Apttus_Approval__Approval_Request__c> requestList = new List<Apttus_Approval__Approval_Request__c>();
        
        //Get all approval request related to quotes updated
        requestList = [select id, Apttus_Approval__Approval_Status__c, Apttus_Approval__Actual_Approver__c, 
                    Related_Quote__c, Apttus_Approval__Step_Name__c, 
                    Apttus_Approval__Approver_Comments__c, Apttus_Approval__DateApproved__c from Apttus_Approval__Approval_Request__c 
                    where Related_Quote__c in :quoteNewMap.keySet()];
        
        //create a map of quote id and approval request
        for(Id qId :quoteNewMap.keySet()){
            List<Apttus_Approval__Approval_Request__c> relatedReqs = new List<Apttus_Approval__Approval_Request__c>();
            for(Apttus_Approval__Approval_Request__c req :requestList){
                if(qId == req.Related_Quote__c){
                    relatedReqs.add(req);
                }
            }
            requestMap.put(qId, relatedReqs);
        }
        
    
        List<Apttus_Approval__Approval_Request__c> requestToUpdate = new List<Apttus_Approval__Approval_Request__c>();
        
        //Get the approval requests for which approval status is to set as approved
        for(Quote qt :quoteNewList){
            List<Apttus_Approval__Approval_Request__c> relatedRequests = new List<Apttus_Approval__Approval_Request__c>();
            relatedRequests = requestMap.get(qt.id);
            
            //Finance Approval
            if(quoteOldMap.get(qt.id).Approval_Status_Finance__c == 'Auto-Approved' && qt.Approval_Status_Finance__c == 'Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Finance Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
            //Legal Approval
            if(quoteOldMap.get(qt.id).Approval_Status_Legal__c == 'Auto-Approved' && qt.Approval_Status_Legal__c == 'Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Legal Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
            //Operations Approval
            if(quoteOldMap.get(qt.id).Approval_Status_Operations__c == 'Auto-Approved' && qt.Approval_Status_Operations__c=='Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Operations Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
            //Sales Discount Approval
            if(quoteOldMap.get(qt.id).Approval_Status_Sales_Discount__c == 'Auto-Approved' && qt.Approval_Status_Sales_Discount__c=='Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Sales Discount Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
            //Sales Terms Approval
            if(quoteOldMap.get(qt.id).Approval_Status_Sales_Terms__c == 'Auto-Approved' && qt.Approval_Status_Sales_Terms__c=='Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Sales Terms Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
            //Support Approval
            if(quoteOldMap.get(qt.id).Approval_Status_Support__c == 'Auto-Approved' && qt.Approval_Status_Support__c=='Approval Needed'){
                for(Apttus_Approval__Approval_Request__c req :relatedRequests){
                    if(req.Apttus_Approval__Step_Name__c == 'Support Approval'){
                        req.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                        req.Apttus_Approval__Approver_Comments__c = '';
                        req.Apttus_Approval__Actual_Approver__c = null;
                        req.Apttus_Approval__DateApproved__c = null;
                        req.Apttus_Approval__Date__c = currentDateTime;
                        requestToUpdate.add(req);
                    }
                }
            }
            
        }
        
        if(requestToUpdate.size()>0){
            update requestToUpdate;
        }
        }
        }
        }
        ------------------------------------------------------------------------------------------------------------------------------------@@@***/
    /*}*/
    
}