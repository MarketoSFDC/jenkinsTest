trigger DTOTriggerSalesOrderItem on Sales_Order_Item__c (after insert, after update, before delete) {
    DTOController DTOCon = new DTOController();
    if(Trigger.isInsert || Trigger.isUpdate){
        set<Id> oppLineItemIdSet = new Set<Id>();
        for(Sales_Order_Item__c soi :Trigger.new){
            if(soi.Opp_Product_id__c != null && soi.Opp_Product_id__c != '')
                oppLineItemIdSet.add(soi.Opp_Product_id__c);
        }
        
        if(oppLineItemIdSet.size() > 0){
            DTOCon.upsertDTORecords(oppLineItemIdSet);
        }
    }
    
    if(Trigger.isDelete){
        Set<Id> oppLineItemIdSetToDelete = new Set<Id>();
        for(Sales_Order_Item__c soi :Trigger.old){
            if(soi.Opp_Product_id__c != null && soi.Opp_Product_id__c != '')
                oppLineItemIdSetToDelete.add(soi.Opp_Product_id__c);
        }
        
        if(oppLineItemIdSetToDelete.size() > 0){
            DTOCon.deleteDTORecords(oppLineItemIdSetToDelete);
        }
    }
}