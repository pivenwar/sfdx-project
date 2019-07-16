/*
* @autor: Marcela Taborda
* @fecha: 05/09/2018
* @version: 1.0
*/
public with sharing class SST_ComunicacionesCC {
    //Atributo para almacenar la cédula del informador
    Public String cedula {get;set;}
    
    //Atributo para mostrar en pantalla el nombre del informador
    Public String nombre {get;set;}  
    
    //Atributo para mostrar en pantalla el record type del informador
    Public String tipoContacto {get;set;}
    
    //Atributo para mostrar en pantalla la sede del informador
    Public String sede {get;set;}   
    
    //Atributo para mostrar en pantalla el área del informador
    Public String area {get;set;}   
    
    //Atributo para almacenar la empresa del contacto
    Public String empresa {get;set;}    
    
    //Atributo para almacenar el detalle del reporte
    Public String detalle {get;set;}    
    
    //Atributo para mostrar en pantalla los datos del informador
    Contact informador {get;set;}
    
    //Atributo para mostrar los mensajes de éxito, confirmación o error en la página
    public List<SST_MensajesPaginaMobil> mensajesPaginaPrincipal {get;set;}
    
    //Atributo para renderizar el formulario del reporte en pantalla    
    public Boolean mostrarInfo {get;set;}
    
    //Atributo con el link de la comunidad SST
    Public String linkSST {get;set;}
    
    //Atributos para obtener el archivo cargado por pantalla
    public transient Blob fileBody{get;set;}
    public transient String contentType {get;set;}
    public transient String fileName {get;set;}
    public transient Integer fileSize {get;set;}
    
    
    
    public SST_ComunicacionesCC(){   
        mensajesPaginaPrincipal = new List<SST_MensajesPaginaMobil>();    
        cedula = null;
        empresa = '';
        sede ='';
        area = '';
        tipoContacto = '';
        informador = new Contact();
        detalle = '';
        fileName = '';
        mostrarInfo = false;
        linkSST = SST_Constantes.LINK_SST;
    }
    
    public pageReference consultarContacto(){
        mensajesPaginaPrincipal = new List<SST_MensajesPaginaMobil>();   
        cedula = cedula.trim();
        if(String.isEmpty(cedula)){
            mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.INFO,'Digite el número de identificación para continuar'));
        } else if(!cedula.isAlphaNumeric()){
            mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.INFO,'El texto ingresado no es un número de identificación válido'));            
        } else {
            try{
                List<Contact> lista = [select id, name, recordType.name, SST_Identificacion__c, sst_sede__c, sst_sede__r.name, sst_area_trabajo__c, sst_area_trabajo__r.name, sst_estado__c, recordTypeId, sst_empresa__c from contact where sst_identificacion__c =: cedula];
                if(lista == null || lista.size()==0){
                    mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.INFO,'El contacto no está registrado en el sistema'));
                } else {
                    informador = lista.get(0);
                    if(informador.sst_estado__c.equals(SST_Constantes.INACTIVO)){
                        mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.INFO,'El contacto está inactivo en el sistema'));
                    } else {
                        List<String> tiposContactos = SST_Constantes.TIPOS_CONTACTO;
                        mostrarInfo = true; 
                        nombre = informador.name;
                        empresa = informador.sst_empresa__c;
                        if(informador.sst_sede__c == null){
                            sede = '';
                        } else {
                            sede = informador.sst_sede__r.name;   
                        } 
                        if (informador.sst_area_trabajo__c == null){
                            area = '';
                        } else {
                            area = informador.sst_area_trabajo__r.name;   
                        }
                        if(informador.recordType.name.equals(SST_Constantes.CONTRATISTA)){
                            tipoContacto = tiposContactos[0];
                        } else if(informador.recordType.name.equals(SST_Constantes.FUNCIONARIO)){
                            tipoContacto = tiposContactos[1];
                        } else if(informador.recordType.name.equals(SST_Constantes.PROVEEDOR)){
                            tipoContacto = tiposContactos[2];
                        }
                    }
                }
            } catch (DmlException e) {
                system.debug('Mensaje error:'+e.getMessage());
                system.debug('Linea error:'+e.getLineNumber());
                system.debug('Causa error:'+e.getCause());
                mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.ERROR,'Ha ocurrido un error, por favor intente nuevamente')); 
            }
        }
        return null;
    }
    
    public pageReference guardar(){
        mensajesPaginaPrincipal = new List<SST_MensajesPaginaMobil>();   
        if(detalle == null || String.isEmpty(detalle)){
            mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.INFO,'Debe ingresar el detalle para enviar el informe')); 
        } else {
            try{
                SST_Comunicacion__c reporte = new SST_Comunicacion__c();
                if(Schema.sObjectType.SST_Comunicacion__c.fields.informador__c.isCreateable()&&
                   Schema.sObjectType.SST_Comunicacion__c.fields.Descripcion__c.isCreateable()&&
                   Schema.sObjectType.SST_Comunicacion__c.fields.empresa__c.isCreateable()){
                       reporte.informador__c = informador.id;
                       reporte.Descripcion__c = detalle;
                       reporte.empresa__c = empresa;
                       insert reporte; 
                   }else{
                       throw new ApplicationException('Permisos insuficientes para eliminar o registrar comunicaciones');
                   }
                
                //Se valida el tipo de archivo cargado
                if(!String.isEmpty(fileName) && !fileName.endsWithIgnoreCase('pdf') && !fileName.endsWithIgnoreCase('doc') && !fileName.endsWithIgnoreCase('docx') && !fileName.endsWithIgnoreCase('xls')
                   && !fileName.endsWithIgnoreCase('xlsx') && !fileName.endsWithIgnoreCase('png') && !fileName.endsWithIgnoreCase('jpg')){
                       mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.ERROR,'El tipo de archivo no es permitido. Cargue sólo documentos de tipo .pdf,.doc,.xlsx,.png,.jpg')); 
                   }  else if(!String.isEmpty(fileName)){
                       
                       //Se valida el tamaño del archivo, y si es mayor a 3mb no se permite cargarlo
                       if(fileSize>3072000){
                           mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.ERROR,'El tamaño del archivo no puede ser superior a 3Mb')); 
                       }else{
                           
                           try{
                               
                               if(Schema.sObjectType.ContentVersion.fields.versionData.isCreateable()&&
                                  Schema.sObjectType.ContentVersion.fields.pathOnClient.isCreateable()&&
                                  Schema.sObjectType.ContentVersion.fields.FirstPublishLocationId.isCreateable()&&
                                  Schema.sObjectType.ContentVersion.fields.IsMajorVersion.isCreateable()){
                                      transient ContentVersion nuevoDoc = new ContentVersion();
                                      nuevoDoc.versionData = fileBody;
                                      nuevoDoc.pathOnClient =fileName;
                                      nuevoDoc.FirstPublishLocationId = reporte.id;
                                      nuevoDoc.IsMajorVersion = false;
                                      insert nuevoDoc;
                                  }else{
                                      throw new ApplicationException('Permisos insuficientes para eliminar o registrar asociaciones de sedes con Normatividades');
                                  }
                               
                               
                           } catch (DmlException e) {
                               system.debug('Mensaje error:'+e.getMessage());
                               system.debug('Linea error:'+e.getLineNumber());
                               system.debug('Causa error:'+e.getCause());
                               mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.ERROR,'Ha ocurrido un error, por favor intente cargar el archivo nuevamente')); 
                           }
                       } 
                   }
                
                SST_Comunicacion__c nuevo = [select id, name, createdDate from SST_Comunicacion__c where id=: reporte.id];
                String fechaReporte = nuevo.CreatedDate.format(SST_Constantes.FORMATO_FECHA_REPORTE);
                fechaReporte = SST_Constantes.cambiarNombreMes(fechaReporte);
                
                String mensaje = 'Su informe ha sido enviado exitosamente: Fecha y hora: '+fechaReporte +' - Consecutivo: '+nuevo.name;
                mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.CONFIRMACION,mensaje));   
                cedula = null;
                mostrarInfo = false;
            }catch(ApplicationException ae){
                mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.ERROR,ae.getMessage())); 
            }catch (DmlException e) {
                system.debug('Mensaje error:'+e.getMessage());
                system.debug('Linea error:'+e.getLineNumber());
                system.debug('Causa error:'+e.getCause());
                mensajesPaginaPrincipal.add(new SST_MensajesPaginaMobil(SST_MensajesPaginaMobil.ERROR,'Ha ocurrido un error, por favor intente nuevamente')); 
            }
        }
        return null;
    }
    
    public pageReference cancelar(){
        mensajesPaginaPrincipal = new List<SST_MensajesPaginaMobil>();   
        cedula = null;
        mostrarInfo = false;
        return null;
    }  
    
    //Método que retorna un select list con las opciones de empresas
    public List<SelectOption> getEmpresas(){
        List<SelectOption> empresas = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Contact.SST_empresa__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry temp : itemsTemp){
            empresas.add(new SelectOption(temp.getValue(),temp.getLabel()));
        }
        return empresas;
    }
    
    public class ApplicationException extends Exception {}
}