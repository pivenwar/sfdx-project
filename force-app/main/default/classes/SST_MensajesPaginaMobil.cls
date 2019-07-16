public class SST_MensajesPaginaMobil {
    
    //Constante para indicar que el mensaje es de tipo confirmación (exito).
    public static String CONFIRMACION = 'CONFIRM';
    //Constante para indicar que el mensaje es de tipo error.
    public static String ERROR = 'ERROR';
    //Constante para indicar que el mensaje es de tipo información.
    public static String INFO = 'INFO';
        
    //Atributo para indicar cual es el tipo del mensaje.
    public String tipoMensaje 	{get;set;}
    //Atributo con el mensaje de error a mostrar.
    public String mensajePage 	{get;set;}
    
    //Atributo con la clase a mostrar en pantalla de acuerdo al tipo de mensaje.
    public String claseDiv 	{get;set;}
    //Atributo con la clase a mostrar en pantalla de acuerdo al tipo de mensaje.
    public String claseSpan {get;set;}
    //Atributo con el ícono a mostrar en pantalla de acuerdo al tipo de mensaje.
    public String icon		{get;set;}
    
    public SST_MensajesPaginaMobil(String tipoMensaje, String mensajePage){
        this.tipoMensaje = tipoMensaje;
        this.mensajePage = mensajePage;
        
        if(tipoMensaje.equals(CONFIRMACION)){
            claseDiv = 'slds-theme_success';
            claseSpan = 'slds-icon-utility-success';
            icon = '/assets/icons/utility-sprite/svg/symbols.svg#success';
        }
        if(tipoMensaje.equals(ERROR)){
            claseDiv = 'slds-theme_error';
            claseSpan = 'slds-icon-utility-error';
            icon = '/assets/icons/utility-sprite/svg/symbols.svg#error';
        }
        if(tipoMensaje.equals(INFO)){
            claseDiv = 'slds-theme--alt-inverse';
            claseSpan = 'slds-icon-utility-warning';
            icon = '/assets/icons/utility-sprite/svg/symbols.svg#warning';
        }    
    }

}