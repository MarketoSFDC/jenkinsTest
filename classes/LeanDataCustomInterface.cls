global class LeanDataCustomInterface extends LeanData.CustomInterface {
  global override Set<String> getCustomLeadFields() {
    return new Set<String> {'Touch_Stage__c', 'SDR_Owner__c'};
  }
}