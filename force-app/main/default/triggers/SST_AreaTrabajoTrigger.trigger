/*Trigger para validaciones sobre el objeto Área de trabajo previo a la actualización y eliminación
* @Marcela Taborda
* @version 3.0
* @date 18/12/2018
*/
trigger SST_AreaTrabajoTrigger on SST_Area_trabajo__c (before insert, before update, before delete) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            Integer cant = SST_Constantes.getCantidadEmpresas();
            List <String> nombresAreas = new List <String>();
            List <String> empresasAreas = new List <String>();
            for(SST_Area_trabajo__c nuevoRegistro : trigger.new){
                nuevoRegistro.codigo_externo__c = nuevoRegistro.name;
                if(cant > 1){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.empresa__c;
                }
                nombresAreas.add(nuevoRegistro.name);
                empresasAreas.add(nuevoRegistro.empresa__c);
            }
            //Se valida si existen áreas con el mismo nombre en la misma empresa
            List<SST_Area_trabajo__c> areasExistentes = [Select id, name, empresa__c from SST_Area_trabajo__c where name in : nombresAreas and empresa__c =: empresasAreas];
            if(areasExistentes.size()>0){
                for(SST_Area_trabajo__c nuevoRegistro : trigger.new){
                    for(SST_Area_trabajo__c temp : areasExistentes){
                        if(nuevoRegistro.name.equalsIgnoreCase(temp.name) &&nuevoRegistro.empresa__c.equalsIgnoreCase(temp.empresa__c)){
                            nuevoRegistro.adderror('Ya existe un área de trabajo con el nombre '+temp.name+' en la misma empresa. Verifique si se encuentra inactiva y proceda a actualizar el estado.');      
                        }
                    }
                }
            }
        }
        
        if(trigger.isUpdate){     
            Map <Id,SST_Area_trabajo__c> mapaAreas = new Map <Id,SST_Area_trabajo__c>();
            List <Id> idAreas =new List <Id>();
            List <String> nombresAreas = new List <String>();
            List <String> empresasAreas = new List <String>();
            Integer cant = SST_Constantes.getCantidadEmpresas();
            for(SST_Area_trabajo__c nuevoRegistro : trigger.New){
                SST_Area_trabajo__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                if(!registroModificar.name.equals(nuevoRegistro.name)){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.name;
                    if(cant > 1){
                        nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.empresa__c;
                    }
                    nombresAreas.add(nuevoRegistro.name);
                    empresasAreas.add(nuevoRegistro.empresa__c);
                }
                if(registroModificar.estado__c.equals(SST_Constantes.ACTIVO) && nuevoRegistro.estado__c.equals(SST_Constantes.INACTIVO)){
                    idAreas.add(registroModificar.id);
                } 
            }
            //Si se modifica el nombre del área, se valida que si existen áreas con el mismo nombre en la misma empresa
            if(nombresAreas.size()>0){
                List<SST_Area_trabajo__c> areasExistentes = [Select id, name, empresa__c from SST_Area_trabajo__c where name in : nombresAreas and empresa__c =: empresasAreas];
                if(areasExistentes.size()>0){
                    for(SST_Area_trabajo__c nuevoRegistro : trigger.new){
                        for(SST_Area_trabajo__c temp : areasExistentes){
                            if(nuevoRegistro.name.equalsIgnoreCase(temp.name) &&nuevoRegistro.empresa__c.equalsIgnoreCase(temp.empresa__c) && !temp.id.equals(nuevoRegistro.id)){
                                nuevoRegistro.adderror('Ya existe un área de trabajo con el nombre '+temp.name+' en la misma empresa. Verifique si se encuentra inactiva y proceda a actualizar el estado.');      
                            }
                        }
                    }
                }
            }
            //Si el área se va a inactivar, se valida si tiene áreas hijas asociadas en estado activo
            if(idAreas <> null && idAreas.size()>0){
                List<SST_Area_trabajo__c > registrosExistentes = [select id, name, estado__c, area_padre__c, area_padre__r.name from SST_Area_trabajo__c where area_padre__r.id in : idAreas and estado__c =:SST_Constantes.ACTIVO];   
                if(registrosExistentes.size()>0){
                    for (SST_Area_trabajo__c temp : registrosExistentes){
                        mapaAreas.put(temp.area_padre__c,temp);
                    }
                    for (SST_Area_trabajo__c nuevoRegistro : trigger.New){
                        SST_Area_trabajo__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                        if(registroModificar.estado__c.equals(SST_Constantes.ACTIVO) && nuevoRegistro.estado__c.equals(SST_Constantes.INACTIVO)){
                            if(mapaAreas.get(nuevoRegistro.id) <> null){
                                SST_Area_trabajo__c temp = mapaAreas.get(nuevoRegistro.id);
                                nuevoRegistro.adderror('El área '+temp.area_padre__r.name+' tiene subáreas asociadas en estado activo, debe inactivar las subáreas antes de inactivar el área padre.');      
                            }   
                        }
                    }
                }
            }
            SST_Constantes.inactivarPeligros(null, idAreas, null);
        }
        
        //Si el área se va a eliminar, se valida si tiene áreas hijas asociadas sin importar el estado
        if (Trigger.isDelete){
            List<Id> idsEliminar = new List<Id>();
            for(SST_Area_trabajo__c registroEliminar : Trigger.old){
                idsEliminar.add(registroEliminar.id);
            }
            List <SST_Area_trabajo__c> areasExistentes = [Select id, name, Area_padre__r.id from SST_Area_trabajo__c where Area_padre__r.id in: idsEliminar];   
            for(SST_Area_trabajo__c registroEliminar : Trigger.old){
                if(areasExistentes.size()>0){
                    String areasHijas = '';
                    for(SST_Area_trabajo__c temp : areasExistentes){
                        if(temp.Area_padre__r.id == registroEliminar.id){
                        	areasHijas = areasHijas + temp.name+', ';    
                        }
                    }
                    if(!String.isEmpty(areasHijas)){
                     	registroEliminar.adderror('El área tiene las siguientes subáreas asociadas: '+areasHijas+' debe desasociarlas antes de eliminar el área padre.');   
                    }
                }
            }
        }
    }
}