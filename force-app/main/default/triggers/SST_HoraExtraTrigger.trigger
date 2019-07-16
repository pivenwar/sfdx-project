/*Trigger para validaciones sobre el objeto Hora extra previo a la inserción y actualización
* @Marcela Taborda
* @version 3.0
* @date 18/12/2018
*/
trigger SST_HoraExtraTrigger on SST_Hora_Extra__c (before insert, before update) {    
    if(trigger.isBefore){
        //Al insertar un nuevo registro, se valida si el funcionario ya tenía previamente registradas horas extras para el mismo mes y año
        if(trigger.isInsert){
            Map <Id,SST_Hora_Extra__c> mapaFuncionarios = new Map <Id,SST_Hora_Extra__c>();
            List <String> meses = new List <String>();
            List <Decimal> anios = new List <Decimal>();
            List <Id> idFuncionarios = new List <Id>();
            for(SST_Hora_Extra__c nuevoRegistro :Trigger.new){ 
                meses.add(nuevoRegistro.Mes__c);
                anios.add(nuevoRegistro.Anio__c);
                idFuncionarios.add(nuevoRegistro.funcionario__c);
            }
            List<SST_Hora_Extra__c> registrosExistentes = [select id, name, funcionario__r.name, mes__c, anio__c from SST_Hora_Extra__c  where funcionario__c in : idFuncionarios and Mes__c in: meses and Anio__c in: anios];
            if(registrosExistentes.size()>0){
                for(SST_Hora_Extra__c nuevoRegistro : registrosExistentes){
                    mapaFuncionarios.put(nuevoRegistro.Funcionario__c,nuevoRegistro);
                }
                for(SST_Hora_Extra__c nuevoRegistro : Trigger.new){
                    if(mapaFuncionarios.get(nuevoRegistro.Funcionario__c) <> null){
                        SST_Hora_Extra__c temp = mapaFuncionarios.get(nuevoRegistro.Funcionario__c);
                        if(temp.Mes__c.equals(nuevoRegistro.Mes__c) && temp.Anio__c == nuevoRegistro.Anio__c){
                            nuevoRegistro.adderror('El funcionario ya tiene horas extras registradas para el mes '+nuevoRegistro.Mes__c+' del año '+String.valueOf(nuevoRegistro.Anio__c));   
                        }
                    }
                }
            }
        }
        
        //Al modificar un registro y cambiar el año y/o mes, se valida si el funcionario ya tenía previamente registradas horas extras para el mismo periodo
        if(trigger.isUpdate){
            Map <Id,SST_Hora_Extra__c> mapaFuncionarios = new Map <Id,SST_Hora_Extra__c>();
            List <String> meses = new List <String>();
            List <Decimal> anios = new List <Decimal>();
            List <Id> idFuncionarios = new List <Id>();
            for(SST_Hora_Extra__c nuevoRegistro : Trigger.new){
                SST_Hora_Extra__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                if(registroModificar.Mes__c != nuevoRegistro.Mes__c || registroModificar.Anio__c != nuevoRegistro.Anio__c){
                    idFuncionarios.add(nuevoRegistro.funcionario__c);
                    meses.add(nuevoRegistro.Mes__c);
                    anios.add(nuevoRegistro.Anio__c);
                }
            }
            if(idFuncionarios <> null && idFuncionarios.size()>0){
                List<SST_Hora_Extra__c> registrosExistentes = [select id, name, funcionario__r.name, mes__c, anio__c from SST_Hora_Extra__c  where funcionario__c in : idFuncionarios and Mes__c in: meses and Anio__c in: anios];
                if(registrosExistentes.size()>0){
                    for(SST_Hora_Extra__c nuevoRegistro : registrosExistentes){
                        mapaFuncionarios.put(nuevoRegistro.Funcionario__c,nuevoRegistro);
                    }
                    for(SST_Hora_Extra__c nuevoRegistro : Trigger.new){
                        if(mapaFuncionarios.get(nuevoRegistro.Funcionario__c) <> null){
                            SST_Hora_Extra__c temp = mapaFuncionarios.get(nuevoRegistro.Funcionario__c);
                            if(temp.Mes__c.equals(nuevoRegistro.Mes__c) && temp.Anio__c == nuevoRegistro.Anio__c){
                                nuevoRegistro.adderror('El funcionario '+temp.funcionario__r.name+' ya tiene horas extras registradas para el mes '+nuevoRegistro.Mes__c+' del año '+String.valueOf(nuevoRegistro.Anio__c));   
                            }
                        }
                    }
                }
            }
        } 
    }
}