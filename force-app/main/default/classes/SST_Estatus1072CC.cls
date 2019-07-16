/*
* @autor: Marcela Taborda
* @fecha: 20/06/2018
* @version: 1.0
*/
public with sharing class SST_Estatus1072CC {
    
    //Atributo para sumar el puntaje de todas las actividades en las páginas
    public Double puntajeTotalParametrizacion {get;set;}
    public Double puntajeTotalEvaluacion {get;set;}
    
    //Atributo para mostrar los datos de cada registro en la página
    public List <DTOActividades> listaActividades {get;set;}
    
    //Atributo para mostrar los datos por bloques de ciclos en el reporte en PDF
    public Map <String,List<DTOActividades>> mapaCiclo1 {get;set;}
    public Map <String,List<DTOActividades>> mapaCiclo2 {get;set;}
    public Map <String,List<DTOActividades>> mapaCiclo3 {get;set;}
    public Map <String,List<DTOActividades>> mapaCiclo4 {get;set;}
    public Map <String,List<DTOActividades>> mapaCiclo5 {get;set;}
    private Map <id, SST_Status_Implementacion_1072__c> mapaArticulos {get;set;}
    
    //Atributo para mostrar los mensajes de éxito, confirmación o error en las páginas
    public List<SST_MensajesPagina> mensajesPaginaPrincipalParametrizacion {get;set;}
    public List<SST_MensajesPagina> mensajesPaginaPrincipalEvaluacion {get;set;}
    
    //Atributo para obtener el id del registro que se está modificando en las páginas
    public String idModificarParametrizacion {get;set;}
    public String idModificarEvaluacion {get;set;} 
    
    //Atributo para obtener la url de la página actual
    public String url {get;set;}
    
    //Atributo para obtener la fecha y hora para el encabezado del reporte de evaluación
    Public String fechaReporte {get;set;}
    
    //Atributos para obtener el nombre y nit de la empresa para el encabezado del reporte de evaluación
    Public String empresa {get;set;}
    Public String nit {get;set;}
    
    //Atributo para sumar el puntaje de todas las actividades
    public Double puntajeTotalPDF {get;set;}
    
    //Atributo con la cadena 'Eliminar' para identificar los registros que deberán ser eliminados posteriormente de las listas
    Private String eliminar = 'eliminar';
    
    //Atributo para mostrar el nombre del ciclo en el reporte en PDF
    Public List <String> ciclos {get;set;}
    
    //Atributo para activar o inactivar el botón de guardar en la página
    public Boolean botonActivo {get; set;}
    
    /*Atributo para obtener el nit de la empresa en cuya comunidad está actualmente logueado el usuario*/
    public String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
    
    /*Atributo para guardar los comentarios que serán almacenados en la evaluación que se guarde*/
    public String comentarios{get; set;}
    
    /*variable para mostrar los mensajes de éxito, confirmación o error en la página*/
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}

    /*Atributo para obtener la url del home de la comunidad*/
    private String urlReporte {get;set;}
    
    //Controlador
    public SST_Estatus1072CC (){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();
        urlReporte = SST_Constantes.retornarUrl();
        mapaCiclo1 = new Map <String,List<DTOActividades>>();
        mapaCiclo2 = new Map <String,List<DTOActividades>>();
        mapaCiclo3 = new Map <String,List<DTOActividades>>();
        mapaCiclo4 = new Map <String,List<DTOActividades>>();
        mapaCiclo5 = new Map <String,List<DTOActividades>>();
        mapaArticulos = new Map <id, SST_Status_Implementacion_1072__c>();
        ciclos = new List <String>();
        puntajeTotalEvaluacion = 0;
        puntajeTotalParametrizacion = 0;
        puntajeTotalPDF = 0;
        listaActividades = new List <DTOActividades>();
        mensajesPaginaPrincipalEvaluacion = new List<SST_MensajesPagina>();
        mensajesPaginaPrincipalParametrizacion = new List<SST_MensajesPagina>();
        llenarListas();   
        llenarMapasPDF();
        generarDatosEncabezado();
        actualizarValores();
    }
    
    //Método para consultar y llenar la lista que se mostrará en la página
    public void llenarListas(){ 
        url = ApexPages.currentPage().getHeaders().get('Referer');
        listaActividades = new List <DTOActividades>();
        //Mapa para consultar los registros de primer nivel o ciclos
        Map <id, SST_Status_Implementacion_1072__c> mapaCiclos = new Map <id, SST_Status_Implementacion_1072__c>([select id, descripcion__c, cumplimiento__c, prioridad__c, peso__c, (select id, peso__c, cumplimiento__c, justificacion__c from SST_Status_Implementacion_1072__r where empresa__c=:empresaAutenticada) from SST_Status_Implementacion_1072__c where padre__c =: null and empresa__c=:empresaAutenticada order by name]);
        
        //Mapa para consultar los registros de segundo nivel o artículos
        mapaArticulos = new Map <id, SST_Status_Implementacion_1072__c>([select id, descripcion__c, padre__c, padre__r.id, padre__r.descripcion__c, cumplimiento__c, prioridad__c, peso__c, (select id, peso__c, cumplimiento__c, justificacion__c from SST_Status_Implementacion_1072__r where empresa__c=:empresaAutenticada) from SST_Status_Implementacion_1072__c where padre__c <> null and padre__r.padre__c =:null and empresa__c=:empresaAutenticada order by name]);
        
        //Mapa para consultar los registros de tercer nivel o actividades
        map <id, SST_Status_Implementacion_1072__c> mapaItems = new map <id, SST_Status_Implementacion_1072__c>([select id, name, descripcion__c, padre__c, padre__r.id, padre__r.descripcion__c, padre__r.cumplimiento__c, padre__r.peso__c, padre__r.prioridad__c, padre__r.padre__c, padre__r.padre__r.id, padre__r.padre__r.descripcion__c, padre__r.padre__r.cumplimiento__c, padre__r.padre__r.peso__c, padre__r.padre__r.prioridad__c, cumplimiento__c, prioridad__c, justificacion__c, peso__c from SST_Status_Implementacion_1072__c where padre__c <> null and padre__r.padre__c <>null and empresa__c=:empresaAutenticada order by idExterno__c DESC]);
        
        //Lista temporal que se itera para adicionar o eliminar registros de la lista principal que se muestra en la página
        List <DTOActividades> listaActividadesTemp = new List <DTOActividades>();
        for(id key : mapaCiclos.keyset()){
            SST_Status_Implementacion_1072__c temp = mapaCiclos.get(key);
            ciclos.add(temp.descripcion__c.toUpperCase());
            DTOActividades registroCiclo = new DTOActividades();
            registroCiclo.idItem = temp.id;
            registroCiclo.descripcion = '';
            registroCiclo.descripcionPadre = temp.descripcion__c;
            registroCiclo.descripcionHijo = '';
            registroCiclo.cumplimiento = temp.cumplimiento__c;
            registroCiclo.prioridad = temp.prioridad__c;
            registroCiclo.peso = temp.peso__c;
            registroCiclo.fondo = SST_Constantes.COLOR_PRIMER_NIVEL;
            registroCiclo.fondoPuntaje = SST_Constantes.COLOR_PRIMER_NIVEL;
            registroCiclo.justificacion = '';
            registroCiclo.inhabilitar = false;
            registroCiclo.Puntaje = 0;
            registroCiclo.url = '';
            registroCiclo.ciclo = '';
            registroCiclo.articulo = '';
            registroCiclo.idItemPadre = '';
            listaActividades.add(registroCiclo);
            listaActividadesTemp.add(registroCiclo);
        }
        
        DTOActividades registroCiclo = new DTOActividades();
        registroCiclo.descripcionPadre = eliminar;
        listaActividades.add(registroCiclo);
        listaActividadesTemp.add(registroCiclo);
        
        Integer count = 0;
        for(Id key : mapaArticulos.keySet()){
            SST_Status_Implementacion_1072__c ttmp = mapaArticulos.get(key);
            for(Integer i=0; i<listaActividadesTemp.size()-1; i++){
                DTOActividades temp = listaActividadesTemp.get(i);
                if(ttmp.padre__r.id == temp.idItem){
                    DTOActividades registroArticulo = new DTOActividades();
                    registroArticulo.idItem = ttmp.id;
                    registroArticulo.descripcion = '';
                    registroArticulo.descripcionPadre = '';
                    registroArticulo.descripcionHijo = ttmp.descripcion__c;
                    registroArticulo.cumplimiento = ttmp.cumplimiento__c;
                    registroArticulo.prioridad = ttmp.prioridad__c;
                    registroArticulo.peso = ttmp.peso__c;
                    registroArticulo.fondo = SST_Constantes.COLOR_TERCER_NIVEL;
                    registroArticulo.fondoPuntaje = SST_Constantes.COLOR_TERCER_NIVEL;
                    registroArticulo.justificacion = '';
                    registroArticulo.inhabilitar = false;
                    registroArticulo.Puntaje = 0;
                    registroArticulo.idItemPadre = ttmp.padre__r.id;
                    registroArticulo.url = '';
                    registroArticulo.ciclo = '';
                    registroArticulo.articulo = '';
                    for(SST_Status_Implementacion_1072__c temporal : ttmp.SST_Status_Implementacion_1072__r){
                        if(String.isEmpty(temporal.cumplimiento__c)){
                            registroArticulo.Puntaje = registroArticulo.Puntaje + 0;
                        } else {
                            if(temporal.cumplimiento__c.equalsIgnoreCase(SST_Constantes.CUMPLE) || (temporal.cumplimiento__c.equalsIgnoreCase(SST_Constantes.NO_APLICA) && !String.isBlank(temporal.justificacion__c))){
                                registroArticulo.Puntaje = registroArticulo.Puntaje + temporal.peso__c;
                            }
                            else if(temporal.cumplimiento__c.equalsIgnoreCase(SST_Constantes.CUMPLE_PARCIALMENTE)){
                                registroArticulo.Puntaje = registroArticulo.Puntaje + (temporal.peso__c/2);
                            }
                            else if(temporal.cumplimiento__c.equalsIgnoreCase(SST_Constantes.NO_CUMPLE) || String.isBlank(temporal.cumplimiento__c) || (temporal.cumplimiento__c.equalsIgnoreCase(SST_Constantes.NO_APLICA) && String.isBlank(temporal.justificacion__c))){
                                registroArticulo.Puntaje = registroArticulo.Puntaje + 0;
                            }   
                        }
                    }
                    Decimal t = Decimal.valueOf(registroArticulo.Puntaje).setScale(2);
                    registroArticulo.Puntaje = t;
                    count++;
                    listaActividades.add(count+i, registroArticulo);
                }
                DTOActividades registroCiclo2 = new DTOActividades();
                registroCiclo2.descripcionPadre = eliminar;
                listaActividades.add(registroCiclo2);
            }
        }
        listaActividadesTemp = new List <DTOActividades>();
        //listaActividadesTemp.clear();
        listaActividadesTemp = listaActividades;
        
        Integer countItem = 0;
        for(Id key : mapaItems.keySet()){
            SST_Status_Implementacion_1072__c ttmp = mapaItems.get(key);
            for(Integer i=0; i<listaActividadesTemp.size()-1; i++){
                DTOActividades temp = listaActividadesTemp.get(i);
                DTOActividades temp2 = listaActividadesTemp.get(i+1);
                
                if(ttmp.padre__r.id == temp.idItem){
                    DTOActividades registroActividad = new DTOActividades();
                    registroActividad.idItem = ttmp.id;
                    registroActividad.descripcion = ttmp.descripcion__c;
                    registroActividad.descripcionPadre = '';
                    registroActividad.descripcionHijo = '';
                    registroActividad.prioridad = ttmp.prioridad__c;
                    registroActividad.peso = ttmp.peso__c;
                    registroActividad.fondo = '';
                    registroActividad.justificacion = ttmp.justificacion__c;
                    registroActividad.idItemPadre = ttmp.padre__r.id;
                    registroActividad.url = url+'/'+ttmp.id+'/'+ttmp.name;
                    registroActividad.ciclo = ttmp.padre__r.padre__r.descripcion__c;
                    registroActividad.articulo = ttmp.padre__r.descripcion__c;
                    if(ttmp.cumplimiento__c == null){
                        registroActividad.cumplimiento = SST_Constantes.NO_CUMPLE;
                    } else {
                        registroActividad.cumplimiento = ttmp.cumplimiento__c;
                    }
                    
                    if(ttmp.justificacion__c == null){
                        registroActividad.justificacion = '';
                    } else {
                        registroActividad.justificacion = ttmp.justificacion__c;
                    }
                    
                    if(registroActividad.cumplimiento.equalsIgnoreCase(SST_Constantes.CUMPLE) || (registroActividad.cumplimiento.equalsIgnoreCase(SST_Constantes.NO_APLICA) && !String.isBlank(registroActividad.justificacion))){
                        registroActividad.Puntaje = ttmp.peso__c;
                        registroActividad.fondoPuntaje = SST_Constantes.COLOR_CUMPLE;
                    }
                    else if(registroActividad.cumplimiento.equalsIgnoreCase(SST_Constantes.CUMPLE_PARCIALMENTE)){
                        registroActividad.Puntaje = ttmp.peso__c/2;
                        registroActividad.fondoPuntaje = SST_Constantes.COLOR_CUMPLE_PARCIALMENTE;
                    }
                    else if(registroActividad.cumplimiento.equalsIgnoreCase(SST_Constantes.NO_CUMPLE) || String.isBlank(registroActividad.cumplimiento) || (registroActividad.cumplimiento.equalsIgnoreCase(SST_Constantes.NO_APLICA) && String.isBlank(registroActividad.justificacion))){
                        registroActividad.Puntaje = 0;
                        registroActividad.fondoPuntaje = SST_Constantes.COLOR_NO_CUMPLE;
                    }
                    
                    if(ttmp.prioridad__c.equalsIgnoreCase(SST_Constantes.NO_APLICA)){
                        registroActividad.inhabilitar = true;
                    } else {
                        registroActividad.inhabilitar = false;
                    }
                    if(temp2!= null && temp.descripcionHijo != temp2.descripcionHijo){
                        countItem++;
                    }
                    Decimal porcentajeTemp = (decimal.valueOf(puntajeTotalParametrizacion+registroActividad.peso)).setScale(2);
                    if(porcentajeTemp >100 && porcentajeTemp<101){
                        puntajeTotalParametrizacion = Integer.valueOf(porcentajeTemp);
                    } else {
                        puntajeTotalParametrizacion = porcentajeTemp;   
                    }
                    Decimal t = Decimal.valueOf(registroActividad.Puntaje).setScale(2);
                    registroActividad.Puntaje = t;
                    puntajeTotalEvaluacion = puntajeTotalEvaluacion+registroActividad.Puntaje;
                    listaActividades.add(countItem+i, registroActividad);
                    countItem--;
                }
            }
        }
        listaActividadesTemp = new List <DTOActividades>();
        listaActividadesTemp = listaActividades; 
        for (Integer i=listaActividadesTemp.size()-1; i>=0; i-- ){
            DTOActividades temp = listaActividadesTemp.get(i);
            if(temp.descripcionPadre.equals(eliminar)){
                listaActividades.remove(i);    
            } else {
                break;
            }
        }
        for(Integer i=0; i<=listaActividades.size()-1; i++){
            DTOActividades temp = listaActividades.get(i);
            temp.linea=1+i;
        }
        Decimal t = Decimal.valueOf(puntajeTotalEvaluacion).setScale(2);
        puntajeTotalEvaluacion = t;
        puntajeTotalPDF = puntajeTotalEvaluacion;
        actualizarPuntajesCiclos();
    }
    
    //Método para obtener la lista de valores posibles para el select de Prioridad
    public List<SelectOption> getPrioridad(){
        List<SelectOption> prioridad = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = SST_Status_Implementacion_1072__c.Prioridad__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();    
        for(Schema.PicklistEntry prioridadTemp : itemsTemp){
            prioridad.add(new SelectOption(prioridadTemp.GetLabel(),prioridadTemp.GetValue()));
        }
        return prioridad;              
    }
    
    //Método para actualizar los valores en la página de evaluación
    public pageReference actualizarValoresEvaluacion(){
        puntajeTotalEvaluacion = 0;
        mensajesPaginaPrincipalEvaluacion.clear();
        
        for(DTOActividades ttmp: listaActividades){
            if(ttmp.idItem.equals(idModificarEvaluacion)){
                ttmp.cumplimiento = ttmp.cumplimiento;
                ttmp.justificacion = ttmp.justificacion;
                if(!ttmp.cumplimiento.equals(SST_Constantes.NO_APLICA)){
                    ttmp.justificacion = '';
                } else {
                    ttmp.justificacion = ttmp.justificacion;    
                }
                
                if(ttmp.cumplimiento.equalsIgnoreCase(SST_Constantes.CUMPLE) || (ttmp.cumplimiento.equalsIgnoreCase(SST_Constantes.NO_APLICA) && !String.isBlank(ttmp.justificacion))){
                    ttmp.puntaje = ttmp.peso;
                    ttmp.fondoPuntaje = SST_Constantes.COLOR_CUMPLE;
                }
                else if(ttmp.cumplimiento.equalsIgnoreCase(SST_Constantes.CUMPLE_PARCIALMENTE)){
                    Decimal puntajeTemp = (decimal.valueOf(ttmp.peso/2)).setScale(2);
                    ttmp.puntaje = puntajeTemp;
                    ttmp.fondoPuntaje = SST_Constantes.COLOR_CUMPLE_PARCIALMENTE;
                    
                }
                else if(ttmp.cumplimiento.equalsIgnoreCase(SST_Constantes.NO_CUMPLE) || String.isBlank(ttmp.cumplimiento) || (ttmp.cumplimiento.equalsIgnoreCase(SST_Constantes.NO_APLICA) && String.isBlank(ttmp.justificacion))){
                    ttmp.puntaje = 0;
                    ttmp.fondoPuntaje = SST_Constantes.COLOR_NO_CUMPLE;
                } 
            }
            if(!String.isBlank(ttmp.descripcion) && String.isBlank(ttmp.descripcionPadre) && String.isBlank(ttmp.descripcionHijo)){
                puntajeTotalEvaluacion = puntajeTotalEvaluacion+ttmp.puntaje;       
            }   
        }
        Decimal t = Decimal.valueOf(puntajeTotalEvaluacion).setScale(2);
        puntajeTotalEvaluacion = t;
        actualizarPuntajesArticulos();
        actualizarPuntajesCiclos();
        return null;
    }
    
    private void actualizarValores(){
        for(DTOActividades ttmp: listaActividades){
            if(ttmp.cumplimiento<> null && ttmp.cumplimiento.equalsIgnoreCase(SST_Constantes.CUMPLE)){
                ttmp.cumplimiento = SST_Constantes.CUMPLE;
            }
            if(ttmp.cumplimiento<> null && (ttmp.cumplimiento.equalsIgnoreCase(SST_Constantes.CUMPLE_PARCIALMENTE) || ttmp.cumplimiento.equalsIgnoreCase('Cumple parcialmente'))){
                ttmp.cumplimiento = SST_Constantes.CUMPLE_PARCIALMENTE;
            }
            if(ttmp.cumplimiento<> null && (ttmp.cumplimiento.equalsIgnoreCase(SST_Constantes.NO_CUMPLE) || ttmp.cumplimiento.equalsIgnoreCase('No cumple'))){
                ttmp.cumplimiento = SST_Constantes.NO_CUMPLE;
            } 
            if(ttmp.cumplimiento<> null && (ttmp.cumplimiento.equalsIgnoreCase(SST_Constantes.NO_APLICA) || ttmp.cumplimiento.equalsIgnoreCase('No aplica'))){
                ttmp.cumplimiento = SST_Constantes.NO_APLICA;
            } 
        }
    }
    
    //Método para actualizar los valores en la página de parametrización
    public pageReference actualizarValoresParametrizacion(){
        puntajeTotalParametrizacion = 0;
        mensajesPaginaPrincipalParametrizacion.clear();
        for(DTOActividades ttmp: listaActividades){
            if(ttmp.idItem.equals(idModificarParametrizacion)){
                ttmp.peso = ttmp.peso;
                if(ttmp.peso==null){
                    ttmp.peso = 0;
                } else {
                    Decimal temporal = decimal.valueOf(ttmp.peso).setScale(2);
                    ttmp.peso = temporal;
                }
            }
            puntajeTotalParametrizacion = puntajeTotalParametrizacion+ttmp.peso;
        }
        Decimal porcentajeTemp = decimal.valueOf(puntajeTotalParametrizacion).setScale(2);
        if(porcentajeTemp >100 && porcentajeTemp<101){
            puntajeTotalParametrizacion = Integer.valueOf(porcentajeTemp);
        } else {
            puntajeTotalParametrizacion = porcentajeTemp;   
        }
        return null;
    }
    
    //Método para actualizar los puntajes de los artículos en la página
    private void actualizarPuntajesArticulos(){
        List <DTOActividades> listaTemporal = listaActividades;
        for(DTOActividades a : listaActividades){
            if(a.descripcionPadre.equals('') && !a.descripcionHijo.equals('')){
                a.puntaje = 0;
                for(DTOActividades b : listaTemporal){
                    if(a.idItem.equals(b.idItemPadre)){
                        a.puntaje = a.puntaje + b.puntaje;
                    }
                }
            } 
            Decimal t = Decimal.valueOf(a.puntaje).setScale(2);
            a.puntaje = t;
        }
    }
    
    //Método para actualizar los puntajes de los ciclos en la página
    private void actualizarPuntajesCiclos(){
        List <DTOActividades> listaTemporal = listaActividades;
        for(DTOActividades a : listaActividades){
            if(!a.descripcionPadre.equals('') && a.descripcionHijo.equals('')){
                a.puntaje = 0;
                for(DTOActividades b : listaTemporal){
                    if(a.idItem.equals(b.idItemPadre)){
                        a.puntaje = a.puntaje + b.puntaje;
                    }
                }
            } 
            Decimal t = Decimal.valueOf(a.puntaje).setScale(2);
            a.puntaje = t;
        }
    }
    
    //Método para generar los datos para el encabezado del reporte
    public void generarDatosEncabezado(){
        Account cuenta = new Account();
        cuenta = SST_Constantes.consultarDatosEmpresa(SST_Constantes.getEmpresaAutenticada());
        if(cuenta == null){
            mensajesPaginaPrincipalEvaluacion.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'No hay actualmente configurada una empresa como cuenta principal.  Verifique y complete la configuración de los datos de la empresa para continuar con la evaluación'));            
            botonActivo = false;
        } else {
            Datetime fecha = system.now(); 
            fechaReporte = fecha.format(SST_Constantes.FORMATO_FECHA_REPORTE);
            fechaReporte = SST_Constantes.cambiarNombreMes(fechaReporte);
            empresa = cuenta.name;
            nit = String.valueOf(cuenta.sst_nit__c); 
            botonActivo = true;
        }
    }
    
    //Método que guarda las calificaciones de cada actividad
    public PageReference GuardarEvaluacion(){
        mensajesPaginaPrincipalEvaluacion.clear();
        if(Schema.sObjectType.SST_Status_Implementacion_1072__c.fields.Cumplimiento__c.isUpdateable()&&
           Schema.sObjectType.SST_Status_Implementacion_1072__c.fields.Prioridad__c.isUpdateable()&&
           Schema.sObjectType.SST_Status_Implementacion_1072__c.fields.Justificacion__c.isUpdateable()){
               List <SST_Status_Implementacion_1072__c> registrosAGuardar = new List <SST_Status_Implementacion_1072__c>();
               
               List<ID> idEstatus = new List<ID>();
               for(DTOActividades registroTemp : listaActividades){
                   if(registroTemp.descripcionPadre.equals('') && registroTemp.descripcionHijo.equals('')){
                       idEstatus.add(registroTemp.idItem);
                   }
               }
               
               for(SST_Status_Implementacion_1072__c registro : [SELECT ID FROM SST_Status_Implementacion_1072__c WHERE id in :idEstatus]){
                   for(DTOActividades registroTemp : listaActividades){
                       if(registroTemp.idItem == registro.id){
                           registro.Cumplimiento__c = registroTemp.cumplimiento;
                           registro.Prioridad__c = registroTemp.prioridad;
                           registro.Justificacion__c = registroTemp.justificacion;
                           registrosAGuardar.add(registro);
                       }
                   }
               }
               try{
                   Boolean guardarExitoso = true;
                   Database.SaveResult[] results = Database.update(registrosAGuardar); 
                   if (results != null){
                       for (Database.SaveResult result : results) {
                           if (!result.isSuccess()) {
                               guardarExitoso = false;
                               Database.Error[] errs = result.getErrors();
                               mensajesPaginaPrincipalEvaluacion.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'No fue posible actualizar las evaluaciones, por favor intente nuevamente.'));
                               for(Database.Error err : errs)
                                   System.debug(err.getStatusCode() + ' - ' + err.getMessage());
                           }
                       }
                   } 
                   if(guardarExitoso){
                       mensajesPaginaPrincipalEvaluacion.add(new SST_MensajesPagina(SST_MensajesPagina.CONFIRMACION,'La evaluaciones fueron actualizadas exitosamente.'));
                   }
                   llenarListas();   
               } catch (DmlException e) {
                   system.debug('Mensaje error:'+e.getMessage());
                   system.debug('Linea error:'+e.getLineNumber());
                   system.debug('Causa error:'+e.getCause());
                   mensajesPaginaPrincipalEvaluacion.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,e.getMessage()));
               }
           }else{
               mensajesPaginaPrincipalEvaluacion.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Permisos insuficientes para modificar el estatus de implementación 1072'));
           }
        return null;
    }
    
    //Método que guarda las evaluaciones de cada actividad en la página
    public PageReference guardarParametrizacion(){
        mensajesPaginaPrincipalParametrizacion.clear();
        if(Schema.sObjectType.SST_Status_Implementacion_1072__c.fields.Peso__c.isUpdateable()){
            
            List<ID> idActividades = new List<ID>();
            for(DTOActividades registroTemp : listaActividades){
                idActividades.add(registroTemp.idItem);   
            }
            
            List <SST_Status_Implementacion_1072__c> registrosAGuardarParametrizacion = new List <SST_Status_Implementacion_1072__c>();
            for(SST_Status_Implementacion_1072__c registro : [SELECT id FROM SST_Status_Implementacion_1072__c WHERE id in :idActividades]){
                for(DTOActividades registroTemp : listaActividades){
                    if(registro.id == registroTemp.idItem){
                        
                        if(registroTemp.peso > 100){
                            mensajesPaginaPrincipalParametrizacion.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'El porcentaje de la actividad es superior al 100% en la línea #: '+registroTemp.linea));
                        }
                        else {
                            registro.Peso__c = registroTemp.peso;   
                            registrosAGuardarParametrizacion.add(registro);
                        }
                    }
                }
            }
            if(puntajeTotalParametrizacion == 100 && mensajesPaginaPrincipalParametrizacion.size()==0){
                Boolean guardarExitoso = true;
                try{
                    Database.SaveResult[] results = Database.update(registrosAGuardarParametrizacion); 
                    if (results != null){
                        for (Database.SaveResult result : results) {
                            if (!result.isSuccess()) {
                                guardarExitoso = false;
                                Database.Error[] errs = result.getErrors();
                                mensajesPaginaPrincipalParametrizacion.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'No fue posible actualizar la asignación de pesos, por favor intente nuevamente.'));
                                for(Database.Error err : errs)
                                    System.debug(err.getStatusCode() + ' - ' + err.getMessage());
                            }
                        }
                    } 
                    if(guardarExitoso){
                        mensajesPaginaPrincipalParametrizacion.add(new SST_MensajesPagina(SST_MensajesPagina.CONFIRMACION,'La asignaciones de pesos fueron actualizadas exitosamente.'));
                    }
                    llenarListas();     
                } catch (DmlException e) {
                    system.debug('Mensaje error:'+e.getMessage());
                    system.debug('Linea error:'+e.getLineNumber());
                    system.debug('Causa error:'+e.getCause());
                    mensajesPaginaPrincipalParametrizacion.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,e.getMessage()));
                }
            }
            else {
                mensajesPaginaPrincipalParametrizacion.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Las sumatoria de los pesos de todas las actividades es diferente al 100%. Realice el ajuste respectivo.'));
            }
        }else{
            mensajesPaginaPrincipalParametrizacion.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Permisos insuficientes para modificar guardar el resultado de la parametrización'));
        }
        
        return null;
    }
    
    //Método que recorre la lista de actividades y llena los mapas por ciclos que se muestran en el reporte en PDF
    private void llenarMapasPDF(){
        List<DTOActividades> listaTemporalMapas = new List<DTOActividades>();
        Map <String,List<DTOActividades>> mapaCiclo1Temp = new Map <String,List<DTOActividades>>();
        Map <String,List<DTOActividades>> mapaCiclo2Temp = new Map <String,List<DTOActividades>>();
        Map <String,List<DTOActividades>> mapaCiclo3Temp = new Map <String,List<DTOActividades>>();
        Map <String,List<DTOActividades>> mapaCiclo4Temp = new Map <String,List<DTOActividades>>();
        Map <String,List<DTOActividades>> mapaCiclo5Temp = new Map <String,List<DTOActividades>>();
        for(Id key : mapaArticulos.keySet()){
            SST_Status_Implementacion_1072__c registro = mapaArticulos.get(key);
            if(registro.padre__r.descripcion__c.equalsIgnoreCase(ciclos.get(0))){
                mapaCiclo1Temp.put(registro.Descripcion__c, listaTemporalMapas);    
            }
            else if(registro.padre__r.descripcion__c.equalsIgnoreCase(ciclos.get(1))){
                mapaCiclo2Temp.put(registro.Descripcion__c, listaTemporalMapas);    
            }
            else if(registro.padre__r.descripcion__c.equalsIgnoreCase(ciclos.get(2))){
                mapaCiclo3Temp.put(registro.Descripcion__c, listaTemporalMapas);    
            }
            else if(registro.padre__r.descripcion__c.equalsIgnoreCase(ciclos.get(3))){
                mapaCiclo4Temp.put(registro.Descripcion__c, listaTemporalMapas);    
            }
            else if(registro.padre__r.descripcion__c.equalsIgnoreCase(ciclos.get(4))){
                mapaCiclo5Temp.put(registro.Descripcion__c, listaTemporalMapas);    
            }
        }
        List <SelectOption> listaC = getCumplimiento();
        Map <String, String> mapaCumplimiento = new Map <String, String>();
        for(SelectOption t : listaC){
            mapaCumplimiento.put(t.getValue(), t.getLabel());
        }
        Integer orden = 1;
        for(String key : mapaCiclo1Temp.keySet()){
            listaTemporalMapas = new List <DTOActividades>();
            for (DTOActividades temp : listaActividades){
                if(temp.articulo.equals(key) && temp.ciclo.equalsIgnoreCase(ciclos.get(0))){
                    temp.Cumplimiento = mapaCumplimiento.get(temp.Cumplimiento);
                    listaTemporalMapas.add(temp);
                }
            }
            if(listaTemporalMapas.size()>0){
                String t = SST_Constantes.cambiarNumeros(orden);
                mapaCiclo1.put(t+key, listaTemporalMapas);   
            } 
            orden++;
        }
        orden = 1;
        for(String key : mapaCiclo2Temp.keySet()){
            listaTemporalMapas = new List <DTOActividades>();
            for (DTOActividades temp : listaActividades){
                if(temp.articulo.equals(key) && temp.ciclo.equalsIgnoreCase(ciclos.get(1))){
                    temp.Cumplimiento = mapaCumplimiento.get(temp.Cumplimiento);
                    listaTemporalMapas.add(temp);
                }
            }
            if(listaTemporalMapas.size()>0){
                String t = SST_Constantes.cambiarNumeros(orden);
                mapaCiclo2.put(t+key, listaTemporalMapas); 
            }    
            orden++;
        }
        orden = 1;
        for(String key : mapaCiclo3Temp.keySet()){
            listaTemporalMapas = new List <DTOActividades>();
            for (DTOActividades temp : listaActividades){
                if(temp.articulo.equals(key) && temp.ciclo.equalsIgnoreCase(ciclos.get(2))){
                    temp.Cumplimiento = mapaCumplimiento.get(temp.Cumplimiento);
                    listaTemporalMapas.add(temp);
                }
            }
            if(listaTemporalMapas.size()>0){
                String t = SST_Constantes.cambiarNumeros(orden);
                mapaCiclo3.put(t+key, listaTemporalMapas);
            }
            orden++;
        }
        orden = 1;
        for(String key : mapaCiclo4Temp.keySet()){
            listaTemporalMapas = new List <DTOActividades>();
            for (DTOActividades temp : listaActividades){
                if(temp.articulo.equals(key) && temp.ciclo.equalsIgnoreCase(ciclos.get(3))){
                    temp.Cumplimiento = mapaCumplimiento.get(temp.Cumplimiento);
                    listaTemporalMapas.add(temp);
                }
            }
            if(listaTemporalMapas.size()>0){
                String t = SST_Constantes.cambiarNumeros(orden);
                mapaCiclo4.put(t+key, listaTemporalMapas);
            }
            orden++;
        }
        orden = 1;
        for(String key : mapaCiclo5Temp.keySet()){
            listaTemporalMapas = new List <DTOActividades>();
            for (DTOActividades temp : listaActividades){
                if(temp.articulo.equals(key) && temp.ciclo.equalsIgnoreCase(ciclos.get(4))){
                    temp.Cumplimiento = mapaCumplimiento.get(temp.Cumplimiento);
                    listaTemporalMapas.add(temp);
                }
            }
            if(listaTemporalMapas.size()>0){
                String t = SST_Constantes.cambiarNumeros(orden);
                mapaCiclo5.put(t+key, listaTemporalMapas);  
            }
            orden++;
        }
    }
    
    public List<SelectOption> getCumplimiento(){
        Schema.DescribeFieldResult campoCumplimiento = SST_Status_Implementacion_1072__c.Cumplimiento__c.getDescribe();
        
        List<Schema.PicklistEntry> picklistCumplimiento = campoCumplimiento.getPicklistValues();
        List<SelectOption> cumplimiento = new List<SelectOption>();
        
        for( Schema.PicklistEntry pickItem : picklistCumplimiento){
            cumplimiento.add(new SelectOption(pickItem.getValue(), pickItem.getLabel()));
        }
        return cumplimiento;
    }
    
    /*Método que se encarga de guardar la información del reporte generado*/
    public PageReference generarReporteEstatusImplementacion(){
        try{
            mensajesPaginaPrincipal.clear();
            guardarCalificacion(puntajeTotalEvaluacion,'ESTATUS IMPLEMENTACION');
            PageReference reporte = new pageReference(urlReporte+SST_Constantes.REPORTE_ESTATUS_1072);
            return  reporte;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error generando el reporte de Estatus de implementación, por favor contacte al administrador'));
            System.debug('Error en generarReporte'+e.getLineNumber()+e.getMessage());
            return null;
        }             
    }
    
    /*Método encargado de guardar la calificación de estatus de implementación 1072*/
    private void guardarCalificacion(double total, String normaCalificada){
        
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
    
    
    //Inner class con el tipo de objeto que se muestra en la página
    public class DTOActividades{
        public String idItem {get;set;}
        public String idItemPadre {get;set;}
        public String descripcion {get;set;}
        public String descripcionPadre {get;set;}
        public String descripcionHijo {get;set;}
        public String cumplimiento {get;set;}
        public String prioridad {get;set;}
        public Double peso {get;set;}
        public String fondo {get;set;}
        public String justificacion {get;set;}
        public Boolean inhabilitar {get;set;}
        public Double puntaje {get;set;}
        public String fondoPuntaje {get;set;}
        public String url {get;set;}
        public Integer linea {get;set;}
        public String ciclo {get;set;}
        public String articulo {get;set;}
    }
}