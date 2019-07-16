/*Trigger para validaciones sobre el objeto Sede previo a la inserción y actualización
* @Marcela Taborda
* @version 3.0
* @date 19/12/2018
*/
trigger SST_SedeTrigger on SST_Sede__c (before insert, before update) {
    if(trigger.isBefore){
        Integer cantidadEmpresas=SST_Constantes.getCantidadEmpresas();
        if(trigger.isInsert){
            List <String> nombresSedes = new List <String>();
            List <String> empresasSedes = new List <String>();
            for(SST_sede__c nuevoRegistro : trigger.new){
                nuevoRegistro.codigo_externo__c = nuevoRegistro.name;
                if(cantidadEmpresas > 1){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.empresa__c;
                }
                nombresSedes.add(nuevoRegistro.name);
                empresasSedes.add(nuevoRegistro.empresa__c);
            }
            //Se valida si existen sedes con el mismo nombre en la misma empresa
            List<SST_sede__c> sedesExistentes = [Select id, name, empresa__c from SST_sede__c where name in : nombresSedes and empresa__c =: empresasSedes];
            if(sedesExistentes.size()>0){
                for(SST_sede__c nuevoRegistro : trigger.new){
                    for(SST_sede__c temp : sedesExistentes){
                        if(nuevoRegistro.name.equalsIgnoreCase(temp.name) &&nuevoRegistro.empresa__c.equalsIgnoreCase(temp.empresa__c)){
                            nuevoRegistro.adderror('Ya existe una sede con el nombre '+temp.name+' en la misma empresa. Verifique si se encuentra inactiva y proceda a actualizar el estado.');      
                        }
                    }
                }
            }  
        }
        if(trigger.isUpdate){ 
            //Si se va a inactivar la sede, se valida si está asociada a funcionarios y/o seguimientos en estado Activo.
            List <Id> idSedes = new List <Id>();
            Map <id,SST_Seguimiento_sede__c> mapaSedes = new Map <id,SST_Seguimiento_sede__c>();
            Map <id,SST_Normatividad_sede__c> mapaNormasSedes = new Map <id,SST_Normatividad_sede__c>();
            Map <id,Contact> mapaContactos = new Map <id,Contact>();
            List <String> nombresSedes = new List <String>();
            List <String> empresasSedes = new List <String>();
            for(SST_Sede__c nuevoRegistro : trigger.new){
                SST_sede__c registroExistente = trigger.oldMap.get(nuevoRegistro.id);
                if(!registroExistente.name.equals(nuevoRegistro.name)){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.name;
                    if(cantidadEmpresas > 1){
                        nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.empresa__c;
                    }
                    nombresSedes.add(nuevoRegistro.name);
                    empresasSedes.add(nuevoRegistro.empresa__c);
                }
                if(registroExistente.estado__c == SST_Constantes.ACTIVO && nuevoRegistro.estado__c == SST_Constantes.INACTIVO){
                    idSedes.add(nuevoRegistro.id);
                }
            }
            //Si se modifica el nombre de la sede, se valida que si existen sedes con el mismo nombre en la misma empresa
            if(nombresSedes.size()>0){
                List<SST_sede__c> sedesExistentes = [Select id, name, empresa__c from SST_sede__c where name in : nombresSedes and empresa__c =: empresasSedes];
                if(sedesExistentes.size()>0){
                    for(SST_sede__c nuevoRegistro : trigger.new){
                        for(SST_sede__c temp : sedesExistentes){
                            if(nuevoRegistro.name.equalsIgnoreCase(temp.name) &&nuevoRegistro.empresa__c.equalsIgnoreCase(temp.empresa__c)&& !temp.id.equals(nuevoRegistro.id)){
                                nuevoRegistro.adderror('Ya existe una sede con el nombre '+temp.name+' en la misma empresa. Verifique si se encuentra inactiva y proceda a actualizar el estado.');      
                            }
                        }
                    }
                }
            }
            if(idSedes<>null && idSedes.size()>0){
                for(SST_Seguimiento_sede__c temp : [Select id, seguimiento__r.estado__c, sede__c, sede__r.name from SST_Seguimiento_sede__c where sede__c in : idSedes and seguimiento__r.estado__c =: SST_Constantes.ACTIVO]){
                    mapaSedes.put(temp.sede__c, temp);
                }
                for(SST_Normatividad_sede__c temp2 : [Select id, normatividad__r.name, sede__c, sede__r.name from SST_Normatividad_sede__c where sede__c in : idSedes]){
                    mapaNormasSedes.put(temp2.sede__c, temp2);
                }
                for(Contact temp3 : [Select id, sst_sede__c, name from Contact where sst_sede__c<>null and sst_sede__c in: idSedes and sst_estado__c =: SST_Constantes.ACTIVO]){
                    mapaContactos.put(temp3.sst_sede__c, temp3);
                } 
                for(SST_Sede__c nuevoRegistro : trigger.new){
                    SST_sede__c registroExistente = trigger.oldMap.get(nuevoRegistro.id);
                    if(registroExistente.estado__c == SST_Constantes.ACTIVO && nuevoRegistro.estado__c == SST_Constantes.INACTIVO){
                        //Al inactivar la sede, se valida si está asociada a seguimientos Activos
                        if(mapaSedes <>null && mapaSedes.size()>0 && mapaSedes.get(nuevoRegistro.id) <>null){
                            nuevoRegistro.addError('No es posible inactivar la sede '+nuevoRegistro.name+', está asociada a seguimientos en estado Activo');
                        }
                        //Al inactivar la sede, se valida si está asociada a normatividades
                        if(mapaNormasSedes <>null && mapaNormasSedes.size()>0 && mapaNormasSedes.get(nuevoRegistro.id) <>null){
                            nuevoRegistro.addError('No es posible inactivar la sede '+nuevoRegistro.name+', está asociada a una o más normatividades');
                        }
                        //Al inactivar la sede, se valida si tiene asociados contactos en estado Activo
                        if(mapaContactos <>null && mapaContactos.size()>0 && mapaContactos.get(nuevoRegistro.id) <>null){
                            nuevoRegistro.addError('No es posible inactivar la sede'+nuevoRegistro.name+', tiene funcionarios Activos asociados');  
                        }   
                    }
                }
            }
            SST_Constantes.inactivarPeligros(idSedes, null, null);
        }
    }
}