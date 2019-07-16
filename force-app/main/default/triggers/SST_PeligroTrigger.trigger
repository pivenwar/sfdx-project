/*Trigger para validaciones sobre el objeto Peligro previo a la inserción y actualización
* @Angélica Toro
* @version 1.0
* @date 27/08/2018
* 
* @Actualización: 
* @version 3.0
* @Marcela Taborda
* date 18/12/2018
*/
trigger SST_PeligroTrigger on SST_peligro__c (before insert, before update) {
    /*Al Insertar se debe realizar el calculo de los niveles del peligro, ya que la inserción se puede hacer por pantalla o por plantilla*/
    boolean actualizarPeligro = false;
    Set<String> empresasPeligro = new Set<String>();
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            List <SST_peligro__c> peligros = trigger.new;
            List <String> idSedes = new List <String>();
            for(SST_peligro__c temp : peligros){
                idSedes.add(temp.sede__c);
            }
            Map<Id, SST_sede__c> sedes = new Map<Id, SST_sede__c>([select id, empresa__c from SST_sede__c where id in: idSedes]);
            for(SST_peligro__c registro : trigger.new){ 
                empresasPeligro.add(registro.empresa__c);
                registro.empresa__c = sedes.get(registro.sede__c).empresa__c;
                /*el nivel de probabilidad es un campo calculado que se obtienen del producto del nivel de deficiencia con el nivel probabilidad*/
                if(registro.nivel_Deficiencia__c != null && registro.nivel_Exposicion__c!= null){
                    registro.nivel_Probabilidad__c = Integer.valueOf(registro.nivel_Deficiencia__c)* Integer.valueOf(registro.nivel_Exposicion__c);
                    if(registro.nivel_Probabilidad__c >= 2 && registro.nivel_Probabilidad__c <=4){
                        registro.interpretacion__c =SST_Constantes.NIVEL_BAJO;    
                    }
                    if(registro.nivel_Probabilidad__c >= 6 && registro.nivel_Probabilidad__c <=8){
                        registro.interpretacion__c=SST_Constantes.NIVEL_MEDIO;    
                    }
                    if(registro.nivel_Probabilidad__c >= 10 && registro.nivel_Probabilidad__c <=20){
                        registro.interpretacion__c = SST_Constantes.NIVEL_ALTO;    
                    }
                    if(registro.nivel_Probabilidad__c >= 24 && registro.nivel_Probabilidad__c <=40){
                        registro.interpretacion__c =SST_Constantes.NIVEL_MUY_ALTO;
                    }
                    if(registro.nivel_Probabilidad__c != null && registro.nivel_Consecuencia__c != null){
                        registro.nivel_Riesgo__C = Integer.valueOf(registro.nivel_Probabilidad__c)*Integer.valueOf(registro.nivel_Consecuencia__c);
                        if(registro.nivel_Riesgo__C>=600){
                            registro.interpretacion_Riesgo__c = SST_Constantes.NIVEL_RIESGO_I;
                            registro.aceptabilidad_Riesgo__c = SST_Constantes.NO_ACEPTABLE;
                        }else if(registro.nivel_Riesgo__C>=150 && registro.nivel_Riesgo__C<600){
                            registro.interpretacion_Riesgo__c = SST_Constantes.NIVEL_RIESGO_II;
                            registro.aceptabilidad_Riesgo__c = SST_Constantes.NO_ACEPTABLE;
                        }else if (registro.nivel_Riesgo__C>=40 && registro.nivel_Riesgo__C<150){
                            registro.interpretacion_Riesgo__c = SST_Constantes.NIVEL_RIESGO_III;
                            registro.aceptabilidad_Riesgo__c = SST_Constantes.ACEPTABLE;
                        }else{
                            registro.interpretacion_Riesgo__c = SST_Constantes.NIVEL_RIESGO_IV;
                            registro.aceptabilidad_Riesgo__c = SST_Constantes.ACEPTABLE;
                        }
                    }                   
                }
                
                if(registro.estado__c != SST_Constantes.ESTADO_INACTIVO){
                    
                    if(registro.accion__c != null || registro.Controles_ingenieria__c != null || registro.Controles_administrativos__c!=null || registro.EPP__c != null){
                        registro.estado__c = SST_Constantes.ESTADO_INTERVENIDO;
                    }else if( registro.Aceptabilidad_riesgo__c <> null){
                        registro.estado__c = SST_Constantes.ESTADO_EVALUADO;
                    } else{
                        registro.estado__c =SST_Constantes.ESTADO_IDENTIFICADO;
                    }
                }
            }
        } 
        if(trigger.isUpdate){
            /*Para la actualización se actualiza el estado del peligro según los campos diligenciados*/
            for(SST_peligro__c registro : trigger.new){  
                SST_peligro__c registroOld = Trigger.oldMap.get(registro.id);
                if(registroOld.sede__c != registro.sede__c || registroOld.Responsabilidad_cargo__c != registro.Responsabilidad_cargo__c){
                    empresasPeligro.add(registro.empresa__c);
                }
                if(registro.estado__c != SST_Constantes.ESTADO_INACTIVO){
                    if(registro.accion__c != null || registro.Controles_ingenieria__c != null || registro.Controles_administrativos__c!=null || registro.EPP__c != null){
                        registro.estado__c = SST_Constantes.ESTADO_INTERVENIDO;
                    }else if( registro.Aceptabilidad_riesgo__c <> null){
                        registro.estado__c = SST_Constantes.ESTADO_EVALUADO;
                    } else{
                        registro.estado__c =SST_Constantes.ESTADO_IDENTIFICADO;
                    }
                }
            }
        }
    }
    
    if(!empresasPeligro.isEmpty()){
        List<Object> resultados = SST_Constantes.actualizarExpuestosPeligros(trigger.new,empresasPeligro);
        Map <String,Integer> mapaCantContactos = (Map <String,Integer>)resultados.get(0);
        Map<String,Set<String>> mapaCargosExpuestos = (Map<String,Set<String>>) resultados.get(1);
        for(SST_peligro__c registro : trigger.new){
        	if(mapaCantContactos.get(registro.sede__c+'/'+registro.proceso__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c)!= null){
                	registro.Numero_expuestos_planta__c = mapaCantContactos.get(registro.sede__c+'/'+registro.proceso__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c);
                }else{
                    registro.Numero_expuestos_planta__c = 0;
                }
                    
                String cargosExpuestos='';
                if(mapaCargosExpuestos.get(registro.sede__c+'/'+registro.proceso__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c)!= null){
                for(String cargo : mapaCargosExpuestos.get(registro.sede__c+'/'+registro.proceso__c+'/'+registro.Responsabilidad_cargo__c+'/'+registro.empresa__c)){
                    
                    cargosExpuestos +=  cargo+'; ';
                }
                registro.cargos__c = cargosExpuestos.substring(0,cargosExpuestos.length()-2);
                }
        }
    }
}