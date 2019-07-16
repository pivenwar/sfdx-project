/*Trigger para validaciones sobre el objeto SeguimientosELC_Diagnostico antes y después de la actualización.
* @Marcela Taborda
* @version 1.0
* @date 28/03/2019
*/
trigger SST_SeguimientosELCDiagnosticosTrigger on SST_SeguimientoELC_DiagnosticoCIE10__c (before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            Map <String,String> mapaSeguimientosELC =  new Map <String,String>();
            List <String> seguimientosELC =  new List <String>();
            List<SST_SeguimientoELC_DiagnosticoCIE10__c> listaSeguimientosELC = new List<SST_SeguimientoELC_DiagnosticoCIE10__c>();
            Map<String,String> mapaSeguimientosFuncionarios = new Map<String,String>();
            //Se llena una lista con los id de los seguimientos ELC de los nuevos registros
            for(SST_SeguimientoELC_DiagnosticoCIE10__c temp : trigger.new){
                seguimientosELC.add(temp.Seguimiento_ELC__c);
            }
            //Se consultan los registros existentes asociados a los mismos seguimientos ELC de los nuevos registros,
            //se llena un mapa cuya llave es la concatenación del ID del seguimiento ELC y el Diagnóstico CIE10
            for(SST_SeguimientoELC_DiagnosticoCIE10__c temp : [select id, name, Diagnostico_CIE10__c, Seguimiento_ELC__c, Seguimiento_ELC__r.estado_recomendaciones__c, Seguimiento_ELC__r.funcionario__c from SST_SeguimientoELC_DiagnosticoCIE10__c where seguimiento_ELC__c in: seguimientosELC]){
                mapaSeguimientosELC.put(temp.Seguimiento_ELC__c+'/'+temp.Diagnostico_CIE10__c,temp.Seguimiento_ELC__c+'/'+temp.Diagnostico_CIE10__c);  
            }
            //Se llena un mapa cuya llave son los id de los seguimientos ELC asociados a los nuevos registros, y los valores son los id de los funcionarios de cada seguimiento ELC
            for(SST_Seguimiento_ELC__c temp : [SELECT Id, Name, Funcionario__c FROM SST_Seguimiento_ELC__c where id in: seguimientosELC]){
                mapaSeguimientosFuncionarios.put(temp.id,temp.funcionario__c);
            }
            //Con la lista de id de funcionarios, se consultan otros seguimientos ELC y diagnósticos existentes para los mismos funcionarios
            if(mapaSeguimientosFuncionarios.size()>0){
                for(SST_SeguimientoELC_DiagnosticoCIE10__c temp : [select id, Diagnostico_CIE10__c, Seguimiento_ELC__r.funcionario__c from SST_SeguimientoELC_DiagnosticoCIE10__c where seguimiento_ELC__r.funcionario__c in: mapaSeguimientosFuncionarios.values() and Seguimiento_ELC__r.estado_recomendaciones__c =: SST_Constantes.VIGENTE]){
                    listaSeguimientosELC.add(temp);
                }   
            }
            for(SST_SeguimientoELC_DiagnosticoCIE10__c nuevoRegistro : trigger.new){
            	//Se recorre el mapa de los registros existentes, para verificar si existe una asociación previa al mismo seguimiento ELC y diagnóstico CIE10
                if(mapaSeguimientosELC.get(nuevoRegistro.Seguimiento_ELC__c+'/'+nuevoRegistro.Diagnostico_CIE10__c) <> null){
                    nuevoRegistro.addError('El diagnóstico ya se encuentra asociado al seguimiento de ELC');    
                }
                //Se verifica si los diagnósticos CIE10 de los registros actuales, ya están asociados a los mismos funcionarios bajo otros seguimientos ELC con recomendaciones aún vigentes
                /*if(listaSeguimientosELC.size()>0){
                    for(SST_SeguimientoELC_DiagnosticoCIE10__c temp : listaSeguimientosELC){
                        String funcionario = mapaSeguimientosFuncionarios.get(nuevoRegistro.Seguimiento_ELC__c);
                        if(temp.Seguimiento_ELC__r.funcionario__c == funcionario && temp.Diagnostico_CIE10__c == nuevoRegistro.Diagnostico_CIE10__c){
                            nuevoRegistro.addError('El funcionario asociado al seguimiento de ELC actual, ya tiene el mismo diagnóstico asociado a otro seguimiento de ELC con recomendaciones vigentes'); 
                        }
                    }
                }*/
            }
        }
        if(trigger.isUpdate){
            Map <String,String> mapaSeguimientosELC =  new Map <String,String>();
            List <String> seguimientosELC =  new List <String>();
            List <Id> idRegistros = new List <Id>();
            List<SST_SeguimientoELC_DiagnosticoCIE10__c> listaSeguimientosELC = new List<SST_SeguimientoELC_DiagnosticoCIE10__c>();
            Map<String,String> mapaSeguimientosFuncionarios = new Map<String,String>();
            //En caso que se modifique el diagnóstico CIE10 de uno o más registros, se llena una lista con los id de los seguimientos ELC de los registros a modificar
            //y una lista con los id de dichos registros
            for(SST_SeguimientoELC_DiagnosticoCIE10__c temp : trigger.new){
                if(trigger.oldMap.get(temp.id).Diagnostico_CIE10__c <> temp.Diagnostico_CIE10__c){
                    seguimientosELC.add(temp.Seguimiento_ELC__c);   
                    idRegistros.add(temp.id);
                }
            }
            if(seguimientosELC.size()>0){                   
                //Se consultan los registros existentes asociados a los mismos seguimientos ELC de los registros a modificar sin incluir éstos últimos,
            	//se llena un mapa cuya llave es la concatenación del ID del seguimiento ELC y el Diagnóstico CIE10
                for(SST_SeguimientoELC_DiagnosticoCIE10__c temp : [select id, name, Diagnostico_CIE10__c, Seguimiento_ELC__c, Seguimiento_ELC__r.estado_recomendaciones__c, Seguimiento_ELC__r.funcionario__c from SST_SeguimientoELC_DiagnosticoCIE10__c where seguimiento_ELC__c in: seguimientosELC and id not in: idRegistros]){
                    mapaSeguimientosELC.put(temp.Seguimiento_ELC__c+'/'+temp.Diagnostico_CIE10__c,temp.Seguimiento_ELC__c+'/'+temp.Diagnostico_CIE10__c);  
                }
                //Se llena un mapa cuya llave son los id de los seguimientos ELC asociados a los nuevos registros, y los valores son los id de los funcionarios de cada seguimiento ELC
                for(SST_Seguimiento_ELC__c temp : [SELECT Id, Name, Funcionario__c FROM SST_Seguimiento_ELC__c where id in: seguimientosELC]){
                    mapaSeguimientosFuncionarios.put(temp.id,temp.funcionario__c);
                }
                if(mapaSeguimientosFuncionarios.size()>0){
                    //Con la lista de id de funcionarios, se consultan otros seguimientos ELC y diagnósticos existentes para los mismos funcionarios, diferentes a los registros que están siendo modificados
                    for(SST_SeguimientoELC_DiagnosticoCIE10__c temp : [select id, name, Diagnostico_CIE10__c, Seguimiento_ELC__c, Seguimiento_ELC__r.estado_recomendaciones__c, Seguimiento_ELC__r.funcionario__c from SST_SeguimientoELC_DiagnosticoCIE10__c where seguimiento_ELC__r.funcionario__c in: mapaSeguimientosFuncionarios.values() AND seguimiento_ELC__r.estado_recomendaciones__c =: SST_Constantes.VIGENTE and id not in: idRegistros]){
                        listaSeguimientosELC.add(temp);
                    }   
                }
                for(SST_SeguimientoELC_DiagnosticoCIE10__c nuevoRegistro : trigger.new){
                    if(trigger.oldMap.get(nuevoRegistro.id).Diagnostico_CIE10__c <> nuevoRegistro.Diagnostico_CIE10__c){  
                        //Se recorre el mapa de los registros existentes, para verificar si existe una asociación previa al mismo seguimiento ELC y diagnóstico CIE10 que está siendo modificado
                        if(mapaSeguimientosELC.get(nuevoRegistro.Seguimiento_ELC__c+'/'+nuevoRegistro.Diagnostico_CIE10__c) <> null){
                            nuevoRegistro.addError('El diagnóstico ya se encuentra asociado al seguimiento de ELC');    
                        }
                        /*if(listaSeguimientosELC.size()>0){
                            //Se verifica si los diagnósticos CIE10 que están siendo modificados, ya están asociados a los mismos funcionarios bajo otros seguimientos ELC con recomendaciones aún vigentes
                            for(SST_SeguimientoELC_DiagnosticoCIE10__c temp : listaSeguimientosELC){
                                String funcionario = mapaSeguimientosFuncionarios.get(nuevoRegistro.Seguimiento_ELC__c);
                                if(temp.Seguimiento_ELC__r.funcionario__c == funcionario && temp.Diagnostico_CIE10__c == nuevoRegistro.Diagnostico_CIE10__c){
                                    nuevoRegistro.addError('El funcionario asociado al seguimiento de ELC actual, ya tiene el mismo diagnóstico asociado a otro seguimiento de ELC con recomendaciones vigentes'); 
                                }
                            }
                        }*/
                    }
                }
            }
        }
    }
}