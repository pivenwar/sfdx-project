/*Trigger para validaciones sobre el objeto Comunicacion luego de la inserción y actualización
* @Marcela Taborda
* @date 09/10/2018
*/
trigger SST_ComunicacionTrigger on SST_Comunicacion__c (before insert, after insert, after update, before delete) {
    if(trigger.isAfter){
        List <String> tipoReporte = SST_Constantes.ACTO_Y_CONDICION_INSEGURA;
        if(trigger.isInsert){
            List<ID> informadores = new List<ID>();
            SST_Acto_condicion_insegura__c actoCondicion = new SST_Acto_condicion_insegura__c();
            SST_Comunicacion__c registroComunicacion = new SST_Comunicacion__c();
            for(SST_Comunicacion__c nuevoRegistro : trigger.new){
                informadores.add(nuevoRegistro.Informador__c);
            }
            Map<ID,Contact> contactos = new Map<ID,Contact>();
            for(Contact contacto : [select id, sst_empresa__c,name from contact where id in :informadores]){
                contactos.put(contacto.id,contacto);
            }
            List<User> mailList = SST_Constantes.returnUserList();  
            for(SST_Comunicacion__c nuevoRegistro : trigger.new){
                registroComunicacion = nuevoRegistro;
                }
                //Se obtiene el nombre de la persona que realiza el reporte desde el módulo de comunicaciones
                Contact contacto = contactos.get(registroComunicacion.Informador__c);
                String nombre = contacto.name;
                //Al crear un registro en el objeto Comunicación y seleccionar el tipo Acto inseguro o Condición insegura,
                //se crea un registro en el objeto Acto_condicion_insegura
                if(!String.isEmpty(registroComunicacion.Tipo_reporte__c) && 
                   (registroComunicacion.Tipo_reporte__c.equals(tipoReporte[0]) || 
                    registroComunicacion.Tipo_reporte__c.equals(tipoReporte[1]))){
                        actoCondicion = new SST_Acto_condicion_insegura__c();
                        //Se envía al nuevo registro la fecha de reporte, el identificador del registro en el módulo de
                        //comunicaciones, el tipo de evento, el nombre del informador y la descripción
                        actoCondicion.Informador__c = nombre;
                        actoCondicion.Fecha_reporte__c = Date.valueOf(registroComunicacion.createdDate-5);
                        actoCondicion.Descripcion__c = registroComunicacion.Descripcion__c;
                        actoCondicion.identificador_comunicacion__c = registroComunicacion.id;
                        actoCondicion.Evento__c = registroComunicacion.Tipo_reporte__c;
                        actoCondicion.empresa__c = registroComunicacion.empresa__c;
                        //Se inserta el nuevo registro de Acto_condicion_insegura
                        Insert actoCondicion;
                    }
                String texto = 'Identificador del registro: '+registroComunicacion.name+' - funcionario quien reporta: '+nombre+' - fecha de reporte: '+String.valueOf(registroComunicacion.createdDate)+' - descripción del evento: '+registroComunicacion.Descripcion__c;
                Set<String> mailsEnviarSet = new Set<String>();
                //Se llena una lista con los email de los contactos asociados al evento
                for(User usuario : mailList){
                    if(!String.isEmpty(usuario.email) || !String.isBlank(usuario.email)){
                        mailsEnviarSet.add(usuario.email);
                    }   
                }
                if(mailsEnviarSet.size()!=0){ 
                    Account cuenta = SST_Constantes.consultarDatosEmpresa(contacto.sst_empresa__c);
                    List<String> emailAddressList = new List<String>();
                    emailAddressList.addAll(mailsEnviarSet);
                    String fecha = registroComunicacion.CreatedDate.format(SST_Constantes.FORMATO_FECHA_REPORTE);
                    fecha = SST_Constantes.cambiarNombreMes(fecha);
                    String campos = '';
                    campos = '<b>Identificador del registro: </b>'+registroComunicacion.name+'<br />';
                    campos = campos+'<b>Contacto quien reporta: </b>'+nombre+'<br />';
                    campos = campos+'<b>fecha de reporte: </b>'+fecha+'<br />';
                    campos = campos+'<b>Descripción del evento: </b>'+registroComunicacion.Descripcion__c;
                    
                    List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(emailAddressList);
                    mail.setSubject('Nuevo reporte del módulo de comunicaciones');
                    String cuerpoMensajes='';
                    cuerpoMensajes= '<p>Cordial saludo,</p><br /><p>El &aacute;rea de Seguridad y Salud en el trabajo se permite informarle que se ha creado el siguiente reporte a trav&eacute;s del m&oacute;dulo de comunicaciones: </p><br />';
                    cuerpoMensajes = cuerpoMensajes+campos+' <br /><p>Para obtener m&aacute;s informaci&oacute;n sobre el detalle de la misma, favor contactar a la persona quien reporta.</p><br />';
                    cuerpoMensajes = cuerpoMensajes+'<p>Cordialmente, </p><br /><p>'+cuenta.sst_grupo_empresarial__c+'</p><br />';
                    mail.setHtmlBody(cuerpoMensajes);
                    mailsList.add(mail);
                    List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsList);
                } 
                     
        }
        else if(trigger.isUpdate){
            /*se consulta si el registro de comunicaciones tiene actos o condiciones inseguras ya relacionados*/
            List<ID> idComunicaciones = new List<ID>();
            for(SST_Comunicacion__c nuevoRegistro : trigger.new){
                idComunicaciones.add(nuevoRegistro.id);
            }
            Map<ID,SST_Acto_condicion_insegura__c> actosCondiciones = new Map<ID,SST_Acto_condicion_insegura__c>();
            for(SST_Acto_condicion_insegura__c acto: [select id,identificador_comunicacion__c from SST_Acto_condicion_insegura__c where identificador_comunicacion__c in :idComunicaciones]){
                actosCondiciones.put(acto.identificador_comunicacion__c,acto);
            }
            /*se consultan los nombres del contacto informador*/
            List<ID> idInformadores = new List<ID>();
            for(SST_Comunicacion__c nuevoRegistro : trigger.new){
                idInformadores.add(nuevoRegistro.Informador__c);
            }
            Map<ID,String> nombresContacto = new Map<ID,String>();
            for(Contact contacto: [select name from Contact where id in :idInformadores]){
                nombresContacto.put(contacto.id,contacto.name);
            }
            List<SST_Acto_condicion_insegura__c> actosCondicionesGuardar = new List<SST_Acto_condicion_insegura__c>();
            for(SST_Comunicacion__c nuevoRegistro : trigger.new){
                //Al actualizar un registro en el módulo de comunicaciones, se valida si ya existe un registro de Acto_condicion_insegura
                //creado previamente para el registro modificado.  Si no existe, se crea uno en caso que el tipo de evento
                //del registro de comunicación sea Acto inseguro o Condición insegura
                if(actosCondiciones.get(nuevoRegistro.id) == null){
                    if(!String.isEmpty(nuevoRegistro.Tipo_reporte__c) && 
                       (nuevoRegistro.Tipo_reporte__c.equals(tipoReporte[0]) || 
                        nuevoRegistro.Tipo_reporte__c.equals(tipoReporte[1]))){
                            //Se obtiene el nombre de la persona que realiza el reporte desde el módulo de comunicaciones
                            //para enviarlo al nuevo registro de Acto_condicion_insegura
                            String nombre = nombresContacto.get(nuevoRegistro.Informador__c);
                            SST_Acto_condicion_insegura__c actoCondicion = new SST_Acto_condicion_insegura__c();
                            //Se envía al nuevo registro la fecha de reporte, el identificador del registro en el módulo de
                            //comunicaciones, el tipo de evento, el nombre del informador y la descripción
                            actoCondicion.Informador__c = nombre;
                            actoCondicion.Fecha_reporte__c = Date.valueOf(nuevoRegistro.createdDate);
                            actoCondicion.Descripcion__c = nuevoRegistro.Descripcion__c;
                            actoCondicion.identificador_comunicacion__c = nuevoRegistro.id;
                            actoCondicion.Evento__c = nuevoRegistro.Tipo_reporte__c;
                            actoCondicion.empresa__c = nuevoRegistro.empresa__c;
                            //Se inserta el nuevo registro de Acto_condicion_insegura
                            actosCondicionesGuardar.add(actoCondicion);
                        }   
                }
            }   
            if(actosCondicionesGuardar.size()>0){
                insert actosCondicionesGuardar;
            }	
        }
    }
    if (trigger.isBefore){
        if(trigger.isUpdate){
            Map<ID,String> idComunicaciones = new Map<ID,String>();
            for(SST_Comunicacion__c nuevoRegistro : trigger.new){
                //Si se modifica la empresa del registro de comunicaciones, se modifica también la empresa de los
                //registros de actos o condiciones inseguras generados a partir de la comunicación modificada.
                if(trigger.oldMap.get(nuevoRegistro.id).empresa__c <> nuevoRegistro.empresa__c){
                    idComunicaciones.put(nuevoRegistro.id,nuevoRegistro.empresa__c);
                }
            }
            List<SST_Acto_condicion_insegura__c> listaRegistros = new List<SST_Acto_condicion_insegura__c>();
            for(SST_Acto_condicion_insegura__c actoCondicion : [select id, empresa__c,identificador_comunicacion__c from SST_Acto_condicion_insegura__c where identificador_comunicacion__c = : idComunicaciones.keySet()]){
                actoCondicion.empresa__c = idComunicaciones.get(actoCondicion.identificador_comunicacion__c);
                listaRegistros.add(actoCondicion);
            }                
            if(listaRegistros.size()>0){
                update(listaRegistros);
            }	
        }
        if(trigger.isDelete){
            for(SST_Comunicacion__c registro : trigger.old){
                registro.addError('No es posible eliminar un registro de comunicaciones');
            } 
        }
    }
}