/*Trigger para validaciones sobre el objeto Formación Cargo antes y después de insertar y de actualizar */
trigger SST_FormacionCargoTrigger on SST_Formacion_Cargo__c (before insert, before update,after insert, after update,after delete) {
    
    
    if(trigger.isBefore){
        /*Al insertar un nuevo registro se valida el tipo de formación para así mismo asignarle un nombre a la asociación de la formación con el cargo*/
        set<ID> idFormaciones = new set<ID>();
        set<ID> idCargos = new set<ID>();
        
        for(SST_Formacion_Cargo__c nuevoRegistro :Trigger.new){
            idFormaciones.add(nuevoRegistro.formacion__c);
            idCargos.add(nuevoRegistro.cargo__c);
        }
        Map<Id, SST_Formacion__c> formacionesActuales = New Map<Id, SST_Formacion__c> ([select id, RecordTypeId, RecordType.name, name,Nombre__c from SST_Formacion__c where id in:idFormaciones]);
        Map<Id, SST_Cargo__c> cargosActuales = New Map<Id, SST_Cargo__c> ([Select id, name, empresa__c from sst_cargo__c where id in: idCargos]);
        List <String> listaNames = new List <String>();
        if(trigger.isInsert){
            for(SST_Formacion_Cargo__c nuevoRegistro :Trigger.new){ 
                
                SST_Formacion__c formacion = formacionesActuales.get(nuevoRegistro.formacion__c);
                SST_Cargo__c cargo = cargosActuales.get(nuevoRegistro.cargo__c);
                nuevoRegistro.Name = cargo.name + ' - ';
                if(formacion.recordType.name.contains (SST_Constantes.RECORD_TYPE_RESPONSABILIDADES)){
                    nuevoRegistro.Name= nuevoRegistro.Name + SST_Constantes.RESPONSABILIDAD_CARGO+': '+formacion.Nombre__c;
                }
                else if(formacion.recordType.name.contains (SST_Constantes.RECORD_TYPE_RESPONSABILIDADES_COMITE)){
                    nuevoRegistro.Name= nuevoRegistro.Name + SST_Constantes.RESPONSABILIDAD_COMITE+': '+formacion.Nombre__c;
                }
                
                else if(formacion.recordType.name.contains (SST_Constantes.RECORD_TYPE_COMPETENCIAS)){
                    nuevoRegistro.Name= nuevoRegistro.Name + SST_Constantes.COMPETENCIA+': ' + formacion.Nombre__c;
                }	
                else{
                    nuevoRegistro.Name= nuevoRegistro.Name+SST_Constantes.ENTRENAMIENTO+': '+formacion.Nombre__c;
                }	
                if(nuevoRegistro.name.length()>80){
                    nuevoRegistro.Name = nuevoRegistro.Name.substring(0, 80);
                }
                listaNames.add(nuevoRegistro.Name);
            }
            //Se consulta si existen asociaciones de formación cargos con los mismos nombres de los nuevos registros
            Map <String, SST_formacion_cargo__c> mapaRegistros = new Map <String, SST_formacion_cargo__c>([select id, name, Formacion__r.name, cargo__r.name from SST_formacion_cargo__c where name in: listaNames]);
            if(mapaRegistros.size()>0){
                for(SST_Formacion_Cargo__c nuevoRegistro :Trigger.new){
                    if(mapaRegistros.get(nuevoRegistro.name) <> null){
                        nuevoRegistro.addError('La formación '+mapaRegistros.get(nuevoRegistro.name).formacion__r.name+' ya ha sido asociada con anterioridad al cargo '+mapaRegistros.get(nuevoRegistro.name).cargo__r.name);       
                    }
                }
            }
        }
        if(trigger.isUpdate){ 
       /*Al actualizar el registro se valida el tipo de formación para así mismo asignarle un nombre a la asociación de la formación con el cargo*/

            for(SST_Formacion_Cargo__c nuevoRegistro :Trigger.new){
                
                SST_Cargo__c cargo = cargosActuales.get(nuevoRegistro.cargo__c);
                SST_Formacion__c formacion = formacionesActuales.get(nuevoRegistro.formacion__c);
                SST_Formacion_Cargo__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                
                if(registroModificar.formacion__c != nuevoRegistro.formacion__c){
                    nuevoRegistro.Name = cargo.name + ' - ';
                    if(formacion.recordType.name.contains (SST_Constantes.RECORD_TYPE_RESPONSABILIDADES)){
                        nuevoRegistro.Name= nuevoRegistro.Name+SST_Constantes.RESPONSABILIDAD_CARGO+': '+formacion.Nombre__c;
                    }
                    else if(formacion.recordType.name.contains (SST_Constantes.RECORD_TYPE_RESPONSABILIDADES_COMITE)){
                        nuevoRegistro.Name= nuevoRegistro.Name+SST_Constantes.RESPONSABILIDAD_COMITE+': '+formacion.Nombre__c;
                    }
                    
                    else if(formacion.recordType.name.contains (SST_Constantes.RECORD_TYPE_COMPETENCIAS)){
                        nuevoRegistro.Name= nuevoRegistro.Name+SST_Constantes.COMPETENCIA+': ' + formacion.Nombre__c;
                    }	
                    
                    else{
                        nuevoRegistro.Name= nuevoRegistro.Name+SST_Constantes.ENTRENAMIENTO+': '+formacion.Nombre__c;
                    }	
                    if(nuevoRegistro.name.length()>80){
                        nuevoRegistro.Name = nuevoRegistro.Name.substring(0, 80);
                    } 
                    listaNames.add(nuevoRegistro.Name);
                }
            } 
            if(listaNames.size()>0){
                //Se consulta si existen asociaciones de formación cargos con los mismos nombres de los nuevos registros
                Map <String, SST_formacion_cargo__c> mapaRegistros = new Map <String, SST_formacion_cargo__c>([select id, name, Formacion__r.name, cargo__r.name from SST_formacion_cargo__c where name in: listaNames]);
                if(mapaRegistros.size()>0){
                    for(SST_Formacion_Cargo__c nuevoRegistro :Trigger.new){
                        if(mapaRegistros.get(nuevoRegistro.name) <> null){
                            nuevoRegistro.addError('La formación '+mapaRegistros.get(nuevoRegistro.name).formacion__r.name+' ya ha sido asociada con anterioridad al cargo '+mapaRegistros.get(nuevoRegistro.name).cargo__r.name);       
                        }
                    }
                }
            }
        }
    }
    else if(trigger.isAfter){
        Set<String> empresasPeligros = new Set<String>();
        if(trigger.isInsert || trigger.isUpdate){
		set<ID> idCargos = new set<ID>();        
        for(SST_Formacion_Cargo__c nuevoRegistro :Trigger.new){
            idCargos.add(nuevoRegistro.cargo__c);
        }
        Map<Id, SST_Cargo__c> cargosActuales = New Map<Id, SST_Cargo__c> ([Select id, name, empresa__c from sst_cargo__c where id in: idCargos]);
        
            for(SST_Formacion_Cargo__c nuevoRegistro :Trigger.new){ 
                SST_Cargo__c cargo = cargosActuales.get(nuevoRegistro.cargo__c);
                empresasPeligros.add(cargo.empresa__c);
            }
        }
        if(trigger.isdelete){
            empresasPeligros.add(SST_Constantes.getEmpresaAutenticada());
        }
        /*se realiza la actualización de la cantidad de expuestos en los peligros*/
        SST_Constantes.actualizarExpuestosPeligros(null,empresasPeligros);
    }
}