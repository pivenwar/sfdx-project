/*Trigger para validaciones sobre el objeto Proceso antes de la actualización y la eliminación
* @Marcela Taborda
* @version 3.0
* @date 18/12/2018
*/
trigger SST_ProcesoTrigger on SST_Proceso__c (before insert, before update, before delete) {
    if(trigger.isBefore){
        Integer cantidadEmpresas = SST_Constantes.getCantidadEmpresas();
        if(trigger.isInsert){
            List <String> nombresProcesos = new List <String>();
            List <String> empresasProcesos = new List <String>();
            for(SST_Proceso__c nuevoRegistro : trigger.new){
                nuevoRegistro.codigo_externo__c = nuevoRegistro.name;
                if(cantidadEmpresas> 1){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.empresa__c;
                }
                nombresProcesos.add(nuevoRegistro.name);
                empresasProcesos.add(nuevoRegistro.empresa__c);
            }
            //Se valida si existen procesos con el mismo nombre en la misma empresa
            List<SST_Proceso__c> procesosExistentes = [Select id, name, empresa__c from SST_Proceso__c where name in : nombresProcesos and empresa__c =: empresasProcesos];
            if(procesosExistentes.size()>0){
                for(SST_Proceso__c nuevoRegistro : trigger.new){
                    for(SST_Proceso__c temp : procesosExistentes){
                        if(nuevoRegistro.name.equalsIgnoreCase(temp.name) &&nuevoRegistro.empresa__c.equalsIgnoreCase(temp.empresa__c)){
                            nuevoRegistro.adderror('Ya existe un proceso con el nombre '+temp.name+' en la misma empresa. Edite el proceso existente o bien indique otro nombre para el actual.');      
                        }
                    }
                }
            }
        }
        if(trigger.isUpdate){     
            Map <Id,SST_Proceso__c> mapaProcesos = new Map <Id,SST_Proceso__c>();
            List <Id> idProcesos =new List <Id>();
            List <String> nombresProcesos = new List <String>();
            List <String> empresasProcesos = new List <String>();
            for(SST_Proceso__c nuevoRegistro : trigger.New){
                SST_Proceso__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                if(registroModificar.estado__c.equals(SST_Constantes.ACTIVO) && nuevoRegistro.estado__c.equals(SST_Constantes.INACTIVO)){
                    idProcesos.add(registroModificar.id);  
                } 
                if(!registroModificar.name.equals(nuevoRegistro.name)){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.name;
                    if(cantidadEmpresas > 1){
                        nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.empresa__c;
                    }
                    nombresProcesos.add(nuevoRegistro.name);
                	empresasProcesos.add(nuevoRegistro.empresa__c);
                }
            }
            if(nombresProcesos.size()>0){
                //Si se modifica el nombre de un proceso existente, se valida si existen procesos con el mismo nombre en la misma empresa
                List<SST_Proceso__c> procesosExistentes = [Select id, name, empresa__c from SST_Proceso__c where name in : nombresProcesos and empresa__c =: empresasProcesos];
                if(procesosExistentes.size()>0){
                    for(SST_Proceso__c nuevoRegistro : trigger.new){
                        for(SST_Proceso__c temp : procesosExistentes){
                            if(nuevoRegistro.name.equalsIgnoreCase(temp.name) &&nuevoRegistro.empresa__c.equalsIgnoreCase(temp.empresa__c)&& !temp.id.equals(nuevoRegistro.id)){
                                nuevoRegistro.adderror('Ya existe un proceso con el nombre '+temp.name+' en la misma empresa. Edite el proceso existente o bien indique otro nombre para el actual.');      
                            }
                        }
                    }
                }
            }
            //Al inactivar un proceso, se verifica si tiene subprocesos en estado Activo
            if(idProcesos <> null && idProcesos.size()>0){
                List<SST_Proceso__c> registrosExistentes = [select id, name, proceso_padre__c, proceso_padre__r.name, estado__c from SST_Proceso__c  where proceso_padre__r.id in: idProcesos and estado__c =: SST_Constantes.ACTIVO];   
                if(registrosExistentes.size()>0){
                    for (SST_Proceso__c temp : registrosExistentes){
                        mapaProcesos.put(temp.proceso_padre__c,temp);
                    }
                    for (SST_Proceso__c nuevoRegistro : trigger.New){
                        SST_Proceso__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                        if(registroModificar.estado__c.equals(SST_Constantes.ACTIVO) && nuevoRegistro.estado__c.equals(SST_Constantes.INACTIVO)){
                            if(mapaProcesos.get(nuevoRegistro.id) <> null){
                                SST_Proceso__c temp = mapaProcesos.get(nuevoRegistro.id);
                                nuevoRegistro.adderror('El proceso '+temp.proceso_padre__r.name+' tiene subprocesos asociados en estado activo, debe inactivor los subprocesos antes de inactivar el proceso padre.');      
                            }   
                        }
                    }
                }
            }
            SST_Constantes.inactivarPeligros(null, null, idProcesos);
        }
        if (Trigger.isDelete){
            List <SST_Proceso__c> procesosExistentes = [Select id, name from SST_Proceso__c where Proceso_padre__r.id in: trigger.oldMap.keySet()];   
            if(procesosExistentes.size()>0){
                for(SST_Proceso__c registroEliminar : Trigger.old){
                    //Si se va a eliminar un proceso, se verifica si tiene subprocesos dependientes
                    String procesosHijos = '';
                    for(SST_Proceso__c temp : procesosExistentes){
                        if(temp.id == registroEliminar.id){
                         	procesosHijos = procesosHijos + temp.name+', ';   
                        }
                    }
                    if(!String.isEmpty(procesosHijos)){
                        registroEliminar.adderror('El proceso tiene los siguientes subprocesos asociados: '+procesosHijos+' debe desasociarlos antes de eliminar el proceso padre.');
                    }
                }
            }
        }
    }
}