/**
* Clase que se encarga de controlar la navegación entre comunidades para el caso de empresas multiempresa.
* */
public with sharing class SST_NavegacionEntreComunidadesCC {
    
    /*Variable que va contener el nombre de la comunidad seleccionada para ser redirigida*/
    public String comunidad {get;set;}
    /*Lista de todas las comunidades para ser mostradas en pantalla*/
    public Map<String,DTOComunidad> comunidades {get;set;}
    //Atributo para mostrar los mensajes de éxito, confirmación o error en la página
    public List<SST_MensajesPagina> mensajesPaginaPrincipal {get;set;}
    
    
    /*Método constructor, consulta toda las url de las diferentes comunidades*/
    public SST_NavegacionEntreComunidadesCC (){
        mensajesPaginaPrincipal = new List<SST_MensajesPagina>();
        List<Network> networks = new List<Network>();
        for(Network network : [select id, name, urlPathPrefix from Network where urlPathPrefix<>null and status = 'Live' order by name ASC]){
            networks.add(network);
        }
        if(networks.isEmpty()){
            for(Network network : [select id, name, urlPathPrefix from Network limit 1 ]){
                networks.add(network); 
            }
        } 
        //A la url de la comunidad principal, se adiciona el prefijo de cada una de las comunidades de las empresas
        //para llenar el mapa con las direcciones a las que se redirigirá al usuario en pantalla
        comunidades = new Map<String,DTOComunidad>();
        Integer pos = 0;        
        for(Network comunidadExistente : networks){ 
            DTOComunidad comunidad = new DTOComunidad();
            comunidad.url = SST_Constantes.LINK_SST+'/'+comunidadExistente.urlPathPrefix+'/s';
            comunidad.nombreEmpresa = comunidadExistente.name;
            comunidad.pos=pos;
            comunidades.put(comunidadExistente.name,comunidad);
            pos++;
        } 
    }
    
    /*Método para setear en el usuario, el nit de la empresa en la que iniciará sesión*/
    public pageReference actualizarEmpresaAutenticada(){ 
        if(Schema.sObjectType.User.fields.SST_empresa_autenticada__c.isUpdateable()){
            Integer nit = Integer.valueOf([select SST_Nit__c from Account where name =:comunidad].SST_Nit__c); 
            User usuarioAutenticado = [select id, SST_empresa_autenticada__c from user where id =: userInfo.getUserId()];
            usuarioAutenticado.SST_empresa_autenticada__c = String.valueOf(nit);
            update usuarioAutenticado;
            if(comunidades.get(comunidad)!= null){
                return new pageReference(comunidades.get(comunidad).url);
            }
        }else{
            mensajesPaginaPrincipal.add(new SST_MensajesPagina(SST_MensajesPagina.ERROR,'Permisos insuficientes para cambiar entre comunidades'));
        }
        return null;  
    }
    
    /*Clase interna que contiene la url y nombre de la empresa*/
    public class DTOComunidad {
        public String url {get;set;}
        public String nombreEmpresa {get;set;}
        public Integer pos {get;set;}
    }
}