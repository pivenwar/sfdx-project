/*Trigger para validaciones sobre el objeto Encuesta sociodemografica posterior a la inserción y actualización
* @Marcela Taborda
* @version 1.0
* @date 12/12/2018
*/
trigger SST_EncuestaSociodemograficaTrigger on SST_Encuesta_sociodemografica__c (before insert, before delete, after insert, after update) {
    String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();   
    if(trigger.isBefore){
        if(trigger.isInsert){         
            List <SST_Encuesta_sociodemografica__c> encuestasAnteriores = [select id, vigente__c from SST_Encuesta_sociodemografica__c where empresa__c =:empresaAutenticada and (vigente__c =: true or estado__c =: SST_Constantes.ACTIVO)];
            if(encuestasAnteriores.size()>0){
                for(SST_Encuesta_sociodemografica__c temp : encuestasAnteriores){
                    temp.vigente__c = false;
                    temp.estado__c = SST_Constantes.INACTIVO;
                }
                update encuestasAnteriores;
            }
            for(SST_Encuesta_sociodemografica__c nuevoRegistro : trigger.new){
                nuevoRegistro.vigente__c = true;
                nuevoRegistro.empresa__c = empresaAutenticada;
            }
        }
        if(trigger.isDelete){
            for(SST_Encuesta_sociodemografica__c nuevoRegistro : trigger.new){
                nuevoRegistro.adderror('No es posible eliminar las encuestas sociodemográficas.');
            }
        }
    }
    if(trigger.isAfter){
        if(trigger.isInsert){
            List <Account> cuentas = [select id, name, SST_Plazo_encuesta_sociodemografica__c, SST_Nit__c from account where type =:SST_Constantes.CLIENTE and SST_Nit__c =: Decimal.valueOf(empresaAutenticada)];
            Account cuenta = new Account();
            Boolean continuar = false;
            //Se consulta si hay una empresa configurada como cuenta principal.  Si no la hay, no permite crear la encuesta
            for(SST_Encuesta_sociodemografica__c nuevoRegistro : trigger.new){
                if(cuentas.size()==0){
                    nuevoRegistro.adderror('No hay actualmente configurada una empresa como cuenta principal.  Verifique y complete la configuración de los datos de la empresa para crear la encuesta.');
                    continuar = false;
                } else {
                    //Si hay configurada una cuenta principal, se guarda en ella la fecha que indica el plazo para diligenciamiento de la encuesta
                    //Este campo se llama en el template del correo de notificación a funcionarios, para indicar allí el plazo máximo para contestar la encuesta
                    cuenta = cuentas.get(0);
                    cuenta.SST_Plazo_encuesta_sociodemografica__c = String.valueOf(nuevoRegistro.Fecha_fin__c);
                    continuar = true;
                }
            }
            //Luego de almacenar la encuesta, se envía correo a todos los funcionarios activos notificando el link y el código para el diligenciamiento
            if(continuar) {
                update cuenta;
                
                List<SST_Informacion_sociodemografica__c> listaInfo = new List<SST_Informacion_sociodemografica__c>();
                for(List<SST_Informacion_sociodemografica__c> encuestas : [select id, name from SST_Informacion_sociodemografica__c WHERE empresa__c=:empresaAutenticada ]){
                    for(SST_Informacion_sociodemografica__c temp :encuestas ){
                        SST_Informacion_sociodemografica__c infoActualizar = new SST_Informacion_sociodemografica__c();
                        infoActualizar.id = temp.id;
                        infoActualizar.name = SST_Constantes.INFO_SOCIODEMOGRAFICA_CADUCADO;
                        listaInfo.add(infoActualizar);
                    }
                }
                if(listaInfo.size()>0){
                    update listaInfo;
                }
                List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
                Id idTemplateEmail = [select Id FROM EmailTemplate where Name =: SST_Constantes.TEMPLATE_ENCUESTA_SOCIODEMOGRAFICA].id;
                for(Contact contacto : [select id, name from contact where recordType.name =:SST_Constantes.FUNCIONARIO and SST_estado__c =: SST_Constantes.ACTIVO and Email <> null and sst_empresa__c =:empresaAutenticada ]){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(contacto.id);
                    mail.setTemplateID(idTemplateEmail);
                    mail.saveAsActivity = false;
                    mailsList.add(mail);
                }
                if(mailsList.size()>0){
                    List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsList);
                }
            }
        }
        if(trigger.isUpdate){
            Account cuenta = SST_Constantes.consultarDatosEmpresa(empresaAutenticada);
            //Si se modifica la fecha fin de diligenciamiento de la encuesta, se guarda la nueva fecha en la cuenta principal, 
            //pero no se envía nuevo correo de notificación
            for(SST_Encuesta_sociodemografica__c nuevoRegistro : trigger.new){
                if(nuevoRegistro.Fecha_fin__c <> trigger.oldMap.get(nuevoRegistro.id).Fecha_fin__c){
                    if(cuenta == null){
                        nuevoRegistro.adderror('No hay actualmente configurada una empresa como cuenta principal.  Verifique y complete la configuración de los datos de la empresa para modificar la encuesta.');
                    } else{
                        cuenta.SST_Plazo_encuesta_sociodemografica__c = String.valueOf(nuevoRegistro.Fecha_fin__c);   
                    }
                }
            }
            if(cuenta <> null){
                update cuenta;
            }
        }
    }
}