/*Trigger para validaciones sobre el objeto Seguimiento Sede previo a la inserción
* @Marcela Taborda
* @version 4.0
* @date 23/04/2019
*/
trigger SST_SeguimientoSedeTrigger on SST_Seguimiento_Sede__c (before insert){
    ID idPlan = Schema.SObjectType.SST_Seguimiento__c.getRecordTypeInfosByName().get('Planes y Programas').getRecordTypeId();
    /*Bloque que obtiene la lista de tipos de seguimiento de salesforce*/
    Schema.DescribeFieldResult campo = SST_Seguimiento__c.Tipo__c.getDescribe();
    List<Schema.PicklistEntry> picklist = campo.getPicklistValues();
    Map<String,String> listaTiposSeguimiento = new Map<String,String>();
    for( Schema.PicklistEntry pickItem : picklist){
        listaTiposSeguimiento.put(pickItem.getValue(),pickItem.getLabel());
    } 
    /*Fin Bloque que obtiene la lista de tipos de seguimientos de salesforce*/
    if(trigger.isBefore){
        if(trigger.isInsert){
            List <Id> idSeguimientos = new List <Id>();
            List <Id> idSedes = new List <Id>();
            for(SST_Seguimiento_sede__c nuevoRegistro : trigger.new){
                idSeguimientos.add(nuevoRegistro.Seguimiento__c);
                idSedes.add(nuevoRegistro.Sede__c);
            }
            List <SST_Seguimiento_sede__c> registrosExistentesPorSedes = [select id, sede__c, Seguimiento__c, Seguimiento__r.name, Seguimiento__r.RecordTypeId, Seguimiento__r.tipo__c, Seguimiento__r.fecha_inicial__c, Seguimiento__r.fecha_final__c,
                                                                          sede__r.name, sede__r.empresa__c, sede__r.estado__c from SST_Seguimiento_sede__c where sede__c in: idSedes];
            Map<Id,SST_Seguimiento__c> seguimientos = new Map <Id,SST_Seguimiento__c>([select id, RecordTypeId, name, tipo__c, fecha_inicial__c, fecha_final__c from SST_Seguimiento__c where id in: idSeguimientos]);
            if(registrosExistentesPorSedes.size()>0){
                for(SST_Seguimiento_sede__c nuevoRegistro : trigger.new){
                    SST_Seguimiento__c seguimientoActual = seguimientos.get(nuevoRegistro.Seguimiento__c);
                    if(seguimientoActual.RecordTypeId == idPlan){
                        for(SST_Seguimiento_sede__c regExistente : registrosExistentesPorSedes){
                            //Al asociar una sede a un seguimiento de tipo plan anual, se valida si la sede ya está asociada a un seguimiento del mismo tipo
                            //para el mismo año del registro a insertar, y de ser así no permite la nueva asociación
                            if(seguimientoActual.Tipo__c.contains(SST_Constantes.TIPO_PLAN_ANUAL_TRABAJO) || seguimientoActual.Tipo__c.contains(SST_Constantes.PROGRAMA_ANUAL_MONITOREO_MEDIOAMBIENTAL)){
                                if(regExistente.sede__c == nuevoRegistro.sede__c && seguimientoActual.tipo__c == regExistente.Seguimiento__r.tipo__c && seguimientoActual.fecha_inicial__c.year() == regExistente.Seguimiento__r.fecha_inicial__c.year()){
                                    nuevoRegistro.adderror('La sede '+regExistente.sede__r.name+' ya está asociada a un seguimiento de tipo '+listaTiposSeguimiento.get(regExistente.Seguimiento__r.Tipo__c)+' para el año '+regExistente.Seguimiento__r.fecha_final__c.year());    
                                }
                            }
                            //Al asociar una sede a un seguimiento de tipo de registro Planes y Programas y diferente a planes anuales, se valida 
                            //si la sede ya está asociada a un seguimiento del mismo tipo con fechas que solapen las fechas del registro a insertar y no permite la nueva asociación
                            else if(!seguimientoActual.Tipo__c.contains(SST_Constantes.TIPO_PLAN_ANUAL_TRABAJO) && !seguimientoActual.Tipo__c.contains(SST_Constantes.PROGRAMA_ANUAL_MONITOREO_MEDIOAMBIENTAL)){
                                if(regExistente.sede__c == nuevoRegistro.sede__c && seguimientoActual.tipo__c == regExistente.Seguimiento__r.tipo__c &&
                                   ((regExistente.seguimiento__r.Fecha_Inicial__c >= seguimientoActual.Fecha_Inicial__c && regExistente.seguimiento__r.Fecha_Inicial__c <= seguimientoActual.Fecha_Final__c)
                                    || (regExistente.seguimiento__r.Fecha_Final__c >= seguimientoActual.Fecha_Inicial__c && regExistente.seguimiento__r.Fecha_Final__c <= seguimientoActual.Fecha_Final__c)
                                    || (regExistente.seguimiento__r.Fecha_Inicial__c >= seguimientoActual.Fecha_Inicial__c && regExistente.seguimiento__r.Fecha_Final__c <= seguimientoActual.Fecha_Final__c)
                                    || (regExistente.seguimiento__r.Fecha_Inicial__c < seguimientoActual.Fecha_Inicial__c && regExistente.seguimiento__r.Fecha_Final__c > seguimientoActual.Fecha_Final__c))){
                                        nuevoRegistro.adderror('La sede '+regExistente.sede__r.name+' ya está asociada al seguimiento '+regExistente.seguimiento__r.name+' de tipo '+listaTiposSeguimiento.get(regExistente.Seguimiento__r.Tipo__c)+' para las fechas '+String.valueOf(regExistente.seguimiento__r.fecha_inicial__c)+' al '+string.valueOf(regExistente.seguimiento__r.Fecha_Final__c));
                                    }
                            }
                        }
                    }
                }
            }
        } 
    }
}