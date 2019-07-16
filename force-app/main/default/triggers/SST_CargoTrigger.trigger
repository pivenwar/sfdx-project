/*Trigger para validaciones sobre el objeto Cargo previo a la inserción, actualización y eliminación
* @Marcela Taborda
* @version 3.0
* @date 18/12/2018
*/
trigger SST_CargoTrigger on SST_Cargo__c (before insert, before update, after update,before delete) {
    if(trigger.isBefore){
        Integer catidadEmpresas = SST_Constantes.getCantidadEmpresas();
        //Al insertar un nuevo registro, se valida que no exista un cargo con el mismo tipo de registro y nombre en la misma emprsea
        if(Trigger.isInsert){
            List <String> empresasCargos = new List <String>();
            List <Id> recordsTypes = new List <Id>();
            List <String> nombresCargos = new List <String>();
            Map <String,SST_Cargo__c> mapaCargos = new Map <String,SST_Cargo__c>();
            for(SST_Cargo__c nuevoRegistro : Trigger.new){
                recordsTypes.add(nuevoRegistro.recordTypeId);
                nombresCargos.add(nuevoRegistro.name);
                empresasCargos.add(nuevoRegistro.empresa__c);
            }
            
            Boolean cargosExistentes = false;
            
            for(SST_Cargo__c temp : [Select id, name, empresa__c, RecordType.name, RecordTypeId from SST_Cargo__c where Empresa__c in:empresasCargos and name in: nombresCargos and recordTypeId in: recordsTypes]){
                cargosExistentes = true;
                String c = temp.name.toLowerCase()+'/'+temp.recordTypeId+'/'+temp.empresa__c;
                mapaCargos.put(c,temp);
            }
            for(SST_Cargo__c nuevoRegistro : trigger.new){
                nuevoRegistro.codigo_externo__c = nuevoRegistro.name;
                if(catidadEmpresas > 1){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.empresa__c;
                }
                if(cargosExistentes){
                    String c = nuevoRegistro.name.toLowerCase()+'/'+nuevoRegistro.recordTypeId+'/'+nuevoRegistro.empresa__c;
                    SST_Cargo__c temp = mapaCargos.get(c);
                    if(temp<>null){
                        nuevoRegistro.adderror('Ya existe un cargo con el Tipo de Registro '+temp.RecordType.name+' y el nombre: '+nuevoRegistro.name+' en la misma empresa.');       
                    }
                } 
            }
        }
        
        if (Trigger.isUpdate){
            Set<String> empresasPeligros = new Set<String>();
            if(Trigger.isBefore){
                
                List <Id> recordsTypes = new List <Id>();
                List <String> empresasCargos = new List <String>();
                List <String> nombresCargos = new List <String>();
                Map <String,SST_Cargo__c> mapaCargos = new Map <String,SST_Cargo__c>();
                Map <Id,Contact> mapaFuncionarios = new Map <Id,Contact>();
                List <Id> idCargos =new List <Id>();
                
                //Al modificar un registro y modificar el nombre, se valida que no exista un cargo con el mismo tipo de registro y nombre
                for(SST_Cargo__c nuevoRegistro : Trigger.new){
                    SST_Cargo__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                    if(!nuevoRegistro.name.equalsIgnoreCase(registroModificar.name)){
                        nuevoRegistro.codigo_externo__c = nuevoRegistro.name;
                        if(catidadEmpresas > 1){
                            nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.empresa__c;
                        }
                        recordsTypes.add(nuevoRegistro.recordTypeId);
                        nombresCargos.add(nuevoRegistro.name);
                        empresasCargos.add(nuevoRegistro.empresa__c);
                    }
                    if(registroModificar.estado__c<>null && nuevoRegistro.estado__c<>null && registroModificar.estado__c.equals(SST_Constantes.ACTIVO) && nuevoRegistro.estado__c.equals(SST_Constantes.INACTIVO)){
                        idCargos.add(registroModificar.id);
                    }
                }
                if(nombresCargos<>null && nombresCargos.size()>0){
                    boolean cargosExistentes = false;
                    for(SST_Cargo__c temp : [Select id, name, RecordType.name, RecordTypeId,empresa__c from SST_Cargo__c where Empresa__c in:empresasCargos and name in: nombresCargos and recordTypeId in: recordsTypes]){
                        cargosExistentes = true;
                        String c = temp.name.toLowerCase()+'/'+temp.recordTypeId+'/'+temp.empresa__c;
                        mapaCargos.put(c,temp);
                    }                
                    if(cargosExistentes){
                        for(SST_Cargo__c nuevoRegistro : trigger.new){
                            SST_Cargo__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                            if(!nuevoRegistro.name.equalsIgnoreCase(registroModificar.name)){
                                String c = nuevoRegistro.name.toLowerCase()+'/'+nuevoRegistro.recordTypeId+'/'+nuevoRegistro.empresa__c;
                                SST_Cargo__c temp = mapaCargos.get(c);
                                if(temp<>null){
                                    nuevoRegistro.adderror('Ya existe un cargo con el Tipo de Registro '+temp.RecordType.name+' y el nombre: '+nuevoRegistro.name+' en la misma empresa.');       
                                }   
                            }
                        }
                    }  
                }
                if(idCargos<>null && idCargos.size()>0){
                    //Al inactivar un cargo, se valida si tiene subcargos asociados en estado activo
                    for (SST_Cargo__c temp : [select id, name, estado__c, cargo_padre__c from SST_Cargo__c where cargo_padre__r.id in: idCargos and estado__c =:SST_Constantes.ACTIVO]){
                        mapaCargos.put(temp.id,temp);
                    }
                    //Al inactivar un cargo, se valida si está asociado a funcionarios Activos
                    for (Contact temp : [select id, name,sst_cargo__c from contact where sst_cargo__c<>null and sst_cargo__c in: idCargos and sst_estado__c =: SST_Constantes.ACTIVO]){
                        mapaFuncionarios.put(temp.sst_cargo__c,temp);
                    }
                    for(SST_Cargo__c nuevoRegistro : trigger.new){
                        SST_Cargo__c registroExistente = trigger.oldMap.get(nuevoRegistro.id);
                        if(registroExistente.estado__c<>null && nuevoRegistro.estado__c<>null && registroExistente.estado__c == SST_Constantes.ACTIVO && nuevoRegistro.estado__c == SST_Constantes.INACTIVO){
                            Boolean inactivar = true;
                            if(mapaCargos <>null && mapaCargos.size()>0 && mapaCargos.get(nuevoRegistro.id) <>null){
                                nuevoRegistro.addError('No es posible inactivar el cargo '+nuevoRegistro.name+', tiene subcargos asociados en estado Activo.  Procesa a inactivar los subcargos antes de inactivar el cargo padre');
                                inactivar = false;
                            }
                            if(mapaFuncionarios <>null && mapaFuncionarios.size()>0 && mapaFuncionarios.get(nuevoRegistro.id) <>null){
                                nuevoRegistro.addError('No es posible inactivar el cargo '+nuevoRegistro.name+', está asociado a funcionarios Activos.  Proceda a cambiar el cargo de los funcionarios antes de inactivar el cargo actual');  
                                inactivar = false;
                            } 
                            if(inactivar){
                                empresasPeligros.add(nuevoRegistro.empresa__c);
                            }
                            
                        }
                    }
                }
            }else if(Trigger.isAfter){
                /*si hay valores en la lista de empresa peligros es porque se inactivó algún cargo*/
                if(!empresasPeligros.isEmpty()){
                    /*se realiza la actualización de la cantidad de expuestos en los peligros*/
                    SST_Constantes.actualizarExpuestosPeligros(null,empresasPeligros);
                    
                }
            }
            
        }
        //Al eliminar un cargo, se valida si tiene subcargos asociados y no permite su eliminación
        if (Trigger.isDelete){
            for(SST_Cargo__c registroEliminar : Trigger.old){
                String cargosHijos = '';
                for(SST_Cargo__c temp : [Select id, name from SST_Cargo__c where Cargo_padre__r.id =: registroEliminar.id]){
                    cargosHijos = cargosHijos + temp.name+', ';
                }
                if(cargosHijos!=''){
                    registroEliminar.adderror('El cargo tiene los siguientes subcargos asociados: '+cargosHijos+' debe desasociarlos antes de eliminar el cargo padre.');
                }
            }
        }
    }
}