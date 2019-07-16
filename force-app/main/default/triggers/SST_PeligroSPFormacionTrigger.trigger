/* Trigger para validaciones sobre el objeto Peligro SP Formacion antes de insertar y actualizar */
trigger SST_PeligroSPFormacionTrigger on SST_Peligro_SP_Formacion__c (before insert, before update) {
    
    set<ID> idFormaciones = new set<ID>();
    set<ID> idPeligrosSP = new set<ID>();
    
    for(SST_Peligro_SP_Formacion__c nuevoRegistro :Trigger.new){
        idFormaciones.add(nuevoRegistro.formacion__c);
        idPeligrosSP.add(nuevoRegistro.Peligro_SP__c);
    }
    Map<Id, SST_Formacion__c> formacionesActuales = New Map<Id, SST_Formacion__c> ([select id, RecordTypeId, RecordType.name, name,Competencias__c,Comite__c,Descripcion__c,Nombre__c,Tipo_Cargo__c,Tipo_Responsabilidad__c from SST_Formacion__c where id in:idFormaciones]);
    Map<Id, SST_Peligro_SP__c> peligrosActuales = New Map<Id, SST_Peligro_SP__c> ();
    for(SST_Peligro_SP__c peligro : [Select id, name from SST_Peligro_SP__c where id in: idPeligrosSP]){
        peligrosActuales.put(peligro.Id,peligro);
    }
    
    if(trigger.isInsert){
        /*Al insertar un nuevo registo se valida el tipo de responsabilidad para asociarle un nombre a la asociación entre Peligro SP y la responsabilidad*/
        for(SST_Peligro_SP_Formacion__c nuevoRegistro :Trigger.new){
            SST_Formacion__c formacion = formacionesActuales.get(nuevoRegistro.formacion__c);
            SST_Peligro_SP__c peligro = peligrosActuales.get(nuevoRegistro.Peligro_SP__c);
            nuevoRegistro.Name = peligro.name + ' - ';
            if(formacion.recordType.name.contains (SST_Constantes.RECORD_TYPE_RESPONSABILIDADES)){
                nuevoRegistro.Name= nuevoRegistro.Name + SST_Constantes.RESPONSABILIDAD_CARGO+': '+formacion.Nombre__c;
            }
            if(nuevoRegistro.name.length()>80){
                nuevoRegistro.Name = nuevoRegistro.Name.substring(0, 80);
            }
        }
    }
    
    if(trigger.isUpdate){
        /*Al actualizar el registo se valida el tipo de responsabilidad para asociarle un nombre a la asociación entre Peligro SP y la responsabilidad*/
        for(SST_Peligro_SP_Formacion__c nuevoRegistro :Trigger.new){
            SST_Peligro_SP__c peligro = peligrosActuales.get(nuevoRegistro.Peligro_SP__c);
            SST_Formacion__c formacion = formacionesActuales.get(nuevoRegistro.formacion__c);
            SST_Peligro_SP_Formacion__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
            
            if(registroModificar.formacion__c != nuevoRegistro.formacion__c){
                nuevoRegistro.Name = peligro.name + ' - ';
                 if(formacion.recordType.name.contains (SST_Constantes.RECORD_TYPE_RESPONSABILIDADES)){
                    nuevoRegistro.Name= nuevoRegistro.Name+SST_Constantes.RESPONSABILIDAD_CARGO+': '+formacion.Nombre__c;
                }
                if(nuevoRegistro.name.length()>80){
                    nuevoRegistro.Name = nuevoRegistro.Name.substring(0, 80);
                } 
            }
            
        }
        
    }

}