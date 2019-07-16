/*Trigger para asignar como propietario del contacto al Administrador del sistema, y asignar la cuenta antes de la inserción,
* y para desasociar un contacto de las tareas, eventos, comités, normatividades y cuentas donde esté asociado, al ser inactivado
* @Angelica Toro: se realiza actualización de peligros cuando la sede o el area son modificadas o se esta creando un funcionario
* @Marcela Taborda
* @date 29/10/2018
*/
trigger SST_ContactTrigger on Contact (before insert, before update, after insert, after update) {
    
    if(trigger.isBefore){
        /*Bloque que obtiene la lista de municipios de salesforce*/
        Schema.DescribeFieldResult campo = Contact.SST_municipio__c.getDescribe();
        List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
        Map<String,String> listaMunicipios = new Map<String,String>();
        for( Schema.PicklistEntry pickItem : picklist){
            listaMunicipios.put(pickItem.getValue(),pickItem.getLabel());
        } 
        /*Fin Bloque que obtiene la lista de municipios de salesforce*/
        
        if(trigger.isInsert){
            /*Se consulta el administrador para asignarlo como owner id*/
            Id idAdmin = SST_Constantes.returnAdministrador().id;
            String nitEmpresaAutenticada = SST_Constantes.getEmpresaAutenticada();
            Integer cantidadEmpresas = SST_Constantes.getCantidadEmpresas();
            Set<Decimal> empresas = new Set<Decimal>();
            empresas.add(Decimal.valueOf(nitEmpresaAutenticada));
            List<String> identificacionTemp = new List<String>();
            Map<String,Contact> mapaIdentificacion = new Map<String,Contact>();
            for(Contact contacto :Trigger.New){
                identificacionTemp.add(contacto.sst_identificacion__c);
                if(contacto.sst_empresa__c <> null && !contacto.sst_empresa__c.equals('')){
                    empresas.add(Decimal.valueOf(contacto.sst_empresa__c));
                }
                
            }
            
            Map<Decimal,Id> cuentas = new Map<Decimal,Id>();
            
            for(Account cuenta : [Select id,name,SST_nit__c FROM Account WHERE SST_nit__c in: empresas]){
                cuentas.put(cuenta.SST_nit__c,cuenta.id);
            }            
            
            for(Contact contactoExistente : [select id, name, sst_identificacion__c, recordtypeId, sst_empresa__c from Contact where sst_identificacion__c in : identificacionTemp]){
                mapaIdentificacion.put(contactoExistente.sst_identificacion__c, contactoExistente);
            }
            for(Contact nuevoRegistro : Trigger.New){
                String nit = '';
                if(nuevoRegistro.sst_empresa__c <> null && !nuevoRegistro.sst_empresa__c.equals('')){
                    nit = nuevoRegistro.sst_empresa__c;
                } else {
                    nit = nitEmpresaAutenticada;
                    nuevoRegistro.sst_empresa__c = nitEmpresaAutenticada;
                }
                
                Id idCuenta = cuentas.get(Decimal.valueOf(nit));
                
                if(idCuenta == null){
                    nuevoRegistro.adderror('No se han configurado los datos de la empresa.  Debe parametrizarla para crear contactos');
                } else {
                    if(!String.isEmpty(nuevoRegistro.sst_identificacion__c) ){
                        if(!nuevoRegistro.sst_identificacion__c.isAlphanumeric()){
                            nuevoRegistro.adderror('El número de identificación no debe contener caracteres diferentes a letras o números'); 
                        }
                        else {
                            nuevoRegistro.AccountId = idCuenta;
                            nuevoRegistro.OwnerId = idAdmin;
                            
                            /*se valida y actualiza los municipios del contacto*/
                            SST_Constantes.validarMunicipiosContacto(nuevoRegistro, listaMunicipios);
                            //Si se va a crear un funcionario, se valida si ya está registrado previamente en la misma empresa
                            if(nuevoRegistro.recordTypeId <> null && nuevoRegistro.recordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.FUNCIONARIO).getRecordTypeId()){
                                if(mapaIdentificacion.get(nuevoRegistro.sst_identificacion__c) <> null && mapaIdentificacion.get(nuevoRegistro.sst_identificacion__c).recordTypeId== nuevoRegistro.recordTypeId && mapaIdentificacion.get(nuevoRegistro.sst_identificacion__c).sst_empresa__c == nuevoRegistro.sst_empresa__c){
                                    nuevoRegistro.adderror('El funcionario ya se encuentra actualmente registrado en la empresa.'); 
                                } else {
                                    nuevoRegistro.SST_codigo_externo__c = nuevoRegistro.sst_identificacion__c;
                                    if(cantidadEmpresas > 1){
                                        nuevoRegistro.SST_codigo_externo__c = nuevoRegistro.SST_codigo_externo__c+'-'+nuevoRegistro.sst_empresa__c;
                                    } 
                                }
                            }
                            
                            /*si se trata de un contratista o proveedor*/
                            if(nuevoRegistro.recordTypeId <> null && nuevoRegistro.recordTypeId <> Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.FUNCIONARIO).getRecordTypeId()){
                                //Se valida si el proveedor ya está registrado previamente en cualquiera de las empresas del grupo empresarial
                                if(mapaIdentificacion.get(nuevoRegistro.sst_identificacion__c) <> null && mapaIdentificacion.get(nuevoRegistro.sst_identificacion__c).recordtypeId == nuevoRegistro.recordTypeId){
                                    nuevoRegistro.adderror('El contacto ya se encuentra actualmente registrado en la empresa.'); 
                                }
                                
                                /*si el contratista no requiere documentación no se debe notificar, y queda activo una vez se cree*/
                                if(String.isEmpty(nuevoRegistro.SST_Documentacion_contacto__c)){
                                    nuevoRegistro.SST_Notificar_link__c = false;
                                    nuevoRegistro.SST_Gestionar_documentos__c = true;
                                    nuevoRegistro.SST_Calificacion__c = SST_Constantes.APROBADO;
                                    nuevoRegistro.SST_Interpretacion_calificacion__c = SST_Constantes.CONSTANTE_PORCENTAJE+SST_Constantes.INTERPRETACION_APROBADO;
                                    nuevoRegistro.SST_isActive__c = 'true';
                                } else {
                                    /*Si el cont. o prov. si requiere documentación se activa link para enviar notificación y no queda activo hasta no realizar la gestión*/
                                    nuevoRegistro.SST_Notificar_link__c = true;
                                    nuevoRegistro.SST_Gestionar_documentos__c = false;
                                    nuevoRegistro.SST_Calificacion__c = SST_Constantes.NO_APROBADO;
                                    nuevoRegistro.SST_Interpretacion_calificacion__c = SST_Constantes.CONSTANTE_CERO+SST_Constantes.INTERPRETACION_NO_APROBADO;     
                                    nuevoRegistro.SST_isActive__c = 'false';
                                }
                            }
                        }
                    } 
                    else if(nuevoRegistro.recordTypeId <> null && String.isEmpty(nuevoRegistro.sst_identificacion__c)){
                        nuevoRegistro.adderror('Debe indicar el número de identificación del contacto'); 
                    }
                }
            }
        }
        if(trigger.isUpdate){
            Integer cantidadEmpresas = SST_Constantes.getCantidadEmpresas();
            /*se consultan los usuarios administrador y gestor de la aplicación*/
            Map<Id,user> mapaUsuarios = new Map<Id,user>();
            for(User usuarioTemp : SST_Constantes.returnUserList()){
                mapaUsuarios.put(usuarioTemp.id, usuarioTemp);
            }
            Map<Id,String> contactosProveedores = new Map<Id,String>();
            List<String> identificacionTemp = new List<String>();
            Map<String,Contact> mapaIdentificacion = new Map<String,Contact>();
            for(Contact contacto :Trigger.New){
                if(trigger.OldMap.get(contacto.id).sst_identificacion__c <> contacto.sst_identificacion__c || trigger.OldMap.get(contacto.id).sst_empresa__c <> contacto.sst_empresa__c){
                    identificacionTemp.add(contacto.sst_identificacion__c);   
                    
                }
                
            }
            if(identificacionTemp.size()>0){
                for( Contact contactoExistente : [select id, name, sst_identificacion__c, recordtypeId, sst_empresa__c from Contact where sst_identificacion__c in : identificacionTemp]){
                    mapaIdentificacion.put(contactoExistente.sst_identificacion__c, contactoExistente);
                }    
            }
            
            for(Contact nuevoRegistro : Trigger.New){
                if(trigger.OldMap.get(nuevoRegistro.id).sst_fecha_retiro__c == null && nuevoRegistro.sst_fecha_retiro__c <> null){
                    nuevoRegistro.SST_isActive__c = 'false';
                }else if(trigger.OldMap.get(nuevoRegistro.id).sst_fecha_Ingreso__c < nuevoRegistro.sst_fecha_ingreso__c
                         && nuevoRegistro.sst_fecha_ingreso__c>trigger.OldMap.get(nuevoRegistro.id).sst_fecha_retiro__c){
                             nuevoRegistro.sst_isActive__c = 'true';
                             Date fechaRetiro = null; 
                             nuevoRegistro.sst_fecha_retiro__c = fechaRetiro;
                         }
                if(trigger.OldMap.get(nuevoRegistro.id).sst_identificacion__c <> nuevoRegistro.sst_identificacion__c ){
                    if(!nuevoRegistro.sst_identificacion__c.isAlphanumeric()){
                        nuevoRegistro.adderror('El número de identificación no debe contener caracteres diferentes a letras o números'); 
                    } else {
                        //Si se va a crear un funcionario, se valida si ya está registrado previamente en la misma empresa
                        if(nuevoRegistro.recordTypeId <> null && nuevoRegistro.recordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.FUNCIONARIO).getRecordTypeId()){
                            if(mapaIdentificacion.get(nuevoRegistro.sst_identificacion__c) <> null && mapaIdentificacion.get(nuevoRegistro.sst_identificacion__c).sst_empresa__c == nuevoRegistro.sst_empresa__c){
                                nuevoRegistro.adderror('Ya existe un funcionario con el mismo número de identificación registrado en esta empresa.'); 
                            } else {
                                nuevoRegistro.SST_codigo_externo__c = nuevoRegistro.sst_identificacion__c;
                                if(cantidadEmpresas > 1){
                                    nuevoRegistro.SST_codigo_externo__c = nuevoRegistro.SST_codigo_externo__c+'-'+nuevoRegistro.sst_empresa__c;
                                }
                            }
                        }
                        //Si se va a crear un contacto diferente a funcionario, se valida si ya está registrado previamente en cualquier empresa del grupo empresarial
                        else if(nuevoRegistro.recordTypeId <> null && nuevoRegistro.recordTypeId <> Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.FUNCIONARIO).getRecordTypeId()){
                            if(mapaIdentificacion.get(nuevoRegistro.sst_identificacion__c) <> null){
                                nuevoRegistro.adderror('Ya existe un contacto con el mismo número de identificación registrado.'); 
                            }
                        }
                    }
                }
                /*se valida y actualiza los municipios del contacto*/
                SST_Constantes.validarMunicipiosContacto(nuevoRegistro, listaMunicipios);
                
                //Se valida si el contacto se va a retirar
                if(!trigger.OldMap.get(nuevoRegistro.id).sst_retirado__c && nuevoRegistro.SST_Retirado__c){
                    nuevoRegistro.SST_isActive__c = 'false';
                    //si es un proveedor, se añade al mapa de proveedores retirados para retirar sus contactos asociados
                    if(nuevoRegistro.recordTypeId <> null && nuevoRegistro.recordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.PROVEEDOR).getRecordTypeId()){
                        contactosProveedores.put(nuevoRegistro.Id,SST_Constantes.RETIRAR);   
                    }
                }
                
                //Se valida si el contacto se va a inactivar
                if(trigger.OldMap.get(nuevoRegistro.id).SST_isActive__c!= null && trigger.OldMap.get(nuevoRegistro.id).SST_isActive__c.equals('true') && nuevoRegistro.SST_isActive__c.equals('false')){
                    //si es un proveedor, se añade al mapa de proveedores inactivos para inactivar sus contactos asociados
                    if(nuevoRegistro.recordTypeId <> null && nuevoRegistro.recordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.PROVEEDOR).getRecordTypeId()){
                        contactosProveedores.put(nuevoRegistro.Id,SST_Constantes.INACTIVAR);   
                    }
                }
                
                //Se valida si el contacto se va a activar
                else if(trigger.OldMap.get(nuevoRegistro.id).SST_isActive__c!= null && trigger.OldMap.get(nuevoRegistro.id).SST_isActive__c.equals('false') && nuevoRegistro.SST_isActive__c.equals('true')){
                    //si es un proveedor, se añade a la lista de proveedores activos para activar sus contactos asociados
                    if(nuevoRegistro.recordTypeId <> null && nuevoRegistro.recordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.PROVEEDOR).getRecordTypeId()){
                        contactosProveedores.put(nuevoRegistro.Id,SST_Constantes.ACTIVAR);   
                    }
                }
                /*
if(trigger.oldMap.get(nuevoRegistro.id).SST_Gestionar_documentos__c <> nuevoRegistro.SST_Gestionar_documentos__c || trigger.oldMap.get(nuevoRegistro.id).SST_Notificar_link__c <> nuevoRegistro.SST_Notificar_link__c){
if(mapaUsuarios.get(userInfo.getUserId())<>null && nuevoRegistro.SST_Gestionar_documentos__c && nuevoRegistro.SST_Notificar_link__c){
nuevoRegistro.adderror('Si el contacto tiene toda la documentación vigente, deje el campo "Documentación actualizada" seleccionado, y el campo "Enviar correo de notificación" sin seleccionar.  Si debe actualizar uno o más documentos, realice la selección en forma inversa y el contacto será notificado para que realice la actualización de su documentación'); 
}                    
}*/
            }
            
            if(contactosProveedores.size()>0){
                SST_Constantes.actualizarContactosProveedor(contactosProveedores);    
            }
        }
        
    }
    
    if (trigger.isAfter){
        boolean actualizarCantidadFuncionarios= false;
        
        Set<String> empresasPeligros = new Set<String>();
        Map<String, Id> emailTemplateMap = new Map<String, Id>{};
            List <String> nombresTemplate = new List <String>();
        nombresTemplate.add(SST_Constantes.TEMPLATE_CONTACTO);
        nombresTemplate.add(SST_Constantes.TEMPLATE_SST);
        nombresTemplate.add(SST_Constantes.TEMPLATE_ENCUESTA_SOCIODEMOGRAFICA);
        nombresTemplate.add(SST_Constantes.TEMPLATE_ACTIVACION_PROVEEDOR);
        for (EmailTemplate item : [ select Id, Name FROM EmailTemplate where Name IN: nombresTemplate]){
            emailTemplateMap.put(item.Name, item.id);
        }
        if(trigger.isInsert){
            ID idProveedor = Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.PROVEEDOR).getRecordTypeId();
            ID idContratista = Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.CONTRATISTA).getRecordTypeId();
            ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.FUNCIONARIO).getRecordTypeId();
            List <String> empresas = new List <String>();
            Map<String,String> mapaEncuestas = new Map<String,String>();
            for(Contact nuevoRegistro : trigger.new){
                empresas.add(nuevoRegistro.sst_empresa__c);
                if(nuevoRegistro.recordTypeId <> null && nuevoRegistro.recordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.FUNCIONARIO).getRecordTypeId()){
                    actualizarCantidadFuncionarios = true;
                }
            }
            
            for (SST_Encuesta_sociodemografica__c encuesta : [select id, empresa__c from SST_Encuesta_sociodemografica__c where vigente__c =: true and estado__c =: SST_Constantes.ACTIVO and empresa__c in: empresas]){
                mapaEncuestas.put(encuesta.empresa__c,encuesta.empresa__c); 
            }
            List <SST_gestion_documentos__c> documentosContactos = new List <SST_gestion_documentos__c>();
            Map<id, List<String>> mapaContactos =  new Map<id, List<String>>();
            List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> mailsListEncuesta = new List<Messaging.SingleEmailMessage>();
            for(Contact nuevoRegistro : trigger.new){
                if(nuevoRegistro.SST_Notificar_link__c == true && nuevoRegistro.SST_Gestionar_documentos__c == false){
                    if((nuevoRegistro.RecordTypeId <> null && (nuevoRegistro.recordTypeId == idProveedor || nuevoRegistro.recordTypeId == idContratista)) 
                       || (nuevoRegistro.RecordType.name <> null && (nuevoRegistro.RecordType.name.equals(SST_Constantes.CONTRATISTA) || nuevoRegistro.RecordType.name.equals(SST_Constantes.PROVEEDOR)))){
                           List<String> documentos = nuevoRegistro.sst_Documentacion_contacto__c.split(';');
                           mapaContactos.put(nuevoRegistro.id, documentos);
                           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                           mail.setTargetObjectId(nuevoRegistro.id);
                           mail.setTemplateID(emailTemplateMap.get(SST_Constantes.TEMPLATE_CONTACTO));
                           mail.saveAsActivity = false;
                           mailsList.add(mail);
                       }    
                    
                    else if((nuevoRegistro.RecordTypeId <> null && nuevoRegistro.recordTypeId == idFuncionario) 
                            || (nuevoRegistro.RecordType.name <> null && nuevoRegistro.RecordType.name.equals(SST_Constantes.FUNCIONARIO))){
                                empresasPeligros.add(nuevoRegistro.SST_empresa__c);
                                if(mapaEncuestas.size()>0 && mapaEncuestas.get(nuevoRegistro.sst_empresa__c) <> null){
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    mail.setTargetObjectId(nuevoRegistro.id);
                                    mail.setTemplateID(emailTemplateMap.get(SST_Constantes.TEMPLATE_ENCUESTA_SOCIODEMOGRAFICA));
                                    mail.saveAsActivity = false;
                                    mailsList.add(mail);
                                }
                            }
                }
            }
            if(mapaContactos.size()>0){
                for(id key : mapaContactos.keyset()){
                    List <String> docs = mapaContactos.get(key);
                    for(String doc : docs){
                        SST_gestion_documentos__c temp = new SST_gestion_documentos__c();
                        temp.Contacto__c = key;
                        temp.Tipo_documento__c = doc;
                        temp.Actualizar_contacto__c = false;
                        documentosContactos.add(temp);
                    }
                }
                insert documentosContactos;
            }
            if(mailsList.size()>0){
                List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsList);
            }
        }
        if(trigger.isUpdate){
            List<Messaging.SingleEmailMessage> mailsListEncuesta = new List<Messaging.SingleEmailMessage>();
            Map <Id, contact> mapaContactos = new Map <Id, contact>();
            Set<String> mailsEnviarSet = new Set<String>();
            List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
            for(User usuario: SST_Constantes.returnUserList()){
                mailsEnviarSet.add(usuario.id);
            }
            List<String> nits = new List<String>();
            String nitGrupoEmpresarial = '';
            Map<String,Boolean> mapaEncuestas = new map<String,Boolean>();
            for(Contact registro : trigger.new){
                nitGrupoEmpresarial = registro.sst_empresa__c;
                if(registro.recordTypeId <> null && registro.recordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.FUNCIONARIO).getRecordTypeId()){
                    if(trigger.oldMap.get(registro.id).SST_Notificar_link__c == false && registro.SST_Notificar_link__c == true){
                        nits.add(trigger.OldMap.get(registro.id).sst_empresa__c);
                    }                    
                }
            }
            String grupoEmpresarial = SST_Constantes.consultarDatosEmpresa(nitGrupoEmpresarial).SST_grupo_empresarial__c;
            if(nits.size()>0){
                for(SST_Encuesta_sociodemografica__c temp : [select id, empresa__c from SST_Encuesta_sociodemografica__c where vigente__c =: true and estado__c =: SST_Constantes.ACTIVO and empresa__c in: nits]){
                    mapaEncuestas.put(temp.empresa__c, true);                
                }  
            }  
            for(Contact registro : trigger.new){
                if((trigger.OldMap.get(registro.id).sst_sede__c <> null && trigger.OldMap.get(registro.id).sst_sede__c <> registro.sst_sede__c) || 
                   (trigger.OldMap.get(registro.id).sst_cargo__c <> null &&trigger.OldMap.get(registro.id).sst_cargo__c <> registro.sst_cargo__c)){
                       empresasPeligros.add(registro.SST_empresa__c);
                   }
                if(trigger.oldMap.get(registro.id).sst_fecha_retiro__c == null && registro.sst_fecha_retiro__c <> null){
                    mapaContactos.put(registro.id,registro);
                }
                System.debug(trigger.OldMap.get(registro.id).sst_Estado__c);
                System.debug(registro.sst_Estado__c);
                if(trigger.OldMap.get(registro.id).sst_Estado__c <> registro.sst_Estado__c && registro.recordTypeId <> null && registro.recordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.FUNCIONARIO).getRecordTypeId()){
                    actualizarCantidadFuncionarios = true;
                }
                if(registro.recordTypeId <> null && (registro.recordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.CONTRATISTA).getRecordTypeId() || registro.recordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.PROVEEDOR).getRecordTypeId())){
                    if(registro.SST_Actualizar_documentacion__c ){
                        if(registro.SST_Gestionar_documentos__c == true && registro.SST_Notificar_link__c == false){
                            List<String> emailAddressList = new List<String>();
                            for(String mail : mailsEnviarSet){  
                                emailAddressList.add(mail);    
                            }
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setToAddresses(emailAddressList);
                            mail.setTemplateID(emailTemplateMap.get(SST_Constantes.TEMPLATE_SST));
                            mail.setTargetObjectId(registro.id);  
                            mail.setTreatTargetObjectAsRecipient(false);
                            mail.saveAsActivity = false;
                            mailsList.add(mail);
                        }
                        else if(registro.SST_Notificar_link__c == true){
                            if(registro.sst_estado__c.equals(SST_Constantes.ACTIVO) && registro.SST_Gestionar_documentos__c == true){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                List<String> emailAddressListContactos = new List<String>();
                                emailAddressListContactos.add(registro.id);
                                mail.setToAddresses(emailAddressListContactos);
                                mail.setTemplateID(emailTemplateMap.get(SST_Constantes.TEMPLATE_ACTIVACION_PROVEEDOR));
                                mail.saveAsActivity = false;
                                mail.setTargetObjectId(registro.id);  
                                mailsList.add(mail);
                            } else if (registro.sst_estado__c.equals(SST_Constantes.INACTIVO) && registro.SST_Gestionar_documentos__c == false){
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                List<String> emailAddressListContactos = new List<String>();
                                emailAddressListContactos.add(registro.id);
                                mail.setToAddresses(emailAddressListContactos);
                                mail.setTemplateID(emailTemplateMap.get(SST_Constantes.TEMPLATE_CONTACTO));
                                mail.saveAsActivity = false;
                                mail.setTargetObjectId(registro.id);  
                                mailsList.add(mail);
                            } 
                        }
                    } 
                }
                if(registro.recordTypeId <> null && registro.recordTypeId == Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.FUNCIONARIO).getRecordTypeId()){
                    if(trigger.oldMap.get(registro.id).SST_Notificar_link__c == false && registro.SST_Notificar_link__c == true){
                        if(mapaEncuestas.get(trigger.OldMap.get(registro.id).sst_empresa__c)){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTargetObjectId(registro.id);
                            mail.setTemplateID(emailTemplateMap.get(SST_Constantes.TEMPLATE_ENCUESTA_SOCIODEMOGRAFICA));
                            mail.saveAsActivity = false;
                            mailsList.add(mail);
                        }
                    }
                }
            }
            /*Si algún contactos se va a retirar se envía correos*/
            if(mapaContactos.size()>0){
                SST_Constantes.enviarAlertasInactivacionContactos(mapaContactos,grupoEmpresarial);
            }   
            if(mailsList.size()>0){
                
                List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsList);
            }
        }
        if(!empresasPeligros.isEmpty()){
            
            SST_Constantes.actualizarExpuestosPeligros(null,empresasPeligros);
        }
        if(actualizarCantidadFuncionarios){
            SST_Utilitarios.actualizarCantidadFuncionariosCuenta();
        } 
        
        /*se verifica si el campo con la foto de nómina viene con valor cuando esu n contacto nuevo o si se modificó*/
        List<ContentVersion> fotos = new List<ContentVersion>();
        for(Contact registroNuevo : trigger.new){
            if(trigger.isInsert && registroNuevo.SST_foto_nomina__c<>null || (trigger.isUpdate && registroNuevo.SST_foto_nomina__c <> trigger.oldMap.get(registroNuevo.id).SST_foto_nomina__c)){
                ContentVersion foto = new ContentVersion();
                foto.versionData = EncodingUtil.base64Decode(registroNuevo.SST_foto_nomina__c);
                foto.pathOnClient =SST_Constantes.NOMBRE_FOTO_PERFIL;
                foto.FirstPublishLocationId = registroNuevo.id;
                foto.IsMajorVersion = false;
                fotos.add(foto);
            }
        }
        /*se almacenan los registros de la foto*/
        insert(fotos);
        Map<ID,String> rutaFotoContacto = new Map<ID,String>();
        
        /*se recorre los registros de las fotos para añadirselos a los contactos*/
        for(ContentVersion foto : fotos){
            for(Contact registroNuevo : trigger.new){
                if(foto.FirstPublishLocationId == registroNuevo.id){
                    rutaFotoContacto.put(registroNuevo.id,SST_Constantes.RUTA_FOTO+ foto.Id);
                }
            }
        }
        /*se añade la ruta de la foto de los registros al contacto y se modifica*/
        List<Contact> contactosModificar = new List<Contact>();
        for(Contact contacto : [SELECT id FROM Contact WHERE id in :rutaFotoContacto.keySet()]){
            contacto.SST_ruta_foto__c = rutaFotoContacto.get(contacto.id);
            contactosModificar.add(contacto);
        }
        update(contactosModificar);
        
    }
    
}