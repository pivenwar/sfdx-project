/*Clase con métodos utilitarios utilizados en más de una clase en la aplicación SST
* @version 1.0
* @date 15/04/2019
*/

public with sharing class SST_Utilitarios {
    
    //Método que retorna un singleEmailMessage para enviar la notificación a los contactos asociados a las actividades creadas en SST
    public static Messaging.SingleEmailMessage enviarNotificacionActividades(Task nuevaTarea, Event nuevoEvento, String nombreRegistro, Account cuenta, String mailPropietario, List<id> idEnviados){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage mailSedes = new Messaging.SingleEmailMessage();
        String fecha = '';
        String fechaInicio = '';
        String fechaFin = '';
        String campos = '';
        String actividad = '';
        String descripcion = '';
        String asunto = '';
        String idActividad = '';
        String fechaInicial = '';
        String fechaFinal = '';
        
        
        if(nuevaTarea <> null){
            actividad = 'tarea';
            fecha = String.valueOf(nuevaTarea.createdDate);  
            campos = '<b>Asunto: </b>'+nuevaTarea.subject+'<br />';
            campos = campos+'<b>Relacionada con: </b>'+nombreRegistro+'<br />';
            campos = campos+'<b>Prioridad: </b>'+nuevaTarea.Priority+'<br />';
            campos = campos+'<b>Tipo de acción: </b>'+nuevaTarea.SST_Tipo_Accion__c+'<br />';
            campos = campos+'<b>Fecha de vencimiento: </b>'+String.valueOf(nuevaTarea.ActivityDate)+'<br />';
            descripcion = nuevaTarea.Description;
            asunto = nuevaTarea.subject;
            idActividad = nuevaTarea.WhatId;
        } else if (nuevoEvento <> null){
            actividad = 'Evento';
            fecha = String.valueOf(nuevoEvento.createdDate);
            if(nuevoEvento.isAllDayEvent){
                fechaInicio = ''+nuevoEvento.StartDateTime;
                fechaFin = ''+nuevoEvento.EndDateTime;
                fechaFin = fechaFin.substring(0,10);
                fechaInicio = fechaInicio.substring(0,10);
                fechaInicial = nuevoEvento.StartDateTime.format('yyyyMMdd');
                fechaFinal = nuevoEvento.EndDateTime.format('yyyyMMdd');
            }else{
                fechaInicio = nuevoEvento.StartDateTime.format(SST_Constantes.FORMATO_FECHA_REPORTE);
                fechaInicio = SST_Constantes.cambiarNombreMes(fechaInicio);
                fechaFin = nuevoEvento.EndDateTime.format(SST_Constantes.FORMATO_FECHA_REPORTE);            	
                fechaFin = SST_Constantes.cambiarNombreMes(fechaFin);
                /*se le suman 5 horas a la fecha para tomar la zon horaria correcta*/
                Integer fInicial = Integer.valueOf(nuevoEvento.StartDateTime.format('hh'))+5;
                Integer fFinal = Integer.valueOf(nuevoEvento.EndDateTime.format('hh'))+5;
                fechaInicial = nuevoEvento.StartDateTime.format('yyyyMMdd')+'T'+fInicial+nuevoEvento.StartDateTime.format('mm')+'00'; 
                fechaFinal = nuevoEvento.EndDateTime.format('yyyyMMdd')+'T'+fFinal+nuevoEvento.EndDateTime.format('mm')+'00';
            }
            
            
            campos = '<b>Asunto: </b>'+nuevoEvento.subject+'<br />';
            campos = campos+'<b>Relacionada con: </b>'+nombreRegistro+'<br />';
            campos = campos+'<b>Fecha inicio: </b>'+fechaInicio+'<br />';
            campos = campos+'<b>Fecha fin: </b>'+fechaFin+'<br />';
            descripcion = nuevoEvento.Description;
            asunto = nuevoEvento.subject;
            idActividad = nuevoEvento.WhatId;
        }
        
        campos = campos+'<b>Detalle de la actividad: </b> '+descripcion+'<p>';
        if(nuevaTarea <> null){
            campos = campos+'<b>Añadir al calendario:</b>'+'<a href="http://www.google.com/calendar/event?action=TEMPLATE&dates='+String.valueOf(nuevaTarea.ActivityDate).replace('-','')+'T130000Z/'+String.valueOf(nuevaTarea.ActivityDate).replace('-','')+'T250000Z&text='+nuevaTarea.subject+'&location=&details='+nuevaTarea.Description+'"> Google Calendar™</a> <b>|</b>';
            campos = campos+'<a href="https://outlook.office.com/owa/?path=/calendar/action/compose&rru=addevent&startdt='+String.valueOf(nuevaTarea.ActivityDate).replace('-','')+'T130000&enddt='+String.valueOf(nuevaTarea.ActivityDate).replace('-','')+'T250000&subject='+nuevaTarea.subject+'&body='+nuevaTarea.Description+'&location="> Outlook® Office</a> <b>|</b>';  
            campos = campos+'<a href="https://outlook.live.com/owa/?path=/calendar/action/compose&rru=addevent&startdt='+String.valueOf(nuevaTarea.ActivityDate).replace('-','')+'T130000&enddt='+String.valueOf(nuevaTarea.ActivityDate).replace('-','')+'T250000&subject='+nuevaTarea.subject+'&body='+nuevaTarea.Description+'&location="> Outlook® Live</a> <br />';  
        }else if(nuevoEvento <> null && nuevoEvento.isAllDayEvent){
            campos = campos+'<b>Añadir al calendario:</b>'+'<a href="http://www.google.com/calendar/event?action=TEMPLATE&dates='+fechaInicial+'T130000Z/'+fechaFinal+'T250000Z&text='+nuevoEvento.subject+'&location=&details='+nuevoEvento.Description+'"> Google Calendar™</a> <b>|</b>';
            campos = campos+'<a href="https://outlook.office.com/owa/?path=/calendar/action/compose&rru=addevent&startdt='+fechaInicial+'T130000&enddt='+fechaFinal+'T250000&subject='+nuevoEvento.subject+'&body='+nuevoEvento.Description+'&location="> Outlook® Office</a> <b>|</b>';  
            campos = campos+'<a href="https://outlook.live.com/owa/?path=/calendar/action/compose&rru=addevent&startdt='+fechaInicial+'T130000&enddt='+fechaFinal+'T250000&subject='+nuevoEvento.subject+'&body='+nuevoEvento.Description+'&location="> Outlook® Live</a> <br />';  
        }else{
            campos = campos+'<b>Añadir al calendario:</b>'+'<a href="http://www.google.com/calendar/event?action=TEMPLATE&dates='+fechaInicial+'Z/'+fechaFinal+'Z&text='+nuevoEvento.subject+'&location=&details='+nuevoEvento.Description+'"> Google Calendar™</a> <b>|</b>';
            campos = campos+'<a href="https://outlook.office.com/owa/?path=/calendar/action/compose&rru=addevent&startdt='+fechaInicial+'&enddt='+fechaFinal+'&subject='+nuevoEvento.subject+'&body='+nuevoEvento.Description+'&location="> Outlook® Office</a> <b>|</b>';  
            campos = campos+'<a href="https://outlook.live.com/owa/?path=/calendar/action/compose&rru=addevent&startdt='+fechaInicial+'&enddt='+fechaFinal+'&subject='+nuevoEvento.subject+'&body='+nuevoEvento.Description+'&location="> Outlook® Live</a> <br />';  
        }
        
        mail.setSubject('Asociación a '+actividad+' en SST: '+asunto);
        String cuerpoMensajes='';
        cuerpoMensajes= '<p>Cordial saludo,</p><br /><p>El &aacute;rea de Seguridad y Salud en el trabajo';
        if(nuevoEvento <> null){
            cuerpoMensajes = cuerpoMensajes+' de la empresa '+ cuenta.name;
        }
        cuerpoMensajes= cuerpoMensajes+' se permite comunicarle que en la fecha '+fecha.substringBefore(' ')+' usted ha sido asociado a la siguiente actividad: </p><br />';
        cuerpoMensajes = cuerpoMensajes+campos+' <br /><p>Si est&aacute; recibiendo por segunda vez o m&aacute;s esta notificaci&oacute;n, es probable que se haya cambiado la fecha de inicio y/o fin de la actividad, por lo que le sugerimos realizar la verificaci&oacute;n respectiva.</p><br />';
        cuerpoMensajes = cuerpoMensajes+' <br /><p>Para obtener el detalle de la misma, puede contactar al funcionario responsable de la creaci&oacute;n en el correo '+mailPropietario+'.</p><br />';
        
        if(nuevoEvento <> null){
            cuerpoMensajes = cuerpoMensajes+'<p>Cordialmente, </p><br /><p>'+cuenta.sst_grupo_empresarial__c+'</p><br />';
        }
        
        
        mail.setHtmlBody(cuerpoMensajes);
        mail.setWhatId(idActividad);
        mail.setToAddresses(idEnviados);
        mail.setSaveAsActivity(true);
        return mail;
    }
    
    
    //Método con la consulta SOSL para buscar por name el objeto sobre el cual fue creada una tarea o evento, y retorna una lista de listas de objetos
    public static List<List<sObject>> busquedaSosl (String cadena){
        List<List<sObject>> searchList = new List<List<sObject>>();
        /*Consulta para ambientes que no fueron instalados por paquete*/
        /*searchList = [FIND : cadena IN name FIELDS RETURNING 
SST_Comites__c(Nombre_Comite__c, fecha_inicio__c, fecha_fin__c, Aplica_todas_sedes__c, Empresa__c), 
sst_seguimiento__c(name,recordType.name,tipo__c, fecha_inicial__c, fecha_final__c), 
sst_normatividad__c(name), 
sst_estandar_minimo__c(Estandar__c), 
SST_Status_Implementacion_1072__c(Descripcion__c), 
sst_peligro_SP__c(peligro__c,name), 
SST_Registro_de_Novedades__c(Fecha_Inicial__c,Funcionario__r.name, recordType.name), 
SST_acto_condicion_insegura__c(Identificador__c,Fecha_reporte__c,Informador__c,Evento__c),
SST_Indicador__c(Name, Fecha_Inicial__c, Fecha_Final__c, Nombre_Indicador__c),
SST_Seguimiento_ELC__c(Name, Funcionario__r.name, Fecha_dx__c, origen__c)];*/
        searchList = [FIND : cadena IN name FIELDS RETURNING 
                      SST_Comites__c(Nombre_Comite__c, fecha_inicio__c, fecha_fin__c, Aplica_todas_sedes__c, Empresa__c), 
                      sst_seguimiento__c(name,recordType.name,tipo__c, fecha_inicial__c, fecha_final__c), 
                      sst_normatividad__c(name), 
                      sst_estandar_minimo__c(Estandar__c), 
                      SST_Status_Implementacion_1072__c(Descripcion__c), 
                      SST_peligro__c(Clasificacion_peligro__c,name), 
                      SST_Registro_de_Novedades__c(Fecha_Inicial__c,Funcionario__r.name, recordType.name), 
                      SST_acto_condicion_insegura__c(Identificador__c,Fecha_reporte__c,Informador__c,Evento__c),
                      SST_Indicador__c(Name, Fecha_Inicial__c, Fecha_Final__c, Nombre_Indicador__c),
                      SST_Seguimiento_ELC__c(Name, Funcionario__r.name, Fecha_dx__c, origen__c)];
        /* Consulta para ambientes que fueron instalados por paquete.  Revisar si el prefijo del namespace en el ambiente destino es igual al de esta consulta
searchList = [FIND : cadena IN name FIELDS RETURNING 
SGSST__SST_Comites__c(Nombre_Comite__c, fecha_inicio__c, fecha_fin__c, Aplica_todas_sedes__c, Empresa__c), 
SGSST__sst_seguimiento__c(recordType.name, name,tipo__c, fecha_inicial__c, fecha_final__c), 
SGSST__sst_normatividad__c(name), 
SGSST__sst_estandar_minimo__c(Estandar__c), 
SGSST__SST_Status_Implementacion_1072__c(Descripcion__c), 
SGSST__SST_peligro__c(Clasificacion_peligro__c,name), 
SGSST__SST_Registro_de_Novedades__c(Fecha_Inicial__c,Funcionario__r.name, recordType.name),
SGSST__SST_acto_condicion_insegura__c(Identificador__c,Fecha_reporte__c,Informador__c,Evento__c),
SGSST__SST_Indicador__c(Name, Fecha_Inicial__c, Fecha_Final__c, Nombre_Indicador__c),
SGSST__SST_Seguimiento_ELC__c(Name, Funcionario__r.name, Fecha_dx__c, origen__c)];    
*/
        return searchList;
    }
    
    //Método que retorna una lista de emails de las sedes, dado el id de un comité o seguimiento, 
    //para enviar la notificación de tarea o evento creada sobre el comité o seguimiento recibido como id
    public static List<String> returnMailList(String whoId){ 
        List<String> mailsEnviarSet = new List<String>();
        String[] temp = whoId.split('-');
        String idRegistro = '';
        if(!temp[1].equals('todas')){
            idRegistro = temp[1];    
        }        
        if(temp[0].equals('comite')){
            if(String.isEmpty(idRegistro)){
                String empresa = temp[2];
                for(SST_Sede__c registroTemp : [SELECT Id, Name, Estado__c, email_sede__c FROM SST_Sede__c where Estado__c =: SST_Constantes.ACTIVO and empresa__c =: empresa]){
                    if(registroTemp.email_sede__c <> null){
                        mailsEnviarSet.add(registroTemp.email_sede__c);   
                    }
                } 
            } else {
                for(SST_comites__c comiteTemp : [select id, sede__r.email_sede__c from SST_comites__c where id =: idRegistro]){
                    if(comiteTemp.sede__r.email_sede__c <> null){
                        mailsEnviarSet.add(comiteTemp.sede__r.email_sede__c);   
                    }
                }  
            }
        } else if(temp[0].equals('seguimiento')){
            for(SST_seguimiento_sede__c seguimientoTemp : [select id, sede__r.email_sede__c from SST_seguimiento_sede__c where seguimiento__r.id =: idRegistro and sede__r.estado__c =: SST_Constantes.ACTIVO]){
                if(seguimientoTemp.sede__r.email_sede__c <> null){
                    mailsEnviarSet.add(seguimientoTemp.sede__r.email_sede__c);   
                }
            }
        }
        return mailsEnviarSet;
    }  
    
    
    
    //Método que actualiza la cantidad de funcionarios de la cuenta
    public static void actualizarCantidadFuncionariosCuenta (){
        if(Schema.sObjectType.Account.fields.SST_Cantidad_trabajadores__c.isUpdateable()&&
           Schema.sObjectType.Account.fields.SST_tipo_empresa__c.isUpdateable()){
               Map <Id,Integer> cuentas = new Map<Id, Integer>();
               for (AggregateResult cuenta : [SELECT COUNT(Id), AccountId FROM Contact where SST_Estado__c = 'ACTIVO' GROUP BY AccountId ]) {
                   cuentas.put((Id)cuenta.get('AccountId'),(Integer)cuenta.get('expr0'));
               }
               List <Account> cuentasActualizar = new List<Account>();
               For (Account cuenta:[SELECT Id,SST_Cantidad_trabajadores__c, SST_Nivel_Riesgo__c FROM Account where Id in: cuentas.keySet()] ){
                   cuenta.SST_Cantidad_trabajadores__c =  cuentas.get(cuenta.Id);
                   cuenta.SST_tipo_empresa__c= obtenerTipoEmpresa(cuenta);
                   cuentasActualizar.add(cuenta);  
               }
               update cuentasActualizar;
           }
        
    }
    
    /*Método que dada una cuenta identifica el tipo de empresa*/
    public static String obtenerTipoEmpresa(Account cuenta){
        if(cuenta.SST_Cantidad_trabajadores__c > 50 || cuenta.SST_Nivel_Riesgo__c == SST_Constantes.RIESGO_4 || cuenta.SST_Nivel_Riesgo__c == SST_Constantes.RIESGO_5 ){
            return SST_Constantes.EMPRESA_GRANDE;
        }else if(cuenta.SST_Cantidad_trabajadores__c >= 11 && (cuenta.SST_Cantidad_trabajadores__c <= 50 && cuenta.SST_Nivel_Riesgo__c == SST_Constantes.RIESGO_3 || cuenta.SST_Nivel_Riesgo__c == SST_Constantes.RIESGO_2 || cuenta.SST_Nivel_Riesgo__c == SST_Constantes.RIESGO_1)){
            return SST_Constantes.EMPRESA_MEDIANA;
        }else{
            return SST_Constantes.EMPRESA_PEQUENA;
        }
    }
    
     /*Método para verificar estandares minimos*/
    public static void actualizarEstandaresMinimos(List<Account> cuentas){
        List<SST_Estandar_minimo__c> listaEstandarMinimo = New List<SST_Estandar_minimo__c>();
        List<String> nit = New List<String>();
        Map<String,Account> mapaCuenta = new Map<String,Account>();
        for(Account cuenta : cuentas){
            nit.add(String.valueOf(cuenta.SST_Nit__c));
            mapaCuenta.put(String.valueOf(cuenta.SST_Nit__c),cuenta);
        }
          
       
        if(Schema.sObjectType.SST_Estandar_minimo__c.fields.Cumplimiento__c.isUpdateable() && Schema.sObjectType.SST_Estandar_minimo__c.fields.Justificacion__c.isUpdateable()){
            for(SST_Estandar_minimo__c estandarMinimo : [SELECT Id, Cumplimiento__c, Justificacion__c,Empresa__c, Tipo_empresa__c FROM SST_Estandar_minimo__c where Empresa__c in: nit ] ){                
                if( mapaCuenta.get(estandarMinimo.Empresa__c).SST_Tipo_empresa__c == estandarMinimo.Tipo_empresa__c ||(estandarMinimo.Tipo_empresa__c== SST_Constantes.EMPRESA_PEQUENA) || (mapaCuenta.get(estandarMinimo.Empresa__c).SST_Tipo_empresa__c == SST_Constantes.EMPRESA_GRANDE  && estandarMinimo.Tipo_empresa__c== SST_Constantes.EMPRESA_MEDIANA) ){
                    if(estandarMinimo.Cumplimiento__c == SST_Constantes.NO_APLICA && (estandarMinimo.Justificacion__c == null || estandarMinimo.Justificacion__c == SST_Constantes.NO_APLICA_EMPRESA)){
                        estandarMinimo.Cumplimiento__c =SST_Constantes.NO_CUMPLE;
                        estandarMinimo.Justificacion__c = null;
                    }
                } else if(mapaCuenta.get(estandarMinimo.Empresa__c).SST_Tipo_empresa__c <> estandarMinimo.Tipo_empresa__c ){
                    estandarMinimo.Justificacion__c =SST_Constantes.NO_APLICA_EMPRESA;  
                    estandarMinimo.Cumplimiento__c = SST_Constantes.NO_APLICA;  
                }
                listaEstandarMinimo.add(estandarMinimo);
            } 
            update listaEstandarMinimo;
        }
    } 
    
    /*Método que se encarga de validar los registros de novedades cuando se trata de incapacidades que llegan en bloque*/
    public static void validarRegistroNovedades(List<SST_Registro_de_Novedades__c> registroNovedades){
        Id recordTypeIncapacidades = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Incapacidades/Licencias').getRecordTypeId();		            
        for(SST_Registro_de_Novedades__c novedad : registroNovedades ){
            if(novedad.recordTypeId ==recordTypeIncapacidades ){
                for(SST_Registro_de_Novedades__c novedadComparar : registroNovedades ){
                    if(novedad<>novedadComparar && novedad.recordTypeId == recordTypeIncapacidades){
                        if(novedad.funcionario__c == novedadComparar.funcionario__c){
                            if(novedad.Fecha_Inicial__c>= novedadComparar.fecha_inicial__c && novedad.Fecha_Inicial__c<= novedadComparar.fecha_final__c){
                                novedad.addError('Ya existe una incapacidad entre esas fechas');
                            }
                        }
                    }
                }
            }
        }
       	Set<SST_Registro_de_Novedades__c> novedadesReducidas= new Set<SST_Registro_de_Novedades__c>();
        if(novedadesReducidas.size()<registroNovedades.size()){
            for(Integer i=0;i<registroNovedades.size();i++){
                SST_Registro_de_Novedades__c novedad = registroNovedades.get(i);
                for(Integer j=0;j<registroNovedades.size();j++){
                    SST_Registro_de_Novedades__c novedadComparar = registroNovedades.get(j);
                    if(novedad== novedadComparar && i<>j){
                        novedadesReducidas.add(novedad);
                    }
                    
                }
            }
            for(SST_Registro_de_Novedades__c novedad: novedadesReducidas){
                novedad.addError('Ya existe una incapacidad entre esas fechas');
            }
        }
        
    }
  
}