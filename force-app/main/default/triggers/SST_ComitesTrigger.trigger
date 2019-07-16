/*Trigger para validaciones sobre el objeto Comités antes de la inserción y actualización, y después de la actualización
* @Marcela Taborda
* @version 3.0
* @date 18/12/2018
*/
trigger SST_ComitesTrigger on SST_Comites__c (before insert, before update, after update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
            List<String> nombres = new List<String>();
            List<ID> sedes = new List<ID>();
            for(SST_Comites__c nuevoRegistro : trigger.new){
                nombres.add(nuevoRegistro.Nombre__c);
                sedes.add(nuevoRegistro.sede__c);
            }
            /*se consultan si hay sedes con el mismo nombre en las mismas sedes y para la empresa autenticada*/
            Map<String,SST_Comites__c> comitesExistentes = new Map<String,SST_Comites__c>();
            for(SST_Comites__c comite :[select id, name,Nombre__c,sede__c from SST_Comites__c where Empresa__c=:empresaAutenticada and Nombre__c in :nombres and sede__c in : sedes]){
                comitesExistentes.put(comite.Nombre__c+comite.sede__c,comite);                
            }
            /*se recorre la lista si se identifica que hay uno repetido genera error sino se obtiene la sede para concatenar su nombre*/
            List<ID> idSedes = new List<ID>();
            for(SST_Comites__c nuevoRegistro : trigger.new){
                if(comitesExistentes.get(nuevoRegistro.Nombre__c+nuevoRegistro.sede__c)!= null){
                    nuevoRegistro.adderror('Ya existe un comité creado con el mismo nombre, para la misma sede y en la misma empresa.');
                }else{
                    idSedes.add(nuevoRegistro.Sede__c);
                }
            }
            /*se obtiene el nombre de las sedes*/
            Map<ID,SST_Sede__c> sedesExistentes = new Map<ID,SST_Sede__c>();
            for(SST_Sede__c sede : [Select id, name from sst_sede__c where id in :sedes]){
                sedesExistentes.put(sede.id,sede);
            }
            /*se recorre el registro nuevo y se concatena el nombre de la sede*/
            for(SST_Comites__c nuevoRegistro : trigger.new){
                nuevoRegistro.nombre_comite__c = nuevoRegistro.nombre__c+' - '+sedesExistentes.get(nuevoRegistro.Sede__c).name;
            }
        }
        if(trigger.isUpdate){
            String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
            List<String> nombres = new List<String>();
            List<ID> sedes = new List<ID>();
            for(SST_Comites__c nuevoRegistro : trigger.new){
                //Al modificar un comité cambiando la nombre y/o la sede, se valida que no exista uno creado con el mismo nombre y para la misma sede
                if(trigger.oldMap.get(nuevoRegistro.id).Nombre__c != nuevoRegistro.Nombre__c || trigger.oldMap.get(nuevoRegistro.id).sede__c != nuevoRegistro.Sede__c){
                    nombres.add(nuevoRegistro.Nombre__c);
                    sedes.add(nuevoRegistro.sede__c);
                }
            }
            /*se consultan si hay sedes con el mismo nombre en las mismas sedes y para la empresa autenticada*/
            Map<String,SST_Comites__c> comitesExistentes = new Map<String,SST_Comites__c>();
            for(SST_Comites__c comite :[select id, name,Nombre__c,sede__c from SST_Comites__c where Empresa__c=:empresaAutenticada and Nombre__c in :nombres and sede__c in :sedes]){
                comitesExistentes.put(comite.Nombre__c+comite.sede__c,comite);                
            }
            List<ID> idSedes = new List<ID>();
            for(SST_Comites__c registro : trigger.new){
                //Al modificar un comité cambiando la nombre y/o la sede, se valida que no exista uno creado con el mismo nombre y para la misma sede
                if(trigger.oldMap.get(registro.id).Nombre__c != registro.Nombre__c || trigger.oldMap.get(registro.id).sede__c != registro.Sede__c){
                    if(comitesExistentes.get(registro.Nombre__c+registro.sede__c)!= null){
                        registro.adderror('Ya existe un comité creado con el mismo nombre, para la misma sede y en la misma empresa.');
                    } else {
                        idSedes.add(registro.Sede__c);                        
                    } 
                } 
            }
            /*se obtiene el nombre de las sedes*/
            Map<ID,SST_Sede__c> sedesExistentes = new Map<ID,SST_Sede__c>();
            for(SST_Sede__c sede : [Select id, name from sst_sede__c where id in :sedes]){
                sedesExistentes.put(sede.id,sede);
            }
            for(SST_Comites__c registro : trigger.new){
                //Al modificar un comité cambiando la nombre y/o la sede, se valida que no exista uno creado con el mismo nombre y para la misma sede
                if(trigger.oldMap.get(registro.id).Nombre__c != registro.Nombre__c || trigger.oldMap.get(registro.id).sede__c != registro.Sede__c){
                    registro.nombre_comite__c = registro.nombre__c+' - '+sedesExistentes.get(registro.Sede__c).name;
                }
            }
        }
    }
    if(Trigger.isAfter){
        if(trigger.isUpdate){
            Map <Id,SST_Comites__c> mapaComites = new Map <Id,SST_Comites__c>();
            for(SST_Comites__c registro : trigger.new){   
                if(trigger.oldMap.get(registro.id).cantidad_representantes__c != registro.cantidad_representantes__c){
                    mapaComites.put(registro.id,registro);
                }
                if(trigger.oldMap.get(registro.id).Fecha_fin__c != registro.Fecha_fin__c){
                    mapaComites.put(registro.id,registro); 
                }
            }
            if(mapaComites.size()>0){   
                List <SST_Funcionarios_comites__c> funcionariosComite = [select id, comite__c, funcionario__c, fecha_terminacion__c, estado__c, representante_de__c, titularidad__c from SST_Funcionarios_comites__c where comite__c in: mapaComites.keySet() and estado__c =:SST_Constantes.ACTIVO]; 
                List <SST_Funcionarios_comites__c> funcionariosActualizar = new List <SST_Funcionarios_comites__c>();
                if(funcionariosComite.size()>0){
                    for(SST_Comites__c registro : trigger.new){   
                        Integer countRepresentantesEmpleador = 0;
                        Integer countRepresentantesTrabajadores = 0;
                        if(mapaComites.get(registro.id)<>null){
                            for(SST_Funcionarios_comites__c temp : funcionariosComite){
                                if(temp.comite__c == registro.id && temp.titularidad__c.equalsIgnoreCase(SST_Constantes.PRINCIPAL) && temp.Representante_de__c.equalsIgnorecase(SST_Constantes.EMPLEADOR)){
                                    countRepresentantesEmpleador++;
                                }
                                else if(temp.comite__c == registro.id && temp.titularidad__c.equalsIgnoreCase(SST_Constantes.PRINCIPAL) && temp.Representante_de__c.equalsIgnorecase(SST_Constantes.TRABAJADORES)){
                                    countRepresentantesTrabajadores++;
                                }
                                //Al cambiar la fecha de inicio y fin de un comité, se entiende que se inicia una nueva vigencia, por lo que se inactivan todos los miembros activos actuales del comité
                                if(trigger.oldMap.get(registro.id).Fecha_inicio__c != registro.Fecha_inicio__c && trigger.oldMap.get(registro.id).Fecha_fin__c != registro.Fecha_fin__c){
                                    temp.estado__c = SST_Constantes.INACTIVO;
                                   	funcionariosActualizar.add(temp);
                                }
                                //Al cambiar la fecha de fin de un comité, se actualiza la fecha de terminación para todos los miembros con asociación vigente
                                else if(trigger.oldMap.get(registro.id).Fecha_inicio__c == registro.Fecha_inicio__c && trigger.oldMap.get(registro.id).Fecha_fin__c != registro.Fecha_fin__c){
                                    temp.fecha_terminacion__c = registro.Fecha_fin__c;
                                     funcionariosActualizar.add(temp);
                                }
                            }
                            //Al modificar la cantidad de representantes de un comité, se valida si el total de miembros activos es superior a la cantidad de representantes indicada
                            if(registro.cantidad_representantes__c < countRepresentantesEmpleador || registro.cantidad_representantes__c < countRepresentantesTrabajadores){
                                registro.adderror('La cantidad de representantes indicada es menor a la cantidad de funcionarios asignados.  Por parte del empleador: '+countRepresentantesEmpleador+', por parte de los trabajadores: '+countRepresentantesTrabajadores+'.  Inactive algunas asociaciones primero');
                            }   
                        }
                    }
                    if(funcionariosActualizar.size()>0){
                        update funcionariosActualizar;
                    }
                }    
            }   
        }
    }
}