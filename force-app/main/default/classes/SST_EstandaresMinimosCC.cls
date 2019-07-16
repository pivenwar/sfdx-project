/*Controlador que ejecuta las acciones de negocio de la matriz de evaluación de estándares mínimos
@author Angélica Toro Murillo
@fecha 05/07/2018
*/
public with sharing class SST_EstandaresMinimosCC {
    
    /*Lista de los estándares existentes.*/
    public List<EstandarDTO>  listaEstandares{get;set;}
    /*Lista de los estándares existentes.*/
    public Map<String,List<EstandarDTO>>  estandaresPlanear{get;set;}
    public Map<String,List<EstandarDTO>>  estandaresHacer{get;set;}
    public Map<String,List<EstandarDTO>>  estandaresActuar{get;set;}
    public Map<String,List<EstandarDTO>>  estandaresVerificar{get;set;}
    /*Variable para indicar el ciclo actual para recalcular calificación*/
    public String cicloActual {get; set;}
    /*Variable para indicar el estándar agrupador actual para recalcular calificación*/
    public String estandarAgrupadorActual {get; set;}
    /*Variable para indicar el estándar actual para recalcular calificación*/
    public String estandarActual {get; set;}
    /*Varible que contiene el total*/ 
    public double total {get; set;}
    /*Variable que contiene la fecha en la que se genera el reporte*/
    public String fechaReporte {get; set;}
    /*Variable que contiene el nombre de la empresa del usuario autenticado*/
    public String empresa {get; set;}
    /*Variable que contiene el nit de la empresa del usuario autenticado*/
    public String nit {get; set;}
    /*Variable que contiene el valor del color cuando no hay cumplimiento*/
    public String colorCumple {get; set;}
    /*Variable que contiene el valor del color cuando hay cumplimiento*/
    public String colorNoCumple {get; set;}
    /*Variable que contiene el valor del pickList Cumple*/
    public String cumple {get; set;}
    /*Variable que contiene el valor del pickList No cumple*/
    public String noAplica {get; set;}
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    /*Variable para activar o inactivar el botón de guardar en la página*/
    public Boolean botonActivo {get; set;}
    
    /*Atributo para obtener el nit de la empresa en cuya comunidad está actualmente logueado el usuario*/
    public String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
    
    /*Atributo para guardar los comentarios que serán almacenados en la evaluación que se guarde*/
    public String comentarios{get; set;}
    
    /*Atributo para obtener la url del home de la comunidad*/
    private String url {get;set;}
   
    
    /** Método constructor.*/
    public SST_EstandaresMinimosCC(){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();
        url = SST_Constantes.retornarUrl();
        listaEstandares = new List<EstandarDTO>();
        estandaresPlanear = new Map<String,List<EstandarDTO>>();
        estandaresHacer = new Map<String,List<EstandarDTO>>();
        estandaresActuar = new Map<String,List<EstandarDTO>>();
        estandaresVerificar = new Map<String,List<EstandarDTO>>();
        total = 0;
        obtenerListaEstandares();
        colorNoCumple = SST_Constantes.COLOR_NO_CUMPLE;
        colorCumple = SST_Constantes.COLOR_CUMPLE;
        cumple = SST_Constantes.CUMPLE;
        noAplica = SST_Constantes.NO_APLICA;
    }
    
    /**Método que se encarga de consulta la lista de estándares.*/
    public void obtenerListaEstandares(){
        try{
            String url = ApexPages.currentPage().getHeaders().get('Referer');
            List<SST_Estandar_minimo__c> items = [SELECT name,Ciclo__c,Estandar_Agrupador__c, id,Estandar__c, Item_Estandar__c,Cumplimiento__c,Puntaje__c,Justificacion__c FROM SST_Estandar_minimo__c WHERE empresa__c =:empresaAutenticada order by id asc];
            Integer ordenP = 0;
            Integer ordenH = 0;
            Integer ordenV = 0;
            Integer ordenA = 0;
            String p;
            String h;
            String v;
            String a;
            for(SST_Estandar_minimo__c item :items){
                
                String key = item.Estandar_agrupador__c+'-' +item.Estandar__c;
                
                List<EstandarDTO> itemsDTO = null;
                
                if(item.ciclo__c==SST_Constantes.CICLO_PLANEAR){
                    p = SST_Constantes.cambiarNumeros(ordenP);
                    itemsDTO = estandaresPlanear.get(p+key);    
                }else if(item.Ciclo__c==SST_Constantes.CICLO_HACER){
                    h = SST_Constantes.cambiarNumeros(ordenH);
                    itemsDTO = estandaresHacer.get(h+key);   
                }else if (item.Ciclo__c==SST_Constantes.CICLO_VERIFICAR){
                    v = SST_Constantes.cambiarNumeros(ordenV);
                    itemsDTO = estandaresVerificar.get(v+key);  
                }else if (item.Ciclo__c==SST_Constantes.CICLO_ACTUAR){
                    a = SST_Constantes.cambiarNumeros(ordenA);
                    itemsDTO = estandaresActuar.get(a+key);   
                }
                
                if(itemsDTO == null){
                    itemsDTO = new List<EstandarDTO>();
                }
                if(item.cumplimiento__c == SST_Constantes.CUMPLE || (item.cumplimiento__c == SST_Constantes.NO_APLICA && item.justificacion__c != null && item.justificacion__c != null)){
                    total += item.Puntaje__c;
                } 
                Map <String,String> mapaCumplimiento = new Map <String,String>();
                List <SelectOption> listaC = getCumplimiento();
                for(SelectOption l : listaC){
                    mapaCumplimiento.put(l.getValue(), l.getLabel());
                }
                EstandarDTO itemDTO = new EstandarDTO();
                itemDTO.item = item.Item_Estandar__c;
                itemDTO.cumplimiento = mapaCumplimiento.get(item.Cumplimiento__c);
                itemDTO.justificacion = item.Justificacion__c;
                itemDTO.puntaje = item.Puntaje__c;               
                itemsDTO.add(itemDTO);
                
                if(item.ciclo__c==SST_Constantes.CICLO_PLANEAR){
                    if(estandaresPlanear.get(p+key)== null){
                        ordenP++;
                        p = SST_Constantes.cambiarNumeros(ordenP);
                    }
                    estandaresPlanear.put(p+key,itemsDTO);
                    
                }else if(item.Ciclo__c==SST_Constantes.CICLO_HACER){
                    if(estandaresHacer.get(h+key)== null){
                        ordenH++;
                        h = SST_Constantes.cambiarNumeros(ordenH);
                    }
                    estandaresHacer.put(h+key,itemsDTO);    
                }else if (item.Ciclo__c==SST_Constantes.CICLO_VERIFICAR){
                    if(estandaresVerificar.get(v+key)== null){
                        ordenV++;
                        v = SST_Constantes.cambiarNumeros(ordenV);
                    }
                    estandaresVerificar.put(v+key,itemsDTO); 
                }else if (item.Ciclo__c==SST_Constantes.CICLO_ACTUAR){
                    if(estandaresActuar.get(a+key)== null){
                        ordenA++;
                        a = SST_Constantes.cambiarNumeros(ordenA);
                    }
                    estandaresActuar.put(a+key,itemsDTO); 
                }
                
                
            }
            double totalCiclo = 0;
            double totalEstandarAgrupador = 0;
            double totalEstandar = 0;
            String cicloString = '';
            String estandarString = '';
            String estandarAgrupadorString = '';
            EstandarDTO cicloDTO = new EstandarDTO();
            EstandarDTO estandarAgrupadorDTO = new EstandarDTO();
            EstandarDTO estandarDTO = new EstandarDTO();
            total = 0;
            for(SST_Estandar_minimo__c item :items){
                EstandarDTO itemDTO = new EstandarDTO();
                if(cicloString != item.Ciclo__c){
                    cicloDTO = new EstandarDTO();
                    totalCiclo = 0;     
                    cicloString = item.Ciclo__c;	                                    
                    cicloDTO.ciclo = cicloString;
                    cicloDTO.fondo = SST_Constantes.COLOR_PRIMER_NIVEL;
                    listaEstandares.add(cicloDTO);        
                }
                if(estandarAgrupadorString != item.estandar_agrupador__c){
                    estandarAgrupadorDTO = new EstandarDTO();
                    totalEstandarAgrupador = 0;
                    estandarAgrupadorString = item.estandar_agrupador__c;
                    estandarAgrupadorDTO.estandarAgrupador = estandarAgrupadorString;
                    estandarAgrupadorDTO.fondo = SST_Constantes.COLOR_SEGUNDO_NIVEL;
                    listaEstandares.add(estandarAgrupadorDTO);
                }
                if(estandarString!=item.Estandar__c){
                    estandarDTO = new EstandarDTO();
                    totalEstandar = 0;
                    estandarString = item.Estandar__c;
                    estandarDTO.estandar = estandarString;
                    estandarDTO.fondo = SST_Constantes.COLOR_TERCER_NIVEL;
                    listaEstandares.add(estandarDTO);
                }
                if(item.cumplimiento__c == SST_Constantes.CUMPLE || (item.cumplimiento__c == SST_Constantes.NO_APLICA && item.justificacion__c != null && item.justificacion__c != null)){
                    totalEstandar += item.Puntaje__c;
                    totalEstandarAgrupador += item.Puntaje__c;
                    totalCiclo += item.Puntaje__c;
                    total += item.Puntaje__c;
                }
                
                itemDTO.item = item.Item_Estandar__c;
                itemDTO.cumplimiento = item.Cumplimiento__c;
                itemDTO.ID = item.id;
                itemDTO.justificacion = item.Justificacion__c;
                itemDTO.puntaje = item.Puntaje__c;
                itemDTO.cicloTemp = item.Ciclo__c;
                itemDTO.estandarAgrupadorTemp = item.Estandar_agrupador__c;
                itemDTO.estandarTemp = item.Estandar__c;
                itemDTO.url = url +'/'+item.id+'/'+item.name;
                
                
                listaEstandares.add(itemDTO);
                
                cicloDTO.calificacion = totalCiclo;
                estandarAgrupadorDTO.calificacion = totalEstandarAgrupador;
                estandarDTO.calificacion = totalEstandar;
                
            }
            consultarDatosEncabezado();
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error en obteniendo los estándares mínimos, por favor contacte al administrador'));
            System.debug('Error en obtenerListaEstandares()'+e.getLineNumber()+e.getMessage());
        }
    }
    
    
    /**Método que se encarga de guardar los resultados de la evaluación de estándares mínimos*/
    public void guardarEvaluacionEstandar(){
        try{
            mensajesPaginaPrincipal.clear();
            
            List<ID> idEstandares = new List<ID>();
            for(EstandarDTO estandar : listaEstandares){
                if(estandar.item != null){
                    idEstandares.add(estandar.id);
                }	
            }
            
            List<SST_Estandar_minimo__c> listaGuardar = new List<SST_Estandar_minimo__c>();        
            for(SST_Estandar_minimo__c estandarGuardar : [SELECT id FROM SST_Estandar_minimo__c WHERE id in :idEstandares]){
                for(EstandarDTO estandar : listaEstandares){
                    if(estandar.id == estandarGuardar.id){
                        estandarGuardar.cumplimiento__c = estandar.cumplimiento;
                        estandarGuardar.Justificacion__c = estandar.justificacion;
                        listaGuardar.add(estandarGuardar);
                    }
                }
            }
            if(Schema.sObjectType.SST_Estandar_minimo__c.fields.Cumplimiento__c.isUpdateable()&&
               Schema.sObjectType.SST_Estandar_minimo__c.fields.Justificacion__c.isUpdateable()){
                   update(listaGuardar); 
                   mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.CONFIRMACION,'La evaluaciones fueron actualizadas exitosamente.'));
               }else{
                   mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Permisos insuficientes para modificar los estándares mínimos'));
               }
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error guardando los datos de la evaluación de estándares mínimos, por favor contacte al administrador'));
            System.debug('Error en guardarEvaluacionEstandar()'+e.getLineNumber()+e.getMessage());
        }
    }
    /*Método que se encarga de consultar los datos del encabezado del reporte PDF*/
    private void consultarDatosEncabezado(){
        Account cuenta = new Account();
        cuenta = SST_Constantes.consultarDatosEmpresa(SST_Constantes.getEmpresaAutenticada());
        if(cuenta == null){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No hay actualmente configurada una empresa como cuenta principal.  Verifique y complete la configuración de los datos de la empresa para continuar con la evaluación'));            
            botonActivo = false;
        } else {
            Datetime fecha = System.today();
            fechaReporte = fecha.format(SST_Constantes.FORMATO_FECHA_REPORTE);
            fechaReporte = SST_Constantes.cambiarNombreMes(fechaReporte);
            empresa = cuenta.name;
            nit = String.valueOf(cuenta.sst_nit__c); 
            botonActivo = true;
        }
    }
    
    /**Método que se encarga de actualizar los valores para la actualziación de la calificación*/
    public void actualizarCalificacion(){
        try{
            mensajesPaginaPrincipal.clear();
            total = 0;
            double totalEstandar = 0;
            double totalCiclo = 0;
            double totalEstandarAgrupador = 0;
            
            for(EstandarDTO estandarDTO : listaEstandares){
                if(estandarDTO.cumplimiento == SST_Constantes.CUMPLE || (estandarDTO.cumplimiento == SST_Constantes.NO_APLICA && estandarDTO.justificacion != null && estandarDTO.justificacion != null)){
                    if(estandarDTO.cicloTemp == cicloActual){
                        totalCiclo += estandarDTO.puntaje;
                    }
                    if(estandarDTO.estandarAgrupadorTemp == estandarAgrupadorActual){
                        totalEstandarAgrupador += estandarDTO.puntaje;
                    }
                    if(estandarDTO.estandarTemp == estandarActual){
                        totalEstandar += estandarDTO.puntaje;
                    }    
                    total += estandarDTO.puntaje;
                    
                }
                if(estandarDTO.cumplimiento == SST_Constantes.CUMPLE || estandarDTO.cumplimiento == SST_Constantes.NO_CUMPLE){
                    estandarDTO.justificacion = null;
                }
            }
            for(EstandarDTO estandarDTO : listaEstandares){
                if(estandarDTO.ciclo == cicloActual){
                    estandarDTO.calificacion = totalCiclo;
                    continue;
                }
                if(estandarDTO.estandarAgrupador == estandarAgrupadorActual){
                    estandarDTO.calificacion = totalEstandarAgrupador;
                    continue;
                }
                if(estandarDTO.estandar == estandarActual){
                    estandarDTO.calificacion = totalEstandar;
                    break;
                }
            }
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error actualizando los valores de la calificación, por favor contacte al administrador'));
            System.debug('Error en actualizarCalificacion()'+e.getLineNumber()+e.getMessage());
        }
        
    }
    /**Método que se encarga de obtener la lista de selección para el cumplimiento del estándar.*/
    public List<SelectOption> getCumplimiento(){
        try{
            Schema.DescribeFieldResult campoCumplimiento = SST_Estandar_Minimo__c.Cumplimiento__c.getDescribe();
            
            List<Schema.PicklistEntry> picklistCumplimiento = campoCumplimiento.getPicklistValues();
            List<SelectOption> cumplimiento = new List<SelectOption>();
            
            for( Schema.PicklistEntry pickItem : picklistCumplimiento){
                cumplimiento.add(new SelectOption(pickItem.getValue(), pickItem.getLabel()));
            }    
            return cumplimiento;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error obteniendo la lista del cumplimiento, por favor contacte al administrador'));
            System.debug('Error en getCumplimiento()'+e.getLineNumber()+e.getMessage());
            return null;
        }
    } 
    
    /*Método que se encarga de guardar la información del reporte generado*/
    public PageReference generarReporteEstandaresMinimos(){
        try{
            mensajesPaginaPrincipal.clear();
            guardarCalificacion(total,'ESTANDAR MINIMO');
            pageReference reporte = new pageReference(url+SST_Constantes.REPORTE_ESTANDARES_MINIMOS);
            return reporte;
        }catch(ApplicationException ae){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,ae.getMessage())); 
            return null;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error generando el reporte de Estándares mínimos, por favor contacte al administrador'));
            System.debug('Error en generarReporte'+e.getLineNumber()+e.getMessage());
            return null;
        }             
    }
    
        /*Método encargado de guardar la calificación de estandares mínimos */
    public void guardarCalificacion(double total, String normaCalificada){
        
        if(Schema.sObjectType.SST_Calificacion_norma__c.fields.calificacion__c.isCreateable()&&
           Schema.sObjectType.SST_Calificacion_norma__c.fields.norma_calificada__c.isCreateable()&&
           Schema.sObjectType.SST_Calificacion_norma__c.fields.Comentarios__c.isCreateable()&&
           Schema.sObjectType.SST_Calificacion_norma__c.fields.ultima_calificacion__c.isCreateable()&&
           Schema.sObjectType.SST_Calificacion_norma__c.fields.empresa__c.isCreateable()&&
           Schema.sObjectType.SST_Calificacion_norma__c.fields.ultima_calificacion__c.isUpdateable()){
               List<SST_Calificacion_norma__c> calificacionesAnteriores = New List <SST_Calificacion_norma__c>();
               for(SST_Calificacion_norma__c calificacionNorma:[Select id, name from SST_Calificacion_norma__c where Empresa__c=:empresaAutenticada and norma_calificada__c=: normaCalificada and ultima_calificacion__c =: true]){
                   calificacionNorma.ultima_calificacion__c=false;  
                   calificacionesAnteriores.add(calificacionNorma);
               }  
               update calificacionesAnteriores;
               
               
               SST_Calificacion_norma__c calificacionNorma = new SST_Calificacion_norma__c();
               calificacionNorma.calificacion__c = total;
               calificacionNorma.norma_calificada__c = normaCalificada;
               calificacionNorma.Comentarios__c=comentarios;
               calificacionNorma.ultima_calificacion__c=true;
               calificacionNorma.empresa__c = empresaAutenticada;
               insert(calificacionNorma);
           }else{
               throw new ApplicationException('Permisos insuficientes para modificar o registrar calificación de la norma');
           }
    }
    
     public class ApplicationException extends Exception {}
    
    /*Clase interna que representa el DTO de los estandares mínimos*/
    public class EstandarDTO{
        
        public String ciclo {get; set;}
        public String estandarAgrupador {get; set;}
        public String estandar {get; set;}
        public String item {get;set;}
        public double puntaje {get;set;}
        public String cumplimiento {get;set;}
        public String justificacion {get;set;}
        public String fondo {get; set;}
        public Id id {get;set;}
        public String cicloTemp {get; set;}
        public String estandarAgrupadorTemp {get; set;}
        public String estandarTemp {get; set;}
        public String url {get; set;}
        public double calificacion {get; set;}
        
    }    
}