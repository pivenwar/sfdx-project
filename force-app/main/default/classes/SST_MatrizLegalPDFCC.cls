/*
* @autor: Marcela Taborda
* @fecha: 17/04/2019
* @version: 3.0
*/


public with sharing class SST_MatrizLegalPDFCC {
    /*Variable que contiene la fecha en la que se genera el reporte*/
    public String fechaReporte {get; set;}
    
    /*Variable que contiene el nombre de la empresa del usuario autenticado*/
    public String empresa {get; set;}
    
    /*Variable que contiene el nit de la empresa del usuario autenticado*/
    public String nit {get; set;}
    
    //Lista para consultar los campos de la Matriz Legal
    public List <DTOLista> listaMatriz {get;set;}
     
    /*Atributos para obtener el promedio de las calificaciones*/
    public Double promedio {get;set;}
    public Double total {get;set;}
    
    /*Mapa con el cumplimieto de la matriz*/
    public Map <String,String> mapaCumplimiento{get; set;}
    
     
      
    public SST_MatrizLegalPDFCC(){

        listaMatriz = new List <DTOLista>();
        mapaCumplimiento = new Map <String,String>();
        promedio = 0;
        total = 0;
        consultarDatosEncabezado();
        consultarNormatividades();
        calcularPromedio();
        total = promedio;
        
    }
    
    //Método que se encarga de consultar los datos del encabezado del reporte PDF
    public void consultarDatosEncabezado(){
        Account cuenta = new Account();
        cuenta = SST_Constantes.consultarDatosEmpresa(SST_Constantes.getEmpresaAutenticada());
        if(cuenta <> null){            
            Datetime fecha = system.now(); 
            fechaReporte = fecha.format(SST_Constantes.FORMATO_FECHA_REPORTE);
            fechaReporte = SST_Constantes.cambiarNombreMes(fechaReporte);
            empresa = cuenta.name;
            nit = String.valueOf(cuenta.sst_nit__c); 
        }
    }
    
    public void consultarNormatividades(){
        
        Schema.DescribeFieldResult fieldResult = SST_Normatividad__c.Cumplimiento__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry cumplimientoTemp : itemsTemp){
            mapaCumplimiento.put(cumplimientoTemp.getValue(),cumplimientoTemp.getLabel());
        }

        listaMatriz = new List <DTOLista>();
        
        for(SST_Normatividad__c temp : [select id, CreatedDate,Tipo__c, Fuente__c, Articulo__c, name, Entidad__c, Tema__c, Responsable__c, Funcionario__c, Funcionario__r.name, Cumplimiento__c,Observaciones__c, Codigo_externo__c  from SST_Normatividad__c where Empresa__c=:nit order by name]){
            DTOLista registro = new DTOLista();
            registro.idRegistro = temp.id;
            registro.cumplimiento = temp.Cumplimiento__c;
            registro.responsable = temp.Responsable__c;
            registro.norma = temp.Name;
            registro.fuente = temp.Fuente__c;
            registro.articulo = temp.Articulo__c;
            registro.observaciones = temp.Observaciones__c; 
            registro.idFuncionario = temp.Funcionario__r.name;
            listaMatriz.add(registro);
        }
       
    }
    
    /*Método que se encarga de calcular el promedio de la matriz legal según su cumplimiento.*/
    public pageReference calcularPromedio(){
        promedio = -1;
        if(listaMatriz.size()>0){
            promedio = 0;
            for(DTOLista temp : listaMatriz){
                if(temp.Cumplimiento == SST_Constantes.NO_CUMPLE){
                    promedio = promedio + 0;
                } else if(temp.Cumplimiento == SST_Constantes.CUMPLE_PARCIALMENTE){
                    promedio = promedio + 50;
                } else{
                    promedio = promedio + 100;   
                }
            }
            Decimal t = Decimal.valueOf(promedio/listaMatriz.size()).setScale(2);
            promedio = t;
        } 
        System.debug('promedio '+promedio);
        return null;
    } 
    
    public class DTOLista {
        public String idFuncionario {get;set;}
        public String responsable {get;set;}
        public String cumplimiento {get;set;}
        public String observaciones {get;set;}
        public String idRegistro {get;set;}
        public String norma {get;set;}
        public String fuente {get;set;}
        public String articulo {get;set;}
    }
    
}