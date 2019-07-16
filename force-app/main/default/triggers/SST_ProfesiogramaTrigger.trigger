/*Trigger para validaciones sobre el objeto Profesiograma previo a la inserción y actualización
* @Marcela Taborda
* @version 3.0
* @date 18/12/2018
*/
trigger SST_ProfesiogramaTrigger on SST_Profesiograma__c (before insert, before update) {      
    //Si se crea un nuevo registro, se valida si ya existe previamente un registro con el mismo cargo, proceso y tipo de examen
    if(trigger.isInsert){
        List <Id> idCargos = new List <Id>();
        List <Id> idProcesos = new List <Id>();
        List <String> empresasProfesiogramas = new List <String>();
        List <String> tiposExamen = new List <String>();
        //Se recorre la lista de registros a insertar para obtener los id de los cargos, procesos y los tipos de examen asociados
        for(SST_Profesiograma__c nuevoRegistro :Trigger.new){
            idCargos.add(nuevoRegistro.Cargo__c);
            idProcesos.add(nuevoRegistro.Proceso__c);
            empresasProfesiogramas.add(nuevoRegistro.empresa__c);
            tiposExamen.add(nuevoRegistro.Tipo_Examen__c);
        }
        //Se obtiene un mapa con los Label de los tipos de examen
        Map <String,String> mapaTiposExamen = new Map <String,String>();
        Schema.DescribeFieldResult fieldResult = SST_Profesiograma__c.Tipo_Examen__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry tipoTemp : itemsTemp){
            mapaTiposExamen.put(tipoTemp.getValue(),tipoTemp.getLabel());
        }
        Map <String,SST_Profesiograma__c> mapaRegistros = new Map <String,SST_Profesiograma__c>();
        //Se recorren los registros similares encontrados para llenar un mapa cuya llave es una cadena con 
        //el id del cargo, el id del proceso, el tipo de examen y la empresa
        for(SST_Profesiograma__c registro : [select id, cargo__c, empresa__c, cargo__r.name, proceso__c, proceso__r.name, Tipo_examen__c, name from SST_Profesiograma__c  where Empresa__c in:empresasProfesiogramas and Cargo__c in: idCargos and Proceso__c in: idProcesos and Tipo_examen__c in: tiposExamen]){
            String c = registro.cargo__c+'/'+registro.proceso__c+'/'+registro.Tipo_examen__c+'/'+registro.empresa__c;
            mapaRegistros.put(c, registro);
        }
        //Se recorre la lista de registros a insertar para identificar cuáles son los registros cuyo cargo, proceso y tipo de examen coincide con otros existentes
        for(SST_Profesiograma__c nuevoRegistro :Trigger.new){
            String c = nuevoRegistro.cargo__c+'/'+nuevoRegistro.proceso__c+'/'+nuevoRegistro.Tipo_examen__c+'/'+nuevoRegistro.empresa__c;
            SST_Profesiograma__c ttmp = mapaRegistros.get(c);
            if(mapaRegistros.size()>0 && (ttmp <> null && ttmp.cargo__c == nuevoRegistro.cargo__c && ttmp.empresa__c == nuevoRegistro.empresa__c && ttmp.Proceso__c == nuevoRegistro.Proceso__c && ttmp.Tipo_examen__c.equals(nuevoRegistro.Tipo_examen__c))){
                nuevoRegistro.adderror('Ya existe un profesiograma para el cargo: '+ttmp.Cargo__r.name+', el proceso: '+ttmp.Proceso__r.name+' y el tipo de examen: '+mapaTiposExamen.get(ttmp.Tipo_examen__c)+' en la misma empresa.');
            }
        }
    }
    //Si se modifica un registro y se modifica el cargo, proceso o tipo de examen, se valida si ya existe previamente un registro con los mismos datos
    if(trigger.isUpdate){
        List <Id> idCargos = new List <Id>();
        List <Id> idProcesos = new List <Id>();
        List <String> empresasProfesiogramas = new List <String>();
        List <String> tiposExamen = new List <String>();
        for(SST_Profesiograma__c nuevoRegistro : Trigger.new){
            SST_Profesiograma__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
            if(registroModificar.Cargo__c!=nuevoRegistro.Cargo__c || registroModificar.Proceso__c !=nuevoRegistro.Proceso__c || !registroModificar.Tipo_examen__c.equalsIgnoreCase(nuevoRegistro.Tipo_examen__c)){
                idCargos.add(nuevoRegistro.Cargo__c);
                idProcesos.add(nuevoRegistro.Proceso__c);
                tiposExamen.add(nuevoRegistro.Tipo_Examen__c);
                empresasProfesiogramas.add(nuevoRegistro.empresa__c);
            }
        }
        if(idCargos <> null && idCargos.size()>0){
            //Se obtiene un mapa con los Label de los tipos de examen
            Map <String,String> mapaTiposExamen = new Map <String,String>();
            Schema.DescribeFieldResult fieldResult = SST_Profesiograma__c.Tipo_Examen__c.getDescribe();
            List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry tipoTemp : itemsTemp){
                mapaTiposExamen.put(tipoTemp.getValue(),tipoTemp.getLabel());
            }
            Map <String,SST_Profesiograma__c> mapaRegistros = new Map <String,SST_Profesiograma__c>();
            //Se recorren los registros similares encontrados para llenar un mapa cuya llave es el id del cargo
            for(SST_Profesiograma__c registro : [select id, cargo__c, cargo__r.name, proceso__c, proceso__r.name, Tipo_examen__c, empresa__c, name from SST_Profesiograma__c  where Empresa__c in :empresasProfesiogramas and Cargo__c in: idCargos and Proceso__c in: idProcesos and Tipo_examen__c in: tiposExamen]){
                String c = registro.cargo__c+'/'+registro.proceso__c+'/'+registro.Tipo_examen__c+'/'+registro.empresa__c;
                mapaRegistros.put(c, registro);
            }
            //Se recorre la lista de registros a insertar para identificar cuáles son los registros cuyo cargo, proceso y tipo de examen coincide con otros existentes
            for(SST_Profesiograma__c nuevoRegistro :Trigger.new){
                SST_Profesiograma__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                if(mapaRegistros.size()>0 && (registroModificar.Cargo__c!=nuevoRegistro.Cargo__c || registroModificar.Proceso__c !=nuevoRegistro.Proceso__c || !registroModificar.Tipo_examen__c.equalsIgnoreCase(nuevoRegistro.Tipo_examen__c))){
                    String c = nuevoRegistro.cargo__c+'/'+nuevoRegistro.proceso__c+'/'+nuevoRegistro.Tipo_examen__c+'/'+nuevoRegistro.empresa__c;
                    SST_Profesiograma__c ttmp = mapaRegistros.get(c);
                    if(ttmp <> null && ttmp.cargo__c == nuevoRegistro.cargo__c && ttmp.empresa__c == nuevoRegistro.empresa__c && ttmp.Proceso__c == nuevoRegistro.Proceso__c && ttmp.Tipo_examen__c.equals(nuevoRegistro.Tipo_examen__c)){
                        nuevoRegistro.adderror('Ya existe un profesiograma para el cargo: '+ttmp.Cargo__r.name+', el proceso: '+ttmp.Proceso__r.name+' y el tipo de examen: '+mapaTiposExamen.get(ttmp.Tipo_examen__c) +' en la misma empresa.');
                    }   
                }
            }   
        }
    }
}