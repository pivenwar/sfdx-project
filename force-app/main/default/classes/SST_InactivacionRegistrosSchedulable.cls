/*
* @autor: Marcela Taborda
* @fecha: 25/10/2018
* @version: 2.0
* Clase global que verifica la fecha de vencimiento de los registro de los objetos 
* SST_Gestion_documentos__c, SST_Seguimiento__c, SST_Control_EPP__c y SST_Examen_Ocupacional__c
* ha vencido para cambiar el estado de los registros a Inactivo, inactivar los contratistas o proveedores con documentos vencidos
* y notificar a los contactos de los próximos vencimientos y la inactivación en el sistema
*/

global class SST_InactivacionRegistrosSchedulable implements Schedulable {
    //Atributo para comparar la fecha final o de vencimiento de los registros
    Date fechaActual {get;set;}
    
    //Listas para almacenar los registros de gestión de documentos consultados y que serán actualizados
    List <SST_Gestion_documentos__c> updateListGestionDocumentos {get;set;}
    List <SST_Gestion_documentos__c> documentosActualizar {get;set;}
   
    //Listas para almacenar los seguimientos consultados y que serán actualizados
    List <SST_Seguimiento__c> updateListSeguimientos {get;set;}
    List <SST_Seguimiento__c> seguimientosActualizar {get;set;}
    
    //Listas para almacenar los registros de controles EPP consultados y que serán actualizados
    List <SST_Control_EPP__c> updateListControlesEPP {get;set;}
    List <SST_Control_EPP__c> controlesEPPActualizar {get;set;}
    
    //Listas para almacenar los exámenes ocupacionales consultados y que serán actualizados
    List <SST_Examen_Ocupacional__c> updateListExamenesOcupacionales {get;set;}
    List <SST_Examen_Ocupacional__c> examenesOcupacionalesActualizar {get;set;}

	//Set de String para consultar los email de los administradores del sistema y usuarios gestor para enviar las notificaciones respectivas    
    Set<String> mailsEnviarSet {get;set;}
    
    //Mapa con los label y value de los tipos de documentos en el objeto Gestión de documentos
    Map<String,String> mapaTipoDocumentos {get;set;}
    
    //Atributo para consultar los datos de la cuenta para la firma de los correos electrónicos
    Account cuenta {get;set;}
    
    global void execute(SchedulableContext SC){
        try{
        mapaTipoDocumentos = new Map<String,String>();
 		mailsEnviarSet = new Set<String>();     

        updateListGestionDocumentos = new List <SST_Gestion_documentos__c>();
        updateListSeguimientos = new List <SST_Seguimiento__c>();
        updateListControlesEPP = new List <SST_Control_EPP__c>();
        updateListExamenesOcupacionales = new List <SST_Examen_Ocupacional__c>();
        actualizarRegistrosGestionDocumentos();
        consultarDocumentosPorVencer();
        actualizarRegistrosControlesEPP(); 
        actualizarRegistrosSeguimientos();
        actualizarRegistrosExamenesOcupacionales();  
        }catch(Exception e){
            system.debug(e.getCause()+'-'+e.getMessage()+'-'+e.getLineNumber());
        }
    }
    
    //Método para obtener los label de los tipos de documento en el objeto Gestión de documentos
    public Map<String,String> returnMapaDocumentos(){  
        mapaTipoDocumentos = new Map<String,String>();
        Schema.DescribeFieldResult campo = SST_Gestion_documentos__c.Tipo_documento__c.getDescribe();
        List<Schema.PicklistEntry> picklist = campo.getPicklistValues();        
        for( Schema.PicklistEntry pickItem : picklist){
            mapaTipoDocumentos.put(pickItem.getValue(),pickItem.getLabel());
        }
        return mapaTipoDocumentos;
    }
    
    //Método para obtener un Set de strings con los email de los usuarios admin y gestor
    public Set<String> returnMailSet(){ 
        mailsEnviarSet = new Set<String>();
        for(User usuario: SST_Constantes.returnUserList()){
            if(!String.isEmpty(usuario.email) || !String.isBlank(usuario.email)){
                String correo = 'usuario;'+usuario.id;
                mailsEnviarSet.add(correo);
            }
        }
        return mailsEnviarSet;
    }  
    
    //Método para consultar los registros de gestión de documentos vencidos en estado Activo y actualizarlos a estado Inactivo
    public void actualizarRegistrosGestionDocumentos(){
        mapaTipoDocumentos = returnMapaDocumentos();
        mailsEnviarSet = returnMailSet();
        fechaActual = system.today();
        Map<Id,SST_Gestion_documentos__c> estadoInicialContactos = new Map<Id,SST_Gestion_documentos__c>();
        Map<Id,Contact> estadoFinalContactos = new Map<Id,Contact>();
        Map <Id,String> recordsType = new  Map <Id,String>(); 
        recordsType.put(Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.CONTRATISTA).getRecordTypeId(),Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.CONTRATISTA).getName());
		recordsType.put(Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.PROVEEDOR).getRecordTypeId(),Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.PROVEEDOR).getName());
        documentosActualizar = [SELECT Id, name, Contacto__c, Contacto__r.recordTypeId, Contacto__r.name, contacto__r.sst_estado__c, Tipo_documento__c, Fecha_vencimiento__c, Estado_actual_documento__c FROM SST_Gestion_documentos__c where Fecha_vencimiento__c <: fechaActual and Estado_actual_documento__c =: SST_Constantes.VIGENTE and contacto__r.SST_retirado__c =: false];
        //Si hay documentos con fecha de vencimiento anterior a la fecha actual, se añaden a la lista para modificarles el estado
        if(documentosActualizar.size()>0){
            for(SST_Gestion_documentos__c temp : documentosActualizar){
                SST_Gestion_documentos__c registro = temp;
                registro.Estado_actual_documento__c = SST_Constantes.POR_ACTUALIZAR;
                registro.Actualizar_contacto__c = true;
                updateListGestionDocumentos.add(registro);
                if(temp.Contacto__r.recordTypeId<>null && recordsType.get(temp.Contacto__r.recordTypeId)<>null){
                    estadoInicialContactos.put(temp.Contacto__r.id,temp);   
                }
            }     
        }
        System.debug('Estado inicial contactos'+estadoInicialContactos);
         
        //Si hay registros para actualizar, se ejecuta la acción y se envía correo notificando los registros actualizados y los que no hayan podido ser actualizados
        if(updateListGestionDocumentos!= null && updateListGestionDocumentos.size()>0){
            try{
                Database.SaveResult[] results = Database.update(updateListGestionDocumentos, false);
                if (results != null && results.size()>0){
                    list <String> listaErrores = new list <String>();
                    List<Id> idContactos = new List<Id>();
                    for(Integer i=0; i<=results.size()-1; i++){
                        Database.SaveResult result =  results.get(i);
                        SST_Gestion_documentos__c registro = updateListGestionDocumentos.get(i);
                        
                        //Si el registro no pudo ser actualizado, se adiciona a la lista para notificación de registros fallidos
                        if (!result.isSuccess()){
                            String error = '<b>Tipo de registro: </b>'+'Gestión de documentos'+'<b> - Contacto: </b>'+registro.Contacto__r.name+' - <b>Número del registro: </b>'+registro.name+' - <b>Tipo de documento: </b>'+mapaTipoDocumentos.get(registro.Tipo_documento__c)+' - <b>Fecha de vencimiento: </b>'+String.valueOf(registro.Fecha_vencimiento__c);
                            listaErrores.add(error); 
                        }
                        //Si el registro se actualizó, se adiciona el id del contacto al mapa con el cual se realizará la inactivación de los contactos de tipo contratista o proveedor con documentos vencidos
                        else {
                            if(recordsType.get(registro.Contacto__r.recordTypeId)<>null){
                             	idContactos.add(registro.Contacto__r.id);   
                            }
                        }
                    }
                    System.debug('idContactos'+idContactos);
                    if(idContactos.size()>0){
                        //Se consulta el estado de los contactos de tipo proveedor o contratista luego de la inactivación de documentos, para comparar contra el estado inicial antes de la inactivación de documentos
                        list <Contact> contactosInactivos = [select id, name, email, sst_estado__c, sst_isActive__c, recordTypeId from contact where id in : idContactos];
                        for(Contact ttmp : contactosInactivos){
                            estadoFinalContactos.put(ttmp.id,ttmp);   
                        }    
                    	System.debug('estadoFinalContactos'+estadoFinalContactos);                        
                        //list <Contact> contactosAInactivar = [select id, name, email, sst_estado__c, sst_isActive__c, recordTypeId from contact where id in : idContactos.keyset()];
                        list <String> listaParaNotificacionContactos = new list <String>();
                        Set<String> mailContacto = new Set<String>();
                        for(Id Key : estadoInicialContactos.keySet()){
                            SST_Gestion_documentos__c estadoInicial = estadoInicialContactos.get(key);
                            Contact estadoFinal = estadoFinalContactos.get(key);
                            System.debug('estadoInicial'+estadoInicial);
                            System.debug('estadoFinal'+estadoFinal);
                            if(estadoInicial.contacto__r.sst_estado__c.equals(SST_Constantes.ACTIVO) && estadoFinal.sst_estado__c.equals(SST_Constantes.INACTIVO)){
                                System.debug('el estado es final es diferente al anterior');
                                String recordTemp = recordsType.get(estadoFinal.recordTypeId);
                                String textoNotificacion = '<b>Tipo de contacto: </b>'+recordTemp+'<b> - Contacto: </b>'+estadoFinal.name;
                                listaParaNotificacionContactos.add(textoNotificacion);
                                if(estadoFinal.email <> null){
                                	String correo = 'contacto;'+estadoFinal.id;
                                    mailsEnviarSet.add(correo);   
                                }
                            }
                        }
                         //Llamado al método para notificar a los administradores del sistema, usuarios Gestor y los contactos inactivados
                            EnviarNotificacionInactivacionContactos(listaParaNotificacionContactos,mailsEnviarSet); 
                    }
                    if(listaErrores.size()>0){
                        //Llamado al método para notificar a los administradores del sistema y usuarios Gestor la inactvación fallida de registros
                     	EnviarNotificacion(listaErrores, mailsEnviarSet);   
                    }
                }            
            } catch (DmlException e) {
                list <String> listaErrores = new list <String>();
                for(SST_Gestion_documentos__c registroFallido : updateListGestionDocumentos){
                    String error = '<b>Contacto: </b>'+registroFallido.Contacto__r.name+' - <b>Número del registro: </b>'+registroFallido.name+' - <b>Tipo de documento: </b>'+mapaTipoDocumentos.get(registroFallido.Tipo_documento__c)+' - <b>Fecha de vencimiento: </b>'+String.valueOf(registroFallido.Fecha_vencimiento__c);
                    listaErrores.add(error);
                }
                if(listaErrores.size()>0){
                        //Llamado al método para notificar a los administradores del sistema y usuarios Gestor la inactvación fallida de registros
                     	EnviarNotificacion(listaErrores, mailsEnviarSet);   
                    }
                system.debug('Mensaje error:'+e.getMessage());
                system.debug('Linea error:'+e.getLineNumber());
                system.debug('Causa error:'+e.getCause());
            }
        }
    }
    
    //Método para consultar los registros de gestión de documentos próximos a vencer y obtener los correos para generar a alerta a los correspondientes contratistas o proveedores
    private void consultarDocumentosPorVencer(){
        fechaActual = system.today();
        mapaTipoDocumentos = returnMapaDocumentos();
        if(cuenta<> null && cuenta.SST_periodo_notificacion__c <> null){
            //Se obtiene la parametrización de la empresa de los días del periodo de notificación, para establecer la fecha máximoa de plazo para notificación a contratistas y proveedores
            Date plazo = fechaActual.addDays(Integer.valueOf(cuenta.SST_periodo_notificacion__c));
            
            //Se consultan los documentos cuya fecha de vencimiento está entre la fecha actual y la fecha máxima de plazo para notificaciones
            List <SST_Gestion_documentos__c> documentosPorVencer = [SELECT Id, name, Contacto__c, Contacto__r.name, Contacto__r.email, Tipo_documento__c, Fecha_vencimiento__c, Estado_actual_documento__c FROM SST_Gestion_documentos__c where contacto__r.SST_retirado__c =: false and Fecha_vencimiento__c >=: fechaActual and Fecha_vencimiento__c <=: plazo order by contacto__c, Fecha_vencimiento__c DESC];       
            if(documentosPorVencer.size()>0){
                Map<Id,List <String>> datosParaMail = new Map<Id,List <String>>();
                List <String> lista = new List <String>();
                for(SST_Gestion_documentos__c temp : documentosPorVencer){
                    datosParaMail.put(temp.contacto__c,lista);
                }
                Set <Id> idsTemp = datosParaMail.keySet();
                
                //Se llenan el mapa cuya llave es el id del contacto a notificar, y la lista de documentos próximos a vencer
                for(Id key : idsTemp){
                    List<String> datos = new List<String>();
                    for(SST_Gestion_documentos__c temp : documentosPorVencer){ 
                        if(temp.contacto__c == key){
                            datos.add('<b>Tipo de documento: </b>'+mapaTipoDocumentos.get(temp.tipo_documento__c)+'<b> - Fecha de vencimiento: </b>'+String.valueOf(temp.fecha_vencimiento__c));
                        }
                    }
                    datosParaMail.put(key,datos);
                } 
                //Llamado al método para enviar la notificación a cada contratista o proveedor con la lista de documentos próximos a vencer
                EnviarNotificacionDocumentosPorVencer(datosParaMail);                 
            }
        }
    }
    
    //Método para consultar los registros de controles EPP vencidos en estado Activo y actualizarlos a estado Inactivo
    public void actualizarRegistrosControlesEPP(){
        mailsEnviarSet = returnMailSet();
        fechaActual = system.today();
        controlesEPPActualizar = [SELECT Id, Funcionario__c, Elemento_proteccion_personal__c, Elemento_proteccion_personal__r.empresa__c, Fecha_vencimiento__c, Cantidad__c, Estado__c FROM SST_Control_EPP__c where Fecha_vencimiento__c <: fechaActual and estado__c =: SST_Constantes.ACTIVO];
        //Si hay registros con fecha de vencimiento anterior a la fecha actual, se añaden a la lista para modificarles el estado
        if(controlesEPPActualizar.size()>0){
            for(SST_Control_EPP__c temp : controlesEPPActualizar){
                SST_Control_EPP__c registro = temp;
                registro.estado__c = SST_Constantes.INACTIVO;
                updateListControlesEPP.add(registro);     
            }     
        }
         
        //Si hay registros para actualizar, se ejecuta la acción y se envía correo de los registros que no hayan podido ser actualizados
        if(updateListControlesEPP!= null && updateListControlesEPP.size()>0){
            try{
                Database.SaveResult[] results = Database.update(updateListControlesEPP, false);
                
                if (results != null && results.size()>0){
                    list <String> listaErrores = new list <String>();
                    for(Integer i=0; i<=results.size()-1; i++){
                        Database.SaveResult result =  results.get(i);
                        if (!result.isSuccess()){
                            SST_Control_EPP__c registroFallido = updateListControlesEPP.get(i);
                            Map<String,String> mapaEmpresas = obtenerNombresEmpresas();
                            String error = '<b>Empresa: </b>'+mapaEmpresas.get(registroFallido.Elemento_proteccion_personal__r.empresa__c)+'<b> - Tipo de EPP: </b>'+registroFallido.Elemento_proteccion_personal__r.name+'<b> - Contacto: </b>'+registroFallido.Funcionario__r.name+' - <b>Número del registro: </b>'+registroFallido.name+' - <b>Cantidad: </b>'+registroFallido.Cantidad__c+' - <b>Fecha de vigencia: </b>'+String.valueOf(registroFallido.Fecha_vencimiento__c);
                            listaErrores.add(error); 
                        }
                    }
                    if(listaErrores.size()>0){
                     	EnviarNotificacion(listaErrores, mailsEnviarSet);   
                    }
                }             
            } catch (DmlException e) {
                list <String> listaErrores = new list <String>();
                Map<String,String> mapaEmpresas = obtenerNombresEmpresas();
                for(SST_Control_EPP__c registroFallido : updateListControlesEPP){
					String error = '<b>Empresa: </b>'+mapaEmpresas.get(registroFallido.Elemento_proteccion_personal__r.empresa__c)+'<b> - Tipo de EPP: </b>'+registroFallido.Elemento_proteccion_personal__r.name+'<b> - Contacto: </b>'+registroFallido.Funcionario__r.name+' - <b>Tipo de EPP: </b>'+registroFallido.Elemento_proteccion_personal__r.name+'<b> - Contacto: </b>'+registroFallido.Funcionario__r.name+' - <b>Número del registro: </b>'+registroFallido.name+' - <b>Cantidad: </b>'+registroFallido.Cantidad__c+' - <b>Fecha de vigencia: </b>'+String.valueOf(registroFallido.Fecha_vencimiento__c);
                    listaErrores.add(error);
                }
                EnviarNotificacion(listaErrores,mailsEnviarSet);   
                system.debug('Mensaje error:'+e.getMessage());
                system.debug('Linea error:'+e.getLineNumber());
                system.debug('Causa error:'+e.getCause());
            }
        }
        
    }
    
    //Método para consultar los seguimientos vencidos en estado Activo y actualizarlos a estado Inactivo
    public void actualizarRegistrosSeguimientos(){
        fechaActual = system.today();
        mailsEnviarSet = returnMailSet();
        seguimientosActualizar = [SELECT Id, RecordTypeId, empresa__c, Tipo__c, Fecha_final__c, Estado__c, Fecha_inicial__c, IsDeleted, Name FROM SST_Seguimiento__c where Fecha_final__c <: fechaActual and estado__c =: SST_Constantes.ACTIVO];
        //Si hay seguimientos con fecha de vencimiento anterior a la fecha actual, se añaden a la lista para modificarles el estado
        if(seguimientosActualizar.size()>0){
            for(SST_Seguimiento__c temp : seguimientosActualizar){
                SST_Seguimiento__c registro = temp;
                registro.estado__c = SST_Constantes.INACTIVO;
                updateListSeguimientos.add(registro);     
            }     
        }
        
        //Si hay registros para actualizar, se ejecuta la acción y se envía correo de los registros que no hayan podido ser actualizados
        if(updateListSeguimientos!= null && updateListSeguimientos.size()>0){
            try{
                Database.SaveResult[] results = Database.update(updateListSeguimientos, false);
                
                if (results != null && results.size()>0){
                    Map <Id,RecordType> recordsType = new  Map <Id,RecordType>([select id, name, sobjectType from RecordType where sobjectType = 'SST_Seguimiento__c']); 
                    list <String> listaErrores = new list <String>();
                    for(Integer i=0; i<=results.size()-1; i++){
                        Database.SaveResult result =  results.get(i);
                        if (!result.isSuccess()){
                            SST_Seguimiento__c registroFallido = updateListSeguimientos.get(i);
                            RecordType recordTemp = recordsType.get(registroFallido.RecordTypeId );
                            Map<String,String> mapaEmpresas = obtenerNombresEmpresas();
                            String error = '<b>Empresa: </b>'+mapaEmpresas.get(registroFallido.empresa__c)+'<b> - Clase de seguimiento: </b>'+recordTemp.name+'<b> - Nombre del seguimiento: </b>'+registroFallido.name+'<b> - Tipo: </b>'+registroFallido.tipo__c+' - <b>Fecha inicial: </b>'+String.valueOf(registroFallido.Fecha_inicial__c)+' - <b>Fecha final: </b>'+String.valueOf(registroFallido.Fecha_final__c);
                            listaErrores.add(error); 
                        }
                    } 
                    if(listaErrores.size()>0){
                     	EnviarNotificacion(listaErrores, mailsEnviarSet);   
                    }
                }            
            } catch (DmlException e) {
                list <String> listaErrores = new list <String>();
                Map <Id,RecordType> recordsType = new  Map <Id,RecordType>([select id, name, sobjectType from RecordType where sobjectType = 'SST_Seguimiento__c']); 
                Map<String,String> mapaEmpresas = obtenerNombresEmpresas();
                for(SST_Seguimiento__c registroFallido : updateListSeguimientos){
                    RecordType recordTemp = recordsType.get(registroFallido.RecordTypeId );
					String error = '<b>Empresa: </b>'+mapaEmpresas.get(registroFallido.empresa__c)+'<b> - Clase de seguimiento: </b>'+recordTemp.name+'<b> - Nombre del seguimiento: </b>'+registroFallido.name+'<b> - Tipo: </b>'+registroFallido.tipo__c+' - <b>Fecha inicial: </b>'+String.valueOf(registroFallido.Fecha_inicial__c)+' - <b>Fecha final: </b>'+String.valueOf(registroFallido.Fecha_final__c);
                    listaErrores.add(error);
                }
                EnviarNotificacion(listaErrores,mailsEnviarSet);   
                system.debug('Mensaje error:'+e.getMessage());
                system.debug('Linea error:'+e.getLineNumber());
                system.debug('Causa error:'+e.getCause());
            }
        }
        
    }
   
    //Método para consultar los registros de exámenes ocupacionales vencidos en estado Activo y actualizarlos a estado Inactivo
    public void actualizarRegistrosExamenesOcupacionales(){
        fechaActual = system.today();
        mailsEnviarSet = returnMailSet();
        examenesOcupacionalesActualizar = [SELECT Id, name, Tipo_examen__c, Funcionario_examen__c, Funcionario_examen__r.name, Funcionario_examen__r.sst_empresa__c, proximo_examen__c, Estado__c FROM SST_Examen_Ocupacional__c where estado__c =: SST_Constantes.ACTIVO and proximo_examen__c <> null and proximo_examen__c <: fechaActual];
        //Si hay registros con fecha del próximo examen anterior a la fecha actual, se añaden a la lista para modificarles el estado
        if(examenesOcupacionalesActualizar.size()>0){
            for(SST_Examen_Ocupacional__c temp : examenesOcupacionalesActualizar){
                SST_Examen_Ocupacional__c registro = temp;
                registro.estado__c = SST_Constantes.INACTIVO;
                updateListExamenesOcupacionales.add(registro);     
            }     
        }
        
        //Si hay registros para actualizar, se ejecuta la acción y se envía correo de los registros que no hayan podido ser actualizados
        if(updateListExamenesOcupacionales!= null && updateListExamenesOcupacionales.size()>0){
            try{
                Database.SaveResult[] results = Database.update(updateListExamenesOcupacionales, false);
                
                if (results != null && results.size()>0){
                    list <String> listaErrores = new list <String>();
                    for(Integer i=0; i<=results.size()-1; i++){
                        Database.SaveResult result =  results.get(i);
                        if (!result.isSuccess()){
                            SST_Examen_Ocupacional__c registroFallido = updateListExamenesOcupacionales.get(i);
                            Map<String,String> mapaEmpresas = obtenerNombresEmpresas();
                            String error = '<b>Empresa: </b>'+mapaEmpresas.get(registroFallido.Funcionario_examen__r.sst_empresa__c)+'<b> - Tipo de examen: </b>'+registroFallido.tipo_examen__c+'<b> - Contacto: </b>'+registroFallido.Funcionario_examen__r.name+' - <b>Número del registro: </b>'+registroFallido.name+' - <b>Fecha de próximo examen: </b>'+String.valueOf(registroFallido.proximo_examen__c);
                            listaErrores.add(error); 
                        }
                    }
                    if(listaErrores.size()>0){
                     	EnviarNotificacion(listaErrores, mailsEnviarSet);   
                    }
                }            
            } catch (DmlException e) {
                list <String> listaErrores = new list <String>();
                Map<String,String> mapaEmpresas = obtenerNombresEmpresas();
                for(SST_Examen_Ocupacional__c registroFallido : updateListExamenesOcupacionales){
					String error = '<b>Empresa: </b>'+mapaEmpresas.get(registroFallido.Funcionario_examen__r.sst_empresa__c)+'<b> - Tipo de examen: </b>'+registroFallido.tipo_examen__c+'<b> - Contacto: </b>'+registroFallido.Funcionario_examen__r.name+' - <b>Número del registro: </b>'+registroFallido.name+' - <b>Fecha de próximo examen: </b>'+String.valueOf(registroFallido.proximo_examen__c);
                    listaErrores.add(error);
                }
                EnviarNotificacion(listaErrores,mailsEnviarSet);   
                system.debug('Mensaje error:'+e.getMessage());
                system.debug('Linea error:'+e.getLineNumber());
                system.debug('Causa error:'+e.getCause());
            }
        }
        
    }
    
    //Método para enviar correo de notificación informando sobre los registros que no pudieron ser actualizados
    public void EnviarNotificacion(List <String> registrosNoActualizados, Set<String> mailsEnviarSet){
        try {
            if(registrosNoActualizados.size()!=0){
                List<String> emailAddressList = new List<String>();
                for(String mail : mailsEnviarSet){  
                    List<String> tipoMail = mail.split(';');
                    emailAddressList.add(tipoMail.get(1));
                }
                List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emailAddressList);
                mail.setSubject('Actualización fallida de registros');
                mail.setHtmlBody(mensajeCuerpoCorreo(registrosNoActualizados));
                mailsList.add(mail);
                List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsList);
            }
            
        } catch(Exception e) {
            System.debug('---------------- Error occurred in testEmail() : ' + e.getStackTraceString());
        }
    }
    
    //Método que retorna el contenido del correo de notificación de los registros que no pudieron ser actualizados
    private String mensajeCuerpoCorreo(List <String> registrosNoActualizados){
        String campos = '<br />';
        for(String registros: registrosNoActualizados){
            campos = campos+registros+'<br /><br />';
        }
        String cuerpoMensajes='';
        cuerpoMensajes= '<p>Cordial saludo,</p><br /><p>El &aacute;rea de seguridad y salud en el trabajo se permite informar que al realizar la revisi&oacute;n el d&iacute;a de hoy para actualizar el estado de los documentos, seguimientos, exámenes ocupacionales y controles de EPP cuya fecha de vencimiento o fin ha expirado, no ha sido posible inactivar los siguientes registros: </p>';
        cuerpoMensajes = cuerpoMensajes+campos+' <p>Ma&ntilde;ana en la ma&ntilde;ana se ejecutar&aacute; una nueva revisi&oacute;n y actualizaci&oacute;n, sin embargo se sugiere cambiar el estado de dichos registros manualmente desde la aplicaci&oacute;n el d&iacute;a de hoy. </p><br />';
        cuerpoMensajes = cuerpoMensajes+'<p>Cordialmente, </p><br /><p>'+cuenta.name+'</p><br />';
        return cuerpoMensajes;
    }   
    
    //Método para enviar correo de notificación informando los contactos que fueron inactivados
    public void EnviarNotificacionInactivacionContactos(List <String> listaParaNotificacionContactos, Set<String> mailsEnviarSet){
        try {
            if(listaParaNotificacionContactos.size()>0){
                List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
                for(String temp : mailsEnviarSet){ 
                    List<String> tipoMail = temp.split(';');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(tipoMail.get(1));  
                    mail.saveAsActivity = false;
                    mail.setHtmlBody(mensajeCuerpoCorreoInactivacionContactos(listaParaNotificacionContactos,tipoMail));
                    if(tipoMail.get(0).equals('usuario')){    
                        mail.setSubject('Inactivación de contratistas y proveedores');
                    } else {
                        mail.setTreatBodiesAsTemplate(true);
                        mail.setSubject('Notificación de inactivación como contratista o proveedor de '+cuenta.SST_grupo_empresarial__c);
                    }
                    mailsList.add(mail);
                }
                List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsList);
            }
        } catch(Exception e) {
            System.debug('---------------- Error occurred in testEmail() : ' + e.getStackTraceString());
        }
    }
    
    //Método que retorna el contenido del correo de notificación de inactivación de contactos
    private String mensajeCuerpoCorreoInactivacionContactos(List <String> listaParaNotificacionContactos, List<String> tipo){
        List<String> mesesCerrados = new List<String>();
        String campos = '<br />';
        for(String registros: listaParaNotificacionContactos){
            campos = campos+registros+'<br /><br />';
        }
        String cuerpoMensajes = '';
        //Si el correo pertenece a un usuario como administrador del sistema o usuario gestor, se envía la relación de todos los contactos que fueron inactivados
        if(tipo.get(0).equals('usuario')){
            cuerpoMensajes = cuerpoMensajes+'<p>Cordial saludo,</p><br /><p>El &aacute;rea de Seguridad y Salud en el trabajo se permite informarle que al realizar la revisi&oacute;n el d&iacute;a de hoy para actualizar el estado de los documentos de contratistas y proveedores cuya fecha de vencimiento ha expirado, ha realizado la siguiente inactivaci&oacute;n de contactos en el sistema: </p>';
            cuerpoMensajes = cuerpoMensajes+campos+' <p>Recuerde que la entrada a las instalaciones de la empresa se restringe para los proveedores y contratistas inactivos. </p><br />';
            cuerpoMensajes = cuerpoMensajes+' <p>Cada uno de los contactos relacionados ha sido notificado a fin que ingrese al módulo de gestión de documentos y realice la actualización respectiva. </p><br />';
            cuerpoMensajes = cuerpoMensajes+'<p>Cordialmente, </p><br /><p>'+cuenta.SST_grupo_empresarial__c+'</p><br />';   
        } 
        //Si el correo pertenece a un contratista o proveedor, se le envía mensaje con el código de acceso y el link del site donde puede actualizar la documentación
        else {
            String link = SST_Constantes.LINK_PORTAL_SST+'/sstgestiondocumental';
            cuerpoMensajes = cuerpoMensajes+'<p>Cordial saludo,</p><br /><p>El &aacute;rea de Seguridad y Salud en el trabajo de '+cuenta.SST_grupo_empresarial__c+' se permite informarle que uno o más documentos presentados por usted como contratista o proveedor ha vencido, lo que ha generado su inactivación en nuestros sistemas. </p>';
            cuerpoMensajes = cuerpoMensajes+' <p>Recuerde que esta inactivación podría restringir su acceso a las instalaciones de la empresa.</p><br />';
            cuerpoMensajes = cuerpoMensajes+' <p>Le invitamos a actualizar la documentación vencida en el link que se relaciona al final de este correo, ingresando con su número de identificación y el código de acceso '+tipo.get(1)+' a fin de que pueda ser activado nuevamente. </p><br />';
            cuerpoMensajes = cuerpoMensajes+' <p>Si ya realizó la actualización recientemente, haga caso omiso de este correo.</p><br />';
            cuerpoMensajes = cuerpoMensajes+'<a href="'+link+'">'+link+'</a><br />';
            cuerpoMensajes = cuerpoMensajes+'<p>Cordialmente, </p><br /><p>'+cuenta.SST_grupo_empresarial__c+'</p><br />';   
        }
        return cuerpoMensajes;
    }   
    
    //Método para enviar correo de notificación informando a cada contratista y proveedor los documentos próximos a vencer
    public void EnviarNotificacionDocumentosPorVencer(Map<Id,List <String>> datosParaMail){
        
        try {
            if(datosParaMail.size()>0){
                List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
                List<String> emailAddressList = new List<String>();
                for(String key : datosParaMail.keySet()){  
                    List <String> contenido = datosParaMail.get(key);
                    String codigo = key;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(key);
                    mail.saveAsActivity = false;
                    mail.setSubject('Notificación documentos próximos a vencer ante '+cuenta.SST_grupo_empresarial__c);
                    mail.setHtmlBody(mensajeCuerpoCorreoDocumentosPorVencer(contenido, codigo));
                    mail.setTreatBodiesAsTemplate(true);
                    mailsList.add(mail);
                }  
                List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsList);
            }            
        } catch(Exception e) {
            System.debug('---------------- Error occurred in testEmail() : ' + e.getStackTraceString());
        }
    }
    
    //Método que retorna el contenido del correo de notificación a un contratista o proveedor de sus documentos próximos a vencer, el código de acceso y el link del site para actualizar la documentación
    private String mensajeCuerpoCorreoDocumentosPorVencer(List <String> contenido, String codigo){
        String link = SST_Constantes.LINK_PORTAL_SST+'/sstgestiondocumental';
        String campos = '<br />';
        for(String registros: contenido){
            campos = campos+registros+'<br /><br />';
        }
        
        String cuerpoMensajes= '<p>Cordial saludo,</p><br /><p>El &aacute;rea de Seguridad y Salud en el trabajo de la empresa '+cuenta.name+' se permite notificarle que los siguientes documentos suministrados por usted como contratista o proveedor, se encuentran pr&oacute;ximos a vencer: </p>';
        cuerpoMensajes = cuerpoMensajes+campos+' <p>Le invitamos a actualizar dichos documentos antes de su vencimiento en el link que se relaciona al final de este correo, ingresando con su número de identificación y el código de acceso: '+codigo+'</p>';
        cuerpoMensajes = cuerpoMensajes+' <p>Recuerde que con uno o más documentos vencidos será inactivado en nuestro sistema, lo que podría restringir su acceso a las instalaciones de la empresa. </p><br />';
        cuerpoMensajes = cuerpoMensajes+' <p>Si ya actualizó recientemente los documentos relacionados, haga caso omiso a este correo. </p><br />';
        cuerpoMensajes = cuerpoMensajes+'<a href="'+link+'">'+link+'</a><br /><br />';
        cuerpoMensajes = cuerpoMensajes+'<p>Cordialmente, </p><br /><p>'+cuenta.name+'</p><br />';
        return cuerpoMensajes;
    }   
    
    //Método que retorna una cuenta con el nombre del grupo empresarial y el periodo de notificación establecido para todo el grupo empresarial de la multiempresa
    private Account obtenerDatosGrupoEmpresarial(){
        Account cuentaPrincipal = new Account();
        List <Account >cuentas = [select id, SST_grupo_empresarial__c,name,sst_periodo_notificacion__c from account where type =:SST_Constantes.CLIENTE and sst_estado__c =: SST_Constantes.ACTIVO];
        if(cuentas.size() == 0){
            cuentaPrincipal = null;
        } else {
            cuentaPrincipal = cuentas.get(0);
        }
        return cuentaPrincipal;
    }
    
    //Método que retorna un mapa cuya llave es el nit y el value es el nombre de cada empresa del grupo empresarial
    private Map<String,String> obtenerNombresEmpresas(){
        Map<String, String> nombreEmpresas = new Map<String, String>();
        for(Account temp : [select id, name, sst_nit__c from account where type =:SST_Constantes.CLIENTE and sst_estado__c =: SST_Constantes.ACTIVO]){
            nombreEmpresas.put(String.valueOf(temp.sst_nit__c), temp.name);
        }
        return nombreEmpresas;
    }
}