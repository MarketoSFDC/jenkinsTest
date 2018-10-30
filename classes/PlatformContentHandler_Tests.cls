@istest
public class PlatformContentHandler_Tests {
    public static testmethod void HappyPath() {
        ContentVersion cn = new ContentVersion();
        cn.Title = 'This is a file test1'; 
	    cn.VersionData = Blob.valueOf('xyz');   
        cn.PathOnClient = 'minerva';
        insert cn;
        
        Test.startTest();
        PlatformContentHandler pcd = new PlatformContentHandler();
        pcd.getContentDownloadHandler(new List<Id>{cn.Id}, Sfc.ContentDownloadContext.CONTENT);
        Test.stopTest();
    }
    
    public static testmethod void ExceptionPath() {
        ContentVersion cn = new ContentVersion();
        cn.Title = 'This is a file test1'; 
	    cn.VersionData = Blob.valueOf('xyz');   
        cn.PathOnClient = 'minerva';
        insert cn;
        
        Test.startTest();
        PlatformContentHandler pcd = new PlatformContentHandler();
        pcd.throwException = true;
        pcd.getContentDownloadHandler(new List<Id>{cn.Id}, Sfc.ContentDownloadContext.CONTENT);
        Test.stopTest();
    }
}