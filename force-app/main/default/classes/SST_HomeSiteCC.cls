/* Clase controlador encargada de guardar las Url necesarias para el HomeSite
 * Autor: Yanebi Tamayo
 * Fecha: 05/03/2019
 * Versión 1.0
*/
public with sharing class SST_HomeSiteCC {
    
    /*Variable para guardar el Link de la comunidad*/
    Public String linkSST {get; set;}
    /*Variable para guardar el Link del portal*/
    Public String linkPortalSST {get; set;}
    
    /*Variable para guardar el Link para comunicaciones*/
    Public String comunicaciones {get; set;}
    /*Variable para guardar el Link para Gestión Documental*/
    Public String gestionDocumental {get; set;}
    /*Variable para guardar el Link para la Encuesta Sociodemográfica*/
    Public String encuestaSociodemografica {get; set;}
    
    
    /*Constructor*/
    public SST_HomeSiteCC(){
        
        /*Se asignan las Url correspondientes para ser mostradas en la página SST_HomeSitePage*/
        
        linkSST = SST_Constantes.LINK_SST;
        linkPortalSST = SST_Constantes.LINK_PORTAL_SST; 
		
        comunicaciones = linkPortalSST+'/sstcomunicaciones';
        gestionDocumental = linkPortalSST+'/sstgestiondocumental';
        encuestaSociodemografica = linkPortalSST+'/sstencuestasociodemografica';

    }
    
}