/**
 * Created by CrutchfieldJody on 1/19/2017.
 */
trigger AssetTriggerVA on Asset (after insert) {
  if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_AssetTriggerVA__c)){
      if(!SalesTriggersUtility.AssetTriggerVA){
        VistaAssetVAHandler handler = new VistaAssetVAHandler(Trigger.new);
      }
  }
}