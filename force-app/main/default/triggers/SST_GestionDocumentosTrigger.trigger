/*Trigger para validaciones sobre el objeto Gestión documentos tanto previo como posterior a la inserción y actualización
* @Marcela Taborda
* @version 3.0
* @date 18/12/2018
*/
trigger SST_GestionDocumentosTrigger on SST_Gestion_documentos__c (before insert, before update, after insert, after update, after delete) {
    List <Id> idsRecordTypeContactos = new List <Id>();
    idsRecordTypeContactos.add(Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.CONTRATISTA).getRecordTypeId());
    idsRecordTypeContactos.add(Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.PROVEEDOR).getRecordTypeId());
    Schema.DescribeFieldResult campo = SST_Gestion_documentos__c.Tipo_documento__c.getDescribe();
    List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
    Map<String,String> listaDocumentos = new Map<String,String>();
    for( Schema.PicklistEntry pickItem : picklist){
        listaDocumentos.put(pickItem.getValue(),pickItem.getLabel());
    }
    map<Id,Contact> mapaContactos = new map<Id,Contact>();
    List <Id> idContactosDocumentos = new List <Id>();
    if(trigger.isBefore){
        //Si se crea un nuevo registro de tipo Contrato o Seguridad Social, se valida si el contacto ya tiene registrado previamente un documento del mismo tipo
        if(trigger.isInsert){
            List <Id> idContactos = new List <Id>();
            for(SST_Gestion_documentos__c temp : Trigger.new){
                idContactos.add(temp.Contacto__c);   
                if(!temp.Funcionario__c){
                    temp.Actualizar_contacto__c = true;
                    idContactosDocumentos.add(temp.Contacto__c);
                }
            }
            for(Contact contactoTemp : [select id, recordTypeId, SST_Empresa__c, sst_Documentacion_contacto__c from contact where id in: idContactos]){
                mapaContactos.put(contactoTemp.id, contactoTemp);
            }
            if(idContactosDocumentos.size()>0){
                Map<Id, List <SST_Gestion_documentos__c>> contactos = new Map<Id, List <SST_Gestion_documentos__c>>();
                List <SST_Gestion_documentos__c> documentosContactos = [select id, contacto__c, contacto__r.name, contacto__r.recordTypeId, Tipo_documento__c from SST_Gestion_documentos__c where contacto__c in: idContactosDocumentos and contacto__r.recordTypeId in: idsRecordTypeContactos];
                if(documentosContactos.size()>0){
                    for(Id idTemp : idContactosDocumentos){
                        List <SST_Gestion_documentos__c> docsPorContacto = new List <SST_Gestion_documentos__c>();
                        for(SST_Gestion_documentos__c docTemp : documentosContactos){
                            if(idTemp == docTemp.contacto__c){
                                docsPorContacto.add(docTemp);
                            }
                        }
                        contactos.put(idTemp,docsPorContacto);
                    }
                }
                for(SST_Gestion_documentos__c nuevoRegistro : Trigger.new){
                    nuevoRegistro.Empresa__c = mapaContactos.get(nuevoRegistro.Contacto__c).SST_Empresa__c;
                    List <SST_Gestion_documentos__c> docsContacto = contactos.get(nuevoRegistro.Contacto__c);                    
                    if(nuevoRegistro.Actualizar_contacto__c){                        
                        if(docsContacto <> null && docsContacto.size()>0 && 
                           (docsContacto.get(0).contacto__r.RecordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.CONTRATISTA).getRecordTypeId()
                            || docsContacto.get(0).contacto__r.RecordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.PROVEEDOR).getRecordTypeId())){ 
                                for(SST_Gestion_documentos__c temp : docsContacto){
                                    if(nuevoRegistro.Tipo_documento__c.equals(temp.Tipo_documento__c)){
                                        nuevoRegistro.adderror('El contacto '+docsContacto.get(0).contacto__r.name+' ya tiene registrado un documento de tipo: '+listaDocumentos.get(nuevoRegistro.Tipo_documento__c)+'; proceda a actualizar el registro existente.');
                                    } 
                                }
                            } 
                    }
                } 
            }
        }  
        //Si se modifica registro cambiando el tipo de documento a Contrato o Seguridad Social, se valida si el contacto ya tiene registrado previamente un documento del mismo tipo
        else if(trigger.isUpdate){
            List <Id> idDocumentos = new List <Id>();
            List <Id> idContactos = new List <Id>();
            List<Profile> perfil = [select id from profile where name = 'Modulos SST Profile' or name = 'Módulos SST Profile'];
            for(SST_Gestion_documentos__c temp : Trigger.new){
                if(perfil<>null && !perfil.isEmpty() && perfil.get(0).id <> userInfo.getProfileId()){
                 	temp.Actualizar_contacto__c = true;   
                }
                if(trigger.oldMap.get(temp.id).Tipo_documento__c != temp.Tipo_documento__c){
                    idContactos.add(temp.Contacto__c);  
                    idDocumentos.add(temp.id);
                }
                System.debug('actualizarcontacto'+temp.Actualizar_contacto__c+'estado'+temp.Estado_actual_documento__c);
            }
            if(idContactos.size()>0){
                Map<Id, List <SST_Gestion_documentos__c>> contactos = new Map<Id, List <SST_Gestion_documentos__c>>();
                List <SST_Gestion_documentos__c> documentosContactos = [select id, contacto__c, contacto__r.name, contacto__r.recordTypeId, Tipo_documento__c from SST_Gestion_documentos__c where contacto__c in: idContactos and contacto__r.recordTypeId in: idsRecordTypeContactos and id not in: idDocumentos];
                if(documentosContactos.size()>0){
                    for(Id idTemp : idContactos){
                        List <SST_Gestion_documentos__c> docsPorContacto = new List <SST_Gestion_documentos__c>();
                        for(SST_Gestion_documentos__c docTemp : documentosContactos){
                            if(idTemp == docTemp.contacto__c){
                                docsPorContacto.add(docTemp);
                            }
                        }
                        contactos.put(idTemp,docsPorContacto);
                    }
                }
                for(SST_Gestion_documentos__c nuevoRegistro : Trigger.new){
                    List <SST_Gestion_documentos__c> docsContacto = contactos.get(nuevoRegistro.Contacto__c);                    
                    if(trigger.oldMap.get(nuevoRegistro.id).Tipo_documento__c != nuevoRegistro.Tipo_documento__c){                        
                        if(docsContacto <> null && docsContacto.size()>0 && 
                           (docsContacto.get(0).contacto__r.RecordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.CONTRATISTA).getRecordTypeId()
                            || docsContacto.get(0).contacto__r.RecordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.PROVEEDOR).getRecordTypeId())){ 
                                for(SST_Gestion_documentos__c temp : docsContacto){
                                    if(nuevoRegistro.Tipo_documento__c.equals(temp.Tipo_documento__c)){
                                        nuevoRegistro.adderror('El contacto '+docsContacto.get(0).contacto__r.name+' ya tiene registrado un documento de tipo: '+listaDocumentos.get(nuevoRegistro.Tipo_documento__c)+'; proceda a actualizar el registro existente.');
                                    } 
                                }
                            } 
                    }
                } 
            }
        }    
    }
    //Después de insertar un registro, se valida si se debe activar o inactivar el contacto para el cual se registró el documento
    if(trigger.isAfter){
        mapaContactos = new map<Id,Contact>();
        List <SST_Gestion_documentos__c> registros = new List <SST_Gestion_documentos__c>();
        if(trigger.isDelete){
            registros = trigger.old;
            for(SST_Gestion_documentos__c temp : trigger.old){
                idContactosDocumentos.add(temp.Contacto__c);
            } 
        } else {
            registros = trigger.new;
            for(SST_Gestion_documentos__c temp : trigger.new){
                System.debug('actualizarcontacto'+temp.Actualizar_contacto__c+'estado'+temp.Estado_actual_documento__c);
                if(temp.Actualizar_contacto__c){
                    idContactosDocumentos.add(temp.Contacto__c);
                }
            }
        }
        if(idContactosDocumentos.size()>0){  
            Map<Id, List <SST_Gestion_documentos__c>> contactos = new Map<Id, List <SST_Gestion_documentos__c>>();
            List <SST_Gestion_documentos__c> listaDocs = [select id, name, contacto__c, contacto__r.name, contacto__r.recordTypeId, Tipo_documento__c, Estado_actual_documento__c from SST_Gestion_documentos__c where contacto__c in: idContactosDocumentos and contacto__r.recordTypeId in: idsRecordTypeContactos];
            if(listaDocs.size()>0){
                for(Id idTemp : idContactosDocumentos){
                    List <SST_Gestion_documentos__c> docsPorContacto = new List <SST_Gestion_documentos__c>();
                    for(SST_Gestion_documentos__c docTemp : listaDocs){
                        if(idTemp == docTemp.contacto__c){
                            docsPorContacto.add(docTemp);
                        }
                    }
                    contactos.put(idTemp,docsPorContacto);
                }
            }
            for(SST_Gestion_documentos__c registro : registros){
                Contact contacto = new Contact();
                contacto.id = registro.Contacto__c;
                String documentosContacto = '';
                if(contactos.size()>0 && contactos.get(registro.contacto__c) <> null && contactos.get(registro.contacto__c).size()>0){
                    Integer countDocs = 0;
                    Double promedio = 0;
                    contacto.sst_IsActive__c = 'true';
                    contacto.SST_Gestionar_documentos__c = false;
                    contacto.SST_Notificar_link__c = false;
                    for(SST_Gestion_documentos__c docTemp : listaDocs){
                        if(docTemp.Contacto__c == registro.Contacto__c){
                            countDocs++;
                            documentosContacto = documentosContacto+docTemp.Tipo_documento__c+';';
                            if(docTemp.Estado_actual_documento__c.equals(SST_Constantes.VIGENTE)){
                                promedio = promedio + 100;
                            } else {
                                contacto.sst_IsActive__c = 'false';
                            }   
                        }
                    }
                    promedio = promedio / countDocs;
                    Decimal calificacion = Decimal.valueOf(promedio).setScale(2);
                    if(calificacion <65){
                        contacto.SST_Calificacion__c = SST_Constantes.NO_APROBADO;
                        contacto.SST_Interpretacion_calificacion__c = calificacion+SST_Constantes.INTERPRETACION_NO_APROBADO;
                    } else if (calificacion >= 65 && calificacion < 90){
                        contacto.SST_Calificacion__c = SST_Constantes.CONDICIONAL;
                        contacto.SST_Interpretacion_calificacion__c = calificacion+SST_Constantes.INTERPRETACION_CONDICIONAL;
                    } else {
                        contacto.SST_Calificacion__c = SST_Constantes.APROBADO;
                        contacto.SST_Interpretacion_calificacion__c = calificacion+SST_Constantes.INTERPRETACION_APROBADO;
                    }
                    if(documentosContacto.endsWith(';')){
                        documentosContacto = documentosContacto.removeEnd(';');   
                    }
                    System.debug('for registros actualizarcontacto'+contacto.sst_IsActive__c);
                } else {
                    contacto.SST_Calificacion__c = SST_Constantes.APROBADO;
                    contacto.SST_Interpretacion_calificacion__c = SST_Constantes.CONSTANTE_PORCENTAJE+SST_Constantes.INTERPRETACION_APROBADO;
                    contacto.sst_Documentacion_contacto__c = '';
                    contacto.sst_IsActive__c = 'true';
                }
                contacto.SST_Actualizar_documentacion__c = true;
                contacto.sst_Documentacion_contacto__c = documentosContacto;
                contacto.SST_Modificado_desde_trigger__c = true;
                mapaContactos.put(contacto.id, contacto);                 
            }
            if(mapaContactos.size()>0){
                database.update(mapaContactos.values()); 
            }
        }
    }    
}