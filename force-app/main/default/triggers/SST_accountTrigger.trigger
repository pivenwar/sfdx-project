/*Trigger para validaciones sobre el objeto Account antes y después de la actualización.
* @Marcela Taborda
* @version 2.0
* @date 18/12/2018
*/
trigger SST_accountTrigger on Account (before insert, before update, after update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            String link = SST_Constantes.LINK_PORTAL_SST;
            Map<Id,Account>  cuentasActivas = new Map<Id,Account> ();
            List<Account> checkCuentas = [Select id, name, SST_Cuenta_indicadores_globales__c, sst_periodo_notificacion__c from Account where type =:SST_Constantes.CLIENTE and sst_estado__c =: SST_Constantes.ACTIVO];
            if(checkCuentas.size()>0){
                for(account nuevoRegistro : trigger.new){ 
                    /*Se verifica si la cuenta que se está creando tiene el campo SST_Cuenta_indicadores_globales__c en true */
                    if(nuevoRegistro.SST_Cuenta_indicadores_globales__c == true){
                        for(account temp : checkCuentas){
                            if(temp.SST_Cuenta_indicadores_globales__c == true){
                                temp.SST_Cuenta_indicadores_globales__c = false;
                                cuentasActivas.put(temp.id,temp);
                                break;
                            }
                        }
                    }
                    if(nuevoRegistro.sst_periodo_notificacion__c == null){
                        nuevoRegistro.sst_periodo_notificacion__c = checkCuentas.get(0).sst_periodo_notificacion__c ;
                    } 
                    else {
                        for(Account cuenta : checkCuentas){
                            if(nuevoRegistro.sst_periodo_notificacion__c <> cuenta.sst_periodo_notificacion__c ){
                                if(cuentasActivas.get(cuenta.id)==null){
                                    cuenta.sst_periodo_notificacion__c = nuevoRegistro.sst_periodo_notificacion__c;
                                    cuentasActivas.put(cuenta.id,cuenta);   
                                } else {
                                    cuentasActivas.get(cuenta.id).sst_periodo_notificacion__c = nuevoRegistro.sst_periodo_notificacion__c;
                                }
                            }
                        }
                    }
                }
                if(cuentasActivas.size()>0){
                    List <Account> cuentasActualizar = cuentasActivas.values();
                    update cuentasActualizar;
                }
                
            }
        }
        if(trigger.isUpdate){
            String idPerfilAdmin = SST_Constantes.returnAdministrador().profileId;
            String link = SST_Constantes.LINK_PORTAL_SST;
            id idCuentaIndicadorGlobal;
            List<Account> cuentas = New List<Account>();
            for(account nuevoRegistro : trigger.new){
                if(String.isEmpty(trigger.oldMap.get(nuevoRegistro.id).SST_Link_gestion_documental__c)){
                    nuevoRegistro.SST_Link_gestion_documental__c = link+'/sstgestiondocumental';
                }
                if(String.isEmpty(trigger.oldMap.get(nuevoRegistro.id).SST_Link_encuesta_sociodemografica__c)){
                    nuevoRegistro.SST_Link_encuesta_sociodemografica__c = link+'/sstencuestasociodemografica';
                }
                account registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                if(!registroModificar.name.equals(nuevoRegistro.name)){
                    if(!idPerfilAdmin.equals(userInfo.getProfileId())){
                        nuevoRegistro.adderror('Sólo el administrador del sistema puede modificar el nombre de la empresa en la aplicación.');
                    }
                }
                if(trigger.oldMap.get(nuevoRegistro.id).SST_Nivel_Riesgo__c <> nuevoRegistro.SST_Nivel_Riesgo__c){
                    nuevoRegistro.SST_tipo_empresa__c= SST_Utilitarios.obtenerTipoEmpresa(nuevoRegistro);
                    
                }
                if(trigger.oldMap.get(nuevoRegistro.id).SST_Tipo_Empresa__c <> nuevoRegistro.SST_Tipo_Empresa__c){
                    cuentas.add(nuevoRegistro);
                    
                }
                if(nuevoRegistro.SST_Cuenta_indicadores_globales__c == true){
                    idCuentaIndicadorGlobal = nuevoRegistro.id;
                }
            }  
            if(cuentas.size()>0){
             SST_Utilitarios.actualizarEstandaresMinimos(cuentas);

            }
            if(idCuentaIndicadorGlobal != null){
                List<Account> checkCuentas = new List<Account>();
                for(account temp : [Select id, name, SST_Cuenta_indicadores_globales__c from Account where SST_Cuenta_indicadores_globales__c =: true and id <>: idCuentaIndicadorGlobal]){
                    temp.SST_Cuenta_indicadores_globales__c = false;
                    checkCuentas.add(temp);
                }
                if(checkCuentas.size()>0){
                    update checkCuentas;
                }        
            }
        }
    }
    if(trigger.isAfter){
        
        if(trigger.isUpdate){
            Map<ID, Account> cuentasConExamenesModificar = new Map<ID,Account>();
            List<ID> cuentasModificar = new List<ID>();
            Double nuevoPeriodo = 0;
            List<SST_Examen_ocupacional__c> examenes = new List<SST_Examen_ocupacional__c>();
            for(account nuevoRegistro : trigger.new){
                if(nuevoRegistro.SST_Periodicidad_examen_ocupacional__c != null && nuevoRegistro.SST_Periodicidad_examen_ocupacional__c != trigger.oldMap.get(nuevoRegistro.id).SST_Periodicidad_examen_ocupacional__c){
                    cuentasConExamenesModificar.put(nuevoRegistro.ID,nuevoRegistro);
                }
                if(trigger.oldMap.get(nuevoRegistro.id).sst_periodo_notificacion__c <> nuevoRegistro.sst_periodo_notificacion__c && nuevoRegistro.SST_ejecutar_trigger__c){
                    cuentasModificar.add(nuevoRegistro.ID);
                    nuevoPeriodo = nuevoRegistro.sst_periodo_notificacion__c;
                }
            }    
            if(cuentasConExamenesModificar.size()>0){
                List <String> nits = new List <String>();
                for(Account temp : cuentasConExamenesModificar.values()){
                    nits.add(String.valueOf(temp.sst_nit__c));
                }
                //Si se modifica la periodicidad de examen ocupacional en la cuenta, se recalculan las nuevas fechas de próximo examen para los exámenes que no han vencido
                for(SST_Examen_ocupacional__c examen : [SELECT id,fecha_examen__c,funcionario_examen__r.accountId FROM SST_Examen_ocupacional__c where funcionario_examen__r.sst_empresa__c in: nits and funcionario_examen__r.accountId in :cuentasConExamenesModificar.keyset() and periodicidad_calculada__c = true and proximo_examen__c>=:system.today()]){
                    Integer dias = Integer.valueOf(cuentasConExamenesModificar.get(examen.funcionario_examen__r.accountId).SST_Periodicidad_examen_ocupacional__c);
                    Date fechaProximoExamen = examen.fecha_examen__c.addDays(dias);
                    if(fechaProximoExamen> system.today()){
                        examen.proximo_examen__c = fechaProximoExamen;
                        examenes.add(examen);
                    } 
                }
                if(examenes.size()>0){
                    update(examenes);                
                }
            }
            if(cuentasModificar.size()>0){ 
                //Si se modifica el periodo de notificación de una cuenta, se actualizan todas las demás con el mismo plazo
                List<Account> cuentasExistentes = new List<Account>();
                for(Account temp : [select id, name, SST_ejecutar_trigger__c, sst_periodo_notificacion__c from Account where type =:SST_Constantes.CLIENTE and id <>: cuentasConExamenesModificar.keySet()]){
                    temp.sst_periodo_notificacion__c = nuevoPeriodo;
                    temp.SST_ejecutar_trigger__c = false;
                    cuentasExistentes.add(temp);
                }    
                if(cuentasExistentes.size()>0){                        
                    update cuentasExistentes;
                }
                
            }
           
        }
    }
}