/*Trigger para validaciones sobre el objeto Elementos de Protección Personal previo a la inserción y actualización.
* @Yanebi Tamayo
* @version 1.0
* @date 18/02/2018
*/

trigger SST_EppTrigger on SST_Elemento_Proteccion_Personal__c (before insert, before update, before delete) {
    
    if(trigger.isBefore){
        
        Integer catidadEmpresas = SST_Constantes.getCantidadEmpresas();
        
        //Al insertar un nuevo registro, se valida que no exista un epp con el mismo código en la misma empresa
        if(Trigger.isInsert){
            List <String> empresasEpp = new List <String>();
            List <String> codigosEpp = new List <String>();
            Map <String,SST_Elemento_Proteccion_Personal__c> mapaEpp = new Map <String,SST_Elemento_Proteccion_Personal__c>();
            for(SST_Elemento_Proteccion_Personal__c nuevoRegistro : Trigger.new){
                codigosEpp.add(nuevoRegistro.Codigo__c);
                empresasEpp.add(nuevoRegistro.empresa__c);
                
            }
            
            
            Boolean eppExistentes = false;
            
            for(SST_Elemento_Proteccion_Personal__c temp : [Select id, Codigo__c, empresa__c from SST_Elemento_Proteccion_Personal__c where Empresa__c in:empresasEpp and Codigo__c in: codigosEpp]){
                eppExistentes = true;
                String c = temp.Codigo__c.toLowerCase()+'/'+temp.empresa__c;
                mapaEpp.put(c,temp);
            }
            for(SST_Elemento_Proteccion_Personal__c nuevoRegistro : trigger.new){
                nuevoRegistro.codigo_externo__c = nuevoRegistro.Codigo__c;
                if(catidadEmpresas > 1){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.Codigo__c+'-'+nuevoRegistro.empresa__c;
                }
                if(eppExistentes){
                    String c = nuevoRegistro.Codigo__c.toLowerCase()+'/'+nuevoRegistro.empresa__c;
                    SST_Elemento_Proteccion_Personal__c temp = mapaEpp.get(c);
                    if(temp<>null){
                        nuevoRegistro.adderror('Ya existe un elemento con el Código '+nuevoRegistro.Codigo__c+' en la misma empresa.');       
                    }
                } 
            }
        }
        
        if (Trigger.isUpdate){
            List <String> empresasEpp = new List <String>();
            List <String> codigosEpp = new List <String>();
            Map <String,SST_Elemento_Proteccion_Personal__c> mapaEpp = new Map <String,SST_Elemento_Proteccion_Personal__c>();
            
            //Al modificar un registro y modificar el código, se valida que no exista un epp con el mismo código
            for(SST_Elemento_Proteccion_Personal__c nuevoRegistro : Trigger.new){
                SST_Elemento_Proteccion_Personal__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                if(!nuevoRegistro.Codigo__c.equalsIgnoreCase(registroModificar.Codigo__c)){
                    nuevoRegistro.codigo_externo__c = nuevoRegistro.Codigo__c;
                    if(catidadEmpresas > 1){
                        nuevoRegistro.codigo_externo__c = nuevoRegistro.Codigo__c+'-'+nuevoRegistro.empresa__c;
                    }
                    codigosEpp.add(nuevoRegistro.Codigo__c);
                    empresasEpp.add(nuevoRegistro.empresa__c);
                }
                
            }
            if(codigosEpp<>null && codigosEpp.size()>0){
                
                boolean eppExistentes = false;
                for(SST_Elemento_Proteccion_Personal__c temp : [Select id, Codigo__c,empresa__c from SST_Elemento_Proteccion_Personal__c where Empresa__c in:empresasEpp and Codigo__c in: codigosEpp]){
                    eppExistentes = true;
                    String c = temp.Codigo__c.toLowerCase()+'/'+temp.empresa__c;
                    mapaEpp.put(c,temp);
                }                
                if(eppExistentes){
                    for(SST_Elemento_Proteccion_Personal__c nuevoRegistro : trigger.new){
                        SST_Elemento_Proteccion_Personal__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                        
                        String c = nuevoRegistro.Codigo__c.toLowerCase()+'/'+nuevoRegistro.empresa__c;
                        SST_Elemento_Proteccion_Personal__c temp = mapaEpp.get(c);
                        if(temp<>null){
                            nuevoRegistro.adderror('Ya existe un elemento con el Código '+nuevoRegistro.Codigo__c+' en la misma empresa.');       
                        }   
                        
                    }
                }  
            }
            
        }
        
    }
    
}