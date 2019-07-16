       
        //Método para abrir el modal para anexar archivos
        function abrirModal(){
            //var theValue =  j$('#idInputDoc').val();
            //alert('The value: '+document.getElementById("idInputDoc").innerHTML);
            j$('#slds-backdrop').addClass('slds-backdrop--open');
            j$('#Modal').addClass('slds-fade-in-open'); 
        } 
        
        //Método para cerrar el modal para anexar archivos
        function cerrarModal(){
            j$('#Modal').removeClass('slds-fade-in-open');
            j$('#slds-backdrop').removeClass('slds-backdrop--open'); 
        }
        
        //Método para abrir el modal de confirmación para eliminar archivos
        function abrirModalConfirmacion(){
            j$('#slds-backdrop1').addClass('slds-backdrop--open');
            j$('#ModalE').addClass('slds-fade-in-open'); 
        } 
        
        //Método para cerrar el modal de confirmación para eliminar archivos
        function cerrarModalConfirmacion(){
            j$('#ModalE').removeClass('slds-fade-in-open');
            j$('#slds-backdrop1').removeClass('slds-backdrop--open'); 
        }
        
        //Método para abrir el modal de confirmación para enviar notificación al área de SST
        function abrirModalNotificacion(){
            j$('#slds-backdrop2').addClass('slds-backdrop--open');
            j$('#ModalN').addClass('slds-fade-in-open'); 
        } 
        
        //Método para cerrar el modal de confirmación para enviar notificación al área de SST
        function cerrarModalNotificacion(){
            j$('#ModalN').removeClass('slds-fade-in-open');
            j$('#slds-backdrop2').removeClass('slds-backdrop--open'); 
        }
		//Método para abrir el modal del documento de autorización de datos SST
        function abrirModalDocumento(){
            j$('#slds-backdropDocumento').addClass('slds-backdrop--open');
            j$('#ModalDocumento').addClass('slds-fade-in-open'); 
        } 
        
        //Método para cerrar el modal del documento de autorización de datosSST
        function cerrarModalDocumento(){
            j$('#ModalDocumento').removeClass('slds-fade-in-open');
            j$('#slds-backdropDocumento').removeClass('slds-backdrop--open'); 
        }
		
        
        //Función para limitar los caracteres permitidos en el input de Identificación
        function inputLimiter(e,allow) {
            var AllowableCharacters = '';
            if (allow == 'NameCharactersAndNumbers'){AllowableCharacters='1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';}
            var k = document.all?parseInt(e.keyCode): parseInt(e.which);
            if (k!=13 && k!=8 && k!=0){
                if ((e.ctrlKey==false) && (e.altKey==false)) {
                    return (AllowableCharacters.indexOf(String.fromCharCode(k))!=-1);
                } else {
                    return true;
                }
            } else {
                return true;
            }
        } 
        
        function numbers(e){
            e.value = e.value.replace(/[^0-9]/g,'');
            if(e.value.split('.').length>2) e.value = e.value.replace(/\.+$/,"");
        };  
 