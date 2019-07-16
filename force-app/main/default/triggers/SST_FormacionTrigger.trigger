/*Trigger para validación de nombre único por tipo de registro de formación al insertar y eliminar
* @Marcela Taborda
* @version 3.0
* @date 18/12/2018
*/
trigger SST_FormacionTrigger on SST_Formacion__c (before insert, before update) {
    if(trigger.isBefore){
        //Al insertar registros, se consulta si existen formaciones del mismo record type y con el mismo nombre en la misma empresa
        if(Trigger.isInsert){
            List <Id> recordsTypes = new List <Id>();
            List <String> nombresFormaciones = new List <String>();
            List <String> empresasFormaciones = new List <String>();
            Map <String,SST_Formacion__c> mapaFormaciones = new Map <String,SST_Formacion__c>();
            for (SST_Formacion__c nuevoRegistro : trigger.new){
                recordsTypes.add(nuevoRegistro.recordTypeId);
                nombresFormaciones.add(nuevoRegistro.nombre__c);
                empresasFormaciones.add(nuevoRegistro.empresa__c);
            }
            Boolean formacionesExistentes = false;
            
            for(SST_Formacion__c temp : [select id, nombre__c, recordTypeId, recordType.name,empresa__c from SST_Formacion__c where Empresa__c in:empresasFormaciones and recordTypeId in: recordsTypes and nombre__c in: nombresFormaciones]){
                formacionesExistentes = true;
                String c = temp.nombre__c.toLowerCase()+'/'+temp.recordTypeId+'/'+temp.empresa__c;
                mapaFormaciones.put(c,temp);
            }
            if(formacionesExistentes){
                for(SST_Formacion__c nuevoRegistro : trigger.new){
                    String c = nuevoRegistro.nombre__c.toLowerCase()+'/'+nuevoRegistro.recordTypeId+'/'+nuevoRegistro.empresa__c;
                    SST_Formacion__c temp = mapaFormaciones.get(c);
                    if(temp<>null && temp.Nombre__c.equalsIgnoreCase(nuevoRegistro.nombre__c) && temp.RecordTypeId==nuevoRegistro.RecordTypeId){
                        nuevoRegistro.adderror('Ya existe una formación con el Tipo de Registro '+temp.RecordType.name+' y el nombre: '+nuevoRegistro.Nombre__c+' en la misma empresa.');       
                    }
                }
            }
        }
        if(Trigger.isUpdate){
            List <Id> recordsTypes = new List <Id>();
            List <String> nombresFormaciones = new List <String>();
            List <String> empresasFormaciones = new List <String>();
            Map <String,SST_Formacion__c> mapaFormaciones = new Map <String,SST_Formacion__c>();
            //Al modificar registros cambiándoles el nombre, se consulta si existen formaciones del mismo record type y con el mismo nombre
            for(SST_Formacion__c nuevoRegistro : trigger.new){
                SST_Formacion__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                if(!registroModificar.nombre__c.equalsIgnoreCase(nuevoRegistro.nombre__c)){
                    recordsTypes.add(nuevoRegistro.recordTypeId);
                    nombresFormaciones.add(nuevoRegistro.nombre__c); 
                    empresasFormaciones.add(nuevoRegistro.empresa__c);
                }
            }
            if(nombresFormaciones<>null && nombresFormaciones.size()>0){
                Boolean formacionesExistentes = false;
                
                for(SST_Formacion__c temp : [select id, nombre__c,empresa__c, recordTypeId, recordType.name from SST_Formacion__c where Empresa__c in:empresasFormaciones and recordTypeId in: recordsTypes and nombre__c in: nombresFormaciones]){
                    formacionesExistentes = true;
                    String c = temp.nombre__c.toLowerCase()+'/'+temp.recordTypeId+'/'+temp.empresa__c;
                    mapaFormaciones.put(c,temp);
                }
                if(formacionesExistentes){
                    for(SST_Formacion__c nuevoRegistro : trigger.new){
                        SST_Formacion__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                        if(!registroModificar.nombre__c.equalsIgnoreCase(nuevoRegistro.nombre__c)){
                            String c = nuevoRegistro.nombre__c.toLowerCase()+'/'+nuevoRegistro.recordTypeId+'/'+nuevoRegistro.empresa__c;
                            SST_Formacion__c temp = mapaFormaciones.get(c);
                            if(temp<>null && temp.Nombre__c.equalsIgnoreCase(nuevoRegistro.nombre__c) && temp.RecordTypeId==nuevoRegistro.RecordTypeId){
                                nuevoRegistro.adderror('Ya existe una formación con el Tipo de Registro '+temp.RecordType.name+' y el nombre: '+nuevoRegistro.Nombre__c+' en la misma empresa.');       
                            }   
                        }
                    }
                }
            }
        }
    }
}