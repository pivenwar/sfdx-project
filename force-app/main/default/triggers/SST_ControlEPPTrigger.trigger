trigger SST_ControlEPPTrigger on SST_Control_EPP__c (before insert, before update) {
    /*Si inserta un nuevo registro*/
    if(Trigger.isInsert){
               
        /*se crea la lista con los id de los funcionarios*/
        List<id> idFuncionarios = New List <id>();
        for(SST_Control_EPP__c nuevoRegistro: Trigger.new){
            /*se agrega el id del funcionario a la lista*/
            idFuncionarios.add(nuevoRegistro.funcionario__c);
        }
        /*llama la método validarEPPCargo de la clase SST_Utilitarios en el que se validan los epp que están asociados al cargo del funcionario*/
        //SST_Utilitarios.validarEPPCargo(idFuncionarios, Trigger.new, null);
           
    }  
    /*Si modifica el registro*/
    if(Trigger.isupdate){
        /*se crea la lista con los id de los funcionarios*/
        List<id> idFuncionarios = New List <id>();
        for(SST_Control_EPP__c nuevoRegistro: Trigger.new){
            /*Valida que el nuevo registro sea diferente al anterior*/
            if(!trigger.oldMap.get(nuevoRegistro.id).Elemento_proteccion_personal__c.equals(nuevoRegistro.Elemento_proteccion_personal__c)){
                 /*se agrega el id del funcionario a la lista*/ 
                idFuncionarios.add(nuevoRegistro.funcionario__c);
            }
           
        }
        /*llama la método validarEPPCargo de la clase SST_Utilitarios en el que se validan los epp que están asociados al cargo del funcionario*/
        //SST_Utilitarios.validarEPPCargo(idFuncionarios, Trigger.new, trigger.oldMap);
           
    } 
    
}