/*
* @autor: Marcela Taborda
* @fecha: 05/09/2018
* @version: 1.0
*
* @fecha: 11/04/2019
* @version: 2.0
*/
public with sharing class SST_DocumentacionContactosCC {
    //Atributo para mostrar en pantalla los datos del contacto
    Public DTOContacto contacto {get;set;}
    
    //Atributo para mostrar los mensajes de éxito, confirmación o error en la página
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    //Atributo para renderizar el formulario del reporte en pantalla
    public Boolean mostrarInfo {get;set;}
    
    //Atributo para mostrar en pantalla la lista de documentos registrados para el proveedor o contratista
    public List <DTODocumentos> documentos {get;set;}
    
    //Atributos para obtener el archivo cargado por pantalla
    public transient Blob fileBody{get;set;}
    public transient String contentType {get;set;}
    public transient String fileName {get;set;}
    public transient Integer fileSize {get;set;}
    
    //Atributos para obtener los datos del registro seleccionado para anexar o eliminar archivos
    public string tipoSeleccionado {get;set;}
    public string idSeleccionado {get;set;}
    public String pathDocumento {get;set;}
    
    //Atributo con el link de la comunidad SST
    Public String linkSST {get;set;}
    
    //Atributos para almacenar los datos del pdf que se mostrará en pantalla con el texto de política de tratamiento de datos
    public string contentTypePDF{get;set;}
    public string url{get;set;}
    
    public SST_DocumentacionContactosCC(){   
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();    
        documentos = new List <DTODocumentos>();
        contacto = new DTOContacto();
        mostrarInfo = false;
        contentTypePDF = '';
        url = '';
        fileBody = null;
        contentType = '';
        fileName = '';
        fileSize = null;
        linkSST = SST_Constantes.LINK_SST;
    }
    
    //Método para consultar los datos del contacto y llenar la lista de gestión de documentos
    public pageReference consultarContacto(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        documentos = new List <DTODocumentos>();
        contacto.identificacion = contacto.identificacion.trim();
        contacto.codigo = contacto.codigo.trim();
        
        if(String.isEmpty(contacto.identificacion) || String.isEmpty(contacto.codigo)){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Digite el número de identificación y el código de acceso para continuar'));
        } else if(!contacto.identificacion.isAlphanumeric() || !contacto.codigo.isAlphanumeric()){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El texto ingresado en las casillas contiene caracteres no permitidos'));            
        } else {
            if(!contacto.autorizacion){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Debe aceptar los términos de la política de tratamiento de datos personales'));            
            } else {
                try{
                    //Se consultan los datos del contacto
                    List<Contact> lista = [select id, name, SST_Autorizacion_tratamiento_datos__c, recordType.name, SST_Identificacion__c, sst_estado__c, SST_retirado__c, recordTypeId from contact where id =:contacto.codigo and sst_identificacion__c =: contacto.identificacion];
                    if(lista == null || lista.size()==0){
                        mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El contacto no está registrado en el sistema.  Verifique el número de identificación y el código de acceso'));
                    } else if(lista.get(0).sst_retirado__c){
                        mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El contacto figura retirado en el sistema.  Comuníquese con el área de seguridad y salud en el trabajo de la empresa contratante'));
                    } else if(lista.get(0).recordType.name.equals(SST_Constantes.FUNCIONARIO)){
                        mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El contacto figura registrado en el sistema como Funcionario.  Comuníquese con el área de seguridad y salud en el trabajo de la empresa contratante'));
                    }
                    else {
                        mostrarInfo = true; 
                        //Llamado al método para obtener los label de los tipos de documento en el objeto Gestión de documentos
                        Map<String,String> mapaTipoDocumentos = new Map<String,String>();
                        Schema.DescribeFieldResult campo = SST_Gestion_documentos__c.Tipo_documento__c.getDescribe();
                        List<Schema.PicklistEntry> picklist = campo.getPicklistValues();        
                        for( Schema.PicklistEntry pickItem : picklist){
                            mapaTipoDocumentos.put(pickItem.getValue(),pickItem.getLabel());
                        }
                        
                        //Lista con los nombres de los recordType de Contactos
                        List<String> tiposContactos = SST_Constantes.TIPOS_CONTACTO;
                        
                        //Se llena la variable que se muestra en pantalla con los datos del contacto
                        contacto.nombre = lista.get(0).name;
                        contacto.idContacto = lista.get(0).id;
                        contacto.estado = lista.get(0).sst_estado__c.toLowerCase();
                        contacto.estado = contacto.estado.capitalize();
                        if(lista.get(0).recordType.name.equals(SST_Constantes.CONTRATISTA)){
                            contacto.tipoContacto = tiposContactos[0];
                        } else if(lista.get(0).recordType.name.equals(SST_Constantes.PROVEEDOR)){
                            contacto.tipoContacto = tiposContactos[2];
                        }
                        
                        //Se consulta y llena la lista de gestión de documentos del contacto
                        for(SST_Gestion_documentos__c temp : [select id, tipo_documento__c, Estado_actual_documento__c, Fecha_vencimiento__c, Documento_temporal__c from SST_Gestion_documentos__c where contacto__c=: contacto.idContacto order by Fecha_vencimiento__c DESC]){
                            DTODocumentos documentoTemp = new DTODocumentos();
                            documentoTemp.idDocumento = temp.id;
                            documentoTemp.tipoDocumento = mapaTipoDocumentos.get(temp.tipo_documento__c);
                            documentoTemp.estadoDocumento = temp.Estado_actual_documento__c;
                            if(!String.isBlank(temp.Documento_temporal__c)){
                                documentoTemp.nombreDocumento = temp.Documento_temporal__c;
                            } else {
                                documentoTemp.nombreDocumento = '';
                            }
                            if(temp.fecha_vencimiento__c == null){
                                documentoTemp.fechaVencimiento = '';
                            } else {
                                documentoTemp.fechaVencimiento = String.valueOf(temp.fecha_vencimiento__c);
                            }
                            documentos.add(documentoTemp);
                        }
                    }
                } catch(ApplicationException ae){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,ae.getMessage())); 
                }catch (DmlException e) {
                    system.debug('Mensaje error:'+e.getMessage());
                    system.debug('Linea error:'+e.getLineNumber());
                    system.debug('Causa error:'+e.getCause());
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ha ocurrido un error, por favor intente nuevamente')); 
                }
            }
        }
        return null;
    }
    
    //Método que recarga la página al cerrar el modal de notificación
    public pageReference recargar(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        idSeleccionado = idSeleccionado; 
        return null;
    }
    
    //Método para guardar un archivo adjunto
    public pageReference guardar(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        //Se valida el tipo de archivo cargado
        if(!String.isEmpty(fileName) && !fileName.endsWithIgnoreCase('pdf') && !fileName.endsWithIgnoreCase('doc') && !fileName.endsWithIgnoreCase('docx') && !fileName.endsWithIgnoreCase('xls')
           && !fileName.endsWithIgnoreCase('xlsx') && !fileName.endsWithIgnoreCase('png') && !fileName.endsWithIgnoreCase('jpg')){
               mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El tipo de archivo no es permitido. Cargue sólo documentos de tipo .pdf,.doc,.xlsx,.png,.jpg')); 
           } else if(!String.isEmpty(fileName)) {
               //Se valida el tamaño del archivo, y si es mayor a 3mb no se permite cargarlo
               if(fileSize>3072000){
                   mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El tamaño del archivo no puede ser superior a 3Mb')); 
               } else {
                   try{
                       if(Schema.sObjectType.ContentVersion.fields.versionData.isCreateable()&&
                          Schema.sObjectType.ContentVersion.fields.pathOnClient.isCreateable()&&
                          Schema.sObjectType.ContentVersion.fields.FirstPublishLocationId.isCreateable()&&
                          Schema.sObjectType.ContentVersion.fields.IsMajorVersion.isCreateable()&&
                          Schema.sObjectType.SST_Gestion_documentos__c.fields.Documento_temporal__c.isUpdateable()&&
                          Schema.sObjectType.SST_Gestion_documentos__c.fields.Actualizar_contacto__c.isUpdateable()){
                              transient ContentVersion nuevoDoc = new ContentVersion();
                              nuevoDoc.versionData = fileBody;
                              nuevoDoc.pathOnClient =fileName;
                              nuevoDoc.FirstPublishLocationId = idSeleccionado;
                              nuevoDoc.IsMajorVersion = false;
                              insert nuevoDoc;
                              
                              List<ID> idDocumentos = new List<ID>();
                              for(DTODocumentos temp : documentos){
                                  if(temp.idDocumento.equals(idSeleccionado) && fileBody<>null){
                                      idDocumentos.add(temp.idDocumento);
                                      temp.nombreDocumento = fileName;
                                  }
                              }
                              
                              
                              for(SST_Gestion_documentos__c documento : [SELECT id FROM SST_Gestion_documentos__c WHERE id in :idDocumentos]){
                                  documento.Documento_temporal__c = fileName;
                                  documento.Actualizar_contacto__c = false;
                                  update documento;
                                  break;
                              }
                              
                          }else{
                              throw new ApplicationException('Permisos insuficientes para agregar nuevos documentos');
                          }
                   }catch(ApplicationException ae) {
                       mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,ae.getMessage())); 
                   } catch (DmlException e) {
                       system.debug('Mensaje error:'+e.getMessage());
                       system.debug('Linea error:'+e.getLineNumber());
                       system.debug('Causa error:'+e.getCause());
                       mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ha ocurrido un error, por favor intente cargar el archivo nuevamente')); 
                   }
               }
           }
        return null;
    }
    
    //Método para notificar al área de SST que el contacto ha subido toda la documentación
    public pageReference notificar(){
        try{
            mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
            if(Schema.sObjectType.SST_Gestion_documentos__c.fields.Documento_temporal__c.isUpdateable()&&
               Schema.sObjectType.SST_Gestion_documentos__c.fields.Actualizar_contacto__c.isUpdateable()){
                   List<ID> idDocumentos = new List<ID>();
                   for(DTODocumentos temp : documentos){
                       if(!String.isEmpty(temp.nombreDocumento)){
                           idDocumentos.add(temp.idDocumento);
                           temp.nombreDocumento = '';
                       }
                   }
                   List<SST_Gestion_documentos__c> documentosConAnexos = new list<SST_Gestion_documentos__c>();        
                   
                   for(SST_Gestion_documentos__c documentoActualizar : [SELECT id FROM SST_Gestion_documentos__c WHERE id in :idDocumentos]){
                       documentoActualizar.Documento_temporal__c = '';
                       documentoActualizar.Actualizar_contacto__c = false;
                       documentosConAnexos.add(documentoActualizar);
                       
                   }
                   if(documentosConAnexos.size()>0){
                       update documentosConAnexos;
                   }
                   
                   
                   
                   Contact contactoActualizar = [SELECT id FROM Contact WHERE id= :contacto.idContacto];
                   contactoActualizar.SST_Gestionar_documentos__c = true;
                   contactoActualizar.SST_Notificar_link__c = false;
                   contactoActualizar.SST_Actualizar_documentacion__c = true;
                   contactoActualizar.SST_Autorizacion_tratamiento_datos__c = contacto.autorizacion;
                   update contactoActualizar;
                   
                   mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.CONFIRMACION,'Gracias por actualizar su documentación.  La empresa será notificada para que realice la revisión y evaluación respectiva.'));
                   mostrarInfo = false;
                   documentos = new List <DTODocumentos>();
                   contacto = new DTOContacto();
               }else{
                   mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Permisos insuficientes para modificar documentos'));
               }
        } catch (DmlException e) {
            system.debug('Mensaje error:'+e.getMessage());
            system.debug('Linea error:'+e.getLineNumber());
            system.debug('Causa error:'+e.getCause());
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ha ocurrido un error, por favor intente nuevamente')); 
        }
        return null;
    }
    
    //Método para eliminar un anexo guardado
    public pageReference eliminar(){
        try{
            if(ContentDocument.sObjectType.getDescribe().isDeletable()){
                if(!String.isEmpty(idSeleccionado)){
                    List<ContentVersion> docTemp = [select id, pathOnClient, ContentDocumentId from ContentVersion where FirstPublishLocationId =: idSeleccionado and pathOnClient =: pathDocumento order by CreatedDate DESC limit 1];
                    if(docTemp.size()>0){
                        ContentDocument docEliminar = [select id from ContentDocument where id =: docTemp.get(0).ContentDocumentId];
                        for(DTODocumentos temp : documentos){
                            if(temp.idDocumento.equals(idSeleccionado) && temp.nombreDocumento.equals(docTemp.get(0).pathOnClient)){
                                temp.nombreDocumento = '';
                                delete docEliminar;
                                break;
                            }
                        } 
                    }    
                } 
            }else{
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'No tiene permisos suficientes para eliminar un documento')); 
            }
        } catch (DmlException e) {
            system.debug('Mensaje error:'+e.getMessage());
            system.debug('Linea error:'+e.getLineNumber());
            system.debug('Causa error:'+e.getCause());
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ha ocurrido un error, por favor intente nuevamente')); 
        }
        return null;
    }
    
    //Método para inicializar las variables al volver a la pantalla de inicio
    public pageReference cancelar(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();   
        mostrarInfo = false;
        fileBody = null;
        contentType = '';
        fileName = '';
        fileSize = null;
        documentos = new List <DTODocumentos>();
        contacto = new DTOContacto();
        return null;
    }
    
    //Método para consultar el link público del pdf con el texto de la política de tratamiento de datos personales que se visualiza en pantalla
    public pagereference inicializarDocumento(){
        url = [SELECT SST_url_pdf_politica_datos__c FROM User where isActive =: true and profile.UserType = 'Standard' and SST_url_pdf_politica_datos__c <>:null and (profile.name =: SST_Constantes.SYSTEM_ADMINISTRATOR or profile.name =: SST_Constantes.ADMINISTRADOR) LIMIT 1].SST_url_pdf_politica_datos__c;
        return null;
    }
    
    //Inner Class para mostrar los datos de cada registro de Gestión de documentos en pantalla
    public class DTODocumentos {
        public String idDocumento {get;set;}
        public String tipoDocumento {get;set;}
        public String fechaVencimiento {get;set;}
        public String estadoDocumento {get;set;}
        public String nombreDocumento {get;set;}
    }
    
    //Inner Class para mostrar los datos del contacto en pantalla
    public class DTOContacto {
        public String identificacion {get;set;}
        public String codigo {get;set;}
        public String tipoContacto {get;set;}
        public String estado {get;set;}
        public String nombre {get;set;}
        public String idContacto {get;set;}
        public Boolean autorizacion {get;set;}
    }
    public class ApplicationException extends Exception {}
}