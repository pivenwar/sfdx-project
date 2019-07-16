public class SST_FotoCC {
    @AuraEnabled
    public static void updatePicturePath(String recId){
        //In Lightning Experience, Attachments are stored in ContentDocuments
        ContentDocumentLink docLink = [ SELECT ContentDocumentId
                                       FROM ContentDocumentLink
                                       WHERE LinkedEntityId = :recId order by Id desc Limit 1];
        //ContentVersion Id uniquely identifies the attachment
        ContentVersion ver = [SELECT Id FROM ContentVersion Where ContentDocumentId = :docLink.ContentDocumentId];
        //Update the Picture_Path field with the url of the image
        Contact contacto = [SELECT Id FROM Contact WHERE Id = :recId];
        if(Schema.sObjectType.Contact.fields.sst_ruta_foto__c.isUpdateable()){
        	contacto.sst_ruta_foto__c = SST_Constantes.RUTA_FOTO+ ver.Id;
        	upsert contacto;
        }
    }
}