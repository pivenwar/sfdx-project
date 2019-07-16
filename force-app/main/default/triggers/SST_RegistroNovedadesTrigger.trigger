/*Trigger para validaciones sobre el objeto Registro novedades antes de la inserción y actualización
* @Marcela Taborda
* @version 3.0
* @date 19/12/2018
*/
trigger SST_RegistroNovedadesTrigger on SST_Registro_de_Novedades__c (before insert,  before update) { 
    
    
    ID accidentes = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Accidentes').getRecordTypeId();     
    ID ausentismos = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Ausentismos').getRecordTypeId();     
    ID incapacidades = Schema.SObjectType.SST_Registro_de_Novedades__c.getRecordTypeInfosByName().get('Incapacidades/Licencias').getRecordTypeId();     
    List <Id> idContactos = new List <Id>();
    Map<Id,Decimal> mapaNits = new Map<Id,Decimal>();
    List <Date> fechaAnterior = new List <Date>();

    
    if(trigger.isBefore){
	SST_Utilitarios.validarRegistroNovedades(Trigger.new);
        if(trigger.isInsert){
            Date fechaInicio = system.today();
            Date fechaFin = system.today();
            Boolean validarFechas = false;
            for(SST_Registro_de_Novedades__c nuevoRegistro :Trigger.new){
                mapaNits.put(nuevoRegistro.funcionario__c,null);
                idContactos.add(nuevoRegistro.Funcionario__c);
                fechaAnterior.add(nuevoRegistro.Fecha_incapacidad_anterior__c);
                if(nuevoRegistro.RecordTypeId == ausentismos || nuevoRegistro.RecordTypeId == incapacidades ){
                    validarFechas = true;
                    if(nuevoRegistro.Fecha_Inicial__c < fechaInicio){
                        fechaInicio = nuevoRegistro.Fecha_Inicial__c;
                    }
                    if(nuevoRegistro.Fecha_final__c<>null && nuevoRegistro.Fecha_final__c > fechaFin){
                        fechaFin = nuevoRegistro.Fecha_Final__c;
                    }
                    if(nuevoRegistro.Fecha_Final__c==null){
                        nuevoRegistro.Fecha_Final__c = nuevoRegistro.Fecha_Inicial__c;
                    }
                }
                if(nuevoRegistro.RecordTypeId == incapacidades && nuevoRegistro.numero_dias__c == null){
                    nuevoRegistro.numero_dias__c = ((nuevoRegistro.Fecha_Inicial__c.daysBetween(nuevoRegistro.Fecha_Final__c))+1);       
                } 
            }
            for(Contact contactoTemp : [select id, sst_empresa__c from contact where id in: mapaNits.keySet()]){
                mapaNits.put(contactoTemp.id,Decimal.valueOf(contactoTemp.sst_empresa__c)); 
            }
            
            /*Se consultan las incapacidades entre las fecha inicio y fecha fin de todos los contactos*/
            if(validarFechas){
                List <SST_Registro_de_Novedades__c> incapacidadesExistentes = [select id, name, fecha_inicial__c, fecha_final__c, recordTypeId, recordType.name, funcionario__c, funcionario__r.name from SST_Registro_de_Novedades__c where recordType.name in: SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES and funcionario__c in: idContactos and (
                    (Fecha_Inicial__c >=: fechaInicio and Fecha_Inicial__c <=: fechaFin)
                    OR (Fecha_Final__c >=: fechaInicio and Fecha_Final__c <=: fechaFin)
                    OR (Fecha_Inicial__c >=: fechaInicio and Fecha_Final__c <=: fechaFin)
                    OR (Fecha_Inicial__c <: fechaInicio and Fecha_Final__c >: fechaFin))];
                
                if(incapacidadesExistentes.size()>0){
                    //Si hay incapacidades que se solapen se revisa a que registro corresponda para verificar que sea del mismo funcionario
                    for(SST_Registro_de_Novedades__c nuevoRegistro :Trigger.new){
                        
                        if(nuevoRegistro.RecordTypeId == ausentismos || nuevoRegistro.RecordTypeId == incapacidades ){
                            for(SST_Registro_de_Novedades__c incapacidadExistente : incapacidadesExistentes){
                                if(nuevoRegistro.Funcionario__c == incapacidadExistente.Funcionario__c){
                                    
                                    //Si la novedad es de tipo incapacidad/licencia o ausentismo, se valida que no exista un registro previo que se solape con las fechas del nuevo registro
                                    if((incapacidadExistente.Fecha_Inicial__c >= nuevoRegistro.Fecha_Inicial__c && incapacidadExistente.Fecha_Inicial__c <= nuevoRegistro.Fecha_Final__c)
                                       || (incapacidadExistente.Fecha_Final__c > nuevoRegistro.Fecha_Inicial__c && incapacidadExistente.Fecha_Final__c <= nuevoRegistro.Fecha_Final__c)
                                       || (incapacidadExistente.Fecha_Inicial__c >= nuevoRegistro.Fecha_Inicial__c && incapacidadExistente.Fecha_Final__c <= nuevoRegistro.Fecha_Final__c)
                                       || (incapacidadExistente.Fecha_Inicial__c < nuevoRegistro.Fecha_Inicial__c && incapacidadExistente.Fecha_Final__c > nuevoRegistro.Fecha_Final__c)
                                       || (incapacidadExistente.Fecha_Final__c == nuevoRegistro.Fecha_Inicial__c)){
                                           
                                           nuevoRegistro.adderror('El funcionario '+incapacidadExistente.funcionario__r.name+' ya tiene un ausentismo, incapacidad o licencia registrada en el rango de fechas '+String.valueOf(nuevoRegistro.Fecha_Inicial__c)+' al '+String.valueOf(nuevoRegistro.Fecha_Final__c));
                                       }
                                }
                            }
                        }
                    }
                }
            }
            
            //Se consultan las incapacidades que existen para el contacto del nuevo registro
            List <SST_Registro_de_Novedades__c> incapacidadesExistentes = [select id, name, fecha_inicial__c, recordTypeId, recordType.name, funcionario__c, funcionario__r.name, Fecha_incapacidad_anterior__c, Total_dias_incapacidad__c, numero_dias__c from SST_Registro_de_Novedades__c where RecordTypeId =: incapacidades and funcionario__c in: idContactos and fecha_inicial__c in: fechaAnterior];
            
            //Valida que la fecha inicial de la incapacidad anterior del nuevo registro sea igual a una fecha inicial de una incapacidad que ya tenga el funcionario
            for(SST_Registro_de_Novedades__c nuevoRegistro :Trigger.new){
                if(nuevoRegistro.RecordTypeId == incapacidades){
                    nuevoRegistro.Total_dias_incapacidad__c = nuevoRegistro.numero_dias__c;
                    if(incapacidadesExistentes.size()>0){
                        for(SST_Registro_de_Novedades__c incapacidadExistente : incapacidadesExistentes){
                            if(nuevoRegistro.funcionario__c == incapacidadExistente.funcionario__c){
                                nuevoRegistro.Total_dias_incapacidad__c = nuevoRegistro.numero_dias__c + incapacidadExistente.Total_dias_incapacidad__c;
                            }
                        }
                    }
                }else{
                    if(nuevoRegistro.Tipo__c == 'PRORROGA'){
                        nuevoRegistro.adderror('No se encuentra una incapacidad anterior con esta fecha');
                    }
                }
            } 
            
            /*se consultan las cuentas sobre las que llegaron registros de novedades*/
            Map<String,Account>  cuentas = new Map<String,Account>();
            for(Account cuenta :[SELECT id, sst_nit__c, SST_horas_habiles__c FROM account WHERE sst_estado__c =: SST_Constantes.ACTIVO AND sst_nit__c in :mapaNits.values()]){
                cuentas.put(STring.valueOf(cuenta.sst_nit__c),cuenta); 
            }         
            
            /*se realiza la consulta de la eps y arl de los contactos a los que se les creó novedad*/
            Map<Id,Contact> contactos = new Map<Id,Contact>();
            for(Contact contacto : [SELECT id,SST_eps__c,SST_arl__c,name FROM Contact where id in :idContactos]){
                contactos.put(contacto.id,contacto);
            }        
            /*WORK 99: al guardar una novedad se asigna el valor de la eps y arl que tiene el funcionario actualmente.*/
            
            Schema.DescribeFieldResult eps = Contact.SST_eps__c.getDescribe();            
            Map<String,String> epsLista = new Map<String,String>();
            Schema.DescribeFieldResult arl = Contact.SST_arl__c.getDescribe();            
            Map<String,String> arlLista = new Map<String,String>();
            
            for( Schema.PicklistEntry pickItem : eps.getPicklistValues()){
                epsLista.put(pickItem.getValue(),pickItem.getLabel());
            }  
            for( Schema.PicklistEntry pickItem : arl.getPicklistValues()){
                arlLista.put(pickItem.getValue(),pickItem.getLabel());
            }  
            
            
            /*se recorren los registros y se le asigna la misma empresa del contacto*/
            for(SST_Registro_de_Novedades__c nuevoRegistro :Trigger.new){
                Account cuentaPrincipal = cuentas.get(String.valueOf(mapaNits.get(nuevoRegistro.funcionario__c)));
                nuevoRegistro.empresa__c = String.valueOf(mapaNits.get(nuevoRegistro.funcionario__c));
                if(nuevoRegistro.RecordTypeId == ausentismos){
                    Integer dias = (nuevoRegistro.Fecha_Inicial__c.daysBetween(nuevoRegistro.Fecha_Final__c))+1;
                    if(cuentaPrincipal != null){
                        //Si la novedadad es de tipo Ausentimos, se valida que el total de horas no supere las días permitidas 
                        if(nuevoRegistro.Cantidad_Horas__c > (dias*cuentaPrincipal.SST_horas_habiles__c)){
                            nuevoRegistro.adderror('El ausentismo reportado para el funcionario '+contactos.get(nuevoRegistro.funcionario__c).name+' por '+nuevoRegistro.Cantidad_Horas__c+' horas, excede el tiempo total de ausentismo permitido por día de: '+cuentaPrincipal.SST_horas_habiles__c+' horas');
                        }   
                    } else {
                        //En caso que no haya una empresa configurada con el tipo Ciente o no tenga parametrizada la cantidad de horas laborales por día, no se permite insertar el registro
                        nuevoRegistro.adderror('No hay actualmente configurada una empresa como cuenta principal, y no se tiene establecida la cantidad de horas laborables por día.  Verifique y complete la configuración de los datos de la empresa para guardar el registro de ausentismo del funcionario '+contactos.get(nuevoRegistro.funcionario__c).name);
                    }
                } else if(nuevoRegistro.RecordTypeId == incapacidades){
                    Integer dias = (nuevoRegistro.Fecha_Inicial__c.daysBetween(nuevoRegistro.Fecha_Final__c))+1;
                    if(nuevoRegistro.numero_dias__c == null){
                        nuevoRegistro.numero_dias__c = dias;   
                    }
                    //Se valida si la cantidad de días de la incapacidad o licencia es mayor a la cantidad de días comprendidos entre la fecha de inicio y de fin del mismo
                    if(nuevoRegistro.numero_dias__c != null && nuevoRegistro.numero_dias__c > (dias)){
                        nuevoRegistro.adderror('La incapacidad o licencia reportada para el funcionario '+contactos.get(nuevoRegistro.funcionario__c).name+' por '+nuevoRegistro.numero_dias__c+' días, excede el total de días que abarcan las fechas de inicio y de fin: '+String.valueOf(nuevoRegistro.Fecha_Inicial__c)+' al '+String.valueOf(nuevoRegistro.Fecha_Final__c));
                    } 
                }
                
            }
            
            
            
            
        }
    }
    if(trigger.isUpdate){
        Date fechaInicio = system.today();
        Date fechaFin = system.today();
        List <Id> idNovedades = new List <Id>();
        Boolean validarFechas = false;
        for(SST_Registro_de_Novedades__c nuevoRegistro :Trigger.new){ 
            mapaNits.put(nuevoRegistro.funcionario__c,null);
            idContactos.add(nuevoRegistro.Funcionario__c);
            fechaAnterior.add(nuevoRegistro.Fecha_incapacidad_anterior__c);
            idNovedades.add(nuevoRegistro.Id);
            SST_Registro_de_Novedades__c registroModificar = Trigger.oldMap.get(nuevoRegistro.id);
            if((registroModificar.Fecha_Inicial__c != nuevoRegistro.Fecha_Inicial__c || registroModificar.Fecha_Final__c != nuevoRegistro.Fecha_Final__c) && (nuevoRegistro.RecordTypeId == ausentismos || nuevoRegistro.RecordTypeId == incapacidades)){
                if(nuevoRegistro.RecordTypeId == ausentismos || nuevoRegistro.RecordTypeId == incapacidades ){
                    
                    validarFechas = true;
                    if(nuevoRegistro.Fecha_Inicial__c < fechaInicio){
                        fechaInicio = nuevoRegistro.Fecha_Inicial__c;
                    }
                    if(nuevoRegistro.Fecha_final__c<>null && nuevoRegistro.Fecha_final__c > fechaFin){
                        fechaFin = nuevoRegistro.Fecha_Final__c;
                    }
                    if(nuevoRegistro.Fecha_Final__c==null){
                        nuevoRegistro.Fecha_Final__c = nuevoRegistro.Fecha_Inicial__c;
                    }
                }
                if(nuevoRegistro.RecordTypeId == incapacidades && nuevoRegistro.numero_dias__c == registroModificar.numero_dias__c){
                    nuevoRegistro.numero_dias__c = ((nuevoRegistro.Fecha_Inicial__c.daysBetween(nuevoRegistro.Fecha_Final__c))+1);       
                }
            }
        }
        
        for(Contact contactoTemp : [select id, sst_empresa__c from contact where id in: mapaNits.keySet()]){
            mapaNits.put(contactoTemp.id,Decimal.valueOf(contactoTemp.sst_empresa__c)); 
        }
        if(validarFechas){
            List <SST_Registro_de_Novedades__c> incapacidadesExistentes = [select id, name, fecha_inicial__c, fecha_final__c, recordTypeId, recordType.name, funcionario__c, funcionario__r.name from SST_Registro_de_Novedades__c where id not in: idNovedades and recordType.name in: SST_Constantes.LISTA_RECORD_TYPES_REGISTRO_NOVEDADES and funcionario__c in: idContactos and(
                (Fecha_Inicial__c >=: fechaInicio and Fecha_Inicial__c <=: fechaFin)
                OR (Fecha_Final__c >=: fechaInicio and Fecha_Final__c <=: fechaFin)
                OR (Fecha_Inicial__c >=: fechaInicio and Fecha_Final__c <=: fechaFin)
                OR (Fecha_Inicial__c <: fechaInicio and Fecha_Final__c >: fechaFin))];
            
            if(incapacidadesExistentes.size()>0){
                //Se consulta la cantidad de horas hábiles por día de trabajo configuradas para la empresa
                for(SST_Registro_de_Novedades__c nuevoRegistro :Trigger.new){
                    
                    
                    SST_Registro_de_Novedades__c registroModificar = Trigger.oldMap.get(nuevoRegistro.id);
                    if((registroModificar.Fecha_Inicial__c != nuevoRegistro.Fecha_Inicial__c || registroModificar.Fecha_Final__c != nuevoRegistro.Fecha_Final__c) && (nuevoRegistro.RecordTypeId == incapacidades || nuevoRegistro.RecordTypeId == ausentismos)){ 
                        if(nuevoRegistro.RecordTypeId == ausentismos || nuevoRegistro.RecordTypeId == incapacidades ){
                            for(SST_Registro_de_Novedades__c temp : incapacidadesExistentes){
                                if(nuevoRegistro.Funcionario__c == temp.Funcionario__c){
                                    
                                    //Si la novedad es de tipo incapacidad/licencia o ausentismo, se valida que no exista un registro previo que se solape con las fechas del nuevo registro
                                    if((temp.Fecha_Inicial__c >= nuevoRegistro.Fecha_Inicial__c && temp.Fecha_Inicial__c <= nuevoRegistro.Fecha_Final__c)
                                       || (temp.Fecha_Final__c > nuevoRegistro.Fecha_Inicial__c && temp.Fecha_Final__c <= nuevoRegistro.Fecha_Final__c)
                                       || (temp.Fecha_Inicial__c >= nuevoRegistro.Fecha_Inicial__c && temp.Fecha_Final__c <= nuevoRegistro.Fecha_Final__c)
                                       || (temp.Fecha_Inicial__c < nuevoRegistro.Fecha_Inicial__c && temp.Fecha_Final__c > nuevoRegistro.Fecha_Final__c)
                                       || (temp.Fecha_Final__c == nuevoRegistro.Fecha_Inicial__c)){
                                           
                                           nuevoRegistro.adderror('El funcionario '+temp.funcionario__r.name+' ya tiene un ausentimo, incapacidad o licencia registrada en el rango de fechas '+String.valueOf(nuevoRegistro.Fecha_Inicial__c)+' al '+String.valueOf(nuevoRegistro.Fecha_Final__c));
                                       }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //Se consultan las incapacidades que existen para el contacto del nuevo registro
        List <SST_Registro_de_Novedades__c> incapacidadesExistentes = [select id, name, fecha_inicial__c, recordTypeId, recordType.name, funcionario__c, funcionario__r.name, Fecha_incapacidad_anterior__c, Total_dias_incapacidad__c, numero_dias__c from SST_Registro_de_Novedades__c where RecordTypeId =: incapacidades and funcionario__c in: idContactos and fecha_inicial__c in: fechaAnterior];
        
        //Valida que la fecha inicial de la incapacidad anterior del nuevo registro sea igual a una fecha inicial de una incapacidad que ya tenga el funcionario
        for(SST_Registro_de_Novedades__c nuevoRegistro :Trigger.new){
            SST_Registro_de_Novedades__c registroModificar = Trigger.oldMap.get(nuevoRegistro.id);
            if(incapacidadesExistentes.size()>0){
                IF(registroModificar.Fecha_incapacidad_anterior__c != nuevoRegistro.Fecha_incapacidad_anterior__c || registroModificar.numero_dias__c != nuevoRegistro.numero_dias__c){
                    for(SST_Registro_de_Novedades__c incapacidadExistente : incapacidadesExistentes){
                         if(nuevoRegistro.funcionario__c == incapacidadExistente.funcionario__c){
                            nuevoRegistro.Total_dias_incapacidad__c = nuevoRegistro.numero_dias__c + incapacidadExistente.numero_dias__c;
                        }
                    }
                }
            }else{
                if(nuevoRegistro.Tipo__c == 'PRORROGA'){
                    nuevoRegistro.adderror('No se encuentra una incapacidad anterior con esta fecha');
                }
            }
        }
        
        
        Map<String,Account>  cuentas = new Map<String,Account>();
        for(Account cuenta :[SELECT id, sst_nit__c, SST_horas_habiles__c FROM account WHERE sst_estado__c =: SST_Constantes.ACTIVO AND sst_nit__c in :mapaNits.values()]){
            cuentas.put(STring.valueOf(cuenta.sst_nit__c),cuenta); 
        }
                    /*se realiza la consulta de la eps y arl de los contactos a los que se les creó novedad*/
            Map<Id,Contact> contactos = new Map<Id,Contact>();
            for(Contact contacto : [SELECT id,SST_eps__c,SST_arl__c,name FROM Contact where id in :idContactos]){
                contactos.put(contacto.id,contacto);
            } 
        for(SST_Registro_de_Novedades__c nuevoRegistro :Trigger.new){
            Account cuentaPrincipal = cuentas.get(String.valueOf(mapaNits.get(nuevoRegistro.funcionario__c)));
            nuevoRegistro.empresa__c = String.valueOf(mapaNits.get(nuevoRegistro.funcionario__c));   
            if(nuevoRegistro.RecordTypeId == ausentismos){
                Integer dias = (nuevoRegistro.Fecha_Inicial__c.daysBetween(nuevoRegistro.Fecha_Final__c))+1;
                
                if(cuentaPrincipal != null){
                    //Si la novedadad es de tipo Ausentimos, se valida que el total de horas no supere las días permitidas 
                    if(nuevoRegistro.Cantidad_Horas__c > (dias*cuentaPrincipal.SST_horas_habiles__c)){
                        nuevoRegistro.adderror('El ausentismo reportado para el funcionario '+contactos.get(nuevoRegistro.funcionario__c).name+' por '+nuevoRegistro.Cantidad_Horas__c+' horas, excede el tiempo total de ausentismo permitido por día de: '+cuentaPrincipal.SST_horas_habiles__c+' horas');
                    }   
                } else {
                    //En caso que no haya una empresa configurada con el tipo Ciente o no tenga parametrizada la cantidad de horas laborales por día, no se permite insertar el registro
                    nuevoRegistro.adderror('No hay actualmente configurada una empresa como cuenta principal, y no se tiene establecida la cantidad de horas laborables por día.  Verifique y complete la configuración de los datos de la empresa para guardar el registro de ausentismo del funcionario '+contactos.get(nuevoRegistro.funcionario__c).name);
                }
            } else if(nuevoRegistro.RecordTypeId == incapacidades){
                Integer dias = (nuevoRegistro.Fecha_Inicial__c.daysBetween(nuevoRegistro.Fecha_Final__c))+1;
                //nuevoRegistro.numero_dias__c = dias;
                //Se valida si la cantidad de días de la incapacidad o licencia es mayor a la cantidad de días comprendios entre la fecha de inicio y de fin del mismo
                if(nuevoRegistro.numero_dias__c != null && nuevoRegistro.numero_dias__c > (dias)){
                    nuevoRegistro.adderror('La incapacidad o licencia reportada para el funcionario '+contactos.get(nuevoRegistro.funcionario__c).name+' por '+nuevoRegistro.numero_dias__c+' días, excede el total de días que abarcan las fechas de inicio y de fin: '+String.valueOf(nuevoRegistro.Fecha_Inicial__c)+' al '+String.valueOf(nuevoRegistro.Fecha_Final__c));
                } 
            }
        }
    }
}