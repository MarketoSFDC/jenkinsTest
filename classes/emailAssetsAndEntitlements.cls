/* ---------------------------------
Updated By  - Shridhar Patankar
Date        - 19/01/2015
Description - For CPQ-22. Add Asset Id for updating Asset fields
------------------------------------   */

global class emailAssetsAndEntitlements implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          
         string OpportunityID ;
         string ProductCode;
         string InstanceNumber;
         string Asset;
         string MunchkinID;
         string AccountPrefix;
         string POD;      
         string AssetId; // CPQ-22 Added AssetId 
         
          string emailBody= email.plaintextbody;
          system.debug('this is email body'+emailBody);
          
          if(emailBody.contains('Opportunity ID:'))
          {
              integer oppIdStart = emailBody.indexOf('Opportunity ID:');
              integer oppStartLoc =  oppIdStart +  'Opportunity ID:'.length(); 
              integer oppEndLoc =  emailBody.indexOf('Product Code:'); 
              OpportunityID = emailBody.substring(oppStartLoc,oppEndLoc );
          }
          system.debug('OpportunityID '+OpportunityID );
          
          if(emailBody.contains('Product Code:'))
          {
              integer ProCodeStart = emailBody.indexOf('Product Code:');
              integer ProCodeStartLoc =  ProCodeStart +  'Product Code:'.length(); 
              integer ProCodeEndLoc =  emailBody.indexOf('Instance Number:'); 
              ProductCode = emailBody.substring(ProCodeStartLoc ,ProCodeEndLoc );
          }
          
         system.debug('ProductCode'+ProductCode);
          
          if(emailBody.contains('Instance Number:'))
          {
              integer InsNumStart = emailBody.indexOf('Instance Number:');
              integer InsNumStartLoc =  InsNumStart +  'Instance Number:'.length(); 
              integer InsNumEndLoc =  emailBody.indexOf('Asset:'); 
              InstanceNumber = emailBody.substring(InsNumStartLoc ,InsNumEndLoc);
          }
          
         system.debug('InstanceNumber'+InstanceNumber );
         
          if(emailBody.contains('Asset:'))
          {
              integer AssetStart = emailBody.indexOf('Asset:');
              integer AssetStartLoc =  AssetStart +  'Asset:'.length(); 
              integer AssetEndLoc =  emailBody.indexOf('Munchkin ID:'); 
              Asset = emailBody.substring(AssetStartLoc ,AssetEndLoc);
          }
          
         system.debug('Asset'+Asset );
         
         
          
          if(emailBody.contains('Munchkin ID:'))
          {
              integer MunIdStart = emailBody.indexOf('Munchkin ID:');
              integer MunIdStartLoc =  MunIdStart +  'Munchkin ID:'.length(); 
              integer MunIdEndLoc =  emailBody.indexOf('Account Prefix:'); 
              MunchkinID = emailBody.substring(MunIdStartLoc,MunIdEndLoc);
          }
          
         system.debug('MunchkinID'+MunchkinID );
           
          if(emailBody.contains('Account Prefix:'))
          {
              integer AccPreStart = emailBody.indexOf('Account Prefix:');
              integer AccPreStartLoc =  AccPreStart +  'Account Prefix:'.length(); 
              integer AccPreEndLoc =  emailBody.indexOf('POD:'); 
              AccountPrefix= emailBody.substring(AccPreStartLoc,AccPreEndLoc);
          }
          
         system.debug('AccountPrefix'+AccountPrefix); 
          
          /**GRAZITTI--> UPDATED CODE TO REMOVE SPACES IN BETWEEN 'POD:' AND POD NUMBER**/
          if(emailBody.contains('POD:')) {
              POD = null;
              String emailTextAfterPod = emailBody.substringAfter('POD:');
              if(emailTextAfterPod!= null) emailTextAfterPod = emailTextAfterPod.trim();
              POD = emailTextAfterPod;
          }
          // CPQ-22 Added for AssetId Start
         /*
          if(emailBody.contains('Asset ID:'))
          {
              integer AssetIdStart = emailBody.indexOf('Asset ID:');
              system.debug('###'+AssetIdStart );
              integer AssetIdStartLoc =  AssetIdStart +  'Asset ID:'.length(); 
              system.debug('$$$$'+AssetIdStartLoc );
              integer AssetIdEndLoc =  emailBody.indexOf('Asset ID:'); 
              system.debug('%%%%'+AssetIdEndLoc );
              AssetId = emailBody.substring(AssetIdStartLoc ,AssetIdStartLoc+18);
          }
          */
         system.debug('AssetId '+AssetId );
         
          // CPQ-22 Added for AssetId End
          
         system.debug('POD '+POD.length() ); 
         system.debug('POD value====================='+POD ); 
         
         OpportunityID = OpportunityID.trim();
         ProductCode= ProductCode.trim();
         InstanceNumber = InstanceNumber.trim();
         Asset= Asset.trim();
         
        // AssetId = AssetId.trim(); // CPQ-22 Added AssetId for trim
         MunchkinID= MunchkinID.trim();
         AccountPrefix= AccountPrefix.trim();
         POD= POD.trim();
         
         system.debug('POD after trim '+POD.length() ); 
 // ID  NewBusinessRecordTypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('New Business').getRecordTypeId();  
    
        list<opportunity> oppRec = [select id from opportunity where id =:OpportunityID ];
        if(oppRec.size()>0)
        {
            
           // createAssetsAndEntitlements.createFromEmail(OpportunityID,MunchkinID,POD,ProductCode,InstanceNumber,Asset,AccountPrefix);
            //AEEmailHandlerController.createFromEmail(OpportunityID,MunchkinID,POD,ProductCode,InstanceNumber,Asset,AccountPrefix);
            // CPQ-22 Start Calling createFromEmailWithAssetId method to update Asset based on the AssetId
            
            
            // CPQ-22 Start Calling createFromEmailWithAssetId method to update Asset based on the AssetId
              if(Asset!=null && Asset!=''){
            
                AEEmailHandlerWithAssetIdController.createFromEmailWithAssetId(OpportunityID,MunchkinID,POD,ProductCode,InstanceNumber,Asset,AccountPrefix);
              }
              else{
                  AEEmailHandlerController.createFromEmail(OpportunityID,MunchkinID,POD,ProductCode,InstanceNumber,Asset,AccountPrefix);
              }            
            // CPQ-22 Start Calling createFromEmailWithAssetId method to update Asset based on the AssetId
        }
        else
        {
         system.debug('No such opportunity');
        }
         
         
         
          return result;
      }
  }