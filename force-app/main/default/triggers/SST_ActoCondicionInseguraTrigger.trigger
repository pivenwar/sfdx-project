/*Trigger para validaciones sobre el objeto Acto_condicion_insegura antes de la insersión
* @Marcela Taborda
* @version 2.0
* @date 19/12/2018
*/
trigger SST_ActoCondicionInseguraTrigger on SST_Acto_condicion_insegura__c (before insert, before update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            Integer flag = 0;
            Date hoy = system.today();
            
            //Se obtiene el último consecutivo registrado para determinar cuál será el(los) consecutivo(s) siguiente(s) para el(los) nuevo(s) registro(s)
            List<SST_Acto_condicion_insegura__c> ultimoActoCondicion = [SELECT id, Max_Consecutivo__c FROM SST_Acto_condicion_insegura__c order by Max_Consecutivo__c desc limit 1];
            //Si la consulta es nula, significa que es el primer registro que se inserta en el ojbeto
            if(ultimoActoCondicion.size()==0){
                flag = 1;
            } 
            //Si la consulta no es nula, se extrae el año y el consecutivo del valor obtenido
            else {
                String temp = String.valueOf(ultimoActoCondicion.get(0).Max_Consecutivo__c);
                String tempYear = temp.substring(0,4);
                temp = temp.substring(4,temp.length());
                
                //Si el año del último consecutivo es igual al actual, se incrementa en 1 el consecutivo para el registro siguiente
                if(Integer.valueOf(tempYear) == hoy.year()){
                    flag = Integer.valueOf(temp)+1;    
                } 
                
                //Si no son iguales ambos años, se inicia un nuevo consecutivo para el año actual
                else {
                    flag = 1;
                }
            }
            List<String> idComunicacion = new List<String>();
            String nit = SST_Constantes.getEmpresaAutenticada();
            for(SST_Acto_condicion_insegura__c nuevoRegistro : trigger.new){
                if(nuevoRegistro.identificador_comunicacion__c <> null){
                 	idComunicacion.add(nuevoRegistro.identificador_comunicacion__c);
                } 
            }
            Map<Id,SST_Comunicacion__c> comunicaciones = new Map<Id,SST_Comunicacion__c>([select id, empresa__c from SST_Comunicacion__c where id in: idComunicacion]);
            for(SST_Acto_condicion_insegura__c nuevoRegistro : trigger.new){
                if(nuevoRegistro.identificador_comunicacion__c <> null){
                    nuevoRegistro.empresa__c = comunicaciones.get(nuevoRegistro.identificador_comunicacion__c).empresa__c;
                } else {
					nuevoRegistro.empresa__c = nit;
                }
                
                String c = String.valueOf(hoy.year())+String.valueOf(flag);
                
                //Se guarda el nuevo consecutivo para el registro creado.  Este campo es de tipo numérico, no visible a los
                //usuarios, y se usa exclusivamente para consultar el último consecutivo existente y calcular el siguiente
                nuevoRegistro.Max_Consecutivo__c = Integer.valueOf(c);
                
                //Se guarda el identificador del nuevo registro el cual tiene la estructura AAAA-# donde AAAA es el
                //año de la fecha en que se realiza el registro, y # es el consecutivo que se incrementa uno a uno
                //dentro del mismo año, y se reinicia al cambiar de año
                nuevoRegistro.Identificador__c = hoy.year()+'-'+flag;
                flag = flag+1;
            }
        }
    }
}