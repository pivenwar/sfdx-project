/*Trigger para validaciones sobre el objeto Funcionarios Comités antes de la inserción y actualización
* @Marcela Taborda
* @version 3.0
* @date 23/04/2019
*/
trigger SST_FuncionariosComitesTrigger on SST_Funcionarios_Comites__c (before insert, before update) {
    if(trigger.isBefore){
        if(Trigger.isInsert){   
            List<Id> idComites = new List<Id>();
            for(SST_Funcionarios_Comites__c nuevoRegistro : Trigger.new){
                idComites.add(nuevoRegistro.comite__c);
            }
            Map<Id,SST_Comites__c> comites = new Map<Id,SST_Comites__c>([select id, fecha_inicio__c, empresa__c, fecha_fin__c, cantidad_representantes__c from SST_Comites__c where id in: idComites]);
            List<SST_Funcionarios_Comites__c> funcionariosActuales = [select id, cargo_comite__c, titularidad__c, estado__c, representante_de__c, funcionario__c, comite__c from SST_Funcionarios_Comites__c  where comite__c in: idComites and estado__c=:SST_Constantes.ACTIVO];   
            for(SST_Funcionarios_Comites__c nuevoRegistro : Trigger.new){ 
                nuevoRegistro.Estado__c = SST_Constantes.ACTIVO;
                //Al asociar un miembro al comité, se valida que la fecha de nombramiento esté dentro del periodo de vigencia del comité
                if(nuevoRegistro.Fecha_nombramiento__c < comites.get(nuevoRegistro.comite__c).Fecha_inicio__c || nuevoRegistro.Fecha_nombramiento__c > comites.get(nuevoRegistro.comite__c).fecha_fin__c){
                    nuevoRegistro.adderror('La fecha de nombramiento debe estar dentro del periodo de vigencia del comité: '+ String.valueOf(comites.get(nuevoRegistro.comite__c).Fecha_inicio__c) +' al '+ String.valueOf(comites.get(nuevoRegistro.comite__c).Fecha_fin__c));
                }
                
                //Al realizar una nueva asociación, se valida que la fecha de terminación quede en blanco
                if(nuevoRegistro.Fecha_terminacion__c != null){
                    nuevoRegistro.adderror('Para nuevas asociaciones, la fecha de terminación debe quedar en blanco');
                } else {
                    nuevoRegistro.Fecha_terminacion__c = comites.get(nuevoRegistro.comite__c).Fecha_fin__c;
                }
                
                if(funcionariosActuales.size()>0){
                    Integer countRepresentantes = 0;
                    for(SST_Funcionarios_Comites__c miembro : funcionariosActuales){
                        //Al asociar un miembro al comité, se valida que el cargo no esté asignado actualmente y vigente en el comité con la misma titularidad
                        if(miembro.comite__c == nuevoRegistro.Comite__c && miembro.cargo_comite__c == nuevoRegistro.cargo_comite__c && miembro.titularidad__c == nuevoRegistro.Titularidad__c){
                            nuevoRegistro.adderror('El cargo ya se encuentra actualmente asignado dentro del comité con la misma titularidad');
                        }
                        //Al asociar un miembro al comité, se valida que no tenga una asociación vigente al mismo comité
                        if(miembro.comite__c == nuevoRegistro.Comite__c && miembro.funcionario__c == nuevoRegistro.funcionario__c){
                            nuevoRegistro.adderror('El funcionario ya tiene un cargo activo asignado dentro del comité');
                        }
                        if(miembro.titularidad__c == nuevoRegistro.titularidad__c && miembro.comite__c == nuevoRegistro.Comite__c && miembro.representante_de__c == nuevoRegistro.representante_de__c){
                            countRepresentantes ++;
                        }
                    }
                    //Al asociar un miembro al comité, se valida que no se supere la cantidad de miembros vigentes representantes de la misma parte parametrizada para el comité
                    if(countRepresentantes >= comites.get(nuevoRegistro.comite__c).cantidad_representantes__c){
                        nuevoRegistro.adderror('La cantidad de funcionarios activos de titularidad '+nuevoRegistro.titularidad__c+' ha llegado al tope máximo de '+countRepresentantes+' en representación de: '+nuevoRegistro.representante_de__c); 
                    }
                }    
            }
        }
        if(Trigger.isUpdate){
            List<Id> idComites = new List<Id>();
            List<Id> idRegistros = new List<Id>();
            for(SST_Funcionarios_Comites__c nuevoRegistro : Trigger.new){
                idComites.add(nuevoRegistro.comite__c);
                idRegistros.add(nuevoRegistro.id);
            }
            Map<Id,SST_Comites__c> comites = new Map<Id,SST_Comites__c>([select id, fecha_inicio__c, empresa__c, fecha_fin__c, cantidad_representantes__c from SST_Comites__c where id in: idComites]);
            List<SST_Funcionarios_Comites__c> funcionariosActuales = [select id, cargo_comite__c, titularidad__c, estado__c, representante_de__c, funcionario__c, comite__c from SST_Funcionarios_Comites__c  where comite__c in: idComites and estado__c=:SST_Constantes.ACTIVO and id not in: idRegistros];   
            
            for(SST_Funcionarios_Comites__c nuevoRegistro : Trigger.new){
                if(nuevoRegistro.Fecha_terminacion__c != trigger.oldMap.get(nuevoRegistro.id).Fecha_terminacion__c){
                    //Al registrar la fecha de terminación de un mimbro, se valida que sea mayor o igual a la fecha de nombramiento y menor o igual a la fecha fin del comité
                    if(nuevoRegistro.Fecha_terminacion__c < trigger.oldMap.get(nuevoRegistro.id).Fecha_nombramiento__c || nuevoRegistro.Fecha_terminacion__c > comites.get(nuevoRegistro.comite__c).fecha_fin__c){
                        nuevoRegistro.adderror('La fecha de terminación debe ser mayor o igual a la fecha de nombramiento y menor o igual a la fecha fin del comité '+ String.valueOf(comites.get(nuevoRegistro.comite__c).Fecha_fin__c));
                    } else if (nuevoRegistro.Fecha_terminacion__c >= comites.get(nuevoRegistro.comite__c).Fecha_inicio__c && nuevoRegistro.Fecha_terminacion__c < comites.get(nuevoRegistro.comite__c).fecha_fin__c){
                        nuevoRegistro.Estado__c = SST_Constantes.INACTIVO;   
                    }
                }
                if(nuevoRegistro.Fecha_nombramiento__c != trigger.oldMap.get(nuevoRegistro.id).Fecha_nombramiento__c){                
                    //Al modificar la fecha de nombramiento, se valida que la misma esté dentro del periodo de vigencia del comité
                    if(nuevoRegistro.Fecha_nombramiento__c < comites.get(nuevoRegistro.comite__c).Fecha_inicio__c || nuevoRegistro.Fecha_nombramiento__c > nuevoRegistro.Fecha_terminacion__c){
                        nuevoRegistro.adderror('La fecha de nombramiento debe ser mayor o igual a la fecha de inicio del comité '+ String.valueOf(comites.get(nuevoRegistro.comite__c).Fecha_inicio__c)+' y menor o igual a la fecha de terminación de la asignación');
                    }
                } 
                if(funcionariosActuales.size()>0){
                    Integer countRepresentantes = 0;
                    for(SST_Funcionarios_Comites__c miembro : funcionariosActuales){
                        //Al modificar el comité o cargo de un miembro ya asignado, se valida que el cargo no esté asignado actualmente y vigente en el comité con la misma titularidad
                        if(nuevoRegistro.cargo_comite__c != trigger.oldMap.get(nuevoRegistro.id).cargo_comite__c 
                           || nuevoRegistro.Comite__c != trigger.oldMap.get(nuevoRegistro.id).Comite__c 
                           || nuevoRegistro.titularidad__c != trigger.oldMap.get(nuevoRegistro.id).titularidad__c 
                           || nuevoRegistro.representante_de__c != trigger.oldMap.get(nuevoRegistro.id).representante_de__c){
                               if(miembro.comite__c == nuevoRegistro.Comite__c && miembro.cargo_comite__c == nuevoRegistro.cargo_comite__c && miembro.titularidad__c == nuevoRegistro.Titularidad__c){
                                   nuevoRegistro.adderror('El cargo ya se encuentra actualmente asignado dentro del comité con la misma titularidad');    
                               }
                               //Al modificar el comité o cargo de un miembro ya asignado, se valida que no se supere la cantidad de miembros vigentes representantes de la misma parte parametrizada para el comité
                               if(miembro.titularidad__c == nuevoRegistro.titularidad__c && miembro.comite__c == nuevoRegistro.Comite__c && miembro.representante_de__c == nuevoRegistro.representante_de__c){
                                   countRepresentantes ++;
                               }
                           }
                        //Al modificar el miembro del comité, se valida que el nuevo funcionario no tenga una asociación vigente al mismo comité
                        if(nuevoRegistro.funcionario__c <> trigger.oldMap.get(nuevoRegistro.id).funcionario__c && miembro.comite__c == nuevoRegistro.Comite__c && miembro.funcionario__c == nuevoRegistro.funcionario__c){
                            nuevoRegistro.adderror('El funcionario ya tiene un cargo activo asignado dentro del comité');
                        }
                        
                    }
                    if(countRepresentantes >= comites.get(nuevoRegistro.comite__c).cantidad_representantes__c){
                        nuevoRegistro.adderror('La cantidad de funcionarios activos de titularidad '+nuevoRegistro.titularidad__c+' ha llegado al tope máximo de '+countRepresentantes+' en representación de: '+nuevoRegistro.representante_de__c); 
                    }
                }
            }
        }
    }
}