import '../../logica/casosDeUsoTurnos.dart';
import '../../datos/modelos/turno.dart';

class ControladorTurnos {
  final CasosDeUsoTurnos casosDeUso;

  ControladorTurnos(this.casosDeUso);

  Future<List<Turno>> cargarTurnos() {
    return casosDeUso.obtenerTurnos();
    //cargamos los turnos para mostrar en la pantalla
  }
}



/*
El controlador va a ser el intermediario:
Pantalla
   ↓
ControladorTurnos
   ↓
CasosDeUsoTurnos
   ↓
Repositorio
*/
