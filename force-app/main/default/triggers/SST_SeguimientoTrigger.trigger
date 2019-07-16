/*Trigger para validaciones sobre el objeto Seguimiento previo a la inserción y actualización
* @Yanebi Tamayo
* @date 20/12/2018
*/
trigger SST_SeguimientoTrigger on SST_Seguimiento__c (before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            List <String> nombresSeguimientos = new List <String>();
            List <String> empresasSeguimientos = new List <String>();
            List <String> recordType = new List <String>();
            List<SST_Seguimiento__c> seguimientos = trigger.new;
            for(SST_Seguimiento__c nuevoRegistro : seguimientos){
                nombresSeguimientos.add(nuevoRegistro.name);
                empresasSeguimientos.add(nuevoRegistro.empresa__c);
                recordType.add(nuevoRegistro.RecordTypeId);
            }
            Integer cantidadEmpresas = SST_Constantes.getCantidadEmpresas();
            //Se valida si existen Seguimientos con el mismo nombre en la misma empresa
            List<SST_Seguimiento__c> seguimientosExistentes = [Select id, name, empresa__c from SST_Seguimiento__c where name in : nombresSeguimientos and empresa__c =: empresasSeguimientos and RecordTypeId=: recordType];
            for(SST_Seguimiento__c nuevoRegistro : trigger.new){
                nuevoRegistro.codigo_externo__c = nuevoRegistro.name;
                if(cantidadEmpresas> 1){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.empresa__c;
                }
                if(seguimientosExistentes.size()>0){        
                    for(SST_Seguimiento__c temp : seguimientosExistentes){
                        if(nuevoRegistro.name.equalsIgnoreCase(temp.name) &&nuevoRegistro.empresa__c.equalsIgnoreCase(temp.empresa__c)){
                            nuevoRegistro.adderror('Ya existe un Seguimiento con el nombre '+temp.name+' en la misma empresa. Edite el Seguimiento existente o bien indique otro nombre para la actual.');      
                        }
                    }
                }
            }
        }
        if(trigger.isUpdate){
            List <String> nombresSeguimientos = new List <String>();
            List <String> empresasSeguimientos = new List <String>();
            Integer cantidadEmpresas = SST_Constantes.getCantidadEmpresas();
            //Si se modifica el nombre del seguimiento, se adiciona a la lista
            for(SST_Seguimiento__c nuevoRegistro : trigger.new){
                if(!trigger.oldMap.get(nuevoRegistro.id).name.equals(nuevoRegistro.name)){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.name;
                    if(cantidadEmpresas > 1){
                        nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.empresa__c;
                    }
                    nombresSeguimientos.add(nuevoRegistro.name);
                    empresasSeguimientos.add(nuevoRegistro.empresa__c);   
                }
            }
            if(nombresSeguimientos.size()>0){
                //Se valida si existen Seguimientos con el mismo nombre en la misma empresa
                List<SST_Seguimiento__c> seguimientosExistentes = [Select id, name, empresa__c from SST_Seguimiento__c where name in : nombresSeguimientos and empresa__c =: empresasSeguimientos];
                if(seguimientosExistentes.size()>0){
                    for(SST_Seguimiento__c nuevoRegistro : trigger.new){
                        for(SST_Seguimiento__c temp : seguimientosExistentes){
                            if(nuevoRegistro.name.equalsIgnoreCase(temp.name) &&nuevoRegistro.empresa__c.equalsIgnoreCase(temp.empresa__c)&& !temp.id.equals(nuevoRegistro.id)){
                                nuevoRegistro.adderror('Ya existe un Seguimiento con el nombre '+temp.name+' en la misma empresa. Edite el Seguimiento existente o bien indique otro nombre para la actual.');      
                            }
                        }
                    }
                }
            }
        }
    }
}