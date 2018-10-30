public class GlobalFunctions {

               
    
    public static Integer MAX_SHORT_BODY_LENGTH = 250;
   
    public GlobalFunctions() {
        init();
    }
    
    public void init() {
      //  mcce = new MarketoCommunityContentController();
      //  mcc = mcce.getMarketoCommunityContent();
    }
        


    public static String getShortBody(String body) {
    
        return getShortBody(body, MAX_SHORT_BODY_LENGTH);
    }
    
    public static String getShortBody(String body, Integer maxCharacters) {
        if (body == null) return null;        
        integer indexOfStartTag = 0;
        integer indexOfEndTag = 0;
        string strStartTag = '<a';
        string strEndTag = '</a>';
        String shortBody = body;
        String linkBody = '';      
        if (shortBody.contains(strStartTag)) {
            indexOfStartTag = shortBody.indexOf(strStartTag);
            system.debug('*******indexOfStartTag *********' + indexOfStartTag );
        }
        if (shortBody.contains(strEndTag)) {
            indexOfEndTag = shortBody.indexOf(strEndTag);
            system.debug('*******indexOfEndTag *********' + indexOfEndTag );
        }              
        if(indexOfStartTag > -1 && indexOfEndTag > -1)
        {           
            if (indexOfStartTag < indexOfEndTag){          
                linkBody = shortBody.substring(indexOfStartTag , (indexOfEndTag + 4));
                if(linkBody.contains('<img')){
                    system.debug('imagestart');
                    linkbody = '<br>' + '<span style="float:left;padding-top:10px;">'+linkBody+'</span>';
                }
            }           
        }        
        
        shortBody = shortBody.replaceAll('[\r\n]+', ' ');
        shortBody = shortBody.replaceAll('<\\s*br[^>]*[/]?>', '\n'); // Temporarily convert <br> to newline character.
        shortBody = shortBody.replaceAll('</p>', '\n\n'); // Temporarily convert </p> to newline character.
        shortBody = shortBody.replaceAll('<[^>]*>?', '');
        if (shortBody.length() > maxCharacters) {
            shortBody = shortBody.substring(0, maxCharacters) + ' ...';
            
        }        
        if (linkBody.length() > 0) {
            shortBody += '...' + linkBody;
        }
        // Convert newline character back to <br/>.
        shortBody = shortBody.replaceAll('\n', '<br/>');
        return shortBody;
    }

     
    
}