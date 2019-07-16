/*Trigger para validar que no se repita una asociación de una sede a una normatividad
* @Marcela Taborda
* @version 1.0
* @date 05/02/2019
*/
trigger SST_NormatividadSedeTrigger on SST_Normatividad_sede__c (before insert) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            List<Id> sedes = new List<Id>();
            List<Id> normas = new List<Id>();
            for(SST_Normatividad_sede__c temp : trigger.new){
                sedes.add(temp.sede__c);    
                normas.add(temp.normatividad__c);    
            }
            Map<Id,sst_sede__c> mapaSedes = new Map<Id,sst_sede__c>([select id, name from sst_sede__c where id in: sedes]);
            Map<Id,sst_normatividad__c> mapaNormas = new Map<Id,sst_normatividad__c>([select id, name from sst_normatividad__c where id in: normas]);
            Map<String,SST_Normatividad_sede__c> mapaRegistros = new Map<String,SST_Normatividad_sede__c>();
            
            for(SST_Normatividad_sede__c temp : [select id, name, sede__c, sede__r.name, normatividad__c, normatividad__r.name from SST_Normatividad_sede__c where sede__c in: sedes and normatividad__c in: normas]){
                mapaRegistros.put(temp.normatividad__c+'-'+temp.sede__c,temp);   
            }
            for(SST_Normatividad_sede__c nuevoRegistro : trigger.new){
                String cadena = nuevoRegistro.normatividad__c+'-'+nuevoRegistro.sede__c;
                //Se valida si la asociación de la sede y la normatividad ya existe
                if(mapaRegistros.size()>0 && mapaRegistros.get(cadena) <> null){
                    nuevoRegistro.adderror('La sede: '+mapaRegistros.get(cadena).sede__r.name+', ya se encuentra asociada a la normatividad: '+mapaRegistros.get(cadena).normatividad__r.name);    
                } 
            }
        }
    }
}