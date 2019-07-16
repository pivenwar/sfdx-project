trigger SST_PeligroSPTrigger on SST_Peligro_SP__c (before insert, before update) {
    
    if(trigger.isInsert){
        
        for(SST_Peligro_SP__c registro : trigger.new){
            
            if(registro.Nivel_Deficiencia__c != null && registro.Nivel_Exposicion__c!= null){
                registro.Nivel_Probabilidad__c = Integer.valueOf(registro.nivel_Deficiencia__c)* Integer.valueOf(registro.nivel_Exposicion__c);
				
         /*       if(registro.nivel_Probabilidad__c != null && registro.nivel_Consecuencia__c != null){
                    registro.Riesgo_Cuantitativo_Num__c = Integer.valueOf(registro.nivel_Probabilidad__c)*Integer.valueOf(registro.nivel_Consecuencia__c);
                    if(registro.Riesgo_Cuantitativo_Num__c>=600){
                        registro.Riesgo_Cualitativo_Texto__c = SST_Constantes.NIVEL_RIESGO_I;
                        registro.Valoracion_Riesgo__c = SST_Constantes.NO_ACEPTABLE;
                    }else if(registro.Riesgo_Cuantitativo_Num__c>=150 && registro.Riesgo_Cuantitativo_Num__c<600){
                        registro.Riesgo_Cualitativo_Texto__c = SST_Constantes.NIVEL_RIESGO_II;
                        registro.Valoracion_Riesgo__c = SST_Constantes.NO_ACEPTABLE;
                    }else if (registro.Riesgo_Cuantitativo_Num__c>=40 && registro.Riesgo_Cuantitativo_Num__c<150){
                        registro.Riesgo_Cualitativo_Texto__c = SST_Constantes.NIVEL_RIESGO_III;
                        registro.Valoracion_Riesgo__c = SST_Constantes.ACEPTABLE;
                    }else{
                        registro.Riesgo_Cualitativo_Texto__c = SST_Constantes.NIVEL_RIESGO_IV;
                        registro.Valoracion_Riesgo__c = SST_Constantes.ACEPTABLE;
                    }
                }  */
            }
            
            if((registro.Eliminar__c <> null || registro.Sustituir__c <> null || registro.Controles_Ingenieria__c <> null || registro.Controles_Administrativos__c <>null || registro.Senalizacion_Advertencias__c <> null || registro.EPP__c <> null || registro.Capacitacion__c <> null))
                                             {
                                                 registro.Estado__c = SST_Constantes.ESTADO_CONTROLES_ESTABLECIDOS;
                                             }else if(registro.Fuente__c <> null && registro.Medio__c <> null && registro.Trabajador__c<>null && registro.Metodo__c <> null && registro.Riesgo_Cualitativo_Texto__c <> null && registro.Valoracion_Riesgo__c <> null ){
                                                 registro.Estado__c = SST_Constantes.ESTADO_EVALUADO;
                                             }else{
                                                 registro.Estado__c =SST_Constantes.ESTADO_IDENTIFICADO;
                                             }
        }
	}
    
    if(trigger.isUpdate){
        for(SST_Peligro_SP__c registro : trigger.new){  
            if((registro.Eliminar__c <> null || registro.Sustituir__c <> null || registro.Controles_Ingenieria__c <> null || registro.Controles_Administrativos__c <>null || registro.Senalizacion_Advertencias__c <> null || registro.EPP__c <> null || registro.Capacitacion__c <> null))
            {
                registro.Estado__c = SST_Constantes.ESTADO_CONTROLES_ESTABLECIDOS;
            }else if(registro.Fuente__c <> null && registro.Medio__c <> null && registro.Trabajador__c<>null && registro.Metodo__c <> null && registro.Riesgo_Cualitativo_Texto__c <> null && registro.Valoracion_Riesgo__c <> null ){
                registro.Estado__c = SST_Constantes.ESTADO_EVALUADO;
            }else{
                registro.Estado__c =SST_Constantes.ESTADO_IDENTIFICADO;
            }
        }
    }

}