public class GeoLocationCallouts {

      static public Jive_User__c  getLocation(Jive_User__c GeoLocation){
        // create an address string
        String address = '';
        if (GeoLocation.jive_city__c!= null)
            address += GeoLocation.jive_city__c+', ';
        if (GeoLocation.jive_state__c!= null)
            address += GeoLocation.jive_state__c +' ';   
        address = EncodingUtil.urlEncode(address, 'UTF-8');
        system.debug('address===>'+address);

        //build callout
        Http httpCallout = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Label.GoogleCallOut+address); // Label.GoogleCallOut = https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyC4BuzFBLtADQZrW7en9Q3ZFXTRAJsMRpU&sensor=false&address= 
        req.setMethod('GET');
        req.setTimeout(60000);

        try{
            // callout
            HttpResponse res = new HttpResponse();
            JSONParser parser;
            if(!test.isrunningtest()){
                res = httpCallout.send(req);
                parser = JSON.createParser(res.getBody());
                system.debug('Geo Res===>'+res);
            }else{
               parser = JSON.createParser('{"results":[{"address_components":[{"long_name":"Chandigarh","short_name":"Chandigarh","types":["locality","political"]},{"long_name":"Chandigarh","short_name":"CH","types":["administrative_area_level_1","political"]},{"long_name":"India","short_name":"IN","types":["country","political"]},{"long_name":"160017","short_name":"160017","types":["postal_code"]}],"formatted_address":"Chandigarh, Chandigarh 160017, India","geometry":{"bounds":{"northeast":{"lat":30.7958938,"lng":76.8529701},"southwest":{"lat":30.5944928,"lng":76.6798587}},"location":{"lat":30.7333148,"lng":76.7794179},"location_type":"APPROXIMATE","viewport":{"northeast":{"lat":30.7958938,"lng":76.8529701},"southwest":{"lat":30.6568986,"lng":76.6798587}}},"place_id":"ChIJa8lu5gvtDzkR_hlzUvln_6U","types":["locality","political"]}],"status":"OK"}');
            }

            // parse coordinates from response
            
            System.debug('whole data is'+res.getBody());
            double lat = null;
            double lon = null;
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'location')){
                   parser.nextToken(); // object start
                   while (parser.nextToken() != JSONToken.END_OBJECT){
                       String txt = parser.getText();
                       parser.nextToken();
                       if (txt == 'lat')
                           lat = parser.getDoubleValue();
                       else if (txt == 'lng')
                           lon = parser.getDoubleValue();
                   }
                }
            }

            // update coordinates if we get back
            system.debug('lat===>'+lat);
            system.debug('lon===>'+lon);
            if(lat != null && lon != null){
                GeoLocation.geolocation__Latitude__s  = lat;
                GeoLocation.geolocation__Longitude__s = lon; 
                //update GeoLocation;               
            }
        
        } catch (Exception e) {
        } 
        return GeoLocation;
    }
}