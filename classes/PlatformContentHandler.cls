public class PlatformContentHandler implements Sfc.ContentDownloadHandlerFactory{ 
    // The purpose of the next 2 lines is just for code coverage.  Testing the happy path (no exception)
    // was not sufficient to meet the 75% code coverage requirement since as of this writing, this is the only
    // Apex class in the package.  Therefore, each line that's not covered represents a significant percentage,
    // as opposed to a package that has thousands of Apex lines of code where one uncovered line barely causes a blip
    // in the overall coverage.  Because of this, we need to make sure the exception handling code is also covered.
    // However, APXT_Redlining.PlatformContentDownloadHelper was not written to be unit testable (no way to inject
    // a dependency such that we can replace the dependency with a stub that throws an exception). We could of course
    // refactor PlatformContentDownloadHelper in our managed package to be testable but it's a global class, so we're stuck 
    // with its current signature.  Not to say that we can't create a new class that is testable, but at this point, the effort 
    // involved in making that happen justifies the use of the workaround below.

    // The workaround involves exposing a class level variable (throwException) that the test method can set to true to 
    // trigger a fake exception.
    public Boolean throwException = false;
    public class FakeException extends Exception {}

    public Sfc.ContentDownloadHandler getContentDownloadHandler(List<ID> ids, Sfc.ContentDownloadContext c){    
        Sfc.ContentDownloadHandler cdh = new Sfc.ContentDownloadHandler();   
        cdh.isDownloadAllowed = true;    
        try{       
            APXT_Redlining.PlatformContentDownloadHelper pcd = new APXT_Redlining.PlatformContentDownloadHelper();      
            cdh = pcd.getContentDownloadHandler(ids,c);  
            if (Test.isRunningTest() && throwException) throw new FakeException();
        }catch(Exception ex){ 
            cdh = new Sfc.ContentDownloadHandler(); 
            cdh.isDownloadAllowed = true; 
            return cdh;
        }   
        return cdh;  
    } 
}