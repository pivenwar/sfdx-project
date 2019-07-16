/*Trigger para hacer pública la tarea y hacer validaciones sobre el objeto Tarea luego de la inserción y actualización
* @Marcela Taborda
* @version 3.0
* @date 19/12/2018
*/
trigger SST_taskTrigger on Task (before insert, after insert, after update) {
    
    //Al insertar una tarea, se setea a true el campo IsVisibleInSelfService para hacerla pública y que los usuarios de comunidad puedan verla y editarla
    if(trigger.isBefore){
        if(trigger.isInsert){
            for(Task nuevoRegistro : Trigger.new){
                nuevoRegistro.IsVisibleInSelfService = true;
            }
        }
    }
    if(trigger.isAfter){
        List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> mailsListCorreos = new List<Messaging.SingleEmailMessage>();
        ID idFuncionario = Schema.SObjectType.contact.getRecordTypeInfosByName().get(SST_Constantes.FUNCIONARIO).getRecordTypeId();
        String nit = '';
        List <Id> idTareas = new List <Id>();
        Id whatIdTask = null;
        Boolean enviarCorreo = false;
        String cadena = '';
        List<List<sObject>> searchList = new List<List<sObject>>();
        Map<id,Datetime> idContactos = new Map<id,Datetime>();
        Boolean esActoCondicion = false;
        Boolean esComite = false;
        Boolean esSeguimiento = false;
        Map<Id, Contact> mapaContactos = new Map<Id, Contact>();
        Account cuenta = new Account();
        List<String> correosSedes = new List<String>();
        List<String> correosAdicionales = new List<String>();
        Boolean actualizarActo = false;
        String mailPropietario = '';
        SST_Acto_condicion_insegura__c actoModificar = new SST_Acto_condicion_insegura__c();
        for(Task nuevoRegistro : Trigger.new){
            mailPropietario = nuevoRegistro.OwnerId;
            idTareas.add(nuevoRegistro.id);
            whatIdTask = nuevoRegistro.whatId;
            if(!nuevoRegistro.Subject.contains('Asociación a tarea en SST') && !nuevoRegistro.Subject.contains('Asociación a Evento en SST')){
                enviarCorreo = true; 
            }
            if(nuevoRegistro.Subject.equals('Correo electrónico: Examen ocupacional')){
                enviarCorreo = false; 
            } 
        }
        if(enviarCorreo){
            for(taskWhoRelation t : [select id, relationId, TaskId, createdDate from taskWhoRelation where taskId in: idTareas]){
                idContactos.put(t.relationId,t.CreatedDate);
            }
            mailPropietario = [select email from user where id =: mailPropietario].email;
            //Se realizan consultas y validaciones sobre los contactos que se asocian en el momento de la creación o modificación de la tarea.
            for(Contact temp : [select id, name, sst_empresa__c, recordTypeId, email, sst_estado__c, sst_area_trabajo__c, sst_area_trabajo__r.name from contact where id in:  idContactos.keySet()]){
                mapaContactos.put(temp.id,temp);
                nit = temp.sst_empresa__c;
            }
            cadena = [SELECT relation.name FROM TaskRelation where relationId =: whatIdTask and IsWhat =: true limit 1].relation.name;
            searchList = SST_Utilitarios.busquedaSosl(cadena); 
            if(searchList[0].size()>0){
                esComite = true;
                if(((SST_Comites__c[])searchList[0])[0].Aplica_todas_sedes__c){
                    correosSedes = SST_Utilitarios.returnMailList('comite-todas-'+((SST_Comites__c[])searchList[0])[0].empresa__c);    
                } else {
                    correosSedes = SST_Utilitarios.returnMailList('comite-'+whatIdTask);   
                }
            }
            else if(searchList[1].size()>0){
                esSeguimiento = true;
                correosSedes = SST_Utilitarios.returnMailList('seguimiento-'+whatIdTask);
            }
            else if(searchList[7].size()>0){
                esActoCondicion = true;
                actoModificar = [select id, fecha_traslado__c, plan_accion__c, Responsable_solucion__c from SST_Acto_condicion_insegura__c where id =: whatIdTask];
            }
            if(!String.isEmpty(nit)){
                cuenta = SST_Constantes.consultarDatosEmpresa(nit);   
            }
            
            //Si el contacto ya estaba asociado previamente a la tarea, no se vuelve a realizar la validación sobre este
            for(Task nuevoRegistro : Trigger.new){ 
                String responsables = 'Tarea - ' + nuevoRegistro.Subject + ': ';
                List<id> idEnviados = new List<Id>();
                String nombreRegistro = '';
                String descripcion = 'Tarea - ';
                for(Id key : mapaContactos.keySet()){
                    contact contacto = mapaContactos.get(key);
                    //Al asociar contactos de cualquier tipo a una tarea, se valida que estén en estado Activo, en caso contrario no permite asociarlos
                    if(contacto.sst_estado__c == SST_Constantes.INACTIVO && contacto.recordTypeId == idFuncionario){
                        nuevoRegistro.addError('El funcionario '+contacto.name+' se encuentra inactivo.  Sólo puede asociar funcionarios activos a la tarea.');
                    }
                    
                    //Al asociar contactos de cualquier tipo a una tarea, se valida que sean de tipo de registro Funcionarios únicamente
                    else if(contacto.recordTypeId <> idFuncionario){
                        if(!nuevoRegistro.Subject.contains('Asociación a tarea en SST')){
                            nuevoRegistro.addError('El contacto '+contacto.name+' no es un funcionario.  Sólo puede asociar funcionarios activos a la tarea.');   
                        }
                    } 
                    
                    //Si los contactos asociados son funcionarios activos, se realiza la consulta para obtener los datos del objeto relacionado
                    //sobre el cual se está creando la tarea, para enviar el email de notificación de la misma
                    else{
                        if(searchList[0].size()>0){
                            SST_Comites__c[] searchComites = (SST_Comites__c[])searchList[0];
                            if(nuevoRegistro.ActivityDate < searchComites[0].fecha_inicio__c || nuevoRegistro.ActivityDate > searchComites[0].fecha_fin__c){
                                nuevoRegistro.addError('La fecha de vencimiento de la tarea debe estar dentro de las fechas de vigencia del comité, desde: '+String.valueOf(searchComites[0].fecha_inicio__c)+' hasta '+String.valueOf(searchComites[0].fecha_fin__c));
                            } else {
                                nombreRegistro = 'Comité: '+searchComites[0].Nombre_Comite__c;   
                            }
                        } 
                        //Se valida si la fecha de vencimiento de la tarea se encuentra dentro del rango de fechas del seguimiento o comité sobre el cual se crea
                        else if(searchList[1].size()>0) {
                            sst_seguimiento__c[] searchSeguimiento = (sst_seguimiento__c[])searchList[1];
                            if(nuevoRegistro.ActivityDate < searchSeguimiento[0].fecha_inicial__c || nuevoRegistro.ActivityDate > searchSeguimiento[0].fecha_final__c){
                                nuevoRegistro.addError('La fecha de vencimiento de la tarea debe estar dentro de las fechas de inicio y fin del seguimiento, desde: '+String.valueOf(searchSeguimiento[0].fecha_inicial__c)+' hasta '+String.valueOf(searchSeguimiento[0].fecha_final__c));
                            } else {
                                nombreRegistro = 'Tipo de seguimiento: '+searchSeguimiento[0].recordType.name+' - nombre: '+searchSeguimiento[0].name;   
                            }
                        } 
                        else if(searchList[2].size()>0){
                            sst_normatividad__c[] searchNormatividad = (sst_normatividad__c[])searchList[2]; 
                            nombreRegistro = 'Normatividad: '+searchNormatividad[0].name;
                        } else if(searchList[3].size()>0){
                            sst_estandar_minimo__c[] searchEstandar = (sst_estandar_minimo__c[])searchList[3]; 
                            nombreRegistro = 'Estándar mínimo: '+searchEstandar[0].Estandar__c;
                        } else if(searchList[4].size()>0){
                            SST_Status_Implementacion_1072__c[] searchEstatus = (SST_Status_Implementacion_1072__c[])searchList[4];
                            nombreRegistro = 'Ítem estatus 1072: '+searchEstatus[0].Descripcion__c;
                        } else if(searchList[5].size()>0){
                            //Al pasar a Super Polo, comentar las líneas descomentar las dos siguientes lineas y comentar las siguientes otras dos
                            //sst_peligro_SP__c[] searchPeligro = (sst_peligro_SP__c[])searchList[5];
                            //nombreRegistro = 'Peligro: '+searchPeligro[0].peligro__c+' - número de registro: '+searchPeligro[0].name ;
                            sst_peligro__c[] searchPeligro = (sst_peligro__c[])searchList[5];
                            nombreRegistro = 'Peligro: '+searchPeligro[0].Clasificacion_peligro__c+' - número de registro: '+searchPeligro[0].name ;
                        } else if(searchList[6].size()>0){
                            SST_Registro_de_Novedades__c[] searchNovedad = (SST_Registro_de_Novedades__c[])searchList[6];
                            nombreRegistro = 'Novedad de tipo: '+searchNovedad[0].recordType.name+' - funcionario: '+searchNovedad[0].Funcionario__r.name+' - fecha novedad: '+String.valueOf(searchNovedad[0].fecha_inicial__c);
                        } else if(searchList[7].size()>0){
                            SST_Acto_condicion_insegura__c[] searchActoCondicion = (SST_Acto_condicion_insegura__c[])searchList[7];
                            String c = searchActoCondicion[0].Evento__c;
                            nombreRegistro = 'Tipo de reporte: '+c.replace('_', ' ')+' - identificador del registro: '+searchActoCondicion[0].Identificador__c+' - funcionario quien reporta: '+searchActoCondicion[0].Informador__c+' - fecha de reporte: '+String.valueOf(searchActoCondicion[0].Fecha_reporte__c);
                        } else if(searchList[8].size()>0){
                            SST_Indicador__c[] searchIndicador = (SST_Indicador__c[])searchList[8];
                            nombreRegistro = 'Identificador Indicador: '+searchIndicador[0].name+' - Nombre Indicador: '+searchIndicador[0].Nombre_Indicador__c+' - fecha inicial: '+String.valueOf(searchIndicador[0].fecha_inicial__c)+' - fecha final: '+String.valueOf(searchIndicador[0].fecha_final__c);
                        } else if(searchList[9].size()>0){
                            SST_Seguimiento_ELC__c[] searchSeguimientoELC = (SST_Seguimiento_ELC__c[])searchList[9];
                            nombreRegistro = 'Identificador Seguimiento de ELC: '+searchSeguimientoELC[0].name+' - Funcionario: '+searchSeguimientoELC[0].Funcionario__r.name+' - origen: '+searchSeguimientoELC[0].origen__c+' - fecha del diagnóstico: '+String.valueOf(searchSeguimientoELC[0].Fecha_dx__c);
                        }
                        //Se llena una lista con los email de los contactos asociados así:
                        //Si es una nueva tarea o se modifica la fecha de vencimiento de una tarea creada, se asocian los email de todos los contactos a la lista.
                        //Si se asocian nuevas personas a una tarea ya creada, sólo se envía correo a los nuevos contactos
                        if((!String.isEmpty(contacto.email) || !String.isBlank(contacto.email))){
                            if(trigger.isInsert 
                               || (trigger.isUpdate && trigger.oldMap.get(nuevoRegistro.id).ActivityDate == nuevoRegistro.ActivityDate && idContactos.get(contacto.id) >= nuevoRegistro.LastModifiedDate)
                               || (trigger.isUpdate && trigger.oldMap.get(nuevoRegistro.id).ActivityDate <> nuevoRegistro.ActivityDate)){
                                   idEnviados.add(contacto.id);
                               } 
                        }
                        //Se concatena en un string el nombre y área de trabajo de los funcionarios asociados a la tarea
                        if(idContactos.get(contacto.id) >= nuevoRegistro.LastModifiedDate){
                            responsables = responsables + contacto.name+' - área '+contacto.sst_area_trabajo__r.name+'; ';
                            actualizarActo = true;
                        }
                    }
                }
                /*si hay valor en el correo adicional*/
                if(nuevoRegistro.SST_Correo_adicional__c != null){
                    if(trigger.isInsert|| trigger.oldMap.get(nuevoRegistro.id).ActivityDate <> nuevoRegistro.ActivityDate ||trigger.oldMap.get(nuevoRegistro.id).SST_Correo_adicional__c==null){
                        correosAdicionales = nuevoRegistro.SST_Correo_adicional__c.split(';');
                    }else{
                        if(trigger.oldMap.get(nuevoRegistro.id).ActivityDate == nuevoRegistro.ActivityDate){
                            List<String> correosAdicionalesNuevos = nuevoRegistro.SST_Correo_adicional__c.split(';');
                            List<String> correosAdicionalesAntiguos = trigger.oldMap.get(nuevoRegistro.id).SST_Correo_adicional__c.split(';');
                            for(String correoNuevo:correosAdicionalesNuevos){
                                if(!correosAdicionalesAntiguos.contains(correoNuevo))
                                    correosAdicionales.add(correoNuevo);
                            }
                        }
                    }
                }	
                
                
                //Si la tarea se creó sobre un acto o condición insegura, se crea una instancia de dicho objeto
                //y se actualiza con los datos obtenidos de la tarea creada
                if(esActoCondicion){ 
                    responsables = responsables.removeEnd('; ');  
                    if(trigger.isInsert){
                        //Se  obtiene la descipción de la nueva tarea
                        descripcion = descripcion + nuevoRegistro.Subject+': '+nuevoRegistro.Description;
                        if(String.isEmpty(actoModificar.Plan_accion__c)){
                            actoModificar.Plan_accion__c = descripcion;    
                        } else {
                            actoModificar.Plan_accion__c = actoModificar.Plan_accion__c+' / '+descripcion;   
                        }
                        if(String.isEmpty(actoModificar.Responsable_solucion__c)){
                            actoModificar.Responsable_solucion__c = responsables;
                        } else {
                            actoModificar.Responsable_solucion__c = actoModificar.Responsable_solucion__c+' / '+responsables;
                        }
                    } 
                    else if(trigger.isUpdate){
                        if(actualizarActo){
                            actoModificar.Responsable_solucion__c = actoModificar.Responsable_solucion__c+' / '+responsables;
                        }
                        //Se obtienen los nuevos valores de asunto o descripción en caso que éstos sean modificados
                        if(trigger.oldMap.get(nuevoRegistro.id).Subject <> nuevoRegistro.Subject){
                            descripcion = 'Modificación tarea - '+trigger.oldMap.get(nuevoRegistro.id).Subject+',  nuevo asunto - '+nuevoRegistro.Subject;
                            actoModificar.Plan_accion__c = actoModificar.Plan_accion__c+' / '+descripcion;   
                            actualizarActo = true;
                        }
                        if(trigger.oldMap.get(nuevoRegistro.id).Description <> nuevoRegistro.Description){
                            descripcion = 'Modificación tarea - '+trigger.oldMap.get(nuevoRegistro.id).Subject+',  nueva descripción: '+nuevoRegistro.Description;
                            actoModificar.Plan_accion__c = actoModificar.Plan_accion__c+' / '+descripcion;  
                            actualizarActo = true;
                        }
                    }
                    if(actoModificar.Fecha_traslado__c == null){
                        actoModificar.Fecha_traslado__c = Date.valueOf(nuevoRegistro.CreatedDate);
                        actualizarActo = true;
                    }
                }
                //Se llena el cuerpo del mensaje con los datos principales del objeto relacionado a la tarea
                //y se envían los correos respectivos.
                /*si se trata de una nueva tarea o una modificación de la fecha asociar a correosAdicionales todos los correos de la cadena */
                /*si es una modificación del la cadena de correos, verificar cuales se agregaron y adicionarlos a los correos adicionales*/                
                
                Messaging.SingleEmailMessage mail = SST_Utilitarios.enviarNotificacionActividades(nuevoRegistro, null, nombreRegistro, cuenta, mailPropietario, idEnviados);
                
                if(idEnviados.size()>0){ 
                    mailsList.add(mail);
                }
                if(trigger.isInsert){
                    if(mailsListCorreos.size()==0 && correosSedes.size()>0){
                        Messaging.SingleEmailMessage mailSedes = new Messaging.SingleEmailMessage();
                        mailSedes.setSubject(mail.subject);
                        mailSedes.setHtmlBody(mail.HtmlBody);
                        mailSedes.setToAddresses(correosSedes);
                        mailSedes.setSaveAsActivity(true);
                        mailsListCorreos.add(mailSedes);
                    }   
                }
                if(correosAdicionales.size()>0){
                    Messaging.SingleEmailMessage mailAdicional = new Messaging.SingleEmailMessage();
                    mailAdicional.setSubject(mail.subject);
                    mailAdicional.setHtmlBody(mail.HtmlBody);
                    mailAdicional.setToAddresses(correosAdicionales);
                    mailAdicional.setSaveAsActivity(true);
                    mailsListCorreos.add(mailAdicional);
                }
                
            }
            if(esActoCondicion){
                if(trigger.isInsert || actualizarActo){
                    update actoModificar;   
                }
            }
            if(mailsListCorreos.size()>0){
                List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsListCorreos);
            }
            if(mailsList.size()>0){
                List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsList);
                
            }
        }
    }
}