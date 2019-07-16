/*Trigger para validaciones sobre el objeto Grupo familiar previo a la inserción y actualización
* @Marcela Taborda
* @version 3.0
* @date 12/12/2018
*/
trigger SST_GrupoFamiliarTrigger on SST_Grupo_familiar__c (before insert, before update) {
    if(trigger.isBefore){
        //Si se inserta un nuevo registro, se valida si el funcionario ya tiene previamente asociado a su grupo familiar, miembros de parentesco Madre o Padre
        //pues sólo puede tener hasta dos registros de cada tipo
        if(trigger.isInsert){
            List <id> idFuncionarios = new List <id>();
            List <String> nombresFamiliares = new List <String>();
            List <String> identifFamiliares = new List <String>();
            List <SST_Grupo_familiar__c> listaRegistros = Trigger.new;
            for(SST_Grupo_familiar__c nuevoRegistro :listaRegistros){ 
                idFuncionarios.add(nuevoRegistro.Funcionario__c);
                nombresFamiliares.add(nuevoRegistro.Nombre_completo__c);
                identifFamiliares.add(nuevoRegistro.Numero_Identificacion__c);
            } 
            if(idFuncionarios.size()>0 && nombresFamiliares.size()>0 && identifFamiliares.size()>0){
                List<SST_Grupo_familiar__c> registrosExistentesMadres = [select id, name, Funcionario__c, Funcionario__r.name, parentesco__c from SST_Grupo_familiar__c  where Funcionario__c in: idFuncionarios and Parentesco__c =: SST_Constantes.MADRE];
                List<SST_Grupo_familiar__c> registrosExistentesPadres = [select id, name, Funcionario__c, Funcionario__r.name, parentesco__c from SST_Grupo_familiar__c  where Funcionario__c in: idFuncionarios and Parentesco__c =: SST_Constantes.PADRE];
                List<SST_Grupo_familiar__c> registrosExistentesNombres = [select id, name, Funcionario__c, Funcionario__r.name, nombre_completo__c from SST_Grupo_familiar__c  where Funcionario__c in: idFuncionarios and nombre_completo__c in: nombresFamiliares];
                List<SST_Grupo_familiar__c> registrosExistentesIdentificacion = [select id, name, Funcionario__c, Funcionario__r.name, Numero_Identificacion__c from SST_Grupo_familiar__c  where Funcionario__c in: idFuncionarios and Numero_Identificacion__c in: identifFamiliares];
                for(SST_Grupo_familiar__c nuevoRegistro :Trigger.new){
                    Integer countMadres = 0;
                    Integer countPadres = 0;
                    Integer countNombres = 0;
                    Integer countIdentificacion = 0;
                    if(nuevoRegistro.parentesco__c.equals(SST_Constantes.MADRE)){
                        for(SST_Grupo_familiar__c temp : registrosExistentesMadres){
                            if(temp.funcionario__c == nuevoRegistro.funcionario__c && temp.parentesco__c.equals(SST_Constantes.MADRE)){
                                countMadres++;
                            }
                        }
                    }
                    
                    if(nuevoRegistro.parentesco__c.equals(SST_Constantes.PADRE)){
                        for(SST_Grupo_familiar__c temp : registrosExistentesPadres){
                            if(temp.funcionario__c == nuevoRegistro.funcionario__c && temp.parentesco__c.equals(SST_Constantes.PADRE)){
                                countPadres++;
                            }
                        }
                    }
                    
                    for(SST_Grupo_familiar__c temp : registrosExistentesNombres){
                        if(temp.funcionario__c == nuevoRegistro.funcionario__c && temp.nombre_completo__c.equalsIgnoreCase(nuevoRegistro.nombre_completo__c)){
                            countNombres++;
                        }
                    }
                    for(SST_Grupo_familiar__c temp : registrosExistentesIdentificacion){
                        if(temp.funcionario__c == nuevoRegistro.funcionario__c && temp.numero_identificacion__c.equalsIgnoreCase(nuevoRegistro.numero_identificacion__c)){
                            countIdentificacion++;
                        }
                    }
                    Boolean error = false;
                    if(countMadres>=2 || countPadres>=2){
                        nuevoRegistro.adderror('El funcionario ya tiene registrados miembros en su grupo familiar como '+nuevoRegistro.Parentesco__c+' y sólo se permite hasta dos registros con dicho parentesco');
                        error = true;
                    }
                    
                    if(countNombres>0){
                        nuevoRegistro.adderror('El funcionario ya tiene registrado un miembro en su grupo familiar con el mismo nombre');
                        error = true;
                    }
                    
                    if(countIdentificacion>0){
                        nuevoRegistro.adderror('El funcionario ya tiene registrado un miembro en su grupo familiar con el mismo número de identificación');
                        error = true;
                    }
                }
            }
            else {
                for(SST_Grupo_familiar__c nuevoRegistro :Trigger.new){
                    nuevoRegistro.adderror('Cada registro debe contener el ID del funcionario, nombre completo y número de identificación del familiar a registrar');
                }
            }
        }
        //Si se modifica un registro cambiando el tipo de parentesco a Madre o Padre, o modificando el nombre o identificación, se valida si el 
        //funcionario ya tiene previamente asociados miembros a su grupo familiar con tipo de parentesco, o con el nuevo nombre o nueva identificacion
        if(trigger.isUpdate){
            List <id> idFuncionariosM = new List <id>();
            List <id> idFuncionariosP = new List <id>();
            List <id> idFuncionariosN = new List <id>();
            List <id> idFuncionariosI = new List <id>();
            List <String> nombresFamiliares = new List <String>();
            List <String> identifFamiliares = new List <String>();
            List <SST_Grupo_familiar__c> listaRegistros = Trigger.new;
            for(SST_Grupo_familiar__c nuevoRegistro : listaRegistros){
                SST_Grupo_familiar__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                if(registroModificar.Parentesco__c != nuevoRegistro.Parentesco__c && nuevoRegistro.Parentesco__c.equalsIgnoreCase(SST_Constantes.MADRE)){
                    idFuncionariosM.add(nuevoRegistro.Funcionario__c);
                }
                if(registroModificar.Parentesco__c != nuevoRegistro.Parentesco__c && nuevoRegistro.Parentesco__c.equalsIgnoreCase(SST_Constantes.PADRE)){
                    idFuncionariosP.add(nuevoRegistro.Funcionario__c);
                }
                if(!registroModificar.nombre_completo__c.equalsIgnoreCase(nuevoRegistro.nombre_completo__c)){
                    idFuncionariosN.add(nuevoRegistro.Funcionario__c);
                    nombresFamiliares.add(nuevoRegistro.nombre_completo__c);
                }
                if(!registroModificar.numero_identificacion__c.equalsIgnoreCase(nuevoRegistro.numero_identificacion__c)){
                    idFuncionariosI.add(nuevoRegistro.Funcionario__c);
                    identifFamiliares.add(nuevoRegistro.numero_identificacion__c);
                }
            }
            List<SST_Grupo_familiar__c> registrosExistentesMadres = new List<SST_Grupo_familiar__c>();
            List<SST_Grupo_familiar__c> registrosExistentesPadres = new List<SST_Grupo_familiar__c>();
            List<SST_Grupo_familiar__c> registrosExistentesNombres = new List<SST_Grupo_familiar__c>();
            List<SST_Grupo_familiar__c> registrosExistentesIdentif = new List<SST_Grupo_familiar__c>();
            if(idFuncionariosM.size()>0){
                registrosExistentesMadres = [select id, name, Funcionario__c, Funcionario__r.name, parentesco__c from SST_Grupo_familiar__c  where Funcionario__c in: idFuncionariosM and Parentesco__c =: SST_Constantes.MADRE];  
            }
            if(idFuncionariosP.size()>0){
                registrosExistentesPadres = [select id, name, Funcionario__c, Funcionario__r.name, parentesco__c from SST_Grupo_familiar__c  where Funcionario__c in: idFuncionariosP and Parentesco__c =: SST_Constantes.PADRE];
            }
            if(idFuncionariosN.size()>0){
                registrosExistentesNombres = [select id, name, Funcionario__c, Funcionario__r.name, nombre_completo__c from SST_Grupo_familiar__c  where Funcionario__c in: idFuncionariosN and nombre_completo__c in: nombresFamiliares];
            }
            if(idFuncionariosI.size()>0){
                registrosExistentesIdentif = [select id, name, Funcionario__c, Funcionario__r.name, numero_identificacion__c from SST_Grupo_familiar__c  where Funcionario__c in: idFuncionariosI and numero_identificacion__c in: identifFamiliares];
            }
            for(SST_Grupo_familiar__c nuevoRegistro :Trigger.new){
                SST_Grupo_familiar__c registroModificar = trigger.oldMap.get(nuevoRegistro.id);
                String nombreFuncionario = '';
                Integer countMadres = 0;
                Integer countPadres = 0;
                Integer countNombres = 0;
                Integer countIdentificacion = 0;
                if(registroModificar.Parentesco__c != nuevoRegistro.Parentesco__c && nuevoRegistro.Parentesco__c.equalsIgnoreCase(SST_Constantes.MADRE) && registrosExistentesMadres.size()>0){
                    for(SST_Grupo_familiar__c temp : registrosExistentesMadres){
                        if(temp.funcionario__c == nuevoRegistro.funcionario__c){
                            if(temp.parentesco__c.equals(SST_Constantes.MADRE)){
                                nombreFuncionario = temp.funcionario__r.name;
                                countMadres++;
                            }
                        }
                    }                
                }
                if(registroModificar.Parentesco__c != nuevoRegistro.Parentesco__c && nuevoRegistro.Parentesco__c.equalsIgnoreCase(SST_Constantes.PADRE) && registrosExistentesPadres.size()>0){
                    for(SST_Grupo_familiar__c temp : registrosExistentesPadres){
                        if(temp.funcionario__c == nuevoRegistro.funcionario__c){
                            if(temp.parentesco__c.equals(SST_Constantes.PADRE)){
                                nombreFuncionario = temp.funcionario__r.name;
                                countPadres++;
                            }
                        }
                    }                
                }
                if(registroModificar.nombre_completo__c != nuevoRegistro.nombre_completo__c && registrosExistentesNombres.size()>0){
                    for(SST_Grupo_familiar__c temp : registrosExistentesNombres){
                        if(temp.funcionario__c == nuevoRegistro.funcionario__c){
                            if(temp.nombre_completo__c.equals(nuevoRegistro.nombre_completo__c)){
                                nombreFuncionario = temp.funcionario__r.name;
                                countNombres++;
                            }
                        }
                    }                
                }
                if(registroModificar.numero_identificacion__c != nuevoRegistro.numero_identificacion__c && registrosExistentesIdentif.size()>0){
                    for(SST_Grupo_familiar__c temp : registrosExistentesIdentif){
                        if(temp.funcionario__c == nuevoRegistro.funcionario__c){
                            if(temp.numero_identificacion__c.equals(nuevoRegistro.numero_identificacion__c)){
                                nombreFuncionario = temp.funcionario__r.name;
                                countIdentificacion++;
                            }
                        }
                    }                
                }
                if(countMadres>=2 || countPadres>=2){
                    nuevoRegistro.adderror('El funcionario '+nombreFuncionario+' ya tiene registrados miembros en su grupo familiar como '+nuevoRegistro.Parentesco__c+' y sólo se permite hasta dos registros con dicho parentesco');
                }
                if(countNombres>0){
                    nuevoRegistro.adderror('El funcionario '+nombreFuncionario+' ya tiene registrado un miembro en su grupo familiar con el mismo nombre');
                }
                if(countIdentificacion>0){
                    nuevoRegistro.adderror('El funcionario '+nombreFuncionario+' ya tiene registrado un miembro en su grupo familiar con el mismo número de identificación');
                }
            }
        }   
    }
}