     
        //Función para limitar los caracteres permitidos en el input de Identificación
        function inputLimiter(e,allow) {
            var AllowableCharacters = '';
            if (allow == 'NameCharactersAndNumbers'){AllowableCharacters='1234567890 ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';}
            if (allow == 'Numbers'){AllowableCharacters='1234567890';}
            if (allow == 'Letters'){AllowableCharacters=' 1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzáéíóúÁÉÍÓÚüÜ';}
            if (allow == 'NameCharacters'){AllowableCharacters=' 1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzáéíóúÁÉÍÓÚüÜ-.';}
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
        
        //Función para abrir el modal con mensaje de formulario inválido
        function abrirModalValidacion(){
            j$('#slds-backdrop-validacion').addClass('slds-backdrop--open');
            j$('#ModalValidacion').addClass('slds-fade-in-open'); 
        } 
        
        //Método para cerrar el modal con mensaje de formulario inválido
        function cerrarModalValidacion(){
            j$('#ModalValidacion').removeClass('slds-fade-in-open');
            j$('#slds-backdrop-validacion').removeClass('slds-backdrop--open'); 
        }
        
        //Función para abrir el modal para agregar miembros del grupo familiar
        function abrirModal(){
            j$('#slds-backdrop').addClass('slds-backdrop--open');
            j$('#Modal').addClass('slds-fade-in-open'); 
        } 
        
        //Método para cerrar el modal para agregar miembros del grupo familiar
        function cerrarModal(){
            j$('#Modal').removeClass('slds-fade-in-open');
            j$('#slds-backdrop').removeClass('slds-backdrop--open'); 
        }
        
        //Función para abrir el modal de confirmación al remover un miembro del grupo familiar
        function abrirModalConfirmacion(){
            j$('#slds-backdrop-confirmacion').addClass('slds-backdrop--open');
            j$('#ModalConfirmacion').addClass('slds-fade-in-open'); 
        } 
        
        //Método para cerrar el modal de confirmación al remover un miembro del grupo familiar
        function cerrarModalConfirmacion(){
            j$('#ModalConfirmacion').removeClass('slds-fade-in-open');
            j$('#slds-backdrop-confirmacion').removeClass('slds-backdrop--open'); 
        }
        
        //Función para abrir el modal con mensaje de formulario inválido en el modal
        function abrirModalValidacion2(){
            j$('#Modal').removeClass('slds-fade-in-open');
            j$('#slds-backdrop').removeClass('slds-backdrop--open'); 
            j$('#slds-backdrop-validacion2').addClass('slds-backdrop--open');
            j$('#ModalValidacion-form2').addClass('slds-fade-in-open'); 
        } 
        
        //Método para cerrar el modal con mensaje de formulario inválido en el modal
        function cerrarModalValidacion2(){
            j$('#ModalValidacion-form2').removeClass('slds-fade-in-open');
            j$('#slds-backdrop-validacion2').removeClass('slds-backdrop--open'); 
            j$('#slds-backdrop').addClass('slds-backdrop--open');
            j$('#Modal').addClass('slds-fade-in-open'); 
        }
        
        //Función para habilitar un input de un dato precargado desde nómina
        function habilitar(id1,id2,id3,id4){
            var v1 = '[id$='+id1+']';
            var v2 = '[id$='+id2+']';
            var v3 = '[id$='+id3+']';
            var v4 = '[id$='+id4+']';
            j$(v1).show();
            j$(v2).show();
            j$(v3).hide();
            j$(v4).hide();
        }
        
        //Función para validar los campos de cada página
        function validarSeccion(pagina){
            if(pagina == 1){
                var hoy = '{!fechaMax}';
                var input1 = '[id$=input-1-1]';
                var input2 = '[id$=input-2-1]';
                var input3 = '[id$=input-3-1]';
                var input4 = '[id$=input-4-1]';
                var input5 = '[id$=input-5-1]';
                var input6 = '[id$=input-6-1]';
                var input7 = '[id$=input-7-1]';
                var input8 = '[id$=input-8-1]';
                var input15 = '[id$=input-15-1]';
                var input10 = '[id$=input-10-1]';
                var input11 = '[id$=input-11-1]';
                var input12 = '[id$=input-12-1]';
                var input13 = '[id$=input-13-1]';
                var input14 = '[id$=input-14-1]';
                var input9 = '[id$=input-9-1]';
                var input18 = '[id$=input-18-1]';
                var input16 = '[id$=input-16-1]';
                var input17 = '[id$=input-17-1]';
                if(j$(input1).val() == '' || j$(input2).val() == '-- Seleccione --' || j$(input3).val() == '' ||
                   j$(input4).val() == '' || j$(input5).val() == '-- Seleccione --' || j$(input6).val() == '-- Seleccione --' ||
                   j$(input7).val() == '-- Seleccione --' || j$(input8).val() == '-- Seleccione --' || j$(input15).val() == '-- Seleccione --' ||
                   j$(input10).val() == '' || j$(input11).val() == '' || j$(input12).val() == '' || j$(input13).val() == '-- Seleccione --' ||
                   j$(input14).val() == '-- Seleccione --' || j$(input9).val() == '-- Seleccione --' || j$(input18).val() == '-- Seleccione --' ||
                   j$(input16).val() == '-- Seleccione --' || j$(input17).val() == '-- Seleccione --' || 
				   (j$(input4).val() != '' && ((!j$(input4).val().startsWith('19') && !j$(input4).val().startsWith('20')) || j$(input4).val()>= hoy))){
                    abrirModalValidacion();   
                } else {
                    topLocation('1');
                }
            }
            
            else if(pagina == 2){
                var input21 = '[id$=input-21-1]';
                var input22 = '[id$=input-22-1]';
                var input23 = '[id$=input-23-1]';
                var input24 = '[id$=input-24-1]';
                var input26 = '[id$=input-26-1]';
                var input29 = '[id$=input-29-1]';
                var input30 = '[id$=input-30-1]';
                var input27 = '[id$=input-27-1]';
                var input28 = '[id$=input-28-1]';
                var input31 = '[id$=input-31-1]';
                var input32 = '[id$=input-32-1]';
                var input25 = '[id$=input-25-1]';
                if(j$(input22).val() == '' || j$(input21).val() == '-- Seleccione --' || j$(input23).val() == '-- Seleccione --' ||
                   j$(input24).val() == '-- Seleccione --' || j$(input26).val() == '-- Seleccione --' || j$(input29).val() == '-- Seleccione --' ||
                   j$(input30).val() == '-- Seleccione --' || j$(input28).val() == '-- Seleccione --' || j$(input27).val() == '-- Seleccione --' ||
                   j$(input31).val() == '-- Seleccione --' || j$(input32).val() == '-- Seleccione --' || j$(input25).val() == '-- Seleccione --'){
                    abrirModalValidacion();   
                } else {
                    topLocation('2');
                }
            }
            
                else if(pagina == 3){
                    var input35 = '[id$=input-35-1]';
                    var input36 = '[id$=input-36-1]';
                    var input34 = '[id$=input-34-1]';
                    var input37 = '[id$=input-37-1]';
                    var input38 = '[id$=input-38-1]';
                    var input39 = '[id$=input-39-1]';
                    
                    if(j$(input35).val() == '-- Seleccione --' || j$(input36).val() == '-- Seleccione --' || j$(input34).val() == '-- Seleccione --'){
                        abrirModalValidacion();   
                    } 
                    else if(j$(input34).val() == 'SI' && (j$(input37).val() == '-- Seleccione --' || j$(input38).val() == '-- Seleccione --')){
                        abrirModalValidacion();   
                    }
                        else if(j$(input34).val() == 'SI' && j$(input38).val() == 'SI' && j$(input39).val() == ''){
                            abrirModalValidacion();   
                        }
                            else if(j$(input34).val() == 'SI' && j$(input38).val() == 'SI' && j$(input39).val() != '' && (j$(input39).val()<1 || j$(input39).val()>100)){
                                abrirModalValidacion();   
                            }
                                else if(j$(input34).val() == 'NO' && (j$(input37).val() == 'SI' || j$(input38).val() == 'SI')){
                                    abrirModalValidacion();   
                                }
                                    else if(j$(input34).val() == 'NO' && j$(input38).val() == 'NO' && j$(input39).val() != ''){
                                        abrirModalValidacion();   
                                    } else {
                                        topLocation('3');
                                    }
                }
        }
        
        //Función para validar los campos en el modal de agregar familiar
        function validarModal(){
            var hoy = '{!fechaMax}'; 
            var input40 = '[id$=input-40-1]';
            var input41 = '[id$=input-41-1]';
            var input42 = '[id$=input-42-1]';
            var input43 = '[id$=input-43-1]';
            var input44 = '[id$=input-44-1]';
            var input45 = '[id$=input-45-1]';
            var input46 = '[id$=input-46-1]';
            var input47 = '[id$=input-47-1]';
            var input48 = '[id$=input-48-1]';
            var input49 = '[id$=input-49-1]';
            var input50 = '[id$=input-50-1]';
            var input51 = '[id$=input-51-1]';
            var input52 = '[id$=input-52-1]';
            var input53 = '[id$=input-53-1]';
            if((j$(input40).val() == '' || j$(input41).val() == '-- Seleccione --' || j$(input42).val() == '' ||
               j$(input43).val() == '-- Seleccione --' || j$(input44).val() == '' || j$(input45).val() == '-- Seleccione --' ||
               j$(input46).val() == '-- Seleccione --' || j$(input47).val() == '-- Seleccione --')
			   || (j$(input42).val() != '' && j$(input42).val()>= hoy)
			   || (j$(input47).val() == 'NO' && (j$(input51).val() != '' || j$(input52).val() != '' || j$(input53).val() != ''))
			   || (j$(input47).val() == 'SI' && 
                           (j$(input48).val() == '-- Seleccione --' || j$(input49).val() == '-- Seleccione --' || j$(input50).val() == '-- Seleccione --'))
				|| (j$(input47).val() == 'SI' && j$(input51).val() != '' && j$(input52).val() == '')
				|| (j$(input51).val() == '' && (j$(input52).val() != '' || j$(input53).val() != ''))
				|| (j$(input51).val() != '' && j$(input52).val() == '' && j$(input53).val() != '')
				|| (j$(input51).val() != '' && j$(input52).val() != '' && j$(input53).val() != '' && (j$(input52).val()> hoy || j$(input53).val()> hoy || j$(input53).val()<j$(input52).val()))){
                abrirModalValidacion2();   
            } else {
					agregarFamiliar();
					showLoadingDialog();
			}
        }
        
        //Función para navegar hacia adelante en las diferentes páginas de la encuesta
        function topLocation(pagina){
            window.scrollTo(0,0);
            showLoadingDialog(); 
            if(pagina == 1){
                irSeccion2(); 
            }
            else if(pagina == 2){
                irSeccion3(); 
            }
			else if(pagina == 3){
            	irSeccion4(); 
			}
			else if(pagina == 4){
				irSeccion5();
			}
            else if(pagina == 5){
				irInicio();
			}
			else if(pagina == 6){
				finalizar();
			}
        }  
        
        //Función para navegar hacia atrás en las diferentes páginas de la encuesta
        function devolver(pagina){
            showLoadingDialog();  
            if(pagina == 1){
                irAtras(); 
            }
            else if(pagina == 2){
                irAtras1(); 
            }
			else if(pagina == 3){
            	irAtras2(); 
			}
            else if(pagina == 4){
            	irAtras3(); 
			}
            else if(pagina == 5){
            	irAtras4(); 
			}
        }