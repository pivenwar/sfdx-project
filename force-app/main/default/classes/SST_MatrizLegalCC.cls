/*
* @autor: Marcela Taborda
* @fecha: 27/08/2018
* @version: 1.0
* 
* @fecha: 17/04/2019
* @version: 3.0
*/

public with sharing class SST_MatrizLegalCC {
    
    //Lista para consultar los campos de la Matriz Legal
    public List <DTOLista> listaMatriz {get;set;}
    
    //Atributo para mostrar los mensajes de éxito, confirmación o error en la página
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    /*Atributo para obtener la url del home de la comunidad*/
    public String url {get;set;}
    
    /*Atributos para obtener el promedio de las calificaciones*/
    public Decimal promedio {get;set;}
    
    /*Variable que contiene el valor del picklist cumple*/
    public String cumple {get; set;}
    
    /*Variable que contiene el valor del picklist cumple parcialmente*/
    public String cumpleParcialmente {get; set;}
    
    /*Variable que contiene el valor del color cuando no hay cumplimiento*/
    public String colorCumple {get; set;}
    
    /*Variable que contiene el valor del color cuando hay cumplimiento*/
    public String colorNoCumple {get; set;}
    
    /*Variable que contiene el valor del color cuando cumple parcialmente*/
    public String colorCumpleParcialmente {get; set;}
    
    /*Variable para activar o inactivar el botón de guardar en la página*/
    public Boolean botonActivo {get; set;}
    
    /*Variable que indica si el botón pdf esta activo o no*/
    public Boolean botonPDFActivo {get; set;}
    
    /*Mapa con el cumplimieto de la matriz*/
    public Map <String,String> mapaCumplimiento{get; set;}
    
    /*Mapa con el los value de Responsable*/
    public Map <String,String> mapaResponsable {get;set;}
    
    /*Mapa con los nombres de los funcionarios*/
    public Map <String,String> mapaFuncionario {get;set;}
    
    String empresaAutenticada = SST_Constantes.getEmpresaAutenticada();
    
    /*Variables para el manejo de la paginacion*/
    public Integer offSet{get;set;}
    public Integer total{get;set;}
    public Integer paginas{get;set;}
    public Integer paginaActual{get;set;}
    /*Lista que contiene el mapa con los valores del puntaje promedio*/
    Map<String,Integer> puntajePromedio;
    
    
    //Constructor de la clase
    public SST_MatrizLegalCC(){
        offSet = 0;
        paginaActual = 1;
        listaMatriz = new List <DTOLista>();
        mapaResponsable = new Map <String,String>();
        mapaFuncionario = new Map <String,String>();
        cumple = SST_Constantes.CUMPLE;
        cumpleParcialmente = SST_Constantes.CUMPLE_PARCIALMENTE;
        colorNoCumple = SST_Constantes.COLOR_NO_CUMPLE;
        colorCumple = SST_Constantes.COLOR_CUMPLE;
        colorCumpleParcialmente = SST_Constantes.COLOR_CUMPLE_PARCIALMENTE;
        url = SST_Constantes.retornarUrl()+SST_Constantes.PAGINA_DETALLE_NORMATIVIDAD;
        promedio = 0;
        
        puntajePromedio = new Map<String,Integer>();
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();
        try{
            List<AggregateResult> cantidad= [select COUNT(ID) from SST_Normatividad__c where Empresa__c=:empresaAutenticada];
            total =(Integer)cantidad.get(0).get('expr0');
            Decimal division = Decimal.valueOf(total);
            paginas = Integer.valueOf((division/10).round(System.RoundingMode.CEILING));
            
            mapaCumplimiento = new Map <String,String>();
            consultarMatrizLegalPromedio();
            consultar();
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'Ha ocurrido un error, comuníquese con el administrador del sistema'));            
            System.debug('Error al cargar el controlador: '+e.getLineNumber()+e.getMessage());
            botonActivo = false;
            botonPDFActivo = false;
        }
        
    }
    
    /*Método que se encarga de consultar la matriz legal para actualizar el promedio*/    
    public void consultarMatrizLegalPromedio(){
        
        for(List<SST_Normatividad__c> normatividades : [select id,Cumplimiento__c from SST_Normatividad__c where Empresa__c=:empresaAutenticada order by name ASC]){
            for(SST_Normatividad__c normatividad : normatividades){
                puntajePromedio.put(normatividad.id,convertirCumplimientoAValor(normatividad.Cumplimiento__c));
            }            
        }
    }
    
    /*Método encargado de calcular el promedio, se tiene con el map porque se debe realizar con toda la matriz y no solo con los registros que muestra la página*/
    public void calcularPromedio (){
        /*si se invoca este metodo desde pantalla actualiza los valores del mapa para */
        if(listaMatriz!=null && !listaMatriz.isEmpty()){
            for(DTOLista normatividad : listaMatriz){
                puntajePromedio.put(normatividad.idRegistro,convertirCumplimientoAValor(normatividad.cumplimiento));
            }
        }        
        botonActivo = true;
        Decimal sumatoria = 0;
        for(Integer valor : puntajePromedio.values()){
            sumatoria += valor;
        }
        
        if(puntajePromedio.size()!= 0){
            promedio = (sumatoria/puntajePromedio.size()).setScale(2);
        }else{
            promedio = 0;
        }
        
        
        if(promedio == -1){
            botonActivo = false;
            botonPDFActivo = false;
        } 
        
    } 
    
    /*Método que se encarga de convertir un cumplimiento al valor que representa*/    
    public Integer convertirCumplimientoAValor(String cumplimiento){
        Integer valorCumplimiento;
        if(cumplimiento== SST_Constantes.NO_CUMPLE){
            valorCumplimiento =  0;
        } else if(cumplimiento == SST_Constantes.CUMPLE_PARCIALMENTE){
            valorCumplimiento =  50;
        } else{
            valorCumplimiento =  100;   
        }
        return valorCumplimiento;
    }
    
    
    
    //Este método se encarga de guardar los datos ingresados
    public void Guardar(){
        try{
            List <SST_Normatividad__c> listaActualizar = new List <SST_Normatividad__c>();
            Boolean error = false;
            mensajesPaginaPrincipal.Clear();
            List<ID> idMatriz = new List<ID>();
            for(DTOLista ttmp : listaMatriz){
                if(ttmp.Responsable.equalsIgnoreCase('FUNCIONARIO') && ttmp.IdFuncionario == SST_Constantes.ITEM_VACIO_PICKLIST){
                    mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'Debe seleccionar un funcionario responsable para la normatividad: "'+ttmp.norma+'"'));            
                    error = true;
                    botonPDFActivo = false;
                }else{
                    idMatriz.add(ttmp.idRegistro);
                }
            }
            if(!error){
                for(SST_Normatividad__c registroModificar : [SELECT id FROM SST_Normatividad__c WHERE id in :idMatriz]){
                    for(DTOLista ttmp : listaMatriz){
                        if(registroModificar.Id == ttmp.idRegistro){
                            registroModificar.Cumplimiento__c = ttmp.cumplimiento;
                            registroModificar.Observaciones__c = ttmp.observaciones;
                            registroModificar.Responsable__c = ttmp.responsable;
                            if(ttmp.Responsable.equalsIgnoreCase('EMPRESA')){
                                registroModificar.Funcionario__c = null;   
                            } else {
                                registroModificar.Funcionario__c = ttmp.idFuncionario;
                            }
                            listaActualizar.add(registroModificar);
                        }
                    }
                }
                
                if(Schema.sObjectType.SST_Normatividad__c.fields.Cumplimiento__c.isUpdateable()&&
                   Schema.sObjectType.SST_Normatividad__c.fields.Observaciones__c.isUpdateable()&&
                   Schema.sObjectType.SST_Normatividad__c.fields.Responsable__c.isUpdateable()&&
                   Schema.sObjectType.SST_Normatividad__c.fields.Funcionario__c.isUpdateable()){
                       update listaActualizar;
                       consultar();
                       mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.CONFIRMACION,'Se ha actualizado la Matriz exitosamente.'));   
                       botonPDFActivo = true;
                   }else{
                       mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Permisos insuficientes para modificar la matriz legal'));
                       botonPDFActivo = false;
                   }
            }
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'Ha ocurrido un error, comuníquese con el administrador del sistema'));            
            system.debug('Mensaje error:'+e.getMessage());
            system.debug('Linea error:'+e.getLineNumber());
            system.debug('Causa error:'+e.getCause());
            botonPDFActivo = false;
        }
    }
    /*Método que se encarga de consultar la matriz legal de acuerdo  */
    public void consultar(){
        listaMatriz = new List <DTOLista>();
        for(SST_Normatividad__c temp : [select id, CreatedDate,Tipo__c, Fuente__c, Articulo__c, name, Entidad__c, Tema__c, Responsable__c, Funcionario__c, Funcionario__r.name, Cumplimiento__c,Observaciones__c, Codigo_externo__c  from SST_Normatividad__c where Empresa__c=:empresaAutenticada order by name ASC LIMIT 10 OFFSET :offSet]){
            DTOLista registro = new DTOLista();
            registro.idRegistro = temp.id;
            registro.cumplimiento = temp.Cumplimiento__c;
            registro.responsable = temp.Responsable__c;
            registro.norma = temp.Name;
            registro.fuente = temp.Fuente__c;
            registro.articulo = temp.Articulo__c;
            registro.observaciones = temp.Observaciones__c; 
            if(temp.Responsable__c.equalsIgnoreCase('FUNCIONARIO') && temp.Funcionario__c == null){
                mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR, 'Debe seleccionar un funcionario responsable para la normatividad: "'+temp.name+'"'));            
                registro.idFuncionario = SST_Constantes.ITEM_VACIO_PICKLIST;
                botonPDFActivo = false;
            } else {
                registro.idFuncionario = temp.Funcionario__r.id;
            }
            listaMatriz.add(registro);
        }
        calcularPromedio();
    }
    
    /*Método que se encarga de consultar la siguiente pagina*/
    public void verSiguiente(){
        offSet +=10;
        paginaActual +=1;
        consultar();
        mensajesPaginaPrincipal.Clear();
        
    }
    
    /*Método que se encarga de guardar y consultar la siguiente pagina*/
    public void verSiguienteGuardar(){
        offSet +=10;
        paginaActual +=1;
        Guardar();
        consultar();
    }
    
    /*Método que se encarga de consultar la pagina anterior*/
    public void verAnterior(){
        offSet -=10;
        paginaActual -=1;
        consultar();
        mensajesPaginaPrincipal.Clear();
        
    }
    
    /*Método que se encarga de guardar y consultar la pagina anterior*/
    public void verAnteriorGuardar(){
        offSet -=10;
        paginaActual -=1;
        Guardar();
        consultar();
    }
    /*Método que se encarga de consultar la primera página*/
    public void verInicio(){
        offSet = 0;
        paginaActual = 1;
        consultar();
        mensajesPaginaPrincipal.Clear();
    }
    
    /*Método que se encarga de guardar y consultar la primera página*/
    public void verInicioGuardar(){
        offSet = 0;
        paginaActual = 1;
        Guardar();
        consultar();
    }
    /*Método que se encarga de consultar la ultima página*/
    public void verFinal(){
        Integer modulo = Math.mod(total,10);
        offSet = total-modulo;
        paginaActual = paginas;
        consultar();
        mensajesPaginaPrincipal.Clear();
    }    
    
    /*Método que se encarga de guardar y consultar la ultima página*/
    public void verFinalGuardar(){
        Integer modulo = Math.mod(total,10);
        offSet = total-modulo;
        paginaActual = paginas;
        Guardar();
        consultar();
    }    
    
    /*Método que se encarga de guardar la información del reporte generado*/
    public PageReference generarReporteMatrizLegal(){
        try{
            mensajesPaginaPrincipal.clear();
            if(Schema.sObjectType.SST_Calificacion_norma__c.fields.calificacion__c.isCreateable()&&
               Schema.sObjectType.SST_Calificacion_norma__c.fields.norma_calificada__c.isCreateable()&&
               Schema.sObjectType.SST_Calificacion_norma__c.fields.Comentarios__c.isCreateable()&&
               Schema.sObjectType.SST_Calificacion_norma__c.fields.ultima_calificacion__c.isCreateable()&&
               Schema.sObjectType.SST_Calificacion_norma__c.fields.empresa__c.isCreateable()&&
               Schema.sObjectType.SST_Calificacion_norma__c.fields.ultima_calificacion__c.isUpdateable()){
                   List<SST_Calificacion_norma__c> calificacionesAnteriores = New List <SST_Calificacion_norma__c>();
                   for(SST_Calificacion_norma__c calificacionNorma:[Select id, name from SST_Calificacion_norma__c where Empresa__c=:empresaAutenticada and norma_calificada__c=: 'MATRIZ LEGAL' and ultima_calificacion__c =: true]){
                       calificacionNorma.ultima_calificacion__c=false;  
                       calificacionesAnteriores.add(calificacionNorma);
                   }  
                   update calificacionesAnteriores;
                   SST_Calificacion_norma__c calificacionNorma = new SST_Calificacion_norma__c();
                   calificacionNorma.calificacion__c = promedio;
                   calificacionNorma.norma_calificada__c = 'MATRIZ LEGAL';
                   calificacionNorma.ultima_calificacion__c=true;
                   calificacionNorma.empresa__c = empresaAutenticada;
                   insert(calificacionNorma);
               }else{
                   throw new ApplicationException('Permisos insuficientes para modificar o registrar calificación de la norma');
               }
            String paginaReporte = ApexPages.currentPage().getHeaders().get('Referer');   
            List <String> dir = paginaReporte.split('/', 5);
            paginaReporte = 'https:'+paginaReporte.substringBetween(dir.get(0), dir.get(dir.size()-1));
            if(paginaReporte.endsWithIgnoreCase('apex/')){
                paginaReporte = paginaReporte.removeEndIgnoreCase('apex/');
            }
            pageReference reporte = new pageReference(paginaReporte+'s/'+SST_Constantes.REPORTE_MATRIZ_LEGAL);
            return reporte;
        }catch(ApplicationException ae){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,ae.getMessage()));
            return null;
        }catch(Exception e){
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Ocurrió un error generando el reporte de matriz legal, por favor contacte al administrador'));
            System.debug('Error en generarReporte'+e.getLineNumber()+e.getMessage());
            return null;
        }             
    }
    
    
    //Este método se encarga de traer los valores del campo responsable de tipo pickDTOListalist
    public List<SelectOption> getResponsable(){
        List<SelectOption> responsable = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = SST_Normatividad__c.Responsable__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();    
        for(Schema.PicklistEntry responsableTemp : itemsTemp){
            responsable.add(new SelectOption(responsableTemp.GetValue(),responsableTemp.GetLabel()));
            mapaResponsable.put(responsableTemp.GetValue(),responsableTemp.GetLabel());
        }
        return responsable;              
    }
    
    //Este método se encarga de traer los valores del campo funcionario de tipo lookup y ponerlos en una lista de selección ordenada
    public List<SelectOption> getFuncionario(){
        List<Contact> contactos = [SELECT recordType.Name, Name, SST_Estado__c, id FROM Contact where SST_Empresa__c=:empresaAutenticada and recordType.Name =: SST_Constantes.FUNCIONARIO and SST_Estado__c =: SST_Constantes.ACTIVO  Order by Name];
        List<SelectOption> funcionarios = new List<SelectOption>();
        funcionarios.add(new SelectOption(SST_Constantes.ITEM_VACIO_PICKLIST,SST_Constantes.ITEM_VACIO_PICKLIST));
        for(Contact contacto: contactos){
            String[] c = contacto.name.toLowerCase().split(' ');
            String nombre = '';
            for(Integer i=0; i<c.size(); i++){
                nombre = nombre+c[i].capitalize() + ' ';
            }
            funcionarios.add(new SelectOption(contacto.id,nombre));
            mapaFuncionario.put(contacto.id,nombre);
        }
        return funcionarios;     
    }
    
    //Este método se encarga de traer los valores del campo cumplimiento de tipo picklist
    public List<SelectOption> getCumplimiento(){
        List<SelectOption> cumplimiento = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = SST_Normatividad__c.Cumplimiento__c.getDescribe();
        List<Schema.PicklistEntry> itemsTemp = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry cumplimientoTemp : itemsTemp){
            cumplimiento.add(new SelectOption(cumplimientoTemp.getValue(),cumplimientoTemp.getLabel()));
            mapaCumplimiento.put(cumplimientoTemp.getValue(),cumplimientoTemp.getLabel());
        }
        return cumplimiento;              
    }
    
    
    /*DTO utilizado para controlar la lista de la matriz legal*/
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
    
    /*Clase exception*/
    public class ApplicationException extends Exception {}
}