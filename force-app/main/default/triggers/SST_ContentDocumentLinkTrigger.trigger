/*Trigger para setear visibilidad a Todos los usuarios, para los archivos adjuntos
* @Marcela Taborda
* @date 06/11/2018
*/
trigger SST_ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    for(ContentDocumentLink nuevoRegistro : Trigger.new){
        nuevoRegistro.Visibility = 'AllUsers';
    }
}