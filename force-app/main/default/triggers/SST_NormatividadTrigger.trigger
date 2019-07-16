/*Trigger para validaciones sobre el objeto Normatividad previo a la inserción
* @Yanebi Tamayo
* @date 20/12/2018
*/
trigger SST_NormatividadTrigger on SST_Normatividad__c (before insert, before update) {
    if(trigger.isBefore){
        Integer cantidadEmpresas = SST_Constantes.getCantidadEmpresas();
        if(trigger.isInsert){
            List <String> nombresNormatividades = new List <String>();
            List <String> articulosNormatividades = new List <String>();
            List <String> empresasNormatividades = new List <String>();
                        
            for(SST_Normatividad__c nuevoRegistro : trigger.new){
                nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.Articulo__c;
                if(cantidadEmpresas > 1){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.Articulo__c+'-'+nuevoRegistro.empresa__c;
                }
                nombresNormatividades.add(nuevoRegistro.name);
                articulosNormatividades.add(nuevoRegistro.Articulo__c);
                empresasNormatividades.add(nuevoRegistro.empresa__c);
            }
            
            //Se valida si existen Normatividades con el mismo nombre en la misma empresa
            List<SST_Normatividad__c> normatividadesExistentes = [Select id, name,Articulo__c, empresa__c from SST_Normatividad__c where name in : nombresNormatividades and Articulo__c =: articulosNormatividades and empresa__c =: empresasNormatividades];
            if(normatividadesExistentes.size()>0){
                for(SST_Normatividad__c nuevoRegistro : trigger.new){
                    for(SST_Normatividad__c temp : normatividadesExistentes){
                        if(nuevoRegistro.name.equalsIgnoreCase(temp.name) &&nuevoRegistro.Articulo__c.equalsIgnoreCase(temp.Articulo__c) &&nuevoRegistro.empresa__c.equalsIgnoreCase(temp.empresa__c)){
                            nuevoRegistro.adderror('Ya existe una Normatividad con el nombre '+temp.name+' y el artículo '+temp.Articulo__c+' en la misma empresa. Edite la Normatividad existente o bien indique otro nombre para la actual.');      
                        }
                    }
                }
            }
        }
        if(trigger.isUpdate){
            List <String> nombresNormatividades = new List <String>();
            List <String> articulosNormatividades = new List <String>();
            List <String> empresasNormatividades = new List <String>();
            //Si se modifica el nombre de la normatividad, se adiciona a la lista
            for(SST_Normatividad__c nuevoRegistro : trigger.new){
                if(!trigger.oldMap.get(nuevoRegistro.id).name.equals(nuevoRegistro.name)){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.name;
                    if(cantidadEmpresas > 1){
                        nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.Articulo__c+'-'+nuevoRegistro.empresa__c;
                    }else{
                        nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.Articulo__c;
                    }
                    nombresNormatividades.add(nuevoRegistro.name);
                    articulosNormatividades.add(nuevoRegistro.Articulo__c);
                    empresasNormatividades.add(nuevoRegistro.empresa__c);   
                }
            }
            
            //Si se modifica el artículo de la normatividad, se adiciona a la lista
            for(SST_Normatividad__c nuevoRegistro : trigger.new){
                if(trigger.oldMap.get(nuevoRegistro.id).Articulo__c!=null && !trigger.oldMap.get(nuevoRegistro.id).Articulo__c.equals(nuevoRegistro.Articulo__c)){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.Articulo__c;
                    if(cantidadEmpresas > 1){
                        nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.Articulo__c+'-'+nuevoRegistro.empresa__c;
                    }else{
                        nuevoRegistro.codigo_externo__c = nuevoRegistro.name+'-'+nuevoRegistro.Articulo__c;
                    }
                    nombresNormatividades.add(nuevoRegistro.name);
                    articulosNormatividades.add(nuevoRegistro.Articulo__c);
                    empresasNormatividades.add(nuevoRegistro.empresa__c); 
                }
            }
            
            
            //Se valida si existen Normatividades con el mismo nombre en la misma empresa
            if(nombresNormatividades.size()>0){
                List<SST_Normatividad__c> normatividadesExistentes = [Select id, name,Articulo__c, empresa__c from SST_Normatividad__c where name in : nombresNormatividades and Articulo__c =: articulosNormatividades and empresa__c =: empresasNormatividades];
                if(normatividadesExistentes.size()>0){
                    for(SST_Normatividad__c nuevoRegistro : trigger.new){
                        for(SST_Normatividad__c temp : normatividadesExistentes){
                            if(nuevoRegistro.name.equalsIgnoreCase(temp.name) &&nuevoRegistro.Articulo__c.equalsIgnoreCase(temp.Articulo__c) &&nuevoRegistro.empresa__c.equalsIgnoreCase(temp.empresa__c)){
                                nuevoRegistro.adderror('Ya existe una Normatividad con el nombre '+temp.name+' y el artículo '+temp.Articulo__c+' en la misma empresa. Edite la Normatividad existente o bien indique otro nombre para la actual.');      
                            }
                        }
                    }      
                }
            }            
        }
    }
}