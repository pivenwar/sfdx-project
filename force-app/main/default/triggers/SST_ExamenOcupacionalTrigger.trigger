/*Trigger para calcular automáticamente la fecha del próximo examen ocupacional
* @Marcela Taborda
* @version 2.0
* @date 19/12/2018
*/
trigger SST_ExamenOcupacionalTrigger on SST_Examen_Ocupacional__c (before insert){
    if(trigger.isBefore){
        if(trigger.isInsert){
            Map<Id,Decimal> mapaNits = new Map<Id,Decimal>();
            for(SST_Examen_Ocupacional__c nuevoRegistro : trigger.new){
                mapaNits.put(nuevoRegistro.Funcionario_examen__c,null);
            }
            for(Contact contactoTemp : [select id, sst_empresa__c from contact where id in: mapaNits.keySet()]){
                mapaNits.put(contactoTemp.id,Decimal.valueOf(contactoTemp.sst_empresa__c)); 
            }
            Map<Decimal,Account> cuentas = new Map<Decimal,Account>();
            for(Account cuenta : [SELECT SST_Periodicidad_examen_ocupacional__c,SST_nit__c from Account where SST_nit__c in :mapaNits.values()]){
            	cuentas.put(cuenta.SST_nit__c,cuenta);
            }                           
            for(SST_Examen_Ocupacional__c nuevoRegistro : trigger.new){
                Account cuentaPrincipal = cuentas.get(mapaNits.get(nuevoRegistro.Funcionario_examen__c));
                if(nuevoRegistro.Tipo_examen__c.equals(SST_Constantes.INGRESO) || nuevoRegistro.Tipo_examen__c.equals(SST_Constantes.PERIODICO)){
                    if((nuevoRegistro.proximo_examen__c == null && cuentaPrincipal == null) || (nuevoRegistro.proximo_examen__c == null && cuentaPrincipal <> null && cuentaPrincipal.SST_Periodicidad_examen_ocupacional__c == null)){
                        nuevoRegistro.adderror('No se ha indicado la periodicidad de los exámenes ocupacionales en la empresa.  Puede parametrizar la periodicidad en el menú Configuración >> Datos de la empresa, o diligencie el campo Fecha Próximo Examen');
                    } else if(nuevoRegistro.proximo_examen__c == null && cuentaPrincipal <> null && cuentaPrincipal.SST_Periodicidad_examen_ocupacional__c <> null){
                        Integer dias = Integer.valueOf(cuentaPrincipal.SST_Periodicidad_examen_ocupacional__c);
                        nuevoRegistro.proximo_examen__c = nuevoRegistro.fecha_examen__c.addDays(dias);
                        nuevoRegistro.periodicidad_calculada__c = true;
                    }
                } 
            }
        }
    }
}