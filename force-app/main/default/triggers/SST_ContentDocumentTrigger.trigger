/*Trigger para remover el nombre del archivo adjunto en el registro Gestión de Documentos, cuando el adjunto es eliminado
* @Marcela Taborda
* @date 06/11/2018
*/
trigger SST_ContentDocumentTrigger on ContentDocument (before delete) {
    if(trigger.isBefore){
        if(trigger.isDelete){
            List<String> idsDoc1 = new List<String>();
            List<String> idsDoc2 = new List<String>();
            List<ContentVersion> temp = [select id, FirstPublishLocationId, pathOnClient, ContentDocumentId from ContentVersion where ContentDocumentId in: trigger.oldMap.keyset()];
            for(ContentDocument registroEliminar : trigger.old){
                if(temp.size()>0){
                    for(ContentVersion t : temp){
                        idsDoc1.add(t.FirstPublishLocationId);
                        idsDoc2.add(t.pathOnClient);
                    }
                }   
            }
            List <SST_Gestion_documentos__c> docActualizar = new List <SST_Gestion_documentos__c>();
            for(SST_Gestion_documentos__c tt : [select id, Actualizar_contacto__c, Documento_temporal__c from SST_Gestion_documentos__c where id in: idsDoc1 and Documento_temporal__c in: idsDoc2]){
                tt.Documento_temporal__c = '';
                tt.Actualizar_contacto__c = false;
                docActualizar.add(tt);
            }        
            if(docActualizar.size()>0){
                update docActualizar;
            }
        }
    }
}